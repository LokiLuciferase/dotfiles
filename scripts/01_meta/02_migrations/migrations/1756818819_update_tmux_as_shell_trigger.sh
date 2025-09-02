#!/usr/bin/env bash
set -euo pipefail

# SUMMARY: For environments where USE_TMUX_AS_SHELL=true, create the file ~/.local/state/tmux/use_as_shell, which serves as the new trigger for starting directly into tmux when requested.
# ISSUED: 2025-09-02 15:14:44+02:00
# ---
source ~/.dotfiles/zsh/.config/zsh/local/env_vars.local.zsh || exit 0
if [ "${USE_TMUX_AS_SHELL:-}" = "true" ]; then
    mkdir -p ~/.local/state/tmux
    touch ~/.local/state/tmux/use_as_shell
fi
