#!/usr/bin/env bash
set -euo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
REPO_DIR="$( cd "${DIR}/../../../.." >/dev/null 2>&1 && pwd )"
DOCKER_BIN=$(which podman &> /dev/null && echo podman || echo docker)
export BUILDKIT_PROGRESS=plain

run_tests() {
    ${DOCKER_BIN} build -f "${DIR}/Dockerfile.ubuntu" -t dotfiles.ubuntu-headless "${REPO_DIR}"
    ${DOCKER_BIN} build -f "${DIR}/Dockerfile.nosudo" -t dotfiles.ubuntu-nosudo "${REPO_DIR}"
    ${DOCKER_BIN} build --build-arg DOTFILES_MACHINE_TYPE=gui -f "${DIR}/Dockerfile.ubuntu" -t dotfiles.ubuntu-gui "${REPO_DIR}"

    if [[ "${DOTFILES_TEST_ALL_DISTROS:-false}" = true ]]; then
        ${DOCKER_BIN} build -f "${DIR}/Dockerfile.fedora" -t dotfiles.fedora "${REPO_DIR}"
        ${DOCKER_BIN} build -f "${DIR}/Dockerfile.archlinux" -t dotfiles.archlinux "${REPO_DIR}"
        ${DOCKER_BIN} build -f "${DIR}/Dockerfile.alpine" -t dotfiles.alpine "${REPO_DIR}"
    fi
}

run_tests
