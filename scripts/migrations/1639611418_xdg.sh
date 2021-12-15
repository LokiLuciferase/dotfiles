#!/usr/bin/env bash
mv ~/.zoom ~/.local/share/zoom
mkdir -p ~/.config/conda && mv ~/.condarc ~/.config/conda/condarc
rm -rf .nv/
mkdir ~/.config/gtk-1.0/ && mv ~/.gtkrc-1.0 ~/.config/gtk-1.0/gtkrc
mkdir ~/.config/gtk-2.0/ && mv ~/.gtkrc-2.0 ~/.config/gtk-2.0/gtkrc
mkdir ~/.config/gtk-3.0/ && mv ~/.gtkrc-3.0 ~/.config/gtk-3.0/gtkrc
mkdir ~/.config/gtk-4.0/ && mv ~/.gtkrc-4.0 ~/.config/gtk-4.0/gtkrc
mv ~/.docker ~/.config/docker

