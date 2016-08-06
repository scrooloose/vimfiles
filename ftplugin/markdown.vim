nnoremap <leader>= :s/.*/\=repeat("=", len(getline(line(".") - 1)))/<cr> <bar> :noh<cr>
nnoremap <leader>- :s/.*/\=repeat("-", len(getline(line(".") - 1)))/<cr> <bar> :noh<cr>

autocmd insertleave,textchanged <buffer> call MarkdownUpdateHeadingUnderline()

function! MarkdownUpdateHeadingUnderline() abort
    let lnum = line(".")

    if getline(lnum) =~ '^\s*-'
        return
    endif

    if getline(lnum+1) =~ '^-\+$'
        call setline(lnum+1, repeat("-", len(getline(lnum))))
    elseif getline(lnum+1) =~ '^=\+$'
        call setline(lnum+1, repeat("=", len(getline(lnum))))
    endif
endfunction

call textobj#user#plugin('markdown', {
      \   'subhead': {
      \     'pattern': ['^.\+\n--\+$', '\(.\{-}\n\ze.\+\n[-=]\{2,}$\|.*\%$\)'],
      \     'select-a': 'ah',
      \     'select-i': 'ih',
      \   },
      \
      \   'head': {
      \     'pattern': ['^.*\n^==\+$', '\(.\{-}\n\ze.\+\n=\{2,}$\|.*\%$\)'],
      \     'select-a': 'aH',
      \     'select-i': 'iH',
      \   },
      \ })


autocmd insertleave <buffer> call <SID>CheckToRealignTable()
function! s:CheckToRealignTable() abort
    echomsg "CheckToRealignTable"
    if getline(line(".")) =~ '^|.*|.*|'
        TableModeRealign
    endif
endfunction
