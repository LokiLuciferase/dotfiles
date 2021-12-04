set -euo pipefail

rm $HOME/.SpaceVim.d || true
ln -s $HOME/.dotfiles/spacevim/.SpaceVim.d $HOME/.SpaceVim.d
