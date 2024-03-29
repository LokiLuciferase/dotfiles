#!/usr/bin/env python3
import os
import sys
import argparse
from pprint import pformat

import requests


URL = os.environ['HOMEASSISTANT_API_URL']
TOKEN = os.environ['HOMEASSISTANT_TOKEN']
NAME_MAP = {
    'L': ('light.smart_bulb_1', 'light', 'Living Room Light'),
    'B': ('light.smart_bulb_2', 'light', "Bedroom Light"),
    'LT': ('light.smart_bulb_4', 'light', 'Table Lamp'),
    'LC': ('light.smart_bulb_3', 'light', 'Couch Lamp'),
    'S': ('switch.smart_plug_1_socket_1', 'switch', 'Sub'),
}
HEADERS = {
    'Authorization': f'Bearer {TOKEN}',
    'Content-Type': 'application/json',
}


def get_args():
    parser = argparse.ArgumentParser(
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
        description=f"""
        Control smart home devices.

        Available devices: {pformat({k: v[2] for k, v in NAME_MAP.items()})}
        """
    )
    parser.add_argument('action', choices=['on', 'off', 'toggle'], default='toggle', nargs='?')
    parser.add_argument('device', choices=list(NAME_MAP.keys()) + ['all'], default='all')
    return parser.parse_args()


def client_call(id: str, action: str = 'toggle', domain: str = 'light'):
    full_url = f'{URL}/services/{domain}/{action}'
    req = requests.post(full_url, json={'entity_id': id}, headers=HEADERS)
    if req.status_code != 200:
        print(f'Error: {req.status_code} {req.text}')
        sys.exit(1)


def main():
    args = get_args()
    if args.device == 'all':
        for _, (id_, domain, _) in NAME_MAP.items():
            client_call(id_, args.action, domain)
    else:
        id_, domain, _ = NAME_MAP[args.device]
        client_call(id_, args.action, domain)


if __name__ == '__main__':
    main()
