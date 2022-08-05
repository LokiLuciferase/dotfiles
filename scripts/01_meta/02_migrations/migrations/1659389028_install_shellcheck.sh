#!/usr/bin/env bash
set -euo pipefail

# FILENAME_SUFFIX: install_shellcheck
# SUMMARY: Installs shellcheck statically linked binary.
# ---
if [ $(arch) = 'x86_64' ]; then
    DLPATH='https://github.com/koalaman/shellcheck/releases/download/stable/shellcheck-stable.linux.x86_64.tar.xz'
elif [ $(arch) = 'aarch64' ]; then
    DLPATH='https://github.com/koalaman/shellcheck/releases/download/stable/shellcheck-stable.linux.aarch64.tar.xz'
elif [ $(arch) = 'armv6hf' ]; then
    DLPATH='https://github.com/koalaman/shellcheck/releases/download/stable/shellcheck-stable.linux.armv6hf.tar.xz'
else
    echo 'Unsupported architecture. Exiting.'
    exit 0
fi

TD=$(mktemp -d)
pushd ${TD}
wget -qO- ${DLPATH} | tar -xJv
mv */shellcheck ~/.local/bin/shellcheck
popd
rm -rf ${TD}
