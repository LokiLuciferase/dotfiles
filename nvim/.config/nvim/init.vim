""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
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

set mouse=a  " enable mouse in all modes
set clipboard=unnamedplus  " sync unnamed register with system clipboard
set backspace=eol,start,indent  " allow to backspace over everything
set whichwrap+=<,>  " allow these characters to move to next line of first/last char in line reached"

set showmatch  " show matching brackets
set matchtime=2  " Tenths of a second to show the matching paren, when 'showmatch' is set.

set ignorecase  " Ignore capitalization during search
set smartcase  " except when searching for capital letters
set hlsearch  " highlight matches during search
set incsearch  " While searching though a file incrementally highlight matching characters as you type.

set wildmenu  " allow tabbing through file matches
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.flv,*.img,*.xlsx,.git/  " exclude these from file matches

set showmode  " Show current mode in statusline
set history=1000  " Set the commands to save in history default number is 20.

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

au FileType markdown setlocal wrap  " enable line wrapping for md
au FileType markdown setlocal spell  " enable spelling for md

set listchars+=precedes:<,extends:>

let mapleader = ','  " define leader key
nmap <SPACE> ,
vmap <SPACE> ,

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
syntax on  " Turn syntax highlighting on.
colorscheme delek_mod  " select color scheme
set background=dark  " assume dark background


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Spell checking
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Pressing <leader>ss will toggle and untoggle spell checking
map <leader>ss :setlocal spell!<cr>

" Shortcuts using <leader>
map <leader>sn ]s
map <leader>sp [s
map <leader>sa zg


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugins
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
try
    call plug#begin('~/.local/share/nvim/plugins')

    " NERDCommenter - enables block/line comment workflows
    Plug 'preservim/nerdcommenter'
    let g:NERDCreateDefaultMappings = 0
    nmap <leader>cl <Plug>NERDCommenterInvert
    vmap <leader>cl <Plug>NERDCommenterInvert

    " nextflow-vim - enables syntax highlighting for NF
    Plug 'LokiLuciferase/nextflow-vim', {'for': 'nextflow'}
    autocmd BufNewFile,BufRead *.{nf,config} set ft=nextflow

    " rainbow_csv - TSV/CSV highlighting
    Plug 'mechatroner/rainbow_csv', {'for': ['tsv', 'csv']}

    " neoformat - code formatter
    Plug 'sbdchd/neoformat', {'on': 'Neoformat'}
    let g:neoformat_python_black = {
    \ 'exe': 'black',
    \ 'stdin': 1,
    \ 'args': ['-q', '-', '-S', '-l', '100'],
    \ }
	let g:neoformat_enabled_python = ['black']

    " vim-fugitive - Git plugin
    Plug 'tpope/vim-fugitive', {'on': ['Git', 'Gdiff']}
    set diffopt+=vertical
    nmap <leader>gd :Gdiff<CR>
    nmap <leader>gs :Git<CR>
    nmap <leader>ga :Git add %<CR>
    nmap <leader>gA :Git add .<CR>
    nmap <leader>gc :Git commit<CR>
    nmap <leader>gca :Git commit --amend<CR>
    nmap <leader>gpl :Git pull<CR>
    nmap <leader>gps :Git push<CR>
    nmap <leader>gb :Git blame<CR>
    nmap <leader>gl :Git log -- %<CR>
    nmap <leader>gL :Git log --<CR>

    " vim-better-whitespace - handle whitespace
    Plug 'ntpeters/vim-better-whitespace', {'on': 'StripWhitespace'}
    nmap <leader>xdw :StripWhitespace<CR>

    " bioSyntax - highlighting for bioinformatics file types
    Plug 'bioSyntax/bioSyntax-vim', {'for': ['fasta']}
    autocmd BufNewFile,BufRead *.{fna,faa,ffn,fa,fasta} set ft=fasta

    " color scheme
    Plug 'joshdick/onedark.vim'

    call plug#end()
catch
    echo "Plugins are unavailable."
endtry
colo onedark
