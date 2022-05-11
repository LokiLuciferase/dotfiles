#!/usr/bin/env bash
set -euo pipefail

# FILENAME_SUFFIX: zsh_local_location
# SUMMARY: move local ZSH config files to separate directory to enable sourcing them after default config (thus overriding existing configs)
# ---

mkdir -p "$HOME/.dotfiles/zsh/local"
mv ~/.dotfiles/zsh/*.local.zsh ~/.dotfiles/zsh/local/ || true
