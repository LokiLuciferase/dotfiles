#!/usr/bin/env bash
set -euo pipefail

# FILENAME_SUFFIX: install_workstyle
# SUMMARY: Installs the workstyle rust binary, if this is a desktop install.
# ---
[ -z "$(ls -A ~/.dotfiles/datafiles/)" ] && echo "Skipping for non-desktop install." && exit 0
source ~/.local/share/cargo/env
cargo install workstyle
echo "Installing workstyle to /usr/local/bin/workstyle, this requires sudo privileges."
sudo cp ~/.local/share/cargo/bin/workstyle /usr/local/bin/workstyle
