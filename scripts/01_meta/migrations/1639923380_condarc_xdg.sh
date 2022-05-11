#!/usr/bin/env bash
set -euo pipefail

# SUMMARY: integrate versioned conda directory into XDG_CONFIG_HOME

mkdir -p ~/.config
mv ~/.config/conda ~/.config/conda.bak || true
mv ~/.conda ~/.conda.bak || true
mv ~/.condarc ~/.condarc.bak || true
cd ~/.config
ln -s ../.dotfiles/conda/.config/conda/ .
