#!/usr/bin/env bash
set -euo pipefail

check-deps() {
    if ! command -v curl &>/dev/null; then
        echo "curl is required to install golang"
        exit 1
    fi
}

get_arch() {
    local arch
    arch=$(uname -m)
    case ${arch} in
        x86_64) echo "amd64";;
        aarch64) echo "arm64";;
        *) echo "unsupported architecture: ${arch}" >&2; exit 1;;
    esac
}

get-url() {
    local os
    local arch
    local fpat
    local fname
    os='linux'
    arch=$(get_arch)
    fpat="go.*.${os}-${arch}.tar.gz"
    fname=$(curl https://go.dev/dl/?mode=json | grep -o "$fpat" | head -n 1 | tr -d '\r\n' )
    echo "https://golang.org/dl/${fname}"
}

do-install() {
    local url
    url=$(get-url)
    rm -rf ~/.local/share/go
    curl -L "${url}" | tar -C ~/.local/share -xzf -
}

write-env-file() {
    local env_file_path="$HOME/.local/share/go/env"
    cat << EOF > "${env_file_path}"
#!/bin/sh
case ":\${PATH}:" in
    *:"$HOME/.local/share/go/bin":*)
        ;;
    *)
        export PATH="$HOME/.local/share/go/bin:\$PATH"
        ;;
esac
EOF
}

main() {
    check-deps
    do-install
    write-env-file
}

main
