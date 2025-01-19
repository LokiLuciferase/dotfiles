# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac
BASHCACHE="${XDG_CACHE_HOME:-$HOME/.cache}/bash"
mkdir -p "$BASHCACHE"
export HISTFILE="$BASHCACHE/history"
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w \$\[\033[00m\] '
# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.config/zsh/common/dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi
source ~/.config/zsh/common/aliases.zsh
