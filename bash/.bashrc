# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac
BASHCACHE="${XDG_CACHE_HOME:-$HOME/.cache}/bash"
mkdir -p "$BASHCACHE"
export HISTFILE="$BASHCACHE/history"
source ~/.config/zsh/common/aliases.zsh
