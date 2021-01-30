#!/usr/bin/env zsh

function ytdl {
    youtube-dl "$1" -x --audio-format mp3 --audio-quality 9
}

function asciinema-upload {
    # Workaround for uploading to asciinema on ubuntu-focal
    curl -v -u $USER:$(cat ~/.config/asciinema/install-id) https://asciinema.org/api/asciicasts -F asciicast=@$1
}

function spip {
    # Safe pip: refuse to install stuff into the base conda environment.
    CONDA_PREFIX=${CONDA_PREFIX:-'null'}
    CURRENV=$(basename ${CONDA_PREFIX})
    if [[ "$CURRENV" == "miniconda3" ]]; then
        echo "Cowardly refusing to mess up base conda environment."
    else
        \pip "$@"
    fi
}

function qsplit {
    # start four-way split tmux session
    tmux new-session \; split-window -h \; split-window -v \; select-pane -t 1 \; split-window -v \; select-pane -t 1 \; attach
}

function pdot {
    # pull newest changes to dotfiles
    cd ${HOME}/.dotfiles || exit 0
    git pull -v
    popd
}

