#!/usr/bin/env bash
set -euo pipefail

# SUMMARY: install rofimoji
# ISSUED: 2023-10-14 01:26:20+02:00
# ---
if [ -z "$(ls -A ~/.dotfiles/datafiles/ || true)" ]; then
    echo "Skipping desktop-only migration."
    exit 0
else
    echo "Running desktop-only migration."
fi

/usr/bin/pip3 install --user rofimoji
