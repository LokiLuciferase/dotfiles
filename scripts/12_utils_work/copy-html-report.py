#!/usr/bin/env -S uv run
# /// script
# requires-python = ">=3.9"
# dependencies = [
#     "paramiko",
# ]
# ///

import argparse
from pathlib import Path
import paramiko


def get_args():
    parser = argparse.ArgumentParser(
        description='Copy HTML report from remote server.', formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument('remote_basedir', type=str, help='Remote base directory containing the HTML report')
    parser.add_argument('--host', type=str, default='p2i', help='SSH host to connect to')
    return parser.parse_args()


def copy_html_report(ssh_hostname: str, remote_basedir: str, localpath: str):
    config = paramiko.SSHConfig.from_path(Path('~/.ssh/config').expanduser())
    user_config = config.lookup(ssh_hostname)
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(
        hostname=user_config['hostname'],
        port=int(user_config.get('port', 22)),
        username=user_config['user'],
        key_filename=user_config.get('identityfile', [None])[0],
        timeout=3,
    )

    sftp = ssh.open_sftp()
    remotepath = None
    for filename in sftp.listdir(remote_basedir):
        if filename.endswith('.html'):
            remotepath = f'{remote_basedir}/{filename}'
            break
    if remotepath is None:
        raise FileNotFoundError(f'No HTML file found in {remote_basedir}')
    sftp.get(remotepath, localpath)
    sftp.close()
    ssh.close()


if __name__ == '__main__':
    args = get_args()
    remote_path = args.remote_basedir
    remote_path_parts = remote_path.split('/')
    assert remote_path_parts[0] == ''
    assert remote_path_parts[1] == 'data'
    local_path = f'./{remote_path_parts[2]}_{remote_path_parts[3]}_report_{remote_path_parts[4]}.html'
    copy_html_report(args.host, remote_path, local_path)
