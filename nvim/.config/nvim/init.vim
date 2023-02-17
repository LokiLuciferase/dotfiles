"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General configuration options
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set encoding=utf8  " default file encoding
scriptencoding utf8  " default script encoding
set nocompatible  " Disable compatibility with vi which can cause unexpected issues.
filetype on  " Enable type file detection. Vim will be able to try to detect the type of file in use.
filetype plugin on  " Enable plugins and load plugin for the detected file type.
filetype indent on  " Load an indent file for the detected file type.
set fileformats=unix,dos  " which line endings to try when editing a file
set number relativenumber  " Turn on hybrid numbering
set shiftwidth=4  " set width of shift
set tabstop=4  " set width of tabstop
set expandtab  " enable smart tabs
set pastetoggle=<F2>  " set pastemode shortcut
set shortmess=atoI  " disable splash screen, don't prompt on save and overwrite messages for each buffer
set mouse=a  " enable mouse in all modes
set clipboard=unnamedplus  " sync unnamed register with system clipboard
set backspace=eol,start,indent  " allow to backspace over everything
set whichwrap+=<,>  " allow these characters to move to next line of first/last char in line reached"
set autochdir  " cwd to the location of the currently edited file

set history=1000  " Set the commands to save in history default number is 20.
set showmatch  " show matching brackets
set matchtime=2  " Tenths of a second to show the matching paren, when 'showmatch' is set.

set ignorecase  " Ignore capitalization during search
set smartcase  " except when searching for capital letters
set hlsearch  " highlight matches during search
set incsearch  " While searching though a file incrementally highlight matching characters as you type.

set wildmenu  " allow tabbing through file matches
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.flv,*.img,*.xlsx,.git/  " exclude these from file matches

set showmode  " Show current mode in statusline

set lazyredraw  " do not redraw screen while running macros
set magic  " enable regex in search patterns

set noerrorbells  " Disable error bell
set novisualbell  " Disable visual error bell
set t_vb=  " Never flash the screen
set tm=500  " The time in milliseconds that is waited for a key code or mapped key sequence to complete.
set guicursor=n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20  " Set the cursor shape

set nobackup  " Do not keep backup of file
set nowritebackup  " do not ever use a backup file, even during :write
set noswapfile  " Do not use a swap file

set splitbelow  " New horz splits appear below
set splitright  " New vert splits appear right

set autoindent  " automatically indent after newline
set smartindent  " basic rules for indenting code

set nowrap  " Disable linewrap and handle sidescrolling
set sidescroll=5  " The minimal number of columns to scroll horizontally.

set hidden  " Allow to hide buffers with unsaved changes

set fillchars+=diff:╱  " Set the fillchars for diff mode

" better listchars - only works if vim is not an ancient piece of shit
if has("patch-7.4.710")
    set listchars=tab:→\ ,space:·,eol:¬,trail:~,extends:>,precedes:<
endif

set pumheight=12  "maximum height of popup window

" explicitly enable preview replace
if has("nvim")
  set inccommand=nosplit
endif

" Remember position of last edit and return on reopen
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
autocmd BufEnter,InsertLeave * :syntax sync fromstart

" Always open multiple files in tabs
autocmd VimEnter * if !&diff | tab all | tabfirst | endif

" Fix autochdir when opening a directory
let g:netrw_keepdir = 0
autocmd BufEnter * if isdirectory(expand("%")) | set noautochdir | else | set autochdir | end


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Keymaps
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let mapleader = ' '
inoremap <S-Tab> <C-d>
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv
nnoremap <silent> <ESC><ESC> :noh<CR>
nnoremap <silent> q :q<CR>
nnoremap <silent> Q :qa<CR>
noremap <silent> <leader>sl :set list!<CR>
noremap <leader>ya :%y+<CR>

" navigation for tabs
noremap <silent> <leader>tn gt
noremap <silent> <leader>tN gT
noremap <leader>1 1gt
noremap <leader>2 2gt
noremap <leader>3 3gt
noremap <leader>4 4gt
noremap <leader>5 5gt
noremap <leader>6 6gt
noremap <leader>7 7gt
noremap <leader>8 8gt
noremap <leader>9 9gt
noremap <leader>0 :tablast<cr>

