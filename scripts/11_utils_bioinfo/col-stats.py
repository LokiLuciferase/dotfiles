#!/usr/bin/env python3

from pathlib import Path
import argparse
import logging
import io
import csv
import sys
from typing import Any, Dict, List, Optional, Union


class ColStats:

    DEFAULT_STATS = ['count', 'mean', 'std', 'min', '50p', 'max', 'sum']
    KNOWN_STATS = [
        'count',
        'mean',
        'std',
        'min',
        '25p',
        '50p',
        '75p',
        'max',
        'sum',
        'iq_range',
        'iq_mean',
        'mode',
        'skewness',
        'kurtosis',
    ]
    HEADER_CONCAT = '__'

    @classmethod
    def _get_args(cls):
        parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
        parser.add_argument(
            'infile',
            nargs='?',
            type=Path,
            default=None,
            help='Input file - if not provided, stdin is used',
        )
        parser.add_argument(
            '-f',
            '--field',
            default='all',
            help='Comma-separated list or ranges of fields to summarize (1-indexed), (e.g. 1-3,5,7-10), or "all"',
        )
        parser.add_argument('-d', '--delimiter', default='\t', help='Input delimiter to use')
        parser.add_argument(
            '-s',
            '--skip',
            default='auto',
            help='Number of header rows to skip, or auto to skip all rows that are not numeric',
        )
        parser.add_argument('-r', '--round-to', default=3, help='Round to this many decimal places')
        parser.add_argument(
            '--skip-cols',
            default=0,
            help='Number of columns to skip at the beginning of each line (to align columns with header when unnamed indices are present)',
        )
        parser.add_argument('--no-out-header', action='store_true', help='Write no header')
        parser.add_argument('--no-out-index', action='store_true', help='Write no index column')
        parser.add_argument(
            '--stats',
            dest='usestats',
            default=','.join(cls.DEFAULT_STATS),
            help=f'Comma-separated list of stats to show, or "all". Prefix with "+" to include default stats (existing: {",".join(cls.KNOWN_STATS)})',
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
        if s == 'all':
            return ColStats.KNOWN_STATS
        elif s.startswith('+'):
            return ColStats.DEFAULT_STATS + [
                x for x in s[1:].split(',') if x not in ColStats.DEFAULT_STATS
            ]
        elif s.startswith('-'):
            return [x for x in ColStats.DEFAULT_STATS if x not in s[1:].split(',')]
        else:
            return s.split(',')

    def __init__(self):
        self._args = self._get_args()
        self._usestats = self._parse_stat_selection(self._args.usestats)
        self._skip = self._args.skip
        self._skip_cols = int(self._args.skip_cols)
        self._field_selection = self._args.field
        self._required_fields = self._parse_field_selection(self._field_selection)

    def _get_raw_lines(self) -> List[str]:
        if self._args.infile is not None:
            with open(self._args.infile, 'r') as f:
                return f.readlines()
        else:
            return sys.stdin.readlines()

    def _calc_col(self, col: List[float]) -> Dict[str, Any]:
        col = col.copy()
        stats = {'count': len(col)}
        stats['mean'] = sum(col) / stats['count']
        stats['std'] = (sum([(x - stats['mean']) ** 2 for x in col]) / stats['count']) ** 0.5
        col.sort()
        stats['min'] = col[0]
        stats['max'] = col[-1]
        stats['sum'] = sum(col)
        stats['25p'] = col[int(stats['count'] * 0.25)]
        stats['50p'] = col[int(stats['count'] * 0.5)]
        stats['75p'] = col[int(stats['count'] * 0.75)]
        stats['mode'] = max(set(col), key=col.count)
        stats['iq_range'] = stats['75p'] - stats['25p']
        iq = col[int(stats['count'] * 0.25) : int(stats['count'] * 0.75)]
        stats['iq_mean'] = sum(iq) / len(iq) if iq else 'nan'
        stats['skewness'] = (stats['mean'] - stats['50p']) / stats['std'] if stats['std'] else 'nan'
        stats['kurtosis'] = (stats['mean'] - stats['75p']) / stats['std'] if stats['std'] else 'nan'
        stats = {x: stats[x] for x in self._usestats}
        return stats

    def _get_col(self, field: int, lines: List[List[str]]) -> Optional[Dict[str, Any]]:
        if self._skip == 'auto':
            header_items = []
            for i, l in enumerate(lines):
                if not self._isnumeric(l[field]):
                    header_items.append(l[field])
                else:
                    self._skip = i
                    break
            header = self.HEADER_CONCAT.join(header_items)
        else:
            header = self.HEADER_CONCAT.join([x[field] for x in lines[: int(self._skip)]])
        field = field + self._skip_cols
        try:
            incol = [float(x[field]) for x in lines[int(self._skip) :]]
        except ValueError:
            if (
                self._field_selection != 'all'
            ):  # if we're doing all fields indiscriminately, don't warn
                logging.warning(
                    f'Could not convert field {field + 1} to float. Use --skip to skip header rows.'
                )
            return None
        if len(incol) == 0:
            return None
        calced = self._calc_col(incol)
        calced = {'column_id': str(field + 1), 'column_name': header, **calced}
        return calced

    def _format_output(self, calced_lines: List[Dict[str, Any]], round_to: int) -> str:
        idx_cols = ['column_id', 'column_name'] if not self._args.no_out_index else []
        header = [*idx_cols, *[x for x in self._usestats]]
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
        lines = [x.strip().split(self._args.delimiter) for x in self._get_raw_lines()]
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
