#!/usr/bin/env bash
set -euo pipefail

# SUMMARY: Installs Tmux Plugin Manager and plugins
# ISSUED: 2023-09-09 23:10:21+02:00
# ---
if [ ! -d ~/.config/tmux ]; then
    echo "Tmux config directory not found. Exiting."
    exit 1
elif [ -d ~/.config/tmux/plugins/tpm ] || [ -L ~/.config/tmux/plugins/tpm ]; then
    # tpm is already installed
    exit 0
elif [ ! -d ~/.config/tmux/plugins ]; then
    mkdir -p ~/.config/tmux/plugins
fi

# Install tpm
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm

# Install plugins
if [ -z "${TMUX}" ]; then
    tmux new-session 'tmux source ~/.config/tmux/tmux.conf && ~/.config/tmux/plugins/tpm/bin/install_plugins'
else
    tmux source ~/.config/tmux/tmux.conf && ~/.config/tmux/plugins/tpm/bin/install_plugins
fi
