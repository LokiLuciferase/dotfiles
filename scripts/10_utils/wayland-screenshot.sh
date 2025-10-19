#!/usr/bin/env bash
set -euo pipefail

command -v slurp &> /dev/null
command -v grim &> /dev/null
command -v wl-copy &> /dev/null

FN=$(mktemp -u).png
slurp | grim -g - $FN
wl-copy < $FN
rm -f $FN
notify-send 'Screenshot sent to clipboard.'
