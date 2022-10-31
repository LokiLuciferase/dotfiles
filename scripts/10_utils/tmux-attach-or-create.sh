#!/usr/bin/env bash
set -euo pipefail


TMUX_CONFIG="$HOME/.config/tmux/tmux.conf"


get-latest-numbered-tmux-session() {
    local sessname
    sessname=$(tmux list-sessions | grep -oE '[0-9]+$' | sort -n | tail -n 1)
    if [[ -z "$sessname" ]]; then
        echo "0"
    else
        echo "$sessname"
    fi
    return 0
}

if [[ $# -eq 0 ]]; then
    SESS_TO_ATTACH=$(get-latest-numbered-tmux-session)
else
    SESS_TO_ATTACH=$1
fi

tmux -f "${TMUX_CONFIG}" attach -t "$SESS_TO_ATTACH" || tmux -f "${TMUX_CONFIG}" new -s "$SESS_TO_ATTACH"
