if exists('g:loaded_snakey_camel')
    finish
endif
let g:loaded_snakey_camel = 1

nnoremap <leader>ss :call SnakeyCamel("toSnake", 0)<cr>
nnoremap <leader>sS :call SnakeyCamel("toSnake", 1)<cr>
nnoremap <leader>sS :call SnakeyCamel("toSnake", 1)<cr>
nnoremap <leader>sc :call SnakeyCamel("toCamel", 0)<cr>
nnoremap <leader>sC :call SnakeyCamel("toCamel", 1)<cr>
nnoremap <leader>sk :call SnakeyCamel("toKebab", 0)<cr>
nnoremap <leader>sK :call SnakeyCamel("toKebab", 1)<cr>

function! SnakeyCamel(convertFunc, convertFuncArg) abort
    let oldIskeyword = &iskeyword
    set iskeyword+=-

    let cword = expand("<cword>")
    let replacement = call("s:" . a:convertFunc, [cword, a:convertFuncArg])
    exec "normal ciw" . replacement
    normal b

    exec 'set iskeyword=' . oldIskeyword
endfunction

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
