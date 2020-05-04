if exists('g:loaded_snakey_camel')
    finish
endif
let g:loaded_snakey_camel = 1

nnoremap <leader>ss caw<c-r>=<SID>toSnake(@", 0)<cr><esc>b
nnoremap <leader>sS caw<c-r>=<SID>toSnake(@", 1)<cr><esc>b
nnoremap <leader>sc caw<c-r>=<SID>toCamel(@", 0)<cr><esc>b
nnoremap <leader>sC caw<c-r>=<SID>toCamel(@", 1)<cr><esc>b
nnoremap <leader>sk caw<c-r>=<SID>toKebab(@", 0)<cr><esc>b
nnoremap <leader>sK caw<c-r>=<SID>toKebab(@", 1)<cr><esc>b

function! s:toCamel(word, leadingCap) abort
    let result = s:convertAnythingToSnake(a:word)
    let result = substitute(result, '_\(\U\)', '\u\1', 'g')
    return a:leadingCap ? substitute(result, '^\(\U\)', '\u\1', '') : result
endfunction

function! s:toSnake(word, screaming) abort
    let result = s:convertAnythingToSnake(a:word)
    return a:screaming ? toupper(result) : result
endfunction

function! s:toKebab(word, screaming) abort
    let result = s:convertAnythingToSnake(a:word)
    let result = substitute(result, '_', '-', 'g')
    return a:screaming ? toupper(result) : result
endfunction

" Simplify other conversion functions by using snake case as our base format
function! s:convertAnythingToSnake(word) abort
    " standard snake
    if a:word =~ '\C^[a-z_]\+ \?$'
        return a:word
    endif

    " screaming snake
    if a:word =~ '\C^[A-Z_]\+ \?$'
        return tolower(a:word)
    endif

    " camel case (standard and leading cap)
    if a:word =~ '^[A-Za-z]\+ \?$'
        let result = substitute(a:word, '\(\u\)', '_\L\1', 'g')
        let result = substitute(result, '^_', '', '')
        return result
    endif

    " kebab
    if a:word =~ '^[A-Za-z\-]\+ \?$'
        return tolower(substitute(a:word, '-', '_', 'g'))
    endif

    throw 'snakey camel: unrecognized word format'
endfunction
