#!/usr/bin/env bash
set -euo pipefail

# If there is a numbered tmux session (not representing a persistent job) which is not currently attached to, attach to it. Otherwise, create a new one.
TMUX_CONFIG="$HOME/.config/tmux/tmux.conf"

get-attach-name() {
    tmux list-sessions -F '#{session_name}#{?session_attached,--attached,}' \
        | grep -v -- '--attached' 2> /dev/null \
        | grep -oE '[0-9]+$' 2> /dev/null \
        | sort -n \
        | tail -n 1 \
        || return 0
}

main() {
    local attach_name
    local cmd
    attach_name=$(get-attach-name)
    if [[ ! -z "${attach_name}" ]]; then
        cmd="tmux -f ${TMUX_CONFIG} attach -t $attach_name"
    else
        cmd="tmux -f ${TMUX_CONFIG} new"
    fi
    eval $cmd
}

main
