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
set matchtime=2  " Tenths of a second to show the matching paren, when 'showmatch' is set.

set ignorecase  " Ignore capitalization during search
set smartcase  " except when searching for capital letters

set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.flv,*.img,*.xlsx,.git/  " exclude these from file matches

set lazyredraw  " do not redraw screen while running macros

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
let mapleader = ' '
let maplocalleader = ' '
inoremap <S-Tab> <C-d>
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv
nnoremap <silent> <ESC><ESC> :noh<CR>
nnoremap <silent> q :q<CR>
nnoremap <silent> Q :qa<CR>
noremap <silent> <leader>sl :set list!<CR>
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

" refreshing syntax highlighting
noremap <F12> <Esc>:syntax sync fromstart<CR>
inoremap <F12> <C-o>:syntax sync fromstart<CR>

" Spell checking
noremap <leader>st :setlocal spell!<cr>
noremap <leader>sn ]s
noremap <leader>sp [s
noremap <leader>sa zg
noremap <leader>sua zug


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
autocmd FileType python,nextflow,c,cpp,sh,rust,lua,perl,php,js,java,go,scala,sql,vim,julia set colorcolumn=100

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

" Highlight yanks
if has("nvim")
    autocmd TextYankPost * silent! lua vim.highlight.on_yank {timeout=100}
endif


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
if has('nvim-0.8.0')
    Plug 'nvim-tree/nvim-tree.lua', {'on': 'NvimTreeToggle'}
    nmap <silent> <F3> :NvimTreeToggle<CR>
else
    Plug 'preservim/nerdtree', {'on': 'NERDTreeToggle'}
    nmap <silent> <F3> :NERDTreeToggle<CR>
    let NERDTreeMapActivateNode='l'
    let NERDTreeMapOpenInTab='<ENTER>'
    autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
endif

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
if executable('node') && (has('nvim-0.5.0') || has('patch-8.1.1719'))
    " Use most recent coc.nvim with custom pum
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    inoremap <silent><expr> <TAB>
        \ coc#pum#visible() ? coc#pum#next(1):
        \ <SID>check_back_space() ? "\<Tab>" :
        \ coc#refresh()
    inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
    inoremap <expr> <cr> coc#pum#visible() ? coc#_select_confirm() : "\<CR>"
    if executable('npm')
        " Ensure default language servers installed
        let g:coc_global_extensions = [
            \ 'coc-diagnostic',
            \ 'coc-json',
            \ 'coc-yaml',
            \ 'coc-pairs',
            \ 'coc-sh',
            \ 'coc-pyright',
            \ 'coc-clangd',
            \ 'coc-lua',
            \ 'coc-db',
        \]
    endif

    set updatetime=100

    " show number of diagnostics in statusline
    set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

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
    nmap <leader>ln :call CocAction('diagnosticNext')<CR>
    nmap <leader>lp :call CocAction('diagnosticPrevious')<CR>
    nmap <leader>ll :CocList<CR>

    " Highlight the symbol and its references when holding the cursor.
    autocmd CursorHold * silent call CocActionAsync('highlight')

    " Allow scrolling of doc float with C-f and C-b
    nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
    nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
    inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
    inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
    vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
    vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"

    autocmd ColorScheme onedark highlight CocInlayHint guifg=#56b6c2
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
nmap <leader>gl :Commits!<CR>
nmap <leader>rg :Rg!<CR>
nmap <leader>fl :Lines!<CR>
let g:fzf_colors = {'hl+': ['fg', 'Statement'], 'hl': ['fg', 'Statement']}

" Trailing whitespace handling
Plug 'ntpeters/vim-better-whitespace'
nmap <leader>xdw :StripWhitespace<CR>
let g:current_line_whitespace_disabled_hard=1

" indent guides
if has('nvim-0.5.0')
    Plug 'lukas-reineke/indent-blankline.nvim'
else
    Plug 'Yggdroot/indentLine'
    let g:indentLine_char = '│'
    let g:indentLine_defaultGroup = 'StatusLineNC'
endif

" better vimdiff file selection
if has('nvim-0.8.0')
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

" TeX support
Plug 'lervag/vimtex', {'for': 'tex'}
if executable('zathura')
    let g:vimtex_view_method = 'zathura'
elseif executable('xreader')
    let g:vimtex_view_general_viewer = 'xreader'
endif
let g:vimtex_quickfix_mode = 2
let g:vimtex_quickfix_autoclose_after_keystrokes = 1
let g:vimtex_quickfix_open_on_warning = 0
let g:vimtex_compiler_latexmk = {'build_dir' : 'build'}

" relational database support
Plug 'tpope/vim-dadbod', {'for': 'sql', 'on': ['DB', 'DBUI', 'DBUIToggle']}
Plug 'kristijanhusak/vim-dadbod-ui', {'for': 'sql', 'on': ['DBUI', 'DBUIToggle']}
nnoremap <F4> :DBUIToggle<CR>
autocmd FileType dbout wincmd T

" Github copilot integration
if executable('node')
    Plug 'github/copilot.vim'
    " ain't nobody got time to hit the right key
    for key in range(9, 11)
        exec 'imap <silent><script><expr> <F' . key . '> copilot#Accept("")'
        exec 'imap <silent><script><expr> <C-F' . key . '> copilot#Next()'
    endfor
    let g:copilot_no_tab_map = v:true
endif

" color scheme
if has('termguicolors')
    set termguicolors
endif
if has('nvim-0.8.0')
    Plug 'nvim-treesitter/nvim-treesitter'
    Plug 'navarasu/onedark.nvim'
    let g:onedark_config = {
        \"colors": {"bg0": "#232323"},
        \"highlights": {
            \"Title": {"fg": "$green"},
            \"TabLine": {"fg": "$grey"},
            \"TabLineSel": {"bg": "$bg3", "fg": "$fg"},
        \},
    \}
else
    Plug 'joshdick/onedark.vim'
    let g:onedark_color_overrides = {
    \    "background": {"gui": "#232323", "cterm": "235", "cterm16": "0"},
    \}
    let g:onedark_termcolors=256
    let g:onedark_terminal_italics=1  " alacritty supports italics
endif

" Local plugin config (optional)
let $LOCALPLUGCONF = $XDG_CONFIG_HOME . "/nvim/local/plugins.local.vim"
if filereadable($LOCALPLUGCONF)
    source $LOCALPLUGCONF
endif

if exists('g:journal_mode')
    Plug 'LokiLuciferase/pensieve.nvim'
    Plug 'vimwiki/vimwiki'
    Plug 'nvim-telescope/telescope.nvim'
    Plug 'xiyaowong/telescope-emoji.nvim'
    Plug 'itchyny/calendar.vim'
    Plug 'jose-elias-alvarez/null-ls.nvim'
    let g:vimwiki_list = []
    let g:copilot_filetypes = {'*': v:false}
endif

call plug#end()

" execute the following only if plugin loading worked.
colorscheme onedark

" execute lua configurations - needs to be done after plug#end
try
lua <<EOF
if vim.g.journal_mode == 1 then
    require("pensieve").setup({spell_langs={"en_us", "de_at"}})
    require("telescope").load_extension("emoji")
end
if vim.fn.has('nvim-0.8.0') == 1 then
    require("nvim-treesitter.configs").setup(
    {
        ensure_installed = {
            "c", "cpp", "rust",
            "javascript", "python", "bash",
            "latex", "toml", "json", "yaml", "sql",
            "dockerfile",
            "lua", "vim"
        },
        highlight = {enable = true},
    }
    )
    require("nvim-tree").setup()
    require("diffview").setup({enhanced_diff_hl = true, use_icons = false})
end
EOF
catch /.*/
endtry
