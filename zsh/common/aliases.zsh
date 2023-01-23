## essential
alias cd..='cd ..'
alias cd2='cd ../..'
alias cd3='cd ../../..'

alias ll='ls -l'
alias la='ls -a'
alias lh='ls -lh'
alias l='ls -lah'
alias lt='ls -lahtr'

alias c='clear'
alias :q='exit'
alias :wq='echo "beep boop...saved" && sleep 1 && exit'
alias dush='du -ahd1 | sort -h'
alias hgrep='history | grep'
alias trace='tail -f -n100000'
alias mkdir='mkdir -pv'
alias tmux="tmux -f ${HOME}/.config/tmux/tmux.conf"
alias dog='highlight -O ansi --force'
alias goto='cd -P'
alias tree="tree -I '.git'"
alias ta="tree -I '.git' -a"
alias dr="desktop-run"
alias gbb="git bisect bad"
alias gbg="git bisect good"
alias sshb="ssh -f -N"
alias lo='libreoffice'
alias dps='docker ps'
alias dls='docker image ls'
alias pps='podman ps'
alias pls='podman image ls'
alias shfmt='shfmt -i 4 -sr -w -l'
alias assume='source assume'
alias watch='watch '
alias vd='vd --config ~/.config/visidata/config.py'
alias chs='term-replace font.size=20 chs'

[[ "$(which nvim)" != "" ]] && VIM_BIN='nvim' || VIM_BIN='vim'
alias nano="${VIM_BIN}"
alias vim="${VIM_BIN}"
alias vi="${VIM_BIN} --cmd 'let g:dumb=1'"
alias gvd="git-nvimdiff"
alias suvi=sudoedit
alias ed="echo 'fuck off'"

[[ "$(which ssha)" != '' ]] && compdef _ssh ssha=ssh

##silly
alias mansplain='man'
alias leckmiamoasch='echo "trottl"'
alias please='sudo '
alias fucking='sudo '
alias get-rekt="sudo apt update && sudo apt upgrade --yes && sudo apt autoremove --yes && _flatpak_upgrade_all_if_exist && pall"
