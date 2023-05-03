#!/usr/bin/env python3
import sys
from random import randint
from typing import List, Tuple, Optional


def parse_die_string(s: str) -> List[Tuple[Optional[int], int]]:
    """
    Parses a die string and returns the number of dice and the number of sides
    """
    parsed = []
    for term in s.split('+'):
        term = term.strip()
        if 'd' in term:
            n, d = term.split('d')
            parsed.append((int(n), int(d)))
        else:
            parsed.append((None, int(term)))
    return parsed


def roll_die(n: int, d: int) -> List[int]:
    """
    Rolls a die with n sides d times
    """
    return [randint(1, d) for _ in range(n)]


def main():
    results = []

    if len(sys.argv) == 1:
        args = '1d20'
    elif len(sys.argv) != 2:
        args = ' '.join(sys.argv[1:])
    else:
        args = sys.argv[1]

    dies = parse_die_string(args)

    for n, d in dies:
        if n is None:
            results.append(d)
        else:
            results.extend(roll_die(n, d))
    print(sum(results), results)


if __name__ == '__main__':
    main()
