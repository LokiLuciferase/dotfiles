#!/usr/bin/env bash
set -uo pipefail
### User settable env variables controlling what to install
ALLOW_SUDO="${ALLOW_SUDO:-true}"
INSTALL_VARIOUS="${INSTALL_VARIOUS:-false}"
INSTALL_DESKTOP="${INSTALL_DESKTOP:-false}"
INSTALL_WORK="${INSTALL_WORK:-false}"
###

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DATADIR="${DIR}/data"
SYSTEM_PACKAGE_MANAGER="${SYSTEM_PACKAGE_MANAGER:-apt-get}"
TMPDIR="${TMPDIR:-/tmp}"
MSG_LOG="${MSG_LOG:-${TMPDIR}/dotfiles_install.log}"

export PIP_BREAK_SYSTEM_PACKAGES=1

if [[ "${INSTALL_DESKTOP}" = true ]] || [[ "${INSTALL_WORK}" = true ]]; then
    ADD_REPOS=true
else
    ADD_REPOS=false
fi


msg() {
echo "#################################################" >&2
echo "$@" |& tee -a "${MSG_LOG}" >&2
echo "#################################################" >&2
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
    if [[ -n "$(which flatpak)" ]] && [[ ! -f "${TMPDIR}/flatpak_repos_added" ]]; then
        msg "Attempting to add repositories for flatpak."
        while read -r line; do
            msg "Adding repo: $line"
            $(get_sudo_prefix) flatpak remote-add --if-not-exists $line
        done < "${DIR}/data/repos/flatpak.txt"
        touch "${TMPDIR}/flatpak_repos_added"
    fi

    have_sudo || return 0
    if [[ "${SYSTEM_PACKAGE_MANAGER}" = 'apt-get' ]] && [[ ! -f "${TMPDIR}/apt_repos_added" ]]; then
        msg "Attempting to add repositories for apt-get."
        $(get_sudo_prefix) apt-get install -y software-properties-common
        while read -r line; do
            msg "Adding repo: $line"
            $(get_sudo_prefix) add-apt-repository "$line" --yes
        done < "${DIR}/data/repos/ubuntu-ppa.txt"
        touch "${TMPDIR}/apt_repos_added"
    fi
    return 0
}

install_with_package_manager() {
    local pkg="$1"
    local mngr="$2"
    msg "Attempting to install '${pkg}' using ${mngr}..."
    if [[ "${mngr}" = 'apt-get' ]]; then
        have_sudo || return 1
        [[ "${ADD_REPOS}" = true ]] && maybe_add_package_manager_repos
        export DEBIAN_FRONTEND=noninteractive
        $(get_sudo_prefix) apt-get install --yes "$pkg"
    elif [[ "${mngr}" = 'dnf' ]]; then
        have_sudo || return 1
        $(get_sudo_prefix) dnf -y install "$pkg"
    elif [[ "${mngr}" = 'pacman' ]]; then
        have_sudo || return 1
        $(get_sudo_prefix) pacman -S --noconfirm "$pkg"
    elif [[ "${mngr}" = 'apk' ]]; then
        have_sudo || return 1
        $(get_sudo_prefix) apk add "$pkg"
    elif [[ "${mngr}" = 'flatpak' ]]; then
        [[ "${ADD_REPOS}" = true ]] && maybe_add_package_manager_repos
        flatpak install --assumeyes $(echo $pkg | tr '@' ' ')
    elif [[ "${mngr}" = 'conda' ]]; then
        local conda_bin
        conda_bin=$(which mamba &> /dev/null && echo 'mamba' || echo 'conda')
        $conda_bin install -c conda-forge --yes "$pkg"
    elif [[ "${mngr}" = 'pip' ]]; then
        if [[ -f /usr/bin/pip ]]; then
            /usr/bin/pip install --user "${pkg}"
        elif [[ -s "$(which pip)" ]]; then
            echo "WARN: Using pip at $(which pip) to install ${pkg}" >&2
            $(which pip) install --user "${pkg}"
        fi
    elif [[ "${mngr}" = 'cargo' ]]; then
        local rootdir
        local sudoprefix
        local gitflag
        if have_sudo ; then
            rootdir="/usr/local"
            sudoprefix=$(get_sudo_prefix)
            [[ "$sudoprefix" != "" ]] && sudoprefix="$sudoprefix -E"
        else
            rootdir="${HOME}/.local"
            sudoprefix=''
        fi
        if [[ "${pkg}" =~ ^https ]]; then
            gitflag='--git'
        else
            gitflag=''
        fi
        ${sudoprefix} cargo +stable install ${gitflag} "${pkg}" --root "${rootdir}"
    else
        msg "Unknown package manager: ${mngr}"
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

install_all_from_installer_dir() {
    # Install various packages using install scripts
    local fraction="$1"
    local script_dir="${DIR}/installers/${fraction}"
    [[ ! -d "${script_dir}" ]] && return 0
    for script in "${script_dir}"/*.sh; do
        msg "Running installer script: ${fraction} - ${script}"
        bash "${script}" || true
    done
    return 0
}

install_all_from_fraction() {
    local fraction="$1"
    local fail_on_unsatisfiable="${2:-false}"
    install_all_from_installer_dir "${fraction}" || return 1
    install_all_from_package_list "${fraction}" "${SYSTEM_PACKAGE_MANAGER}" "${fail_on_unsatisfiable}" || return 1
    install_all_from_package_list "${fraction}" pip "${fail_on_unsatisfiable}" || return 1
    install_all_from_package_list "${fraction}" flatpak "${fail_on_unsatisfiable}" || return 1
    install_all_from_package_list "${fraction}" cargo "${fail_on_unsatisfiable}" || return 1
    return 0
}

ensure_nvim_installed() {
    # If we couldn't install neovim, install from appimage
    which nvim && return 0
    local nvim_latest
    nvim_latest='https://github.com/neovim/neovim/releases/latest/download/nvim.appimage'
    mkdir -p ~/.local/bin
    curl -SsL -o ~/.local/bin/nvim "$nvim_latest"
    chmod u+x ~/.local/bin/nvim
    # Check if we have FUSE support, else extract appimage
    if [[ -z "$(which fusermount)" ]]; then
        msg "FUSE not found. Extracting nvim.appimage..."
        cd ~/.local/bin
        ./nvim --appimage-extract
        rm ./nvim
        mv squashfs-root nvim.appimage
        ln -s nvim.appimage/AppRun nvim
    fi
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
    install_all_from_fraction vim
    ensure_nvim_installed
    [[ "${INSTALL_DESKTOP}" = true ]] && install_all_from_fraction desktop
    [[ "${INSTALL_WORK}" = true ]] && install_all_from_fraction work
   return 0
}


main
