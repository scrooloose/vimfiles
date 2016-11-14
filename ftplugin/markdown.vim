silent TableModeEnable

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



"Generate github flavoured markdown for the current buf.
"
"Note: the npm package 'marked' is used.
command! -buffer GenGFM call s:GenGFM()

"Note: use the same width as gist
let s:gfm_head = '<html><head><meta charset="utf-8"></head>'
let s:gfm_head .= '<style type="text/css" media="screen"> body { width: 888px } </style>'
let s:gfm_head .= '<link rel="stylesheet" href="https://sindresorhus.com/github-markdown-css/github-markdown.css" type="text/css">'
let s:gfm_head .= '<div class="markdown-body">'
let s:gfm_tail  = '</div></html>'
function! s:GenGFM() abort
    let fname = expand('%:p:r') . '.html'

    let cmd  = 'echo '''. s:gfm_head . ''' > ' . fname
    let cmd .= ' && marked ' . expand('%:p') . ' >> ' . fname
    let cmd .= ' && echo ''' . s:gfm_tail . ''' >> ' . fname

    call system(cmd)
endfunction
