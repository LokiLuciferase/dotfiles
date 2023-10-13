#!/usr/bin/env bash
set -euo pipefail

# SUMMARY: Introduce ZSH config files to their new target location under XDG_CONFIG_HOME
# ISSUED: 2023-10-13 18:29:53+02:00
# ---
python3 ~/.dotfiles/scripts/01_meta/01_setup/tools/stow.py -vs zsh
