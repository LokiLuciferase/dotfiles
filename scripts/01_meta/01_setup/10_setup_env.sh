#!/usr/bin/env bash
set -euo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

ensure_tools_present() {
    # Only attempt to run this script if the relevant tools are available.
    local required_tools=( git zsh curl python3 )
    local missed_tools=()
    for tool in "${required_tools[@]}"; do
        which "$tool" &> /dev/null || missed_tools+=("$tool")
    done
    [ "${#missed_tools[@]}" -ne 0 ] && echo "Aborting, essential tools are missing: [${missed_tools[*]}]" && exit 1
    return 0
}

ensure_not_done() {
    # Do not run this script if it was run before
    [ -f "${DIR}/.env_done" ] && echo "Aborting, script was already run (${DIR}/.env_done exists)" && exit 1
    return 0
}

install_omz_stuff() {
    # Install oh-my-zsh and any plugins
    echo "Installing ZSH environment..."
    export CHSH=no
    export RUNZSH=no
    export ZSH="$HOME/.config/oh-my-zsh"
    export ZSH_CUSTOM="$HOME/.config/oh-my-zsh/custom"
    sh -c "$(curl -sL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
    return 0
}

install_vimplug() {
    # Install vim-plug plugin manager
    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    return 0
}

setup_migrations() {
    # Copy over existing migrations and setup cache dirs for shell histories
    echo "Setting up dotfile migrations..."
    mkdir -p "${HOME}"/.cache/{zsh,bash}
    mkdir -p "${HOME}"/.local/share/dotfiles
    cp -r "${HOME}/.dotfiles/scripts/01_meta/02_migrations/migrations" "${HOME}/.local/share/dotfiles/done_migrations"
    return 0
}

do_stow() {
    # Introduce dotfiles
    echo "Introducing dotfiles..."
    "${DIR}/tools/stow.py" install all -v -s
    return 0
}

mark_done() {
    # Ensure this script is not run multiple times by accident
    touch "$DIR"/.env_done
    return 0
}

main() {
    ensure_tools_present
    ensure_not_done
    install_omz_stuff
    install_vimplug
    setup_migrations
    do_stow
    mark_done
    return 0
}


main
