#!/usr/bin/env bash
set -euo pipefail

# FILENAME_SUFFIX: sudo_pip3_install_i3ipc
# SUMMARY: install i3ipc python package to enable use of window swapping script. Requires sudo to enable availability of i3ipc at i3 startup time.
# ---
command -v i3 && sudo pip3 install i3ipc
