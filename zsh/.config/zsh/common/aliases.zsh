## essential
alias cd..='cd ..'
alias cd2='cd ../..'
alias cd3='cd ../../..'

alias ll='ls -l'
alias la='ls -a'
alias lh='ls -lh'
alias l='ls -lah'
alias lt='ls -lahtr'
alias ltt='ls -lahtr --group-directories-first'

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
alias sshb="ssh -f -N"
alias dps='docker ps'
alias dls='docker image ls'
alias pps='podman ps'
alias pls='podman image ls'
alias shfmt='shfmt -i 4 -sr -w -l'
alias assume='source assume'
alias watch='watch '
alias vd='uvx vd --config ~/.config/visidata/config.py'
alias chs='term-replace font.size=20 chs'
alias zat='zathura'
alias lo='libreoffice '
alias refeh='feh --bg-fill --no-fehbg ~/.local/share/backgrounds/default'

# more git aliases - some already defined by oh-my-zsh
alias ga.='git add .'
alias gca='git commit --amend'
alias gpl='git pull'
alias glo='git lola'
alias gdh='git diff HEAD~1'
alias gbb='git bisect bad'
alias gbg='git bisect good'
alias gsp='git stash pop'
alias gfop='git fetch origin $(git rev-parse --abbrev-ref HEAD):$(git rev-parse --abbrev-ref HEAD)'

# docker compose
alias dcd='docker compose down'
alias dcu='docker compose up'
alias dcud='docker compose up -d'
alias dcudr='docker compose up -d --force-recreate'
alias dcr='docker compose restart'
alias dcl='docker compose logs --follow'
alias dcp='docker compose pull'

[[ "$(which nvim 2> /dev/null)" != "" ]] && VIM_BIN='nvim' || VIM_BIN='vim'
alias ed="echo 'fuck off'"
alias nano="${VIM_BIN}"
alias vi="${VIM_BIN} --cmd 'let g:dumb=1'"
alias vim="${VIM_BIN} -p"
alias nvim="${VIM_BIN} -p"
alias nvimdiff='\nvim -d'
alias gvd="git-nvimdiff"
alias suvi=sudoedit
alias http="uvx --from httpie http"

[[ "$(which ssha 2> /dev/null)" != '' ]] && compdef _ssh ssha=ssh

##silly
alias mansplain='man'
alias leckmiamoasch='echo "trottl"'
alias please='sudo '
alias fucking='sudo '
alias get-rekt="true && _package_manager_upgrade_all && _flatpak_upgrade_all_if_exist && pall"
