#!/usr/bin/env bash
set -euo pipefail

# SUMMARY: introduce versioned bashrc which redirects the bash history to prevent overwriting of zsh history

cd ~
mkdir -p ~/.cache/bash
ln -vs --backup=t .dotfiles/bash/.bashrc .bashrc
