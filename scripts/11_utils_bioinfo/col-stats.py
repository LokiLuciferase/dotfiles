#!/usr/bin/env python3

import argparse
import logging
import io
import csv
import sys
from typing import Any, Dict, List, Optional, Union





class ColStats:

    DEFAULT_STATS = ['count', 'mean', 'std', 'min', '50p', 'max']

    @classmethod
    def _get_args(cls):
        parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
        parser.add_argument(
            '-f',
            '--field',
            '-k',
            '--key',
            '-c',
            '--column',
            dest='field',
            default='1',
            help='Field to read (1-indexed), or comma-separated list of fields, or range of fields (e.g. 1-3,5,7-10)',
        )
        parser.add_argument(
            '-d',
            '--delimiter',
            '-s',
            '--separator',
            dest='delimiter',
            default='\t',
            help='Input delimiter to use',
        )
        parser.add_argument(
            '--skip',
            dest='skip',
            default='0',
            help='Number of header rows to skip, or auto to skip all rows that are not numeric',
        )
        parser.add_argument(
            '-r', '--round-to', dest='round_to', default=3, help='Round to this many decimal places'
        )
        parser.add_argument(
            '--no-out-header', dest='no_out_header', action='store_true', help='Write no header'
        )
        parser.add_argument(
            '--usecols',
            dest='usecols',
            default=','.join(cls.DEFAULT_STATS),
            help='Comma-separated list of stats to show. Prefix with "+" to include default stats',
        )
        return parser.parse_args()

    @staticmethod
    def _isnumeric(s) -> bool:
        try:
            float(s)
            return True
        except ValueError:
            return False

    @staticmethod
    def _parse_field_selection(s) -> Union[List[int], str]:
        if s == 'all':
            return 'all'
        comsep = s.split(',')
        linsep = []
        for x in comsep:
            if '-' in x:
                linsep.extend(range(int(x.split('-')[0]), int(x.split('-')[1]) + 1))
            else:
                linsep.append(int(x))
        return [x - 1 for x in linsep]

    @staticmethod
    def _parse_stat_selection(s) -> List[str]:
        if s.startswith('+'):
            return ColStats.DEFAULT_STATS + [
                x for x in s[1:].split(',') if x not in ColStats.DEFAULT_STATS
            ]
        elif s.startswith('-'):
            return [x for x in ColStats.DEFAULT_STATS if x not in s[1:].split(',')]
        else:
            return s.split(',')

    def __init__(self):
        self._args = self._get_args()
        self._usecols = self._parse_stat_selection(self._args.usecols)
        self._skip = self._args.skip
        self._required_fields = self._parse_field_selection(self._args.field)

    def _calc_col(self, col: List[float]) -> Dict[str, Any]:
        col = col.copy()
        stats = {'count': len(col)}
        stats['mean'] = sum(col) / stats['count']
        stats['std'] = (sum([(x - stats['mean']) ** 2 for x in col]) / stats['count']) ** 0.5
        col.sort()
        stats['min'] = col[0]
        stats['max'] = col[-1]
        stats['25p'] = col[int(stats['count'] * 0.25)]
        stats['50p'] = col[int(stats['count'] * 0.5)]
        stats['75p'] = col[int(stats['count'] * 0.75)]
        stats['skewness'] = (stats['mean'] - stats['50p']) / stats['std'] if stats['std'] else 'nan'
        stats['kurtosis'] = (stats['mean'] - stats['75p']) / stats['std'] if stats['std'] else 'nan'
        stats = {x: stats[x] for x in self._usecols}
        return stats

    def _get_col(self, field: int, lines: List[List[str]]) -> Optional[Dict[str, Any]]:
        if self._skip == 'auto':
            header = str(field + 1)
            incol = [float(x[field]) for x in lines if self._isnumeric(x[field])]
        else:
            header = '__'.join([x[field] for x in lines[: int(self._skip)]])
            try:
                incol = [float(x[field]) for x in lines[int(self._skip) :]]
            except ValueError:
                logging.warning(
                    f'Could not convert field {field + 1} to float. Use --skip to skip header rows.'
                )
                return None
        if len(incol) == 0:
            return None
        calced = self._calc_col(incol)
        calced = {'column': header, **calced}
        return calced

    def _format_output(self, calced_lines: List[Dict[str, Any]], round_to: int) -> str:
        header = ['column', *[x for x in self._usecols]]
        with io.StringIO() as fout:
            writer = csv.DictWriter(fout, fieldnames=header, delimiter='\t')
            if not self._args.no_out_header:
                writer.writeheader()
            for line in calced_lines:
                fmt_line = {
                    x: line[x] if isinstance(line[x], str) else str(round(line[x], round_to))
                    for x in header
                }
                writer.writerow(fmt_line)
            return fout.getvalue()

    def run(self):
        lines = [x.strip().split(self._args.delimiter) for x in sys.stdin]
        if self._required_fields is None:
            self._required_fields = [0]
        elif self._required_fields == 'all':
            self._required_fields = list(range(len(lines[0])))
        else:
            pass
        calced_lines = []
        for field in self._required_fields:
            calced = self._get_col(field, lines)
            if calced is not None:
                calced_lines.append(calced)
        to_print = self._format_output(calced_lines, self._args.round_to)
        print(to_print, end='')


if __name__ == '__main__':
    colstats = ColStats().run()
