#!/usr/bin/env bash
set -euo pipefail

# FILENAME_SUFFIX: move_i3status_config_dir
# SUMMARY: Move the i3status config dir into the i3 config dir
# ---
[ ! -L "$HOME/.config/i3status" ] && exit 0
cd "$HOME/.config" || exit 1
ln -sf "$HOME/.dotfiles/i3/.config/i3status" i3status
