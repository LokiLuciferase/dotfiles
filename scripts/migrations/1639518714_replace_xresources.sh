#!/usr/bin/env bash
set -euo pipefail

cd $HOME
ln -vs --backup=t .dotfiles/xresources/.Xresources .Xresources
