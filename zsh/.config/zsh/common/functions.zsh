#!/usr/bin/env zsh

## these commands cause the loading of nvm or conda on-demand
export __DOTFILES_LAZY_NVM_CMDS=( 'nvm' 'node' 'yarn' 'npm' 'npx' 'cdk' 'vercel' )
export __DOTFILES_LAZY_CONDA_CMDS=( 'conda' 'mamba' 'ipython' 'pip' 'pip3' )


nvm-unalias() {
    # remove nvm aliases
    for lazy_nvm_alias in $__DOTFILES_LAZY_NVM_CMDS; do
        unalias $lazy_nvm_alias &> /dev/null || true
    done
    unset __DOTFILES_LAZY_NVM_CMDS
}

conda-unalias() {
    # remove conda aliases
    for lazy_conda_alias in $__DOTFILES_LAZY_CONDA_CMDS; do
        unalias $lazy_conda_alias &> /dev/null || true
    done
    unset __DOTFILES_LAZY_CONDA_CMDS
}

nvm-init() {
    # locate nvm
    local nvm_basedir
    if [ -n "$1" ]; then
        nvm_basedir="$1"
    elif [ -d "${HOME}/.local/share/nvm" ]; then
        nvm_basedir="${HOME}/.local/share/nvm"
    elif [ -d "${XDG_DATA_HOME}/nvm" ]; then
        nvm_basedir="${XDG_DATA_HOME}/nvm"
    else
        echo "No nvm installation dir found and none passed." >&2
        return 1
    fi

    nvm-unalias

    # init nvm
    . "${nvm_basedir}/nvm.sh"
    nvm use default
}

conda-init() {
    # locate conda installation
    local conda_basedir
    if [ -n "$1" ]; then
        conda_basedir="$1"
    elif [ -d "${HOME}/.local/share/miniconda3" ]; then
        conda_basedir="${HOME}/.local/share/miniconda3"
    elif [ -d "${XDG_DATA_HOME}/miniconda3" ]; then
        conda_basedir="${XDG_DATA_HOME}/miniconda3"
    elif [ -d "${HOME}/miniconda3" ]; then
        conda_basedir="${HOME}/miniconda3"
    else
        echo "No conda installation dir found and none passed." >&2
        return 1
    fi

    conda-unalias

    # init conda
    source "${conda_basedir}/bin/activate"
    echo "Now using conda @ ${CONDA_PREFIX} ($(python --version))"
}

nvm-lazy-init() {
    # lazy init nvm only when relevant commands are called
    for lazy_nvm_alias in $__DOTFILES_LAZY_NVM_CMDS; do
        alias $lazy_nvm_alias="nvm-init && \\$lazy_nvm_alias"
    done
}

conda-lazy-init() {
    # lazy init conda only when relevant commands are called
    for lazy_conda_alias in $__DOTFILES_LAZY_CONDA_CMDS; do
        alias $lazy_conda_alias="conda-init && \\$lazy_conda_alias"
    done
}

## misc convenience functions ##
require-command() {
    # check for required commands
    local commands
    local any_missing=false
    commands=( "$@" )
    for command in "${commands[@]}"; do
        if ! command -v $command &> /dev/null; then
            echo "Required command '$command' not found." >&2
            any_missing=true
        fi
    done
    if $any_missing; then
        return 1
    fi
}

ytdl-mp3() {
    require-command yt-dlp || return 1
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
    require-command yt-dlp || return 1
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
    require-command yt-dlp mpv || return 1
    yt-dlp -f b -o - "$1" | mpv -
}

ytdl-cast() {
    # Cast the downloaded video to chromecast
    require-command lolcatt yt-dlp || return 1
    lolcatt "$1"
}

say() {
    # read aloud arguments
    require-command gtts-cli mpv || return 1
    local in="$@"
    [ -z "$in" ] && read -r in
    echo "$in" | gtts-cli - | mpv - &> /dev/null
}

read-aloud() {
    # read aloud contents of file
    require-command gtts-cli mpv || return 1
    local in="$1"
    [ -z "$in" ] && read -r in
    cat "$in" | gtts-cli - | mpv - &> /dev/null
}

pip() {
    # Safe pip: refuse to install stuff into the base conda environment.
    CONDA_PREFIX=${CONDA_PREFIX:-'null'}
    local CURRENV=$(basename ${CONDA_PREFIX})
    local PIP="$(whence -p pip)"
    if [[ "$CURRENV" == "miniconda3" && "$VIRTUAL_ENV" == "" ]]; then
        echo "Cowardly refusing to mess up base conda environment." >&2
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
    nohup ${SHELL:-zsh} -c "$@" &> /dev/null &
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
    require-command fzf || return 1
    local found=$(fzf $@)
    [ ! -z "$found" ] && print -z "\"$found\""
}

