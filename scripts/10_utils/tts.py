#!/usr/bin/env python3
# /// script
# requires-python = ">3.10"
# ///

import sys
import json
import shutil
import argparse
import subprocess
import urllib.request
from pathlib import Path


def get_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument('-s', '--say', required=False, default=None, type=str, help='A text string to speak.')
    parser.add_argument('-f', '--file', required=False, default=None, type=str, help='A file to read out.')
    parser.add_argument('-u', '--url', default=None, required=True, type=str, help='The endpoint URL.')
    parser.add_argument('-x', '--speed', default=1.0, type=float, help='Playback speed.')
    parser.add_argument(
        '-v', '--voices', default='af_bella+af_sky', required=False, help='A combination of voice strings.'
    )
    parser.add_argument(
        'output',
        nargs='?',
        help='The output file of the spoken sounds. "-" for stdout. If none, pipe to MPV internally.',
    )

    args = parser.parse_args()
    if args.output is None and not shutil.which('mpv'):
        raise RuntimeError('MPV not found, cannot play.')
    elif args.output is not None and args.output != '-' and not args.output.endswith('mp3'):
        raise RuntimeError('Only mp3 is supported as output format.')
    return args


def get_text(say: str | None, file: str | None) -> str:
    if say is None and file is None:
        raise RuntimeError('Either -s or -f must be specified.')
    elif say is not None and file is not None:
        raise RuntimeError('Only -s or -f must be specified.')
    elif say is not None:
        return say
    elif file is not None:
        return Path(file).read_text()
    else:
        raise NotImplementedError


def stream_response(url: str, text: str, voices: str, speed: float):
    data = json.dumps({
        'input': text,
        'voice': voices,
        'speed': speed,
        'response_format': 'mp3',
    }).encode('utf-8')

    req = urllib.request.Request(
        url,
        data=data,
        headers={'Content-Type': 'application/json'},
        method='POST'
    )
    response = urllib.request.urlopen(req)
    return response


def output_response(response, output: str | None):
    if output == '-':
        out_handle = sys.stdout.buffer
    elif output is not None:
        out_handle = open(output, 'wb')
    else:
        out_handle = None

    if out_handle is not None:
        # write it out
        while True:
            chunk = response.read(1024)
            if not chunk:
                break
            out_handle.write(chunk)
            out_handle.flush()

    else:
        # pipe it to MPV
        mpv = subprocess.Popen(['mpv', '-'], stdin=subprocess.PIPE)
        while True:
            chunk = response.read(1024)
            if not chunk:
                mpv.stdin.close()
                break
            mpv.stdin.write(chunk)
            mpv.stdin.flush()
        mpv.wait()


def main():
    args = get_args()
    text = get_text(args.say, args.file)
    response = stream_response(args.url, text, args.voices, args.speed)
    output_response(response, args.output)


if __name__ == '__main__':
    main()
