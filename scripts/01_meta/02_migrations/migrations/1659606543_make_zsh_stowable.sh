#!/usr/bin/env bash
set -euo pipefail

# FILENAME_SUFFIX: make_zsh_stowable
# SUMMARY: Retarget .zshrc link in zsh directory to make the directory work with stow.py. Scary!
# ---

NEW_ZSHRC_LOC="${HOME}/.dotfiles/zsh/.zshrc"
RELATIVE_ZSHRC_LOC=".dotfiles/zsh/.zshrc"
LINK_LOC="${HOME}/.zshrc"


if [ -f "${NEW_ZSHRC_LOC}" ]; then
    echo "Retargeting zshrc."
    ln -fvs "${RELATIVE_ZSHRC_LOC}" "${LINK_LOC}"
else
    echo "${NEW_ZSHRC_LOC} not found."
fi

