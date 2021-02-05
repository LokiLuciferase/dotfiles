# general omz setup
unsetopt nomatch
export ZSH="$HOME/.oh-my-zsh"
DISABLE_UPDATE_PROMPT=true
ZSH_THEME="powerlevel10k/powerlevel10k"
TERM='xterm-256color'
COMPLETION_WAITING_DOTS="true"
HIST_STAMPS="dd.mm.yyyy"
ZLE_RPROMPT_INDENT=0
DEFAULT_USER=$USER
EDITOR=vim
DOTFILES_DIR="${HOME}/.dotfiles"
plugins=(vi-mode git)
[[ -d "$ZSH/custom/plugins/zsh-syntax-highlighting" ]] && plugins+=(zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# load all ZSH-related config files from unified directory
for config in ${DOTFILES_DIR}/*.zsh ; do
    [[ ! -f "$config" ]] || source "$config"
done

# Dirty hacks
# improved highlighting on WSL: make color of other-writable directories less offensive
if [[ -f "${DOTFILES_DIR}/dircolors" ]]; then
    eval "$(dircolors -b "${DOTFILES_DIR}/dircolors" )"
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
fi

