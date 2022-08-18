#!/usr/bin/env bash
set -euo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DOCKER_BIN=$(which podman &> /dev/null && echo podman || echo docker)

run_tests() {
    ${DOCKER_BIN} build -f "${DIR}/tests/Dockerfile.ubuntu" -t dotfiles.ubuntu ~/.dotfiles
    ${DOCKER_BIN} build --build-arg ALLOW_SUDO=false -f "${DIR}/tests/Dockerfile.nosudo" -t dotfiles.nosudo ~/.dotfiles
    ${DOCKER_BIN} build --build-arg INSTALL_DESKTOP=true -f "${DIR}/tests/Dockerfile.ubuntu" -t dotfiles.desktop ~/.dotfiles
    ${DOCKER_BIN} build -f "${DIR}/tests/Dockerfile.fedora" -t dotfiles.fedora ~/.dotfiles
    ${DOCKER_BIN} build -f "${DIR}/tests/Dockerfile.archlinux" -t dotfiles.archlinux ~/.dotfiles
}

run_tests
