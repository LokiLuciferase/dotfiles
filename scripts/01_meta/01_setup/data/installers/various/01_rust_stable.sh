#!/usr/bin/env bash
set -euo pipefail

check-deps() {
    if ! command -v curl &>/dev/null; then
        echo "curl is required to install rust"
        exit 1
    fi
}

install() {
    export XDG_CONFIG_DIR="${HOME}/.config"
    export XDG_DATA_DIR="${HOME}/.local/share"
    export XDG_CACHE_DIR="${HOME}/.cache"
    export CARGO_HOME="${XDG_DATA_DIR}/cargo"
    export RUSTUP_HOME="${XDG_DATA_DIR}/rustup"
    curl https://sh.rustup.rs -sSf | sh -s -- -y --no-modify-path
}

main() {
    check-deps
    install
}

main
