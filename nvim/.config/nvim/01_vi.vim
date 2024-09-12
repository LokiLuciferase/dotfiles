"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General configuration options
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if !(has('nvim'))  " Neovim already sets these options
    set encoding=utf8  " default file encoding
    scriptencoding utf8  " default script encoding
    set nocompatible  " Disable compatibility with vi which can cause unexpected issues.
    filetype on  " Enable type file detection. Vim will be able to try to detect the type of file in use.
    set backspace=eol,start,indent  " allow to backspace over everything
    set history=1000  " Set the commands to save in history default number is 20.
    set hlsearch  " highlight matches during search
    set incsearch  " While searching though a file incrementally highlight matching characters as you type.
    set wildmenu  " allow tabbing through file matches
    set showmode  " Show current mode in statusline
    set magic  " enable regex in search patterns
    set noerrorbells  " Disable error bell
    set novisualbell  " Disable visual error bell
    set t_vb=  " Never flash the screen
    set guicursor=n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20  " Set the cursor shape
    set hidden  " Allow to hide buffers with unsaved changes
endif

filetype plugin on  " Enable plugins and load plugin for the detected file type.
filetype indent on  " Load an indent file for the detected file type.
set fileformats=unix,dos  " which line endings to try when editing a file
set number relativenumber  " Turn on hybrid numbering
set shiftwidth=4  " set width of shift
set tabstop=4  " set width of tabstop
set expandtab  " enable smart tabs
set shortmess=atoI  " disable splash screen, don't prompt on save and overwrite messages for each buffer
set mouse=a  " enable mouse in all modes
set clipboard=unnamedplus  " sync unnamed register with system clipboard
set whichwrap+=<,>  " allow these characters to move to next line of first/last char in line reached"
set autochdir  " cwd to the location of the currently edited file

set showmatch  " show matching brackets
set cursorline  " highlight current line
set matchtime=2  " Tenths of a second to show the matching paren, when 'showmatch' is set.

set ignorecase  " Ignore capitalization during search
set smartcase  " except when searching for capital letters

set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.flv,*.img,*.xlsx,.git/  " exclude these from file matches

set lazyredraw  " do not redraw screen while running macros

set diffopt+=vertical  " start diff mode in vertical split

set tm=500  " The time in milliseconds that is waited for a key code or mapped key sequence to complete.

set nobackup  " Do not keep backup of file
set nowritebackup  " do not ever use a backup file, even during :write
set noswapfile  " Do not use a swap file

set splitbelow  " New horz splits appear below
set splitright  " New vert splits appear right

set autoindent  " automatically indent after newline
set smartindent  " basic rules for indenting code

set nowrap  " Disable linewrap and handle sidescrolling
set showbreak=... "If wrapping is enabled, this option specifies what to show at the begin of wrapped lines.
set sidescroll=5  " The minimal number of columns to scroll horizontally.

set fillchars+=diff:╱  " Set the fillchars for diff mode
set listchars=tab:→\ ,space:·,eol:¬,trail:~,extends:>,precedes:<  " better listchars
set pumheight=12  "maximum height of popup window


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Keymaps
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" What's your favorite thing about space? Mine is space.
let mapleader = ' '
let maplocalleader = ' '
" tab indentation
inoremap <S-Tab> <C-d>
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv
" clear search highlighting and cmdline
nnoremap <silent> <ESC><ESC> :noh \| :echon ''<CR>
" quick exit
nnoremap <silent> q :q<CR>
nnoremap <silent> Q :qa<CR>
" toggle listchars
noremap <silent> <leader>sl :set list!<CR>
" copy complete document
noremap <leader>ya :%y+<CR>

" leader-based navigation for tabs
noremap <silent> <leader>tn gt
noremap <silent> <leader>tN gT
for i in range(1,9)
    exec "noremap <silent> <leader>" . i . " " . i . "gt"
endfor
noremap <leader>0 :tablast<cr>

" navigation for splits
command! Hsplit split
cnoreabbrev hsplit Hsplit
nnoremap <C-W>h <C-W>s
nnoremap <silent> <C-W>n :vnew<CR>
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" resizing splits
nnoremap <silent> <C-Up> :resize +5<CR>
nnoremap <silent> <C-Down> :resize -5<CR>
nnoremap <silent> <C-Left> :vertical resize +5<CR>
nnoremap <silent> <C-Right> :vertical resize -5<CR>

" refreshing syntax highlighting
noremap <F12> <Esc>:syntax sync fromstart<CR>
inoremap <F12> <C-o>:syntax sync fromstart<CR>

