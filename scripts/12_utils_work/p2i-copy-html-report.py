#!/usr/bin/env -S uv run
# /// script
# requires-python = ">=3.9"
# dependencies = [
#     "paramiko",
# ]
# ///

import sys
from pathlib import Path
import paramiko

SSH_HOSTNAME = 'p2i'
SSH_CONFIG = paramiko.SSHConfig.from_path(Path('~/.ssh/config').expanduser())
USER_CONFIG = SSH_CONFIG.lookup(SSH_HOSTNAME)


def copy_html_report(remote_basedir: str, localpath: str):
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(
        hostname=USER_CONFIG['hostname'],
        port=int(USER_CONFIG.get('port', 22)),
        username=USER_CONFIG['user'],
        key_filename=USER_CONFIG.get('identityfile', [None])[0],
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
    if len(sys.argv) != 2:
        print('Usage: p2i-copy-html-report.py <remote_basedir>')
        sys.exit(1)

    remote_path = sys.argv[1]
    remote_path_parts = remote_path.split('/')
    assert remote_path_parts[0] == ''
    assert remote_path_parts[1] == 'data'
    local_path = f'./{remote_path_parts[2]}_{remote_path_parts[3]}_report_{remote_path_parts[4]}.html'
    copy_html_report(remote_path, local_path)
