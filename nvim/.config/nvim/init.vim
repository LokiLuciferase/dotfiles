"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General configuration options
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nocompatible  " Disable compatibility with vi which can cause unexpected issues.
filetype on  " Enable type file detection. Vim will be able to try to detect the type of file in use.
filetype plugin on  " Enable plugins and load plugin for the detected file type.
filetype indent on  " Load an indent file for the detected file type.
set fileformats=unix,dos  " which line endings to try when editing a file
set encoding=utf8  " default file encoding
set number relativenumber  " Turn on hybrid numbering
set shiftwidth=4  " set width of shift
set tabstop=4  " set width of tabstop
set expandtab  " enable smart tabs
set pastetoggle=<F2>  " set pastemode shortcut
set shortmess=atI  " disable splash screen and don't prompt on save
set mouse=a  " enable mouse in all modes
set clipboard=unnamedplus  " sync unnamed register with system clipboard
set backspace=eol,start,indent  " allow to backspace over everything
set whichwrap+=<,>  " allow these characters to move to next line of first/last char in line reached"

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

set nobackup  " Do not keep backup of file
set nowritebackup  " do not ever use a backup file, even during :write
set noswapfile  " Do not use a swap file

set autoindent  " automatically indent after newline
set smartindent  " basic rules for indenting code

set nowrap  " Disable linewrap and handle sidescrolling
set sidescroll=5  " The minimal number of columns to scroll horizontally.

set listchars=tab:→\ ,space:·,eol:¬,trail:~,extends:>,precedes:<  " better listchars

" explicitly enable preview replace
if has("nvim")
  set inccommand=nosplit
endif

" Remember position of last edit and return on reopen
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
autocmd BufEnter,InsertLeave * :syntax sync fromstart


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Keymaps
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let mapleader = ' '  " define leader key
inoremap <S-Tab> <C-d>
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv
nmap <silent> q :q<CR>
nmap <silent> <ESC> :noh<CR>
nmap <silent> <leader>sl :set list!<CR>
noremap <F12> <Esc>:syntax sync fromstart<CR>  " resync syntax if it breaks
inoremap <F12> <C-o>:syntax sync fromstart<CR>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
syntax on  " Turn syntax highlighting on.
colorscheme delek_mod  " select color scheme
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


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Statusline
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set statusline=
set statusline+=%#Title#
set statusline+=\ %f
set statusline+=%m%r
set statusline+=%=
set statusline+=%#CursorColumn#
set statusline+=\%y
if exists('ft')
    set statusline +=\   " intentional trailing whitespace here
endif
set statusline+=[%{&fileencoding?&fileencoding:&encoding}
set statusline+=\|%{&fileformat}\]
set statusline+=\ %l:%c
set statusline+=\ %p%%


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Add custom file headers for new files of a certain type
autocmd FileType * call <SID>add_buffer_head()
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


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugins
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" do not try any plugin hijinks if we are running dumb
if exists("g:dumb")
    finish
endif

try
    call plug#begin()

    " enables block/line comment workflows
    Plug 'preservim/nerdcommenter'
    let g:NERDCreateDefaultMappings = 0
    nmap <leader>cl <Plug>NERDCommenterToggle
    vmap <leader>cl <Plug>NERDCommenterToggle

    " enables file explorer
    Plug 'preservim/nerdtree', {'on': 'NERDTreeToggle'}
    nmap <F3> :NERDTreeToggle<CR>
    autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

    " enables syntax highlighting for NF
    Plug 'LokiLuciferase/nextflow-vim', {'for': 'nextflow'}
    autocmd BufNewFile,BufRead *.{nf,config} set ft=nextflow

    " TSV/CSV highlighting
    Plug 'mechatroner/rainbow_csv', {'for': ['tsv', 'csv', 'text']}
    autocmd BufNewFile,BufRead *.{tsv,csv} set ft=csv

    " code formatting
    Plug 'sbdchd/neoformat', {'on': 'Neoformat'}
    let g:neoformat_python_black = {
    \ 'exe': 'black',
    \ 'stdin': 1,
    \ 'args': ['-q', '-', '-S', '-l', '100'],
    \ }
	let g:neoformat_enabled_python = ['black']
    nmap <leader>fmt :Neoformat<CR>

    " Git plugin
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

    " autocomplete
    if executable('node')
        Plug 'neoclide/coc.nvim', {'branch': 'release'}
        set hidden
        set updatetime=300
        let g:coc_disable_startup_warning = 1
        if executable('npm')
            let g:coc_global_extensions = ['coc-json', 'coc-yaml', 'coc-sh', 'coc-pyright']
        endif

        " Insert <tab> when previous text is space, refresh completion if not.
        function! s:check_back_space() abort
            let col = col('.') - 1
            return !col || getline('.')[col - 1]  =~ '\s'
        endfunction
        inoremap <silent><expr> <TAB>
            \ coc#pum#visible() ? coc#pum#next(1):
            \ <SID>check_back_space() ? "\<Tab>" :
            \ coc#refresh()
        inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
        " Enable completion with Enter
        inoremap <expr> <cr> coc#pum#visible() ? coc#_select_confirm() : "\<CR>"
        autocmd ColorScheme * highlight CocMenuSel ctermfg=12 ctermbg=237
    endif

    " linting
    Plug 'neomake/neomake', {'on': 'Neomake'}
    nmap <leader>l :Neomake<CR>
    let g:neomake_python_flake8_maker = {'args': ['--max-line-length', '100']}
    let g:neomake_python_enabled_makers = ['flake8']

    " handle trailing whitespace
    Plug 'ntpeters/vim-better-whitespace', {'on': ['StripWhitespace', 'EnableWhitespace']}
    nmap <leader>xdw :StripWhitespace<CR>
    nmap <leader>xds :EnableWhitespace<CR>

    if has('nvim')
        " indent guides
        Plug 'lukas-reineke/indent-blankline.nvim', {'for': ['python', 'sh', 'vim', 'lua']}
    endif

    " highlighting for bioinformatics file types
    Plug 'bioSyntax/bioSyntax-vim', {'for': ['fasta']}
    autocmd BufNewFile,BufRead *.{fna,faa,ffn,fa,fasta} set ft=fasta

    " surrounding handling
    Plug 'tpope/vim-surround'

    " undotree visualization
    Plug 'mbbill/undotree', {'on': 'UndotreeToggle'}
    nnoremap <F5> :UndotreeToggle<CR>

    " fzf bindings
    Plug 'junegunn/fzf', {'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim', {'on': ['Files', 'Rg', 'Lines', 'Commits']}
    nmap <leader>ff :Files!<CR>
    nmap <leader>fc :Commits!<CR>
    nmap <leader>rg :Rg!<CR>
    nmap <leader>fl :Lines!<CR>
    let g:fzf_colors = {'hl+': ['fg', 'Statement'], 'hl': ['fg', 'Statement']}

    " Rainbow parentheses
    Plug 'luochen1990/rainbow'
    nmap <leader>rb :RainbowToggle<CR>
    let g:rainbow_conf = {
    \	'ctermfgs': ['NONE', '39', '180', '170', '114'],
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
    let g:onedark_terminal_italics=1  " alacritty supports italics

    Plug 'sonph/onehalf', {'rtp': 'vim/'}

    call plug#end()

    " execute the following only if plugin loading worked.
    colorscheme onedark

catch /.*/
    echo "Plugins unavailable due to error: " . v:exception
endtry

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Local config (optional)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let $LOCALINIT = $XDG_CONFIG_HOME . "/nvim/local/init.local.vim"
if filereadable($LOCALINIT)
    source $LOCALINIT
endif
