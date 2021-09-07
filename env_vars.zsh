export PATH=$HOME/.local/bin:/usr/games:$PATH
export EDITOR=nvim

# bookmarks support
if [ -d "${HOME}/.local/share/bookmarks" ]; then
    export CDPATH=".:${HOME}/.local/share/bookmarks"
fi