rrgr() {
    # recursive ripgrep search and replace, interactively
    # usage: rrgr <search> <replace> <sep>
    local search="$1"
    local replace="$2"
    local sep=${3:-/}
    local matching_files=$(rg --files-with-matches "$search")
    [ -z "$matching_files" ] && echo "No files found matching '$search'." && return
    local maxlen=$(echo "$matching_files" | wc -L)
    local boundary=$(printf "%${maxlen}s" | tr ' ' '#')
    local sed_cmd="sed -i 's${sep}${search}${sep}${replace}${sep}g'"
    echo "Found $(echo "$matching_files" | wc -l) files matching '$search':"
    echo "$boundary"
    echo "$matching_files"
    echo "$boundary"
    echo -n "Proceed with replacing '$search' with '$replace' in all files (${sed_cmd})? [y/N] "
    read -k 1 proceed
    [ "$proceed" != "y" ] && return
    echo ""
    while read -r file; do
        cmd="${sed_cmd} '$file'"
        echo $cmd
        eval $cmd
    done <<< "$matching_files"
}

icat() {
    # print image(s) to terminal
    require-command img2sixel identify || return 1
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
    ssh "$@" -t '~/.dotfiles/scripts/10_utils/tmux-attach-or-create.sh'
}

today() {
    # print today's date in the given format
    local format="${1:-%Y%m%d}"
    date +$format
}

now() {
    # print current datetime
    date --rfc-3339=seconds
}

docker-run-tool() {
    # run a tool inside a docker container, mounting the current directory and setting UID/GID
    local container="${1:-}"
    local full_cmd="docker run -u $(id -u):$(id -g) -w '$PWD' -v '$PWD':'$PWD' --rm ${container} ${@:2}"
    eval "$full_cmd"
}

docker-run-interactive() {
    # open a docker container in an interactive shell
    local container="${1:-}"
    local full_cmd="docker run -u $(id -u):$(id -g) -w $PWD -v $PWD:$PWD --rm -it ${container} ${@:2}"
    eval "$full_cmd"
}

recursive-glacier-restore() {
    require-command aws || return 1
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
    require-command jq curl || return 1
    if [[ "$#" -eq 0 || "$#" -gt 2 ]]; then
        echo "Usage: get-latest-github-release <user>/<repo> <artifact_regex>" >&2 && return 1
    fi
    local repo="$1"
    local file_pat="${2:-''}"
    local files=($(curl -SsL "https://api.github.com/repos/${repo}/releases/latest" | jq ".assets[] | select(.name|test(\"${file_pat}\")) | .browser_download_url" -r))
    for f in ${files[@]}; do
        echo "Downloading ${f}..."
        curl -SL $f -o $(basename $f)
    done
}

aws-assume-role() {
    # assume role and set environment variables
    require-command jq aws || return 1
    if [ -z "$1" ]; then
        echo "Usage: aws-assume-role <role-arn>" >&2
        return 1
    fi
    local output
    output=$(aws sts assume-role --role-arn $1 --role-session-name assuming-direct-control || return 1)
    if [ $? -ne 0 ]; then
        echo "Assuming role failed." >&2
        return 1
    fi
    export AWS_ACCESS_KEY_ID=$(echo "$output" | jq -r .Credentials.AccessKeyId)
    export AWS_SECRET_ACCESS_KEY=$(echo "$output" | jq -r .Credentials.SecretAccessKey)
    export AWS_SESSION_TOKEN=$(echo "$output" | jq -r .Credentials.SessionToken)
    export PREV_AWS_PROFILE=${AWS_PROFILE}
    unset AWS_PROFILE || true
    echo "Assumed role $1 and unset AWS_PROFILE (was ${PREV_AWS_PROFILE})."
}

aws-unassume-role() {
    # unset assumed role environment variables
    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY
    unset AWS_SESSION_TOKEN
    export AWS_PROFILE=${PREV_AWS_PROFILE}
    echo "Unset assumed role and restored AWS_PROFILE to ${AWS_PROFILE}."
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
    require-command notify-send || return 1
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
    require-command nvim || return 1
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
    require-command rsync || return 1
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
    require-command i3-msg || return 1
    LAYOUT="$1"
    WORKSPACE="${2:-1}"
    IFS=$'\n' NAMES=($(grep -o '"name": .*' $LAYOUT | cut -f2- -d' ' | sed -e 's/"\(.*\)",/\1/g' | sed 's/\\//g'))
    i3-msg "workspace number $WORKSPACE; append_layout $LAYOUT"
    for name in $NAMES; do
        echo -n "Executing '$name': "
        bgrun $name
    done
}

