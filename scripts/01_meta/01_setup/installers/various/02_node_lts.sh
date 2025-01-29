#!/usr/bin/env bash
set -euo pipefail

WANTED_MAJOR_VERSION=22

check-deps() {
    if ! command -v curl &>/dev/null; then
        echo "curl is required to install nodejs"
        exit 1
    fi
}

ensure_nvm_present(){
    if [ ! -d "${HOME}/.local/share/nvm" ]; then
        unalias nvm yarn npx npm node &> /dev/null || true
        export NVM_DIR="${HOME}/.local/share/nvm"
        mkdir -p "${NVM_DIR}"
        pushd "${NVM_DIR}"
        curl -sL https://github.com/nvm-sh/nvm/archive/master.tar.gz | tar xz && mv */* .
        popd
    fi
}

install() {
    export NVM_DIR="${HOME}/.local/share/nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install 18
    nvm alias default 18
    nvm use 18
}

main() {
    check-deps
    ensure_nvm_present
    install
}

main
