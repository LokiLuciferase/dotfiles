#!/usr/bin/env zsh

## misc convenience functions ##
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

function desktop-run {
    # run desktop application without blocking CLI
    nohup "$@" &> /dev/null &
    disown
}

function google {
    # google search the given terms
    [[ "$BROWSER" == "" ]] && echo '$BROWSER variable unset.' 1>&2 && return 1
    QUERY=${@// /%20}
    desktop-run ${BROWSER} http://www.google.com/search?q="$QUERY"
}

## Terminal window management
function maximize {
    [[ "$1" != "" ]] && WINDOWNAME="$1" || WINDOWNAME=":ACTIVE:"
    wmctrl -r ${WINDOWNAME} -b add,maximized_horz && wmctrl -r ${WINDOWNAME} -b add,maximized_vert
}

function minimize {
    [[ "$1" != "" ]] && WINDOWNAME="$1" || WINDOWNAME=":ACTIVE:"
    wmctrl -r ${WINDOWNAME} -b remove,maximized_horz && wmctrl -r ${WINDOWNAME} -b remove,maximized_vert
}

## Tmux automation ##
function hsplit {
    tmux new-session \; split-window -h
}

function vsplit {
    tmux new-session \; split-window -v
}

function qsplit {
    # start four-way split tmux session
    [[ "$1" != "" ]] && SESSNAME="$1" || SESSNAME="qsplit"
    tmux new-session \; split-window -h \; split-window -v \; select-pane -t 1 \; split-window -v \; select-pane -t 1 \; attach
}

function hexsplit {
    # start six-way split tmux session
    # maximize window if possible, makes no sense else
    [[ "$1" != "" ]] && SESSNAME="$1" || SESSNAME="hexsplit"
    maximize || true
    tmux new-session -s "$SESSNAME"\; split-window -h -p 66 \; split-window -h -p 50 \; select-pane -t 1 \; split-window -v \; select-pane -t 3 \; split-window -v \; select-pane -t 5 \; split-window -v \; select-pane -t 1 \; attach
}

function pdot {
    # pull newest changes to dotfiles
    cd ${HOME}/.dotfiles || exit 0
    git pull -v
    popd
}

