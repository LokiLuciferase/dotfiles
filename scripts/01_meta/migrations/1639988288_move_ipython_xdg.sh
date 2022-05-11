#!/usr/bin/env bash
set -euo pipefail

# SUMMARY: move ipython and jupyter directories to XDG_CONFIG_HOME

cd ~
mkdir -p ~/.config
mv .ipython ~/.config/ipython || true
mv .jupyter ~/.config/jupyter || true
