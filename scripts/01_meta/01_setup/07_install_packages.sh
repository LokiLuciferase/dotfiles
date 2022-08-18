#!/usr/bin/env bash
set -uo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DATADIR="${DIR}/data"
SYSTEM_PACKAGE_MANAGER="${SYSTEM_PACKAGE_MANAGER:-apt-get}"
ALLOW_SUDO="${ALLOW_SUDO:-true}"
ADD_REPOS="${ADD_REPOS:-false}"
INSTALL_VARIOUS="${INSTALL_VARIOUS:-false}"
INSTALL_DESKTOP="${INSTALL_DESKTOP:-false}"
INSTALL_WORK="${INSTALL_WORK:-false}"


msg() {
echo "#################################################"
echo "$@"
echo "#################################################"
}

ensure_not_done() {
    # Do not run this script if it was run before
    [ -f "${DIR}/.packages_done" ] && echo "Aborting, script was already run (${DIR}/.packages_done exists)" && exit 1
    return 0
}

have_sudo() {
    # Check if we have sudo privileges, and ask for password if required.
    local sudo_prompt
    [[ "$ALLOW_SUDO" != true ]] && return 1
    [[ "$(id -u)" -eq 0 ]] && return 0
    sudo_prompt="$(sudo -nv 2>&1)"
    [[ $? -eq 0 ]] && return 0
    [[ -n "${sudo_prompt}" ]] && sudo true && return 0
    return 1
}

get_sudo_prefix() {
    [[ "$(id -u)" -eq 0 ]] && echo "" || echo "sudo"
    return 0
}

maybe_update_system_package_manager() {
    have_sudo || return 0
    if [[ "${SYSTEM_PACKAGE_MANAGER}" = 'apt-get' ]]; then
        export DEBIAN_FRONTEND=noninteractive
        $(get_sudo_prefix) apt-get update
    fi
    return 0
}

maybe_add_package_manager_repos() {
    if [[ -n "$(which flatpak)" ]]; then
        msg "Attempting to add repositories for flatpak."
        while read -r line; do
            msg "Adding repo: $line"
            flatpak remote-add --if-not-exists $line
        done < "${DIR}/data/repos/flatpak.txt"
    fi

    have_sudo || return 0
    if [[ "${SYSTEM_PACKAGE_MANAGER}" = 'apt-get' ]]; then
        msg "Attempting to add repositories for apt-get."
        $(get_sudo_prefix) apt-get install -y software-properties-common
        while read -r line; do
            msg "Adding repo: $line"
            $(get_sudo_prefix) add-apt-repository "$line" --yes
        done < "${DIR}/data/repos/apt-get.txt"
    fi
    return 0
}

install_with_package_manager() {
    local pkg="$1"
    local mngr="$2"
    msg "Attempting to install '${pkg}' using ${mngr}..."
    if [[ "${mngr}" = 'apt-get' ]]; then
        have_sudo || return 1
        export DEBIAN_FRONTEND=noninteractive
        $(get_sudo_prefix) apt-get install --yes "$pkg"
    elif [[ "${mngr}" = 'dnf' ]]; then
        have_sudo || return 1
        $(get_sudo_prefix) dnf -y install "$pkg"
    elif [[ "${mngr}" = 'pacman' ]]; then
        have_sudo || return 1
        $(get_sudo_prefix) pacman -S --noconfirm "$pkg"
    elif [[ "${mngr}" = 'flatpak' ]]; then
        flatpak install --assumeyes $(echo $pkg | tr '@' ' ')
    elif [[ "${mngr}" = 'conda' ]]; then
        local conda_bin
        conda_bin=$(which mamba &> /dev/null && echo 'mamba' || echo 'conda')
        $conda_bin install -c conda-forge --yes "$pkg"
    elif [[ "${mngr}" = 'pip' ]]; then
        pip install "${pkg}"
    else
        msg "Unknown package manager: ${PACKAGE_MANAGER}"
        false
    fi
    return $?
}

cascading_install() {
    local pkg="$1"
    local mngr="$2"
    local fail_on_unsatisfiable="$3"

    # First check if package is callable, if so do not attempt to install
    which "$pkg" && return 0

    # Initially try the suggested package manager
    install_with_package_manager "$pkg" "$mngr"
    RV=$?
    # If not successful, retry with conda
    if [[ "$RV" -ne 0 ]] && [[ "${mngr}" != conda ]]; then
        install_with_package_manager "${pkg}" conda
        RV=$?
    fi
    if [[ "$RV" -ne 0 ]]; then
        msg "Unsatisfiable package: $pkg"
        [[ "$fail_on_unsatisfiable" = true ]] && return 1
    fi
    return 0
}

get_package_list() {
    # Usage: get_package_list <fraction> <package manager>
    local package_list_file="${DATADIR}/packages.tsv"
    cols=($(head -1 ${package_list_file}))
    idx=""
    for ci in "${!cols[@]}"; do
        [[ "${cols[$ci]}" == "$2" ]] && idx=$ci
    done
    [[ -z "$idx" ]] && msg "Invalid package manager chosen: $2" && return 1
    pkgs=("$(sed 1d ${package_list_file} | grep "$1" | cut -f2- | cut -f"${idx}" | tr '\n' ' ')")
    echo "$pkgs"
    return 0
}

install_all_from_package_list() {
    local fraction="$1"
    local package_manager="$2"
    local fail_on_unsatisfiable="${3:-false}"
    local package_list
    package_list=($(get_package_list "${fraction}" "${package_manager}"))
    for pkg in "${package_list[@]}"; do
        cascading_install "$pkg" "${package_manager}" "${fail_on_unsatisfiable}" || return 1
    done
    return 0
}

install_all_from_fraction() {
    local fraction="$1"
    local fail_on_unsatisfiable="${2:-false}"
    for package_manager in "${SYSTEM_PACKAGE_MANAGER}" flatpak pip; do
        install_all_from_package_list "${fraction}" "${package_manager}" "${fail_on_unsatisfiable}" || return 1
    done
    return 0
}

ensure_nvim_installed() {
    # If we couldn't install neovim, install from appimage
    which nvim && return 0
    local nvim_latest
    nvim_latest='https://github.com/neovim/neovim/releases/download/latest/nvim.appimage'
    mkdir -p ~/.local/bin
    curl -SsL -o ~/.local/bin/nvim "$nvim_latest"
    chmod u+x ~/.local/bin/nvim
    return 0
}

mark_done() {
    touch "${DIR}/.packages_done"
    return 0
}

main() {
    ensure_not_done
    maybe_update_system_package_manager
    install_all_from_fraction minimal true || exit 1
    install_all_from_fraction env true || exit 1
    [[ "${INSTALL_VARIOUS}" = true ]] && install_all_from_fraction various
    [[ "${ADD_REPOS}" = true ]] && maybe_add_package_manager_repos
    install_all_from_fraction vim
    ensure_nvim_installed
    [[ "${INSTALL_DESKTOP}" = true ]] && install_all_from_fraction desktop
    [[ "${INSTALL_WORK}" = true ]] && install_all_from_fraction work
    m
   return 0
}


main