" navigation for splits
command! Hsplit split
cnoreabbrev hsplit Hsplit
nnoremap <C-W>h <C-W>s
nmap <silent> <C-W>n :vnew<CR>
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" refreshing syntax highlighting
noremap <F12> <Esc>:syntax sync fromstart<CR>
inoremap <F12> <C-o>:syntax sync fromstart<CR>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
syntax on  " Turn syntax highlighting on
try
    colorscheme delek_mod  " select color scheme
catch
    colorscheme delek
endtry
set background=dark  " assume dark background


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Spell checking
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <leader>st :setlocal spell!<cr>
map <leader>sn ]s
map <leader>sp [s
map <leader>sa zg


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Filetype quirks
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" markdown
autocmd FileType markdown setlocal wrap  " enable line wrapping for md
autocmd FileType markdown setlocal spell  " enable spelling for md

" highlight jupyter source code
autocmd BufNewFile,BufRead *.{ipynb} set ft=json

" run scripts
autocmd FileType sh nnoremap <F5> :!bash %<CR>
autocmd FileType python nnoremap <F5> :!python3 %<CR>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Statusline
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set laststatus=2  " show statusline
set statusline=
set statusline+=%#Title#
set statusline+=\ %f
set statusline+=%m%r
set statusline+=%=
set statusline+=%#CursorColumn#
set statusline+=\%y
set statusline+=[%{&fileencoding?&fileencoding:&encoding}
set statusline+=\|%{&fileformat}\]
set statusline+=\ %l:%c
set statusline+=\ %p%%


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Add custom file headers for new files of a certain type
let s:ft_head_tp = {
    \ 'python': ['#!/usr/bin/env python3', '', ''],
    \ 'sh': ['#!/usr/bin/env bash', 'set -euo pipefail', '', ''],
    \ 'nextflow': ['#!/usr/bin/env nextflow', 'nextflow.enable.dsl = 2', '', '']
    \ }

function! s:add_buffer_head() abort
  if has_key(s:ft_head_tp, &ft) && getline(1) ==# '' && line('$')  == 1
    let head = s:ft_head_tp[&ft]
    call setline(1, head)
    call cursor(len(head), 0)
  endif
endfunction
autocmd FileType * call <SID>add_buffer_head()

" diff changes with file on disk
function! s:DiffWithSaved()
    let filetype=&ft
    diffthis
    vnew | r
    diffthis
    exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
endfunction
com! DiffSaved call s:DiffWithSaved()

" hide lefthand columns for copying
let s:hidden_all = 0
function! ToggleCopyMode()
    if s:hidden_all  == 0
        let s:hidden_all = 1
        set signcolumn=no
        set nonumber
        set norelativenumber
        try
            IndentBlanklineDisable
        catch
        endtry
    else
        let s:hidden_all = 0
        set signcolumn=yes
        set relativenumber
         try
            IndentBlanklineEnable
        catch
        endtry
   endif
endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General (non-plugin-related) local config (optional)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let $LOCALINIT = $XDG_CONFIG_HOME . "/nvim/local/init.local.vim"
if filereadable($LOCALINIT)
    source $LOCALINIT
endif


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugins
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" do not try any plugin hijinks if we are running dumb
if exists("g:dumb")
    finish
endif

try
    " ensure vim-plug is installed, then load plugins
    let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
    if empty(glob(data_dir . '/autoload/plug.vim'))
      silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
      autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
    endif
    call plug#begin()

    " Block and line comments
    Plug 'preservim/nerdcommenter'
    let g:NERDCreateDefaultMappings = 0
    nmap <leader>cl <Plug>NERDCommenterToggle
    vmap <leader>cl <Plug>NERDCommenterToggle

    " File explorer
    Plug 'preservim/nerdtree', {'on': 'NERDTreeToggle'}
    nmap <F3> :NERDTreeToggle<CR>
    let NERDTreeMapActivateNode='l'
    let NERDTreeMapOpenInTab='<ENTER>'
    autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

    " surrounding handling
    Plug 'tpope/vim-surround'

    " Git integration
    Plug 'tpope/vim-fugitive', {'on': ['Git', 'Gdiff']}
    set diffopt+=vertical
    nmap <leader>gd :Gdiff<CR>
    nmap <leader>gs :Git<CR>
    nmap <leader>gr :Git restore %<CR>
    nmap <leader>ga :Git add %<CR>
    nmap <leader>gA :Git add .<CR>
    nmap <leader>gc :Git commit<CR>
    nmap <leader>gca :Git commit --amend<CR>
    nmap <leader>gpl :Git pull<CR>
    nmap <leader>gps :Git push<CR>
    nmap <leader>gb :Git blame<CR>
    nmap <leader>gl :Git log -- %<CR>
    nmap <leader>gL :Git log --<CR>

    " Git diff signs in signcolumn
    Plug 'mhinz/vim-signify'

    " LSP integration
    if executable('node')
        if has('nvim-0.5.0') || has('patch-8.1.1719')
            " Use most recent coc.nvim with custom pum
            Plug 'neoclide/coc.nvim', {'branch': 'release'}
            inoremap <silent><expr> <TAB>
                \ coc#pum#visible() ? coc#pum#next(1):
                \ <SID>check_back_space() ? "\<Tab>" :
                \ coc#refresh()
            inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
            inoremap <expr> <cr> coc#pum#visible() ? coc#_select_confirm() : "\<CR>"
        else
            " use legacy coc.nvim and (neo)vim internal pum
            Plug 'neoclide/coc.nvim', {'tag': 'v0.0.81'}
            let g:coc_disable_startup_warning = 1
            inoremap <silent><expr> <TAB>
                  \ pumvisible() ? "\<C-n>" :
                  \ <SID>check_back_space() ? "\<TAB>" :
                  \ coc#refresh()
            inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
            inoremap <expr> <CR> pumvisible() ? coc#_select_confirm() : "\<CR>"
        endif
        if executable('npm')
            " Ensure default language servers installed
            let g:coc_global_extensions = [
                \ 'coc-diagnostic',
                \ 'coc-json',
                \ 'coc-yaml',
                \ 'coc-pairs',
                \ 'coc-sh',
                \ 'coc-pyright',
                \ 'coc-clangd'
            \]
        endif

        set updatetime=100
        function! s:check_back_space() abort
            let col = col('.') - 1
            return !col || getline('.')[col - 1]  =~ '\s'
        endfunction

        function! ShowDocumentation()
          if CocAction('hasProvider', 'hover')
            call CocActionAsync('doHover')
          else
            call feedkeys('K', 'in')
          endif
        endfunction

        " Define commonly used shortcuts
        nnoremap K :call ShowDocumentation()<CR>
        nmap <leader>ld <Plug>(coc-definition)
        nmap <leader>lr  <Plug>(coc-rename)
        nmap <leader>lf  <Plug>(coc-format)
        nmap <leader>lfo :call CocAction('fold')<CR>
        nmap <leader>lso :call CocAction('showOutline')<CR>
        nmap <leader>lsi :CocCommand python.sortImports<CR>

        " Highlight the symbol and its references when holding the cursor.
        autocmd CursorHold * silent call CocActionAsync('highlight')

        " Allow scrolling of doc float with C-f and C-b
        nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
        nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
        inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
        inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
        vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
        vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"

        autocmd ColorScheme onedark highlight CocMenuSel ctermfg=12 ctermbg=237 guibg=#3a3a3a
        autocmd ColorScheme onedark highlight CocHighlightText ctermbg=237 guibg=#3a3a3a
    endif

    " fzf bindings
    try
        Plug 'junegunn/fzf', {'do': { -> fzf#install() } }
    catch /E15/
        " Catch an error occurring with ancient vim
        Plug 'junegunn/fzf'
    endtry
    Plug 'junegunn/fzf.vim', {'on': ['Files', 'Rg', 'Lines', 'Commits']}
    nmap <leader>ff :Files!<CR>
    nmap <leader>fc :Commits!<CR>
    nmap <leader>rg :Rg!<CR>
    nmap <leader>fl :Lines!<CR>
    let g:fzf_colors = {'hl+': ['fg', 'Statement'], 'hl': ['fg', 'Statement']}

    " Trailing whitespace handling
    Plug 'ntpeters/vim-better-whitespace'
    nmap <leader>xdw :StripWhitespace<CR>

    " indent guides
    if has('nvim-0.5.0')
        Plug 'lukas-reineke/indent-blankline.nvim'
    else
        Plug 'Yggdroot/indentLine'
        let g:indentLine_char = '│'
        let g:indentLine_defaultGroup = 'StatusLineNC'
    endif

    " better vimdiff file selection
    if has('nvim-0.7.0')
        Plug 'nvim-lua/plenary.nvim'
        Plug 'sindrets/diffview.nvim'
        nmap <leader>dv :DiffviewOpen<CR>
        nmap <leader>dc :DiffviewClose<CR>
    endif

    " undotree visualization
    Plug 'mbbill/undotree', {'on': 'UndotreeToggle'}
    nnoremap <F6> :UndotreeToggle<CR>

    " Syntax highlighting for NF
    Plug 'LokiLuciferase/nextflow-vim', {'for': 'nextflow'}
    autocmd BufNewFile,BufRead *.{nf,config} set ft=nextflow

    " TSV/CSV highlighting
    Plug 'mechatroner/rainbow_csv', {'for': ['tsv', 'csv', 'text']}
    let g:rbql_with_headers = 1
    let g:rb_storage_dir = $HOME . '/.cache/rbql'
    let g:table_names_settings = $HOME . '/.cache/rbql/table_names'
    let g:rainbow_table_index = $HOME . '/.cache/rbql/table_index'
    autocmd BufNewFile,BufRead *.{tsv,csv} set ft=csv

    " Rainbow parentheses
    Plug 'luochen1990/rainbow'
    nmap <leader>rb :RainbowToggle<CR>
    let g:rainbow_conf = {
    \	'ctermfgs': ['NONE', '39', '180', '170', '114'],
    \   'guifgs': ['NONE', '#61AFEF', '#E5C07B', '#C678DD', '#56B6C2'],
    \	'guis': [''],
    \	'cterms': [''],
    \	'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/{/ end=/}/ fold'],
    \	'separately': {
    \		'*': {},
    \		'markdown': {
    \			'parentheses_options': 'containedin=markdownCode contained',
    \		},
    \		'vim': {
    \			'parentheses_options': 'containedin=vimFuncBody',
    \		},
    \		'perl': {
    \			'syn_name_prefix': 'perlBlockFoldRainbow',
    \		},
    \		'css': 0
    \	}
    \}

    " color scheme
    Plug 'joshdick/onedark.vim'
    if has('termguicolors')
        set termguicolors
    endif
    let g:onedark_color_overrides = {
    \ "background": {"gui": "#232323", "cterm": "235", "cterm16": "0"},
    \}
    let g:onedark_termcolors=256
    let g:onedark_terminal_italics=1  " alacritty supports italics

    " Light color scheme for J
    Plug 'NLKNguyen/papercolor-theme'

    " Github copilot integration
    if executable('node')
        Plug 'github/copilot.vim'
        imap <silent><script><expr> <F9> copilot#Accept("")
        imap <silent><script><expr> <F10> copilot#Accept("")
        let g:copilot_no_tab_map = v:true
    endif

    " Local plugin config (optional)
    let $LOCALPLUGCONF = $XDG_CONFIG_HOME . "/nvim/local/plugins.local.vim"
    if filereadable($LOCALPLUGCONF)
        source $LOCALPLUGCONF
    endif

    call plug#end()

    " execute the following only if plugin loading worked.
    colorscheme onedark

    " execute lua configurations - needs to be done after plug#end
    try
        lua require("diffview").setup({enhanced_diff_hl = true, use_icons = false})
    catch /.*/
    endtry


catch /.*/
    echo "Plugins unavailable due to error: " . v:exception
endtry
