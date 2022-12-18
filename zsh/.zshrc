# general omz setup
unsetopt NOMATCH
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
export ZSH="${HOME}/.config/oh-my-zsh"
export LC_ALL='en_US.UTF-8'
export LC_CTYPE='en_US.UTF-8'
export LANG='en_US.UTF-8'
ZSH_THEME="powerlevel10k/powerlevel10k"
TERM='xterm-256color'
DEFAULT_USER=$USER
DISABLE_UPDATE_PROMPT=true
COMPLETION_WAITING_DOTS="true"
HIST_STAMPS="dd.mm.yyyy"
ZLE_RPROMPT_INDENT=0
DISABLE_MAGIC_FUNCTIONS=true
ZVM_CURSOR_STYLE_ENABLED=false
SHELL_DOT_DIR="${HOME}/.dotfiles/zsh"
plugins=(
    vi-mode
    git
    aws
    docker
)
wanted_custom_plugins=(
    zsh-syntax-highlighting
    zsh-autosuggestions
)
# load all found ZSH plugins
for wanted_plugin in "${wanted_custom_plugins[@]}"; do
    [[ -d "$ZSH/custom/plugins/${wanted_plugin}" ]] && plugins+=(${wanted_plugin})
done
source $ZSH/oh-my-zsh.sh

# load all ZSH-related config files from unified directory
for config in ${SHELL_DOT_DIR}/common/*.zsh ; do
    source "$config"
done

# load any local ZSH-related config files
if [[ -d "$SHELL_DOT_DIR/local/" ]] && [[ $(ls "${SHELL_DOT_DIR}/local") != '' ]]; then
    for local_config in ${SHELL_DOT_DIR}/local/*.zsh ; do
        source "$local_config"
    done
fi

# run tmux if requested, if exists and if not inside yet
if [[ "$USE_TMUX_AS_SHELL" = true ]] && command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
   exec tmux -f $HOME/.config/tmux/tmux.conf
fi

# Dirty hacks
# make color of other-writable directories less offensive
if [[ -f "${SHELL_DOT_DIR}/common/dircolors" ]]; then
    eval "$(dircolors -b "${SHELL_DOT_DIR}/common/dircolors" )"
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
fi
