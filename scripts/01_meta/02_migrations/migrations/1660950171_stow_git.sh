#!/usr/bin/env bash
set -euo pipefail

# FILENAME_SUFFIX: stow_git
# SUMMARY: stow git config dir and move old gitconfig out of the way
# ---
which python3
~/.dotfiles/scripts/01_meta/01_setup/tools/stow.py install git -v -s
mv ~/.gitconfig ~/gitconfig.bak || true
