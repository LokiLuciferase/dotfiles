#!/usr/bin/env zsh

function rsync {
    ## make rsync respect .rsyncignore
    RSYNC="$(whence -p rsync)"
    IGNORE_FILES=( ${HOME}/.rsyncignore ./.rsyncignore )
    EXCLUDE_FROM=""
    for f in ${IGNORE_FILES[@]}; do
        if [[ -e $f ]]; then
            EXCLUDE_FROM="$EXCLUDE_FROM --exclude-from=$f"
        fi
    done
    CMD="$RSYNC $EXCLUDE_FROM $@"
    /bin/bash -c "$CMD"
}

## misc convenience functions ##
function ytdl {
    youtube-dl "$1" -x --audio-format mp3 --audio-quality 9
}

function ytdl-vid {
    youtube-dl -f 'bestvideo[height>=720]+bestaudio/best' -ciw -o "%(upload_date)s_%(title)s.%(ext)s" -v --add-metadata $1
}

function ytdl-stream {
    youtube-dl -f 'best' -o - "$1" | vlc -
}

function asciinema-upload {
    # Workaround for uploading to asciinema on ubuntu-focal
    curl -v -u $USER:$(cat ~/.config/asciinema/install-id) https://asciinema.org/api/asciicasts -F asciicast=@$1
}

function spip {
    # Safe pip: refuse to install stuff into the base conda environment.
    CONDA_PREFIX=${CONDA_PREFIX:-'null'}
    CURRENV=$(basename ${CONDA_PREFIX})
    if [[ "$CURRENV" == "miniconda3" && "$VIRTUAL_ENV" == "" ]]; then
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

function sleeptimer {
    # suspend machine after $1 minutes.
    MINS="${1:-60}"
    echo "Will suspend machine after ${MINS} mins. Ctrl+C to abort this."
    SECS=$(($MINS * 60))
    sleep "$SECS" && systemctl suspend -i
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
    tmux new-session \; split-window -h \; attach-session -c $PWD
}

function vsplit {
    tmux new-session \; split-window -v \; attach-session -c $PWD
}

function svimsh {
    ## run spacevim with a true terminal window at bottom
    WD=$(dirname "$@") || WD="$PWD"
    tmux new-session \; attach-session -c "$WD" \; split-window -v -p 20 \; select-pane -t 1 \; send-keys svim Space "$@" Enter
}

function qsplit {
    # start four-way split tmux session
    [[ "$1" != "" ]] && SESSNAME="$1" || SESSNAME="qsplit"
    tmux new-session -s "$SESSNAME" \; split-window -h \; split-window -v \; select-pane -t 1 \; split-window -v \; select-pane -t 1 \; attach-session -c $PWD
}

function hexsplit {
    # start six-way split tmux session
    # maximize window if possible, makes no sense else
    [[ "$1" != "" ]] && SESSNAME="$1" || SESSNAME="hexsplit"
    maximize || true
    tmux new-session -s "$SESSNAME" \; split-window -h -p 66 \; split-window -h -p 50 \; select-pane -t 1 \; split-window -v \; select-pane -t 3 \; split-window -v \; select-pane -t 5 \; split-window -v \; select-pane -t 1 \; attach-session -c $PWD
}

function vhexsplit {
    # start vertical six-way split tmux session
    # maximize window if possible, makes no sense else
    [[ "$1" != "" ]] && SESSNAME="$1" || SESSNAME="vhexsplit"
    maximize || true
    tmux new-session -s "$SESSNAME" \; split-window -v -p 66 \; split-window -v -p 50 \; select-pane -t 1 \; split-window -h \; select-pane -t 3 \; split-window -h \; select-pane -t 5 \; split-window -h \; select-pane -t 1 \; attach-session -c $PWD
}

function pdot {
    # pull newest changes to dotfiles
    pushd ${HOME}/.dotfiles || return 0
    git pull
    popd
}

function pshell {
    # pull newest changes to shell
    pushd ${HOME}/.oh-my-zsh/custom || return 0
    for plugin in plugins/*/ themes/*/; do
        if [ -d "$plugin/.git" ]; then
            git -C "$plugin" pull
        fi
    done
    popd
}

function pall {
    # pull all changes of git-dependent software
    pdot
    pshell
    pushd ${HOME}/.SpaceVim || return 0
    git pull
    popd
}
