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


nnoremap <silent> <buffer> <esc> :call <SID>CheckToRealignTable()<cr>
inoremap <silent> <buffer> <esc> <esc>:call <SID>CheckToRealignTable()<cr>
function! s:CheckToRealignTable() abort
    if getline(line(".")) =~ '^|.*|.*|'
        TableModeRealign
    endif
endfunction