" Spell checking
noremap <leader>st :setlocal spell!<cr>
noremap <leader>sn ]s
noremap <leader>sp [s
noremap <leader>sa zg
noremap <leader>sua zug

" Some concessions to bad habits from using vscode...
nnoremap <C-S> :w<CR>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Statusline
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set laststatus=2  " show statusline
set statusline=\ %f%m%r%=
set statusline+=%#CursorColumn#
set statusline+=\%y
set statusline+=[%{&fileencoding?&fileencoding:&encoding}
set statusline+=\|%{&fileformat}\]
set statusline+=\ %l:%c
set statusline+=\ %p%%

" add statusline background if multiple horizontal splits to improve readability
function SLColor()
    if tabpagewinnr(tabpagenr(), '$') > 1 && winheight('$') != &lines - 2
        exec 'hi StatusLine' .
            \' ctermfg=white' .
            \' guifg=' . synIDattr(synIDtrans(hlID('Title')), 'fg', 'gui')
    else
        hi! link StatusLine Title
    endif
endfunction
autocmd VimEnter,WinEnter,WinLeave,WinClosed,InsertEnter * call SLColor()


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
" Filetype-specific settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" prose
function SetProseOptions()
    try
        if filereadable(expand('./resources/spell.add'))
            setlocal spellfile=./resources/spell.add  " use custom spellfile if exists
            exec 'silent mkspell! ' . &spellfile . '.spl ' . &spellfile
        endif
    catch
    endtry
    setlocal wrap  " enable line wrapping for md
    setlocal spelllang=en_us,de_at  " set spell language
    setlocal spell  " enable spelling for md
    setlocal textwidth=0  " disable textwidth
    setlocal colorcolumn=  " disable colorcolumn
    setlocal linebreak  " break lines at word boundaries
    setlocal showbreak=  " do not show linebreaks
    setlocal spellcapcheck=none  " do not check for capitalization - fixes species names
    setlocal nocursorline
    setlocal diffopt+=iwhite,iblank,followwrap
    nnoremap j gj
    nnoremap k gk
    nnoremap 0 g0
    nnoremap $ g$
    vnoremap j gj
    vnoremap k gk
    vnoremap 0 g0
    vnoremap $ g$
endfunction
autocmd FileType tex,latex,markdown,rst call SetProseOptions()

" highlight jupyter source code
autocmd BufNewFile,BufRead *.{ipynb} set ft=json

" run scripts
function! s:run_file_type(ft) abort
    let s:run_tp = {
        \ 'python': '!python3 %',
        \ 'sh': '!bash %',
        \ 'js': '!node %',
        \ 'go': '!go run %',
        \ 'rust': '!cargo run',
        \ }
    if has_key(s:run_tp, a:ft)
        exec s:run_tp[a:ft]
    elseif executable(a:ft)
        exec '!' . a:ft . ' %'
    endif
endfunction
autocmd FileType * nnoremap <F5> :call <SID>run_file_type(&ft)<CR>

" enable colorcolumn for commonly used code files
autocmd FileType python,nextflow,c,cpp,sh,rust,lua,perl,php,js,java,go,scala,sql,vim,julia set colorcolumn=120

" add custom file headers for new files of a certain type
function! s:add_buffer_head() abort
    let l:ft_head_tp = {
        \ 'python': ['#!/usr/bin/env python3', '', ''],
        \ 'sh': ['#!/usr/bin/env bash', 'set -euo pipefail', '', ''],
        \ }
    if has_key(l:ft_head_tp, &ft) && getline(1) ==# '' && line('$')  == 1
        let head = l:ft_head_tp[&ft]
        call setline(1, head)
        call cursor(len(head), 0)
    endif
endfunction
autocmd FileType * call <SID>add_buffer_head()

autocmd BufNewFile,BufRead *.nf,*.config setlocal filetype=nextflow

autocmd BufNewFile,BufRead *5etools*.json setlocal filetype=json.5etools


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" diff changes with file on disk
function! s:DiffWithSaved()
    let filetype=&ft
    diffthis
    vnew | r
    diffthis
    exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
endfunction
com! DiffSaved call s:DiffWithSaved()

" hide lefthand columns and non-text chars for copying
let s:hidden_all = 0
function! ToggleCopyMode()
    if s:hidden_all  == 0
        let s:hidden_all = 1
        set signcolumn=no
        set nonumber
        set norelativenumber
        set paste
        set showbreak=
        try
            IndentBlanklineDisable
        catch
        endtry
    else
        let s:hidden_all = 0
        set signcolumn=yes
        set number
        set relativenumber
        set nopaste
        set showbreak=...
         try
            IndentBlanklineEnable
        catch
        endtry
   endif
endfunction
com! ToggleCopyMode call ToggleCopyMode()
nnoremap <F2> :ToggleCopyMode<CR>

" Run updates
function! RunUpdates()
    if exists(':PlugUpdate')
        PlugUpdate
        PlugUpgrade
    elseif exists(':Lazy')
        Lazy update
    endif
    if exists(':TSUpdate')
        TSUpdateSync
    endif
    if exists(':CocUpdate')
        CocUpdate
    endif
endfunction
com! RunUpdates call RunUpdates()

" Session handling
function! HandleSession(arg)
    if has('nvim')
        let l:session_file = stdpath('cache') . '/session.vim'
    else
        let l:session_file = $VIM . '/session.vim'
    endif
    if a:arg == 'save'
        execute 'mksession! ' . l:session_file
    elseif a:arg == 'restore'
        if filereadable('session.vim')
            execute 'source session.vim'
        elseif filereadable(l:session_file)
            execute 'source ' . l:session_file
        endif
    endif
endfunction
nnoremap <leader>ss :call HandleSession('save')<CR>
nnoremap <leader>sr :call HandleSession('restore')<CR>

" Paste from clipboard, replacing newline with space
function! PasteReplaceCR(rep)
    let l:reg_save = getreg('+')
    let l:regtype_save = getregtype('+')
    let l:cb_save = &clipboard
    let l:reg = substitute(getreg('+'), '\n', a:rep, 'g')
    call setreg('+', l:reg)
    normal! p
endfunction
nnoremap <leader>ps :call PasteReplaceCR(' ')<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Misc autocmds
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Remember position of last edit and return on reopen
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
autocmd BufEnter,InsertLeave * :syntax sync fromstart

" If we entered in diff mode, exit all buffers with q
autocmd BufEnter * if &diff | nnoremap <silent> q :qa<CR> | endif

" Fix autochdir when opening a directory
let g:netrw_keepdir = 0
autocmd BufEnter * if isdirectory(expand("%")) | set noautochdir | else | set autochdir | endif

" resize splits if window got resized
autocmd VimResized * tabdo wincmd =

" Highlight yanks
if has("nvim")
    autocmd TextYankPost * silent! lua vim.highlight.on_yank {timeout=100}
endif
