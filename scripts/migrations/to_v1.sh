#!/usr/bin/env bash
set -euo pipefail

stow -h
cd $HOME/.dotfiles && [ ! -d "$HOME/.dotfiles/scripts" ] && false

for DIR in alacritty bumblebee-status dunst htop nvim picom i3 i3status ideavim tmux; do
    mv "$HOME/.config/$DIR" "$HOME/.config/${DIR}.bak.d" || true
    stow $DIR
done

mv $HOME/.config/tmux.bak.d/plugins $HOME/.config/tmux
mv $HOME/.config/libinput-gestures.conf $HOME/.config/libinput-gestures.conf.bak
stow libinput-gestures
