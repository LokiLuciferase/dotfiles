"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin-free vim/nvim global config
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Support being called from window manager
if empty($XDG_CONFIG_HOME)
    let $XDG_CONFIG_HOME = $HOME . '/.config'
endif

source $XDG_CONFIG_HOME/nvim/01_vi.vim

if !has('nvim-0.8.0') || exists('g:dumb')
    finish
endif


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin config (requires reasonably up-to-date nvim)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
source $XDG_CONFIG_HOME/nvim/02_plugins.lua
