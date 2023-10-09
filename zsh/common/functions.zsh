#!/usr/bin/env zsh


conda-init() {
    # locate conda installation
    local conda_basedir
    if [ -n "$1" ]; then
        conda_basedir="$1"
    elif [ -d "${HOME}/miniconda3" ]; then
        conda_basedir="${HOME}/miniconda3"
    elif [ -d "${HOME}/.local/share/miniconda3" ]; then
        conda_basedir="${HOME}/.local/share/miniconda3"
    else
        echo "No conda installation dir found and none passed."
        return 1
    fi
    # initialize conda environment
    unalias conda &> /dev/null || true
    unalias mamba &> /dev/null || true
    unalias ipython &> /dev/null || true
    unalias pip &> /dev/null || true
    unalias pip3 &> /dev/null || true
    __conda_setup="$("${conda_basedir}/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "${conda_basedir}/etc/profile.d/conda.sh" ]; then
            . "${conda_basedir}/etc/profile.d/conda.sh"
        fi
    fi
    unset __conda_setup
}

conda-lazy-init() {
    # lazy init conda only when relevant commands are called
    local lazy_conda_cmds=( 'conda' 'mamba' 'ipython' 'pip' 'pip3' )
    for lazy_conda_alias in $lazy_conda_cmds; do
        alias $lazy_conda_alias="conda-init && \\$lazy_conda_alias"
    done
}

## misc convenience functions ##
ytdl-mp3() {
    yt-dlp "$1" \
        -x \
        --audio-format mp3 \
        --audio-quality 0 \
        --continue \
        --ignore-errors \
        --extractor-args youtubetab:skip=authcheck \
        --no-overwrites \
        --verbose \
        --embed-metadata \
        --output '%(title)s.%(ext)s' \
        $1
}

ytdl-vid() {
    yt-dlp \
        --continue \
        --ignore-errors \
        --extractor-args youtubetab:skip=authcheck \
        --no-overwrites \
        --verbose \
        --convert-subs srt \
        --sub-langs 'en.*,de' \
        --embed-subs \
        --embed-metadata \
        --embed-info-json \
        --embed-chapters \
        --embed-thumbnail \
        --sponsorblock-mark all \
        --remux-video mkv \
        --output '%(upload_date)s_%(channel)s_-_%(title)s.%(ext)s' \
        $1
}

ytdl-stream() {
    yt-dlp -f b -o - "$1" | mpv -
}

ytdl-cast() {
    # Cast the downloaded video to chromecast
    lolcatt "$1"
}

say() {
    # read aloud arguments
    echo "${@}" | gtts-cli - | mpv - &> /dev/null
}

read-aloud() {
    # read aloud contents of file
    cat "$1" | gtts-cli - | mpv - &> /dev/null
}

pip() {
    # Safe pip: refuse to install stuff into the base conda environment.
    CONDA_PREFIX=${CONDA_PREFIX:-'null'}
    local CURRENV=$(basename ${CONDA_PREFIX})
    local PIP="$(whence -p pip)"
    if [[ "$CURRENV" == "miniconda3" && "$VIRTUAL_ENV" == "" ]]; then
        echo "Cowardly refusing to mess up base conda environment."
    else
        $PIP "$@"
    fi
}

ps-nxf() {
    # extract relevant nextflow call from ps output
    ps aux | grep nextflo[w] | grep jav[a] | sed -E 's/^([^ ]+)\s+([[:digit:]]+) .* nextflow.cli.Launcher (.*)/\1 \2 nextflow \3/'
}

bgrun() {
    # run application without blocking CLI
    nohup "$@" &> /dev/null &
    disown
}

