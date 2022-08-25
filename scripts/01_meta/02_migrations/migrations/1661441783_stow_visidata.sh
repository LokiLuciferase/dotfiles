#!/usr/bin/env bash
set -euo pipefail

# FILENAME_SUFFIX: stow_visidata
# SUMMARY: stow visidata configs and plugin dir
# ---
which python3 || { echo "python3 not found"; exit 1; }
~/.dotfiles/scripts/01_meta/01_setup/tools/stow.py install visidata -v -s
