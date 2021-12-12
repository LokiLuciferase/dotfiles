function! myspacevim#before() abort
    let g:mapleader=','
    let g:neoformat_python_black = {
    \ 'exe': 'black',
    \ 'stdin': 1,
    \ 'args': ['-q', '-', '-S', '-l', '100'],
    \ }
	let g:neoformat_enabled_python = ['black']
    " set mouse=
    set clipboard=unnamedplus
    autocmd BufNewFile,BufRead *.config set ft=nextflow
    autocmd BufNewFile,BufRead *.{fna,faa,ffn,fa} set ft=fasta
    au FileType markdown setlocal wrap
    au FileType markdown setlocal spell
    au BufNewFile,BufRead Snakefile set syntax=snakemake
    au BufNewFile,BufRead *.rules set syntax=snakemake
    au BufNewFile,BufRead *.snakefile set syntax=snakemake
    au BufNewFile,BufRead *.snake set syntax=snakemake
endfunction

function! myspacevim#after() abort
    set autochdir
	set nopaste
    inoremap <S-Tab> <C-d>
    nnoremap <leader>d "_d
    xnoremap <leader>d "_d
    xnoremap <leader>p "_dP
endfunction