google() {
    # google search the given terms
    [[ "$BROWSER" == "" ]] && echo '$BROWSER variable unset.' 1>&2 && return 1
    QUERY=${@// /%20}
    bgrun ${BROWSER} http://www.google.com/search?q="$QUERY"
}

sleeptimer() {
    # suspend machine after $1 minutes.
    MINS="${1:-60}"
    echo "Will suspend machine after ${MINS} mins. Ctrl+C to abort this."
    SECS=$(($MINS * 60))
    sleep "$SECS" && systemctl suspend -i
}

ff(){
    # fuzzy find files and emit selection to command line
    local found=$(fzf $@)
    [ ! -z "$found" ] && print -z "\"$found\""
}

lo(){
    # libreoffice detached
    bgrun libreoffice "$@"
}

icat() {
    # print image(s) to terminal
    # requires: img2sixel and sixel-enabled terminal
    local default_term_dims=(600 400)
    for img in "$@"; do
        local term_dims=( $(xwininfo -id $WINDOWID 2> /dev/null | grep "Width\|Height" | grep -v xwininfo | tr -s '\n' ' ' | cut -f3,5 -d' ') )
        [ "${#term_dims[@]}" -ne 2 ] && term_dims=( $default_term_dims )
        local img_dims=( $(identify -format "%w %h" "$img") )
        local maxwidth=${term_dims[1]}
        local maxheight=$((${term_dims[2]} - 50))  # subtract some pixels for the prompt
        if [ "$maxwidth" -lt "$maxheight" ]; then
            [ "${img_dims[1]}" -gt "$maxwidth" ] && width=$maxwidth || width=${img_dims[1]}
            height=auto
        else
            [ "${img_dims[2]}" -gt "$maxheight" ] && height=$maxheight || height=${img_dims[2]}
            width=auto
        fi
        img2sixel -w $width -h $height -E fast "$img"
    done
}

ssha() {
    # attach to unnamed, unattached tmux session or create new
    ssh "$1" -t '~/.dotfiles/scripts/10_utils/tmux-attach-or-create.sh'
}

docker-run-tool() {
    # run a tool inside a docker container, mounting the current directory and setting UID/GID
    local container="${1:-}"
    local full_cmd="docker run -u $(id -u):$(id -g) -w $PWD -v $PWD:$PWD --rm ${container} ${@:2}"
    eval "$full_cmd"
}

docker-run-interactive() {
    # open a docker container in an interactive shell
    local container="${1:-}"
    local full_cmd="docker run -u $(id -u):$(id -g) -w $PWD -v $PWD:$PWD --rm -it ${container} ${@:2}"
    eval "$full_cmd"
}

recursive-glacier-restore() {
    if [ $1 =~ s3://.* ]; then
        local arr=($(python3 -c "print('$1'.split('/')[2], '$1'.split('/', 3)[-1])"))
        local bucket=${arr[1]}
        local key=${arr[2]}
    else
        local bucket=$1
        local key=$2
    fi
    cecho Y "Restoring all objects under s3://${bucket}/${key}..."
    aws s3 ls s3://${bucket}/${key}/ --recursive | awk '{print substr($0, index($0, $4))}' | xargs -t -I %%% aws s3api restore-object --restore-request '{"Days":1, "GlacierJobParameters":{"Tier":"Expedited"}}' --bucket ${bucket} --key "%%%"
}

get-latest-github-release() {
    if [[ "$#" -eq 0 || "$#" -gt 2 ]]; then
        echo "Usage: get-latest-github-release <user>/<repo> <artifact_regex>" && return 1
    fi
    local repo="$1"
    local file_pat="${2:-''}"
    local files=($(curl -SsL "https://api.github.com/repos/${repo}/releases/latest" | jq ".assets[] | select(.name|test(\"${file_pat}\")) | .browser_download_url" -r))
    for f in ${files[@]}; do
        echo "Downloading ${f}..."
        curl -SL $f -o $(basename $f)
    done
}

cecho(){
    # print the given string in the given color to the given destination
    # cecho [echo flags] <color> <message>
    local R="\033[0;31m"
    local G="\033[0;32m"
    local Y="\033[0;33m"
    local B="\033[0;34m"
    local M="\033[0;35m"
    local C="\033[0;36m"
    local NC="\033[0m"
    local COLOR_ARG="${@:(-2):1}"
    local MSG_ARG="${@:(-1):1}"
    local ECHO_ARGS=("${@:1:${#}-2}")
    eval COLOR="\${$COLOR_ARG}"
    echo -e ${ECHO_ARGS[@]} "${COLOR}${MSG_ARG}${NC}"
}

nagme() {
    # nag me to do something
    local message="$1"
    local interval="${2:-5m}"
    local urgency="${3:-critical}"
    local ctr=0
    while true; do
        sleep ${interval}
        notify-send -u "$urgency" "$message"
        ctr=$((ctr+1))
        echo "Nagged re '$message' at $(date) ($ctr times already)"
    done
}

git-nvimdiff() {
    # git diff using neovim diffview
    nvimdiff -c "DiffviewOpen ${1:-}"
}

get-newest() {
    # gets the newest directory entry by modification time
    DIR="${1:-.}"
    newest=$(ls -lt "$DIR" | awk '{if ($5 != 0) print $9}' | grep -v '^$' | head -1)
    [[ "$newest" != "" ]] && echo "${DIR}/${newest}"
}

for-each-dir() {
    # perform the given command in each subdirectory in parallel
    set +o monitor
    local sep_len=$(tput cols)
    for d in */; do
        pushd -q $d || continue
        local dir_str="   ${d}   "
        local dir_str_color="$(cecho G "$dir_str")"
        local dir_str_len=${#dir_str}
        local header_left_hashes_len=$(( (sep_len / 2) - (dir_str_len / 2) ))
        local header_right_hashes_len=$(( sep_len - (header_left_hashes_len + dir_str_len) ))
        local extra_header_hashes_left=$(for i in {1..${header_left_hashes_len}}; do echo -n "#"; done)
        local extra_header_hashes_right=$(for i in {1..${header_right_hashes_len}}; do echo -n "#"; done)
        local full_header="${extra_header_hashes_left}${dir_str_color}${extra_header_hashes_right}"
        echo "\n${full_header}\n$($@ 2>&1)" &
        popd -q
    done
    wait
    set -o monitor
}

for-each-dir-in() {
    local parent_dir="$1"
    shift
    pushd -q $parent_dir || return
    for-each-dir $@
    popd -q
}

rsync2() {
    ## make rsync respect .rsyncignore
    RSYNC="$(whence -p rsync)"
    IGNORE_FILES=( ${HOME}/.rsyncignore ./.rsyncignore )
    EXCLUDE_FROM=""
    for f in ${IGNORE_FILES[@]}; do
        if [[ -e $f ]]; then
            EXCLUDE_FROM="$EXCLUDE_FROM --exclude-from=$f"
        fi
    done
    CMD="$RSYNC -PrazuL $EXCLUDE_FROM $@"
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
        bgrun $name
    done
}

select-i3-layout() {
    LAYOUT_NAME="$1"
    WORKSPACE="$2"
    OUTPUT=$(i3-msg -t get_workspaces | jq -r ".[] | select(.num=="$WORKSPACE") | .output")
    GEOM=$(xrandr -q | grep ' connected' | sed 's/primary //g' | grep $OUTPUT | cut -f3 -d' ' | cut -f1 -d'+' | tr 'x' ' ')
    if [ "$GEOM" = "1080 1920" ] || [ "$GEOM" = "1200 1920" ]; then
        ALIGN=vert
        RESOL=FHD
    elif [ "$GEOM" = "1920 1080" ] || [ "$GEOM" = "1920 1200" ]; then
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
        return 1
    fi
    LAYOUT_FILE="$HOME/.config/i3/layouts/$RESOL/$ALIGN/$LAYOUT_NAME.json"
    if [ -f "$LAYOUT_FILE" ]; then
        apply-i3-layout $LAYOUT_FILE $WORKSPACE
    else
        >&2 echo "Layout not found: $LAYOUT_FILE"
        return 1
    fi
}

scrotsel(){
    # scrot select from tmp file
    FN=$(mktemp -u).png
    scrot --select -oe 'xclip -selection clipboard -t image/png -i $f' $FN && rm -f $FN
}

disable-screen-timeout() {
    # disable screen timeout
    xset s off
    xset -dpms
    xset s noblank
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
    _tmux_ctx "split-window -h -p 66 \; split-window -h -p 50 \; select-pane -t 1 \; split-window -v \; select-pane -t 3 \; split-window -v \; select-pane -t 5 \; split-window -v \; select-pane -t 1" hexsplit $1
}

vhexsplit() {
    # start vertical six-way split tmux session
    _tmux_ctx "split-window -v -p 66 \; split-window -v -p 50 \; select-pane -t 1 \; split-window -h \; select-pane -t 3 \; split-window -h \; select-pane -t 5 \; split-window -h \; select-pane -t 1" vhexsplit $1
}

term-replace() {
    # replace current terminal with given one. Per default,
    # replace with a terminal window with full transparency.
    local alacritty_flags="${1:-window.opacity=0.0}"
    local command_to_call="${2:-zsh}"
    local cmd="bgrun alacritty -o ${alacritty_flags} -e ${command_to_call}"
    eval "$cmd" && exit
}

## Package management ##
_apt_upgrade_all() {
    sudo apt update \
        && sudo apt upgrade --yes \
        && sudo apt autoremove --yes
}

_flatpak_upgrade_all_if_exist() {
    which flatpak &> /dev/null || return 0
    flatpak update -y
    flatpak remove --unused --delete-data -y
}

## Git automation ##
_pdot() {
    # pull newest changes to dotfiles
    pushd ${HOME}/.dotfiles || return 0
    git pull
    git submodule update --depth=1
    popd
}

_pshell() {
    # pull newest changes to shell
    pushd "${ZSH}/custom" || return 0
    for plugin in plugins/*/ themes/*/; do
        if [ -d "$plugin/.git" ]; then
            git -C "$plugin" pull &
        fi
    done
    wait
    popd
}

_pnvimplug() {
    # pull updates for neovim
    nvim --headless -c 'call RunUpdates() | quitall' || return 0
}

_migrate-dotfiles(){
    echo ''
    bash ~/.dotfiles/scripts/01_meta/02_migrations/run_migrations.sh
}

_backup_shell_hist(){
    local shells
    local target_backup_dir="${HOME}/.local/share/dotfiles/shell_hist_backups"
    mkdir -p "${target_backup_dir}"
    shells=( bash zsh )
    for sh in "${shells[@]}"; do
        cp "${HOME}/.cache/${sh}/history" "${target_backup_dir}/${sh}_history" || true
    done
}

pall() {
    # pull all changes of git-dependent software, and apply dotfile migrations
    _pdot
    _pshell
    _pnvimplug
    _migrate-dotfiles
    _backup_shell_hist
}

update-git-repo() {
    if [[ ! -d .git ]]; then
        echo "Not a git repo."
        return
    fi
    git fetch --all \
        && git pull \
        && git submodule update --recursive \
        && git sweep \
        || return
    local branch=$(git branch --show-current)
    local color
    if [[ "$branch" == "master" ]] || [[ "$branch" == "main" ]]; then
        color=G
    else
        color=Y
    fi
    cecho $color "On branch $branch."
}

update-git-repos() {
    # update all git repos in the current directory, including submodules, and remove fully merged branches
    for-each-dir eval 'update-git-repo'
}
