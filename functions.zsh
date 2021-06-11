#!/usr/bin/env zsh

rsync() {
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
ytdl-mp3() {
    youtube-dl "$1" -x --audio-format mp3 --audio-quality 9
}

ytdl-vid() {
    youtube-dl -f 'bestvideo[height>=720]+bestaudio/best' -ciw -o "%(upload_date)s_%(title)s.%(ext)s" -v --add-metadata $1
}

ytdl-stream() {
    youtube-dl -f 'best' -o - "$1" | vlc -
}

asciinema-upload() {
    # Workaround for uploading to asciinema on ubuntu-focal
    curl -v -u $USER:$(cat ~/.config/asciinema/install-id) https://asciinema.org/api/asciicasts -F asciicast=@$1
}

spip() {
    # Safe pip: refuse to install stuff into the base conda environment.
    CONDA_PREFIX=${CONDA_PREFIX:-'null'}
    CURRENV=$(basename ${CONDA_PREFIX})
    if [[ "$CURRENV" == "miniconda3" && "$VIRTUAL_ENV" == "" ]]; then
        echo "Cowardly refusing to mess up base conda environment."
    else
        \pip "$@"
    fi
}

desktop-run() {
    # run desktop application without blocking CLI
    nohup "$@" &> /dev/null &
    disown
}

google() {
    # google search the given terms
    [[ "$BROWSER" == "" ]] && echo '$BROWSER variable unset.' 1>&2 && return 1
    QUERY=${@// /%20}
    desktop-run ${BROWSER} http://www.google.com/search?q="$QUERY"
}

sleeptimer() {
    # suspend machine after $1 minutes.
    MINS="${1:-60}"
    echo "Will suspend machine after ${MINS} mins. Ctrl+C to abort this."
    SECS=$(($MINS * 60))
    sleep "$SECS" && systemctl suspend -i
}

## Terminal window management
maximize() {
    [[ "$1" != "" ]] && WINDOWNAME="$1" || WINDOWNAME=":ACTIVE:"
    wmctrl -r ${WINDOWNAME} -b add,maximized_horz && wmctrl -r ${WINDOWNAME} -b add,maximized_vert
}

minimize() {
    [[ "$1" != "" ]] && WINDOWNAME="$1" || WINDOWNAME=":ACTIVE:"
    wmctrl -r ${WINDOWNAME} -b remove,maximized_horz && wmctrl -r ${WINDOWNAME} -b remove,maximized_vert
}

## Tmux automation ##
hsplit() {
    tmux new-session \; split-window -h \; attach-session -c $PWD
}

vsplit() {
    tmux new-session \; split-window -v \; attach-session -c $PWD
}

svimsh() {
    ## run spacevim with a true terminal window at bottom
    WD=$(dirname "$@") || WD="$PWD"
    tmux new-session \; attach-session -c "$WD" \; split-window -v -p 20 \; select-pane -t 1 \; send-keys svim Space "$@" Enter
}

qsplit() {
    # start four-way split tmux session
    [[ "$1" != "" ]] && SESSNAME="$1" || SESSNAME="qsplit"
    tmux new-session -s "$SESSNAME" \; split-window -h \; split-window -v \; select-pane -t 1 \; split-window -v \; select-pane -t 1 \; attach-session -c $PWD
}

hexsplit() {
    # start six-way split tmux session
    # maximize window if possible, makes no sense else
    [[ "$1" != "" ]] && SESSNAME="$1" || SESSNAME="hexsplit"
    maximize || true
    tmux new-session -s "$SESSNAME" \; split-window -h -p 66 \; split-window -h -p 50 \; select-pane -t 1 \; split-window -v \; select-pane -t 3 \; split-window -v \; select-pane -t 5 \; split-window -v \; select-pane -t 1 \; attach-session -c $PWD
}

vhexsplit() {
    # start vertical six-way split tmux session
    # maximize window if possible, makes no sense else
    [[ "$1" != "" ]] && SESSNAME="$1" || SESSNAME="vhexsplit"
    maximize || true
    tmux new-session -s "$SESSNAME" \; split-window -v -p 66 \; split-window -v -p 50 \; select-pane -t 1 \; split-window -h \; select-pane -t 3 \; split-window -h \; select-pane -t 5 \; split-window -h \; select-pane -t 1 \; attach-session -c $PWD
}

_pdot() {
    # pull newest changes to dotfiles
    pushd ${HOME}/.dotfiles || return 0
    git pull
    popd
}

_pshell() {
    # pull newest changes to shell
    pushd ${HOME}/.oh-my-zsh/custom || return 0
    for plugin in plugins/*/ themes/*/; do
        if [ -d "$plugin/.git" ]; then
            git -C "$plugin" pull
        fi
    done
    popd
}

_pspacevim() {
    # pull newest changes of SpaceVim
    pushd ${HOME}/.SpaceVim || return 0
    git pull
    popd
}

pall() {
    # pull all changes of git-dependent software
    _pdot
    _pshell
    _pspacevim
}

for-each() {
    # perform the given command in each subdirectory
    SEP=$(printf %$(tput cols)s | tr " " "#")
    for d in */; do
        echo "\n### $d ###"
        pushd $d || continue
        $@
        echo "${SEP}"
        popd -q
    done
}
