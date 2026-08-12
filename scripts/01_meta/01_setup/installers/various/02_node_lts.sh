#!/usr/bin/env bash
set -euo pipefail

WANTED_MAJOR_VERSION=24

check-deps() {
    if ! command -v curl &>/dev/null; then
        echo "curl is required to install nodejs"
        exit 1
    fi
    if ! command -v unzip &>/dev/null; then
        echo "unzip is required to install nodejs"
        exit 1
    fi
}

ensure_fnm_present(){
    local fnm_path="${HOME}/.local/share/fnm"
    if [ ! -d "${fnm_path}" ]; then
        unalias nvm yarn npx npm node &> /dev/null || true
        curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell --install-dir "${HOME}/.local/share/fnm"
        if [ -d "${fnm_path}" ]; then
          export PATH="${fnm_path}:$PATH"
          eval "$(fnm env --shell bash)"
        fi
    fi
}

install() {
    fnm install $WANTED_MAJOR_VERSION
    fnm alias default $WANTED_MAJOR_VERSION
    fnm use $WANTED_MAJOR_VERSION
}

main() {
    check-deps
    ensure_fnm_present
    install
}

main
