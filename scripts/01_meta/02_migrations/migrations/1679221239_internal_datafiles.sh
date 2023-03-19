#!/usr/bin/env bash
set -euo pipefail

# FILENAME_SUFFIX: internal_datafiles
# SUMMARY: If a datafiles dir exists, init the datafiles module and replace the symlinks
# ---

if [ -d ~/.datafiles/.git/ ]; then
    cd ~/.dotfiles
    git submodule update --init --depth=1
    ~/.dotfiles/scripts/01_meta/01_setup/tools/stow.py install datafiles -vs
    mv ~/.datafiles ~/.datafiles.bak
fi
