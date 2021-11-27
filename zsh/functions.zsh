#!/usr/bin/env zsh

## misc convenience functions ##
YTDL_BIN="${YTDL_BIN:-yt-dlp}"
ytdl-mp3() {
    $YTDL_BIN "$1" -x --audio-format mp3 --audio-quality 9
}

ytdl-vid() {
    $YTDL_BIN -f 'bestvideo[height>=720]+bestaudio/best' -ciw -o "%(upload_date)s_%(title)s.%(ext)s" -v --add-metadata $1
}

ytdl-stream() {
    $YTDL_BIN -f 'best' -o - "$1" | vlc -
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

cpcd() {
    # perform the given cp operation; then cd into the parent directory of the target.
    cp $@
    if [ -d "${@[-1]}" ]; then
        cd "${@[-1]}"
    else
        cd $(dirname "${@[-1]}")
    fi
}

get-newest() {
    # gets the newest directory entry by modification time
    DIR="${1:-.}"
    newest=$(ls -lt "$DIR" | awk '{if ($5 != 0) print $9}' | grep -v '^$' | head -1)
    [[ "$newest" != "" ]] && echo "${DIR}/${newest}"
}

for-each() {
    # perform the given command in each subdirectory
    SEP=$(printf %$(tput cols)s | tr " " "#")
    for d in */; do
        echo "\n### $d ###"
        pushd -q $d || continue
        $@
        echo "${SEP}"
        popd -q
    done
}

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

## i3 session management
apply-i3-layout() {
    # apply i3 layout and start all to-be-slurped tools (identified by name)
    LAYOUT="$1"
    WORKSPACE="${2:-1}"
    NAMES=($(grep -o '"name": .*' $LAYOUT | cut -f2 -d' ' | sed -e 's/"\(.*\)",/\1/g' | sed 's/\\//g' | tr '\n' ' '))
    i3-msg "workspace $WORKSPACE; append_layout $LAYOUT"
    for name in ${NAMES[@]}; do
        echo -n "Executing $name: "
        desktop-run $name
    done
}

select-i3-layout() {
    LAYOUT_NAME="$1"
    WORKSPACE="$2"
    OUTPUT=$(i3-msg -t get_workspaces | jq -r ".[] | select(.num=="$WORKSPACE") | .output")
    GEOM=$(xrandr -q | grep ' connected' | sed 's/primary //g' | grep $OUTPUT | cut -f3 -d' ' | cut -f1 -d'+' | tr 'x' ' ')
    if [ "$GEOM" = "1080 1920" ]; then
        ALIGN=vert
        RESOL=FHD
    elif [ "$GEOM" = "1920 1080" ]; then
        ALIGN=horz
        RESOL=FHD
    elif [ "$GEOM" = "2160 3840" ]; then
        ALIGN=vert
        RESOL=4K
    elif [ "$GEOM" = "3840 2160" ]; then
        ALIGN=horz
        RESOL=4K
    else
        ALIGN=unknown
        RESOL=unknown
        >&2 echo "Unknown resolution: $GEOM"
        exit 1
    fi
    LAYOUT_FILE="$HOME/.config/i3/layouts/$RESOL/$ALIGN/$LAYOUT_NAME.json"
    if [ -f "$LAYOUT_FILE" ]; then
        apply-i3-layout $LAYOUT_FILE $WORKSPACE
    else
        >&2 echo "Layout not found: $LAYOUT_FILE"
        exit 1
    fi
}

scrotsel(){
    # scrot select from tmp file
    FN=$(mktemp -u).png
    scrot --select -oe 'xclip -selection clipboard -t image/png -i $f' $FN && rm -f $FN
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
_tmux_ctx() {
    # run tmux command either in new session if not running
    # or in existing one.
    [[ "$3" != "" ]] && SESSNAME="$3" || SESSNAME="$2"
    if [[ -n "$TMUX" ]]; then
        PREF=""
        SUFF=""
    else
        PREF="new-session -s $SESSNAME \;"
        SUFF="\; attach-session -c $PWD"
    fi
    CMD="tmux $PREF $1 $SUFF"
    eval $CMD
}

hsplit() {
    _tmux_ctx "split-window -h" hsplit $1
}

vsplit() {
    _tmux_ctx "split-window -v" vsplit $1
}

qsplit() {
    _tmux_ctx "split-window -h \; split-window -v \; select-pane -t 1 \; split-window -v \; select-pane -t 1" qsplit $1
}

hexsplit() {
    # start six-way split tmux session
    # maximize window if possible, makes no sense else
    maximize || true
    _tmux_ctx "split-window -h -p 66 \; split-window -h -p 50 \; select-pane -t 1 \; split-window -v \; select-pane -t 3 \; split-window -v \; select-pane -t 5 \; split-window -v \; select-pane -t 1" hexsplit $1
}

vhexsplit() {
    # start vertical six-way split tmux session
    # maximize window if possible, makes no sense else
    maximize || true
    _tmux_ctx "split-window -v -p 66 \; split-window -v -p 50 \; select-pane -t 1 \; split-window -h \; select-pane -t 3 \; split-window -h \; select-pane -t 5 \; split-window -h \; select-pane -t 1" vhexsplit $1
}

svimsh() {
    ## run spacevim with a true terminal window at bottom
    WD=$(dirname "$@") || WD="$PWD"
    tmux new-session \; attach-session -c "$WD" \; split-window -v -p 20 \; select-pane -t 1 \; send-keys svim Space "$@" Enter
}

## Git automation ##
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
	git checkout master
	git pull
	git checkout $(git describe --tags --abbrev=0)
    popd
}

pall() {
    # pull all changes of git-dependent software
    _pdot
    _pshell
    _pspacevim
}

