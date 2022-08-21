#!/usr/bin/env bash
set -euo pipefail

# FILENAME_SUFFIX: move_bash_hist
# SUMMARY: rename bash history file
# ---
mkdir -p ~/.cache/bash/
mv ~/.cache/bash/bash_history ~/.cache/bash/history || touch ~/.cache/bash/history
