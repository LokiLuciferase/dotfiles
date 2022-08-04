#!/usr/bin/env zsh


conda-init() {
    # initialize conda environment
    local conda_basedir=${1:-${HOME}/miniconda3}
    __conda_setup="$("${conda_basedir}/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "${conda_basedir}/etc/profile.d/conda.sh" ]; then
            . "${conda_basedir}/etc/profile.d/conda.sh"
        else
            export PATH="${conda_basedir}/bin:$PATH"
        fi
    fi
    unset __conda_setup
}

## misc convenience functions ##
ytdl-mp3() {
    yt-dlp "$1" -x --audio-format mp3 --audio-quality 9
}

ytdl-vid() {
    yt-dlp -f 'bestvideo[height>=720]+bestaudio/best' -ciw -o "%(upload_date)s_%(title)s.%(ext)s" -v --add-metadata $1
}

ytdl-stream() {
    yt-dlp -f b -o - "$1" | mpv -
}

ytdl-cast() {
    # Cast the downloaded video to chromecast
    yt-dlp -f b -o - "$1" | castnow --quiet -
}

asciinema-upload() {
    # Workaround for uploading to asciinema on ubuntu-focal
    curl -v -u $USER:$(cat ~/.config/asciinema/install-id) https://asciinema.org/api/asciicasts -F asciicast=@$1
}

say() {
    # read aloud arguments
    echo "${@}" | gtts-cli - | mpv - &> /dev/null
}

read-aloud() {
    # read aloud contents of file
    cat "$1" | gtts-cli - | mpv - &> /dev/null
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

transpose() {
    local sep="${2:-\t}"
    awk '
    {
        for (i=1; i<=NF; i++)  {
            a[NR,i] = $i
        }
    }
    NF>p { p = NF }
    END {
        for(j=1; j<=p; j++) {
            str=a[1,j]
            for(i=2; i<=NR; i++){
                str=str" "a[i,j];
            }
            print str
        }
    }' FS="$sep" "$1"
}

docker-interactive() {
    # open a docker container in an interactive shell
    local container="${1:-}"
    local cmd="${2:-/bin/bash}"
    local extra_docker_args=("${@:3}")
    local full_cmd="docker run -u $(id -u):$(id -g) -e ARES_DB_URL -v /tmp/mysql.sock:/tmp/mysql.sock -w $PWD -v $PWD:$PWD ${extra_docker_args} -it ${container} ${cmd}"
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
    while true; do
        notify-send -u "$urgency" "$message"
        sleep ${interval}
    done
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

swap-i3-screens() {
    # swap the screens of currently active workspaces
    i3-msg "mark add 'swapper'"
    local display_config=($(i3-msg -t get_outputs | jq -r '.[]|select(.active == true) |"\(.current_workspace)"'))
    for ROW in "${display_config[@]}"
    do
    read -r CONFIG <<< "${ROW}"
        i3-msg -- workspace --no-auto-back-and-forth "${CONFIG}"
        i3-msg -- move workspace to output right
    done
    i3-msg '[con_mark="swapper"] focus'
    i3-msg unmark 'swapper'
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

svimsh() {
    ## run spacevim with a true terminal window at bottom
    WD=$(dirname "$@") || WD="$PWD"
    tmux new-session \; attach-session -c "$WD" \; split-window -v -p 20 \; select-pane -t 1 \; send-keys svim Space "$@" Enter
}

term-replace() {
    # replace current terminal with given one. Per default,
    # replace with a terminal window with full transparency.
    local alacritty_flags="${1:--o background_opacity=0.0}"
    local cmd="desktop-run alacritty ${alacritty_flags}"
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
    flatpak remove --unused
}

## Git automation ##
_pdot() {
    # pull newest changes to dotfiles
    pushd ${HOME}/.dotfiles || return 0
    git pull
    popd
}

_pdata() {
    # pull newest changes to data
    pushd ${HOME}/.datafiles || return 0
    git pull
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
    # pull updates for vim-plug
    nvim --headless -c PlugUpgrade -c PlugUpdate -c qa || return 0
}

#_pspacevim() {
    ## pull newest changes of SpaceVim
    #pushd ${HOME}/.SpaceVim || return 0
    #git checkout master
    #git pull
    ## git checkout $(git describe --tags --abbrev=0)
    #git checkout v1.8.0
    #popd
#}

migrate-dotfiles(){
    echo ''
    bash ~/.dotfiles/scripts/01_meta/run_migrations.sh
}

pall() {
    # pull all changes of git-dependent software, and apply dotfile migrations
    _pdot
    _pdata
    _pshell
    #_pspacevim
    _pnvimplug
    migrate-dotfiles
}

