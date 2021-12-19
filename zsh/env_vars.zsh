# bookmarks support
if [ ! -z "$BASH" ]; then
    echo "Sourcing environment in bash. This may yield unexpected results."
fi

if [ -d "${HOME}/.local/share/bookmarks" ]; then
    export CDPATH=".:${HOME}/.local/share/bookmarks"
fi

export PATH=$HOME/.local/bin:/usr/games:$PATH
export EDITOR=nvim

# XDG Base Directory Specification
export XDG_CONFIG_HOME=$HOME/.config
export XDG_DATA_HOME=$HOME/.local/share
export XDG_CACHE_HOME=$HOME/.cache

# retarget misc tools to XDG
export SSB_HOME="$XDG_DATA_HOME"/zoom
export CONDARC="$XDG_CONFIG_HOME/conda/condarc"
export IPYTHONDIR="$XDG_CONFIG_HOME/ipython"
export JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME/jupyter"
export BASH_COMPLETION_USER_FILE="$XDG_CONFIG_HOME"/bash-completion/bash_completion
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export CRAWL_DIR="$XDG_DATA_HOME"/crawl/
export CUDA_CACHE_PATH="$XDG_CACHE_HOME/nv"
export __GL_SHADER_DISK_CACHE_PATH="${XDG_CACHE_HOME}/nv"
export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker
export GTK_RC_FILES="$XDG_CONFIG_HOME"/gtk-1.0/gtkrc
export GTK2_RC_FILES="$XDG_CONFIG_HOME"/gtk-2.0/gtkrc
export IPFS_PATH="$XDG_DATA_HOME"/ipfs
export MYSQL_HISTFILE="$XDG_DATA_HOME"/mysql_history
export HISTSIZE=1000000  # disable truncation of history when starting bash
export HISTFILESIZE=1000000
[ -z "$BASH" ] && export HISTFILE="${XDG_CACHE_HOME}/zsh/history"  # do not source with bash! overwrites zsh history
export GNUPGHOME="${XDG_DATA_HOME}/gnupg"
export RUSTUP_HOME="${XDG_DATA_HOME}/rustup"
export TERMINFO="${XDG_DATA_HOME}/terminfo"
export TERMINFO_DIRS="${XDG_DATA_HOME}/terminfo:/usr/share/terminfo"
