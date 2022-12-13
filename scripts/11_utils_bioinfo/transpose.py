#!/usr/bin/env python3
import argparse
import csv
import sys
from pathlib import Path
from tempfile import NamedTemporaryFile
from typing import List, Tuple


def get_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('input_file', type=Path, default=None, nargs='?')
    parser.add_argument('-d', '--delimiter', default='auto')
    return parser.parse_args()


def transpose(input_file: str = None, delimiter: str = 'auto') -> Tuple[List[List[str]], str]:
    if delimiter == 'auto':
        with input_file.open() as f:
            dialect = csv.Sniffer().sniff(f.read(1024))
            delimiter = dialect.delimiter
    with open(input_file, 'r') as input_file:
        reader = csv.reader(input_file, delimiter=delimiter)
        return list(zip(*reader)), delimiter


def main():
    args = get_args()
    used_temp = False
    if args.input_file is None:
        temp_file = NamedTemporaryFile(delete=False)
        temp_file.write(sys.stdin.read().encode())
        temp_file.close()
        args.input_file = Path(temp_file.name)
        used_temp = True
    transposed, used_delimiter = transpose(args.input_file, args.delimiter)
    for row in transposed:
        row = [str(cell) for cell in row]
        print(used_delimiter.join(row))
    if used_temp:
        args.input_file.unlink()


if __name__ == '__main__':
    main()
