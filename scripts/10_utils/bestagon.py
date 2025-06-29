#!/usr/bin/env python3
# /// script
# requires-python = ">3.8"
# dependencies = [
#   "numpy",
#   "pillow",
#   "tqdm",
#   "numba"
# ]
# ///

from typing import Optional, Union, Tuple, List
from argparse import ArgumentDefaultsHelpFormatter, ArgumentParser
from pathlib import Path

import numpy as np
from PIL import Image
from tqdm.auto import tqdm
from tqdm.contrib.concurrent import process_map

try:
    from numba import jit
except ImportError as e:
    print('Cannot import numba - bestagonization will be slow.')

    def jit(f):
        def wrapper(*args, **kwargs):
            return f(*args, **kwargs)

        return wrapper


RATIO = np.array([0.577350278, 1.0])
PI = 3.1415926
CONST_A = 1.047197551
CONST_B = 3.464101665


class Bestagon:
    @staticmethod
    def _get_args():
        parser = ArgumentParser(
            description='A script to create hexagonal pixel art from an image.',
            formatter_class=ArgumentDefaultsHelpFormatter,
        )
        parser.add_argument('-i', '--input', required=True, help='The file to process')
        parser.add_argument('-o', '--output', help='The name of the output file.')
        parser.add_argument(
            '-c',
            '--count',
            default=32,
            type=int,
            nargs='+',
            help='The number of bestagons per row. If multiple are passed, create an image for each.',
        )
        parser.add_argument(
            '-r',
            '--rescale_height',
            default=None,
            help='The height (in px) to rescale the image to before applying bestagon filter.',
        )
        parser.add_argument(
            '--spiky',
            action='store_true',
            default=False,
            help='Whether to have the spiky side of the bestagon on top.',
        )
        parser.add_argument(
            '--iterative',
            action='store_true',
            default=False,
            help='Whether to perform all operations iteratively on the same image.',
        )
        args = parser.parse_args()
        return args

    @staticmethod
    def _resolve_rescale_height(rescale_height: Union[str, int] = None) -> Optional[int]:
        if rescale_height is not None:
            rh = {
                '8k': 4320,
                '4k': 2160,
                'qhd': 1440,
                'fhd': 1080,
            }.get(str(rescale_height).lower(), rescale_height)
            rh = int(rh)
        else:
            rh = None
        return rh

    @staticmethod
    def _rescale_image(im: Image, new_height: int):
        orig_width, orig_height = im.size
        factor = new_height / orig_height
        newsize = (int(orig_width * factor), new_height)
        im1 = im.resize(newsize, resample=Image.Resampling.BICUBIC)
        return im1

    @staticmethod
    @jit
    def _hexagon_map(
        row: int, col: int, resolution: np.ndarray, count: int, r: np.ndarray
    ) -> Tuple[int, int]:
        # Horribly inefficiently re-implemented from: https://www.shadertoy.com/view/wsSyWR
        uv = np.array([row, col]) / resolution[1]
        uv = uv * count * RATIO
        z = min(max(abs(((uv[0] + np.floor(uv[1])) % 2.0) - 1.0) * PI - CONST_A, 0.0), 1.0)
        uv[1] = np.floor(uv[1] + z)
        uv[0] = (np.floor(uv[0] * 0.5 + (uv[1] % 2.0) * 0.5) - (uv[1] % 2.0) * 0.5 + 0.5) * CONST_B
        new_row, new_col = resolution * (uv / count * r)
        return min(int(new_row), resolution[0] - 1), min(int(new_col), resolution[1] - 1)

    @classmethod
    def _parallelize_over_rows(cls, tup):
        row, resolution, count, r = tup
        mapped = []
        for col in range(resolution[1]):
            mapped_row, mapped_col = cls._hexagon_map(
                row, col, resolution=resolution, count=count, r=r
            )
            mapped.append((mapped_row, mapped_col))
        return mapped

    @classmethod
    def from_args(cls):
        args = cls._get_args()
        counts = args.count if isinstance(args.count, list) else [args.count]
        obj = cls(
            input_=args.input,
            output=args.output,
            counts=counts,
            rescale_height=args.rescale_height,
            spiky=args.spiky,
            iterative=args.iterative,
        )
        return obj

    def __init__(
        self,
        input_: Union[str, Path],
        output: Optional[Union[str, Path]],
        counts: List[int],
        rescale_height: str,
        spiky: bool = False,
        iterative: bool = False,
    ):

        self._input = Path(str(input_))
        self._given_output = output
        self._counts = counts if len(counts) == 1 else tqdm(counts, desc='Converting')
        self._rescale_height = self._resolve_rescale_height(rescale_height)
        self._spiky = spiky
        self._iterative = iterative
        self._max_pad = len(str(max(counts)))
        self._processed_outp = []

    def _format_outp(self, count: int):
        outp = self._given_output
        if self._iterative:
            count = '_iterative'  # write to same file
        else:
            count = str(count).zfill(self._max_pad)
        if self._given_output is None:
            fin = Path(self._input)
            fout = fin.parent / f'{fin.stem}_bg{count}{"s" if self._spiky else ""}{fin.suffix}'
            if fout.is_file() and not self._iterative:
                raise RuntimeError(f'Default output file already exists: {fout}')
            outp = str(fout)
        return outp

    def _load_img(self) -> Image:
        pic = Image.open(self._input)
        if self._rescale_height is not None:
            pic = self._rescale_image(pic, self._rescale_height)
        return pic

    def _write_img(self, img, outp: Path):
        img.save(outp)

    def _convert_img(self, pic: Image, count: int) -> Image:
        origcount = count
        count = count * 2
        pix = np.array(pic, dtype=np.uint8)

        if not self._spiky:
            n_cols, n_rows = pic.size
            factor = n_cols / n_rows
            count = int(count // factor)
            pix = np.rot90(pix)

        newpix = np.zeros_like(pix)
        resolution = np.array(pix.shape[:2])
        r = np.array([resolution[1] / resolution[0], 1.0])

        tups = [(row, resolution, count, r) for row in range(resolution[0])]
        mapped = process_map(
            self._parallelize_over_rows,
            tups,
            chunksize=1,
            desc=f'count={origcount}{" (spiky)" if self._spiky else ""}',
            leave=False,
        )
        for row, mapping in enumerate(mapped):
            for col, (mapped_row, mapped_col) in enumerate(mapping):
                newpix[row, col] = pix[mapped_row, mapped_col]

        if not self._spiky:
            newpix = np.rot90(newpix, k=3)
        im = Image.fromarray(newpix)
        return im

    def run(self):
        orig_img = self._load_img()
        for count in self._counts:
            converted_img = self._convert_img(orig_img, count=count)
            outp = self._format_outp(count)
            self._write_img(converted_img, outp=outp)
            self._processed_outp.append(outp)
            if self._iterative:
                orig_img = converted_img


if __name__ == '__main__':
    bestagon = Bestagon.from_args()
    bestagon.run()
