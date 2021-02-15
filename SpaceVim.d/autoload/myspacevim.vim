function! myspacevim#before() abort
    let g:mapleader=','
    let g:neoformat_python_black = {
    \ 'exe': 'black',
    \ 'stdin': 1,
    \ 'args': ['-q', '-', '-S', '-l', '100'],
    \ }
	let g:neoformat_enabled_python = ['black']
    " set mouse=
    set clipboard=unnamed
    autocmd BufNewFile,BufRead *.config set ft=nextflow
    autocmd BufNewFile,BufRead *.{fna,faa,ffn,fa} set ft=fasta
endfunction

function! myspacevim#after() abort
    inoremap <S-Tab> <C-d>
    nnoremap <leader>d "_d
    xnoremap <leader>d "_d
    xnoremap <leader>p "_dP
endfunction