select-i3-layout() {
    require-command i3-msg xrandr || return 1
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
    elif [ "$GEOM" = "1600 2560" ]; then
        ALIGN=vert
        RESOL=WQXGA
    elif [ "$GEOM" = "2560 1600" ]; then
        ALIGN=horz
        RESOL=WQXGA
    elif [ "$GEOM" = "1440 2560" ]; then
        ALIGN=vert
        RESOL=QHD
    elif [ "$GEOM" = "2560 1440" ]; then
        ALIGN=horz
        RESOL=QHD
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

select-i3-layouts(){
    # run multiple sets of layouts
    for lo_scr in $@; do
        local layout
        local screen
        layout=$(echo $lo_scr | cut -f1 -d':')
        screen=$(echo $lo_scr | cut -f2 -d':')
        i3-msg "workspace number $screen" &> /dev/null
        if [ -n "$layout" ]; then
            select-i3-layout $layout $screen
        fi
        sleep 1
    done
}

scrotsel(){
    # scrot select from tmp file
    require-command scrot xclip || return 1
    FN=$(mktemp -u).png
    scrot --select -oe 'xclip -selection clipboard -t image/png -i $f' $FN && rm -f $FN
}

disable-screen-timeout() {
    # disable screen timeout
    require-command xset || return 1
    xset s off
    xset -dpms
    xset s noblank
}

galias() {
    # grep git aliases
        alias | grep "='git" | grep -F "$*"
}

## Tmux automation ##
_tmux_ctx() {
    # run tmux command either in new session if not running
    # or in existing one.
    require-command tmux || return 1
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

send-tg-message() {
    # send a message to telegram
    require-command curl || return 1
    if [ ! -v TG_CHAT_ID ]; then
        echo "TG_CHAT_ID not set." >&2
        return 1
    fi
    if [ ! -v TG_BOT_TOKEN ]; then
        echo "TG_BOT_TOKEN not set." >&2
        return 1
    fi
    local in="$1"
    [ -z "$in" ] && read -r in
    curl -s -X POST https://api.telegram.org/bot${TG_BOT_TOKEN}/sendMessage -d chat_id=${TG_CHAT_ID} -d text="$in" &> /dev/null
}

## Package management ##
_apt_upgrade_all() {
    require-command apt || return 1
    sudo apt update \
        && sudo apt upgrade --yes \
        && sudo apt autoremove --yes
}

_pacman_upgrade_all() {
    require-command pacman || return 1
    sudo pacman -Syu --noconfirm
}

_package_manager_upgrade_all() {
    if which apt &> /dev/null; then
        _apt_upgrade_all
    elif which pacman &> /dev/null; then
        _pacman_upgrade_all
    else
        return 1
    fi
}

_flatpak_upgrade_all_if_exist() {
    require-command flatpak || return 1
    which flatpak &> /dev/null || return 0
    flatpak update -y
    flatpak remove --unused --delete-data -y
}

## Git automation ##
_pdot() {
    # pull newest changes to dotfiles
    require-command git || return 1
    pushd ${HOME}/.dotfiles || return 0
    git pull
    git submodule update --depth=1
    popd
}

_pshell() {
    # pull newest changes to shell
    require-command git || return 1
    set +o monitor
    pushd "${ZSH}/custom" || return 0
    for plugin in plugins/*/ themes/*/; do
        if [ -d "$plugin/.git" ]; then
            git -C "$plugin" pull &
        fi
    done
    wait
    set -o monitor
    popd
}

_pnvimupdates() {
    # pull updates for neovim
    require-command nvim || return 1
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
    echo -n "Pulling dotfile changes..."
    _pdot &> /dev/null
    cecho G "done."
    echo -n "Pulling shell changes..."
    _pshell &> /dev/null
    cecho G "done."
    echo -n "Pulling neovim updates..."
    _pnvimupdates &> /dev/null
    cecho G "done."
    echo -n "Backing up shell history..."
    _backup_shell_hist &> /dev/null
    cecho G "done."
    echo -n "Running any pending dotfile migrations..."
    _migrate-dotfiles
}

update-git-repo() {
    # update a git repo, including submodules, remove fully merged branches, and check for untracked files
    require-command git || return 1
    if [[ ! -d .git ]]; then
        echo "Not a git repo."
        return
    fi
    git fetch --all | grep -v "Fetching origin" || true \
        && git pull || true \
        && git sweep \
        || return
    local branch
    local exists_remote
    local branch_color
    local exists_remote_color
    local untracked_files
    branch=$(git branch --show-current)
    exists_remote=$(git branch --list --remote origin/${branch} | wc -l)
    untracked_files=$(git status --ignore-submodules --porcelain | wc -l)
    if [[ "$branch" == "master" ]] || [[ "$branch" == "main" ]]; then
        branch_color=G
    else
        branch_color=Y
    fi
    if [[ "$exists_remote" -eq 0 ]]; then
        [[ "$branch" =~ "master|main" ]] || cecho Y "Branch does not exist on remote."
    fi
    cecho $branch_color "On branch $branch."
    if [[ "$untracked_files" -gt 0 ]]; then
        cecho Y "Untracked files present."
    fi
    if ! git diff --ignore-submodules --quiet HEAD; then
        cecho R "Repo is dirty."
    elif ! git diff --quiet HEAD; then
        cecho Y "Repo has submodules with changes."
    fi
}

update-git-repos() {
    # update all git repos in the current directory, including submodules, and remove fully merged branches
    for-each-dir eval 'update-git-repo'
}
