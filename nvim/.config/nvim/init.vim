"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin-free vim/nvim global config
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
source $XDG_CONFIG_HOME/nvim/01_vi.vim

if !has('nvim-0.8.0') || exists('g:dumb')
    finish
endif


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin config (requires reasonably up-to-date nvim)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
source $XDG_CONFIG_HOME/nvim/02_plugins.lua
