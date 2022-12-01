#!/usr/bin/env bash
set -euo pipefail

# If there is a numbered tmux session (not representing a persistent job) which is not currently attached to, attach to it. Otherwise, create a new one.

TMUX_CONFIG="$HOME/.config/tmux/tmux.conf"

if [[ $# -eq 0 ]]; then
    ATTACH_NAME=$(tmux list-sessions -F '#{session_name}#{?session_attached,--attached,}' | grep -v -- '--attached' 2> /dev/null | grep -oE '[0-9]+$' 2> /dev/null | sort -n | tail -n 1 || true)
else
    ATTACH_NAME=$1
fi

if [[ -z "$ATTACH_NAME" ]]; then
    NEW_SESS_ARG=""
else
    NEW_SESS_ARG="-s $ATTACH_NAME"
fi

CMD="tmux -f ${TMUX_CONFIG} attach -t $ATTACH_NAME &> /dev/null || tmux -f ${TMUX_CONFIG} new $NEW_SESS_ARG"
eval $CMD
