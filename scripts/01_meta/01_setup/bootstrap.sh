#!/usr/bin/env bash
set -euo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export PATH="${HOME}/.local/bin:${PATH}"

DOTFILES_MACHINE_TYPE="${DOTFILES_MACHINE_TYPE:-headless}"
DOTFILES_INSTALL_WORK="${DOTFILES_INSTALL_WORK:-false}"
DOTFILES_INSTALL_WAYLAND="${DOTFILES_INSTALL_WAYLAND:-false}"
DOTFILES_INSTALL_HEAVY_DEV="${DOTFILES_INSTALL_HEAVY_DEV:-false}"
DOTFILES_INSTALL_VARIOUS="${DOTFILES_INSTALL_VARIOUS:-false}"
DOTFILES_ALLOW_SUDO="${DOTFILES_ALLOW_SUDO:-true}"
DOTFILES_TESTING="${DOTFILES_TESTING:-false}"
DOTFILES_NODE_LTS_MAJOR="${DOTFILES_NODE_LTS_MAJOR:-24}"

usage() {
    cat <<'EOF'
Usage: bootstrap.sh [options] [ansible-playbook options]

Bootstrap this dotfiles repository on the current machine, using Ansible.

Machine type:
  --headless/--gui: Select the machine type. (Default: headless)

Feature flags:
  --work/--no-work: Install work-specific packages. (Default: false)
  --wayland/--no-wayland: Install Wayland-specific GUI packages. (Default: false)
  --heavy-dev/--no-heavy-dev: Install heavier language/dev tooling. (Default: false)
  --various/--no-various: Install miscellaneous optional tools. (Default: false)
  --sudo/--no-sudo: Allow system package installation with sudo. (Default: true)

Other:
  -h, --help             Show this help.

Useful Ansible options are forwarded, for example:
  --tags packages,toolchains
  --syntax-check

Environment overrides:
  DOTFILES_MACHINE_TYPE=headless|gui
  DOTFILES_INSTALL_WORK=true|false
  DOTFILES_INSTALL_WAYLAND=true|false
  DOTFILES_INSTALL_HEAVY_DEV=true|false
  DOTFILES_INSTALL_VARIOUS=true|false
  DOTFILES_ALLOW_SUDO=true|false
  DOTFILES_NODE_LTS_MAJOR=24
  DOTFILES_SYSTEM_PACKAGE_MANAGER=apt|dnf|pacman|apk

Examples:
  bootstrap.sh --headless --no-heavy-dev
  bootstrap.sh --gui --wayland --work
  bootstrap.sh --gui --no-heavy-dev --tags packages,toolchains
EOF
}

ANSIBLE_ARGS=()
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        --headless)
            DOTFILES_MACHINE_TYPE=headless
            ;;
        --gui)
            DOTFILES_MACHINE_TYPE=gui
            ;;
        --work)
            DOTFILES_INSTALL_WORK=true
            ;;
        --no-work)
            DOTFILES_INSTALL_WORK=false
            ;;
        --wayland)
            DOTFILES_INSTALL_WAYLAND=true
            ;;
        --no-wayland)
            DOTFILES_INSTALL_WAYLAND=false
            ;;
        --heavy-dev)
            DOTFILES_INSTALL_HEAVY_DEV=true
            ;;
        --no-heavy-dev)
            DOTFILES_INSTALL_HEAVY_DEV=false
            ;;
        --various)
            DOTFILES_INSTALL_VARIOUS=true
            ;;
        --no-various)
            DOTFILES_INSTALL_VARIOUS=false
            ;;
        --sudo)
            DOTFILES_ALLOW_SUDO=true
            ;;
        --no-sudo)
            DOTFILES_ALLOW_SUDO=false
            ;;
        *)
            ANSIBLE_ARGS+=("$1")
            ;;
    esac
    shift
done

sudo_prefix() {
    if [[ "$(id -u)" -eq 0 ]]; then
        return 0
    fi
    printf '%s\n' sudo
}

install_bootstrap_prereqs() {
    if command -v apt-get &> /dev/null; then
        local sudo_cmd
        sudo_cmd="$(sudo_prefix)"
        ${sudo_cmd} apt-get update
        ${sudo_cmd} apt-get install --yes git curl ca-certificates
    elif command -v dnf &> /dev/null; then
        local sudo_cmd
        sudo_cmd="$(sudo_prefix)"
        ${sudo_cmd} dnf install -y git curl ca-certificates
    elif command -v pacman &> /dev/null; then
        local sudo_cmd
        sudo_cmd="$(sudo_prefix)"
        ${sudo_cmd} pacman -Syu --noconfirm git curl ca-certificates
    elif command -v apk &> /dev/null; then
        local sudo_cmd
        sudo_cmd="$(sudo_prefix)"
        ${sudo_cmd} apk add git curl ca-certificates
    fi
}

install_uv_if_missing() {
    command -v uv &> /dev/null && return 0

    if ! command -v curl &> /dev/null; then
        if [[ "${DOTFILES_ALLOW_SUDO}" != true ]]; then
            echo "curl is missing and DOTFILES_ALLOW_SUDO=false; install curl or uv first." >&2
            return 1
        fi
        install_bootstrap_prereqs
    fi

    UV_NO_MODIFY_PATH=1 curl -LsSf https://astral.sh/uv/install.sh | sh
    command -v uv &> /dev/null && return 0
    echo "Unable to install uv automatically." >&2
    return 1
}

if ! command -v git &> /dev/null || ! command -v curl &> /dev/null; then
    if [[ "${DOTFILES_ALLOW_SUDO}" != true ]]; then
        echo "Missing bootstrap prerequisites and DOTFILES_ALLOW_SUDO=false; install git and curl first." >&2
        exit 1
    fi
    install_bootstrap_prereqs
fi

install_uv_if_missing

EXTRA_VARS=(
    -e "dotfiles_machine_type=${DOTFILES_MACHINE_TYPE}"
    -e "dotfiles_install_work=${DOTFILES_INSTALL_WORK}"
    -e "dotfiles_install_wayland=${DOTFILES_INSTALL_WAYLAND}"
    -e "dotfiles_install_heavy_dev=${DOTFILES_INSTALL_HEAVY_DEV}"
    -e "dotfiles_install_various=${DOTFILES_INSTALL_VARIOUS}"
    -e "dotfiles_allow_sudo=${DOTFILES_ALLOW_SUDO}"
    -e "dotfiles_testing=${DOTFILES_TESTING}"
    -e "dotfiles_node_lts_major=${DOTFILES_NODE_LTS_MAJOR}"
)

if [[ -n "${DOTFILES_SYSTEM_PACKAGE_MANAGER:-}" ]]; then
    EXTRA_VARS+=( -e "dotfiles_system_package_manager=${DOTFILES_SYSTEM_PACKAGE_MANAGER}" )
fi

uvx --from ansible-core ansible-playbook \
    -i localhost, \
    --connection local \
    "${DIR}/ansible/site.yml" \
    "${EXTRA_VARS[@]}" \
    "${ANSIBLE_ARGS[@]}"
