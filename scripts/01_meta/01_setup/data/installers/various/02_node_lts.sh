#!/usr/bin/env bash
set -euo pipefail

WANTED_MAJOR_VERSION=17

check-deps() {
    if ! command -v curl &>/dev/null; then
        echo "curl is required to install nodejs"
        exit 1
    fi
}

get-arch(){
    local arch
    arch="$(uname -m)"
    case "${arch}" in
        x86_64)
            echo "x64"
            ;;
        aarch64)
            echo "arm64"
            ;;
        *)
            echo "Unsupported architecture: ${arch}"
            exit 1
            ;;
    esac
}

install() {
    local maj_dl_url full_dl_url
    maj_dl_url="https://nodejs.org/dist/latest-v${WANTED_MAJOR_VERSION}.x"
    archive_dl_url="$(curl -sL "${maj_dl_url}" | grep -oE "node-v${WANTED_MAJOR_VERSION}[^\"]+-linux-$(get-arch).tar.xz" | head -n 1)"
    full_dl_url="${maj_dl_url}/${archive_dl_url}"
    curl -sL "${full_dl_url}" | tar -xvJ --strip-components=1 -C "${HOME}/.local"
}

main() {
    check-deps
    install
}

main
