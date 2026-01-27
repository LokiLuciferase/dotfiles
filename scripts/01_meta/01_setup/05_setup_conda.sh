#!/usr/bin/env bash
set -euo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DATADIR="${DIR}/data"
CONDA_PATH="${CONDA_PATH:-${HOME}/.local/share/miniconda3}"

ensure_tools_present() {
    # Only attempt to run this script if the relevant tools are available.
    local required_tools=( curl )
    local missed_tools=()
    for tool in "${required_tools[@]}"; do
        which "$tool" &> /dev/null || missed_tools+=("$tool")
    done
    [ "${#missed_tools[@]}" -ne 0 ] && echo "Aborting, essential tools are missing: [${missed_tools[*]}]" && exit 1
    return 0
}

ensure_not_done() {
    # Only attempt to run this script if the target conda directory does not already exist.
    [ -d "${CONDA_PATH}" ] && echo "Aborting, conda directory already present at ${CONDA_PATH}" && exit 1
    [ -f "${DIR}/.conda_done" ] && echo "Aborting, conda already installed" && exit 1
    return 0
}

install_conda() {
    # install miniforge3
    local repo_path="https://github.com/conda-forge/miniforge/releases/latest/download"
    if [[ "$(uname -m)" = "x86_64" ]]; then
        local dlpath="${repo_path}/Miniforge3-Linux-x86_64.sh"
    elif [[ "$(uname -m)" = "arm64" ]] || [[ "$(uname -m)" = 'aarch64' ]]; then
        local dlpath="${repo_path}/Miniforge3-Linux-aarch64.sh"
    else
        echo "Unknown architecture: $(uname -m)"
        exit 1
    fi
    mkdir -p anaconda_install && cd anaconda_install
    curl -sSL "${dlpath}" -o conda.sh
    mkdir -p "$(dirname "${CONDA_PATH}")"
    bash conda.sh -b -p "${CONDA_PATH}"
    cd .. && rm -rf anaconda_install
    export PATH="$CONDA_PATH/bin:$PATH"

    conda install -c conda-forge mamba --yes
    conda create -n dev --yes
    mamba env update -n dev -f "${DATADIR}/conda.yaml"
    pip install pyOpenSSL --upgrade  # work around for https://github.com/conda/conda/issues/12234
    [ "${DOTFILES_TESTING:-false}" = 'false' ] && mamba clean -a --yes
    conda init bash
    return 0
}

mark_done() {
    touch "${DIR}/.conda_done"
    return 0
}

main() {
    ensure_tools_present
    ensure_not_done
    install_conda
    mark_done
}


main
