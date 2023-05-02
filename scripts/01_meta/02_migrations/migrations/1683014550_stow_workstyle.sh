#!/usr/bin/env bash
set -euo pipefail

# SUMMARY: stow workstyle
# ISSUED: 2023-05-02 10:02:38+02:00
# ---
if [ -z "$(ls -A ~/.dotfiles/datafiles/ || true)" ]; then
    echo "Skipping desktop-only migration."
    exit 0
else
    echo "Running desktop-only migration."
fi

~/.dotfiles/scripts/01_meta/01_setup/tools/stow.py install workstyle -vs
