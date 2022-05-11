#!/usr/bin/env bash
set -euo pipefail

# SUMMARY: move .Xresources file to dotfiles and touch local xresources file
cd $HOME
ln -vs --backup=t .dotfiles/xresources/.Xresources .Xresources
touch .dotfiles/xresources/.Xresources.local
