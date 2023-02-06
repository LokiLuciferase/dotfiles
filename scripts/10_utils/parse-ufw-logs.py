#!/usr/bin/env python3
import sys
from pathlib import Path
from typing import List, Union, Dict
import gzip
import re
import csv
import argparse


PAT = r'(.*) (.*) kernel: (\[.*\]) (\[.*\]) (.*)'


def get_log_files(logdir: Path = Path('/var/log')):
    return sorted(list(logdir.glob('ufw.log*')))


def parse_log_file(f: Path) -> List[Dict]:
    open_func = gzip.open if f.name.endswith('.gz') else open
    with open_func(f, 'rt') as fin:
        fred = fin.readlines()
    fred = fred[::-1]
    parsed = []
    for line in fred:
        if not len(line):
            continue
        match = re.match(PAT, line).groups()
        date = match[0]
        hostname = match[1]
        f2 = match[2][1:-1]
        action = match[3][1:-1]
        params = {}
        for rec in match[4].split(' '):
            if '=' in rec:
                k, v = rec.split('=')
                params[k] = v
        parsed.append(
            {'DATE': date, 'HOSTNAME': hostname, 'UPTIME': f2, 'ACTION': action, **params}
        )
    return parsed
    if len(parsed):
        return pd.DataFrame.from_records(parsed)
    else:
        return pd.DataFrame()


def parse_all_log_files(
    logdir: Union[str, Path] = Path('/var/log'), out: Union[str, Path] = Path('ufw_logs.tsv')
):
    final = []
    fieldnames = [
        'DATE',
        'HOSTNAME',
        'UPTIME',
        'ACTION',
        'PHYSIN',
        'IN',
        'OUT',
        'MAC',
        'SRC',
        'DST',
        'LEN',
        'PROTO',
        'SPT',
        'DPT',
        'TOS',
        'PREC',
        'TTL',
        'ID',
        'WINDOW',
        'RES',
        'URG',
        'URGP',
        'TC',
        'HOPLIMIT',
        'FLOWLBL'
    ]
    for x in get_log_files(Path(str(logdir))):
        final += parse_log_file(x)
    with open(out, 'w') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames, delimiter='\t')
        writer.writeheader()
        writer.writerows(final)


def parse_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument(
        '-l',
        '--logdir',
        type=str,
        default='/var/log',
        help='Directory to search for log files.',
    )
    parser.add_argument(
        '-o',
        '--out',
        type=str,
        default='parsed_ufw_logs.tsv',
        help='Output file to write to.',
    )
    return parser.parse_args()


if __name__ == '__main__':
    args = parse_args()
    parse_all_log_files(args.logdir, args.out)
