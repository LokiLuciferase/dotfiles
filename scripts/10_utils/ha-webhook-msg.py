#!/usr/bin/env python3
# /// script
# requires-python = "3.6"
# ///

import os
import json
import typing
import argparse
from pathlib import Path
from urllib import request


HA_URL_NAME = 'HA_NOTIFY_WEBHOOK_URL'
HA_URL = os.environ.get(HA_URL_NAME, None)


def get_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument(
        'msg',
        type=str,
        nargs='+',
        help='The message to send as a notification.',
    )
    parser.add_argument(
        '-s',
        '--service',
        type=str,
        default=None,
        help='The name of the service to declare in the notification title.',
    )
    parser.add_argument(
        '-p',
        '--person',
        type=str,
        default=None,
        help='The name of the homeassistant user to send the notification to.'
    )
    parser.add_argument(
        '-u',
        '--url',
        type=str,
        default=None,
        help='The URL to redirect to when clicking the notification.',
    )
    args = parser.parse_args()
    return args


def do_post(
    msg: str | typing.List[str],
    service: typing.Union[str, None],
    person: typing.Union[str, None],
    url: typing.Union[str, None],
):
    if isinstance(msg, list):
        msg = ' '.join(msg)
    if HA_URL is None:
        raise RuntimeError(f'Missing environment variable "{HA_URL_NAME}"')
    params = {'message': msg, 'service': service if service is not None else Path(__file__).name}
    if url is not None:
        params['data'] = {}  # type: ignore
        params['data']['clickAction'] = url
    if person is not None:
        params['person'] = person  # type: ignore
    params = json.dumps(params).encode()
    req = request.Request(HA_URL, data=params, method='POST')
    req.add_header('Content-Type', 'application/json')
    with request.urlopen(req) as resp:
        if resp.status != 200:
            print(f'{resp.status}: {resp.reason}')


def main():
    args = get_args()
    do_post(args.msg, service=args.service, person=args.person, url=args.url)


if __name__ == '__main__':
    main()
