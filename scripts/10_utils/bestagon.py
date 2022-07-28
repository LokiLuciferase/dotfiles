#!/usr/bin/env python3

from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter

from tqdm.auto import trange
import numpy as np
from PIL import Image


RATIO = np.array([0.577350278, 1.0])
PI = 3.1415926
CONST_A = 1.047197551
CONST_B = 3.464101665


def get_args():
    parser = ArgumentParser(
        description='A script to create hexagonal pixel art from an image.',
        formatter_class=ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument('-i', '--input', required=True, help='The file to process')
    parser.add_argument('-o', '--output', required=True, help='The name of the output file.')
    parser.add_argument(
        '-c', '--count', default=32, type=int, help='The number of bestagons per row.'
    )
    parser.add_argument(
        '--spiky',
        action='store_true',
        default=False,
        help='Whether to have the spiky side of the bestagon on top.',
    )
    args = parser.parse_args()
    return args


def hexagon_map(row, col, resolution, count, r):
    # Horribly inefficiently re-implemented from: https://www.shadertoy.com/view/wsSyWR
    uv = np.array([row, col], dtype=np.uint16) / resolution[1]
    uv = uv * count * RATIO
    z = np.clip(np.abs(np.mod(uv[0] + np.floor(uv[1]), 2.0) - 1.0) * PI - CONST_A, 0.0, 1.0)
    uv[1] = np.floor(uv[1] + z)
    uv[0] = (
        np.floor(uv[0] * 0.5 + np.mod(uv[1], 2.0) * 0.5) - np.mod(uv[1], 2.0) * 0.5 + 0.5
    ) * CONST_B
    new_row, new_col = resolution * (uv / count * r)
    return min(int(new_row), resolution[0] - 1), min(int(new_col), resolution[1] - 1)


def parallelize_over_rows(tup):
    row, resolution, count, r = tup
    mapped = []
    for col in range(resolution[1]):
        mapped_row, mapped_col = hexagon_map(
            row, col, resolution=resolution, count=count, r=r
        )
        mapped.append((mapped_row, mapped_col))
    return mapped


def convert(inp: str, outp: str, count: int, flat: bool):
    count = count * 2
    pic = Image.open(inp)
    pix = np.array(pic, dtype=np.uint8)
    if flat:
        n_cols, n_rows = pic.size
        factor = n_cols / n_rows
        count = int(count // factor)
        pix = np.rot90(pix)
    newpix = np.zeros_like(pix)

    resolution = np.array(pix.shape[:2], dtype=np.uint16)
    r = np.array([resolution[1] / resolution[0], 1.0], dtype=np.float16)

    for row in trange(resolution[0]):
        for col in range(resolution[1]):
            mapped_row, mapped_col = hexagon_map(
                row, col, resolution=resolution, count=count, r=r
            )
            newpix[row, col] = pix[mapped_row, mapped_col]

    if flat:
        newpix = np.rot90(newpix, k=3)
    im = Image.fromarray(newpix)
    im.save(outp)


if __name__ == '__main__':
    args = get_args()
    convert(args.input, args.output, int(args.count), flat=(not args.spiky))
