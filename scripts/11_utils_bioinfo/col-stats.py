#!/usr/bin/env python3

import argparse
import sys


def get_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument(
        '-f',
        '--field',
        '-k',
        '--key',
        '-c',
        '--column',
        dest='field',
        default=1,
        help='Field to read (1-indexed)',
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
        default=0,
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
        default='count,mean,std,min,25p,50p,75p,max',
        help='Comma-separated list of stats to show',
    )
    return parser.parse_args()


def isnumeric(s):
    try:
        float(s)
        return True
    except ValueError:
        return False


def main():
    args = get_args()
    lines = [
        float(x.strip().split(args.delimiter)[int(args.field) - 1]) for x in sys.stdin.readlines()
    ]
    if args.skip == 'auto':
        lines = [x for x in lines if isnumeric(x)]
    else:
        lines = lines[int(args.skip) :]
    stats = {'count': len(lines)}
    stats['mean'] = sum(lines) / stats['count']
    stats['std'] = (sum([(x - stats['mean']) ** 2 for x in lines]) / stats['count']) ** 0.5
    lines.sort()
    stats['min'] = lines[0]
    stats['max'] = lines[-1]
    stats['25p'] = lines[int(stats['count'] * 0.25)]
    stats['50p'] = lines[int(stats['count'] * 0.5)]
    stats['75p'] = lines[int(stats['count'] * 0.75)]
    out_header = []
    out = []
    for hc in args.usecols.split(','):
        out_header.append(hc)
        out.append(stats[hc])
    if not args.no_out_header:
        print('\t'.join(out_header))
    print('\t'.join([str(round(x, int(args.round_to))) for x in out]))


if __name__ == '__main__':
    main()
