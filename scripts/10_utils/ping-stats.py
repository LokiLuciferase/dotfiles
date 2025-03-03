#!/usr/bin/env python3
import re
import json
import argparse
import subprocess
from datetime import datetime


def get_args():
    parser = argparse.ArgumentParser(description='Ping statistics')
    parser.add_argument('-c', '--count', type=int, default=5, help='Number of packets to send')
    parser.add_argument('-t', '--timeout', type=int, default=1, help='Time to wait for a response')
    parser.add_argument('host', nargs='?', default='8.8.8.8', help='Host to ping')
    return parser.parse_args()


def get_ping_statistics(count: int = 5, timeout: int = 1, host: str = '8.8.8.8') -> dict:
    out = {
        'timestamp': datetime.now().isoformat(),
        'packets': count,
        'timeout': timeout,
        'host': host,
        'exitcode': None,
        'packet_loss_perc': None,
        'rtt_min': None,
        'rtt_avg': None,
        'rtt_max': None,
        'rtt_mdev': None,
    }
    rslt = subprocess.run(
        [
            'ping',
            '-c',
            str(count),
            '-W',
            str(timeout),
            host,
        ],
        capture_output=True,
    )
    out['exitcode'] = rslt.returncode
    output = rslt.stdout.decode()

    packet_loss = re.search(r'(\d+)% packet loss', output)
    if packet_loss:
        out['packet_loss_perc'] = int(packet_loss.group(1))

    rtt = re.search(r'.*min/avg/max.* = ([\d.]+)/([\d.]+)/([\d.]+)/([\d.]+) ms', output)
    if rtt:
        out['rtt_min'], out['rtt_avg'], out['rtt_max'], out['rtt_mdev'] = map(float, rtt.groups())

    return out


def main():
    args = get_args()
    ping_statistics = get_ping_statistics(args.count, args.timeout, args.host)
    print(json.dumps(ping_statistics))


if __name__ == '__main__':
    main()
