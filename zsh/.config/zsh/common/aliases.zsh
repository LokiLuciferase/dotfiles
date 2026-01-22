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

alias dush='du -ahd1 | sort -h'
alias hgrep='history | grep'
alias trace='tail -f -n100000'
alias mkdir='mkdir -pv'
alias tmux="tmux -f ${HOME}/.config/tmux/tmux.conf"
alias tree="tree -I '.git'"
alias ta="tree -I '.git' -a"
alias tp="trash-put"
alias uvr="uv run"

alias shfmt='shfmt -i 4 -sr -w -l'
alias assume='source assume'
alias watch='watch '
alias zat='zathura'
alias lo='libreoffice '
alias refeh='feh --bg-fill --no-fehbg ~/.local/share/backgrounds/default'
alias upd='update-git-repos'
alias alu='apt list --upgradable'

# more git aliases - some others already defined by oh-my-zsh
alias ga.='git add .'
alias gca='git commit --amend'
alias gpl='git pull'
alias glo='git lola'
alias gdh='git diff HEAD~1'
alias gdsh='git stash show -p'
alias gbb='git bisect bad'
alias gbg='git bisect good'
alias gsp='git stash pop'
alias gfop='git fetch origin $(git rev-parse --abbrev-ref HEAD):$(git rev-parse --abbrev-ref HEAD)'

# docker (compose)
alias dps='docker ps'
alias dls='docker image ls'
alias dsp='docker system prune'
alias pps='podman ps'
alias pls='podman image ls'

alias dcd='docker compose down'
alias dcu='docker compose up'
alias dcud='docker compose up -d'
alias dcudr='docker compose up -d --build --force-recreate'
alias dcr='docker compose restart'
alias dcl='docker compose logs --follow'
alias dcp='docker compose pull'

# UVX replacements for python CLI tools
alias vd='uvx visidata --config ~/.config/visidata/config.py'
alias http="uvx --from httpie http"
alias https="uvx --from httpie https"
alias ips='uvx ipython'
alias autorandr='uvx autorandr'
alias cookiecutter='uvx cookiecutter'
alias asciinema='uvx asciinema'
alias bpytop='uvx bpytop'
alias yt-dlp='uvx --from=yt-dlp[default] yt-dlp'
alias tldr='uvx tldr'
alias vja='uvx vja'
alias dvc='uvx --with=dvc-s3 dvc'
alias eyeD3='uvx --from=eyeD3[art-plugin] eyeD3'
alias album-fixup="eyeD3 --plugin fixup --file-rename-pattern '\$track:num. \$title'"

# nvim stuff
[[ "$(which nvim 2> /dev/null)" != "" ]] && VIM_BIN='nvim' || VIM_BIN='vim'
alias ed="echo 'fuck off'"
alias nano="${VIM_BIN}"
alias vi="${VIM_BIN} --cmd 'let g:dumb=1'"
alias vim="${VIM_BIN} -p"
alias nvim="${VIM_BIN} -p"
alias nvimdiff='\nvim -d'
alias gvd="git-nvimdiff"
alias suvi=sudoedit

[[ "$(which ssha 2> /dev/null)" != '' ]] && compdef _ssh ssha=ssh

##silly
alias :q='exit'
alias :wq='echo "beep boop...saved" && sleep 1 && exit'
alias mansplain='man'
alias leckmiamoasch='echo "trottl"'
alias please='sudo '
alias fucking='sudo '
alias get-rekt="true && _package_manager_upgrade_all && _flatpak_upgrade_all_if_exist && pall"
