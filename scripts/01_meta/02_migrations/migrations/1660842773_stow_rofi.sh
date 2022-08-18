#!/usr/bin/env bash
set -euo pipefail

# FILENAME_SUFFIX: stow_rofi
# SUMMARY: stow rofi configs
# ---
which python3
~/.dotfiles/scripts/01_meta/01_setup/tools/stow.py install rofi -v -s
