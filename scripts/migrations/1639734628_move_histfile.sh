#!/usr/bin/env bash
set -euo pipefail

# SUMMARY: move zsh history file to XDG directory
ZSH_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
mkdir -p "$ZSH_CACHE"
mv "$HOME/.zsh_history" "$ZSH_CACHE/history"
