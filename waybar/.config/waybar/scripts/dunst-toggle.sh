#!/usr/bin/env bash
set -euo pipefail

statusfile="${XDG_RUNTIME_DIR}/dunst-is-paused"

write-status() {
    dunstctl is-paused > "$statusfile"
}

toggle-status() {
    dunstctl set-paused toggle
    write-status
}

get-status() {
    if [ ! -f "${statusfile}" ]; then
        write-status
    fi

    if [ $(echo -n $(cat "$statusfile")) == "true" ]; then
        echo "paused"
    else
        echo "active"
    fi
}

get-json() {
    local status
    status=$(get-status)
    echo -n "{\"text\": \"${status}\", \"alt\": \"$status\", \"class\": \"$status\", \"percentage\": 0}"
}

main() {
    if [ $1 == "query" ]; then
        get-json
    elif [ $1 == "toggle" ]; then
        toggle-status
    else
        echo "Invalid input"
        exit 1
    fi
}

main $@
