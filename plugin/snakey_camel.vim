if exists('g:loaded_snakey_camel')
    finish
endif
let g:loaded_snakey_camel = 1

nnoremap <plug>SnakeyCamelToSnake
    \ :call <SID>Convert("ToSnake")<cr>
nnoremap <plug>SnakeyCamelToScreamingSnake
    \ :call <SID>Convert("ToScreamingSnake")<cr>

nnoremap <plug>SnakeyCamelToCamel
    \ :call <SID>Convert("ToCamel")<cr>
nnoremap <plug>SnakeyCamelToUpperCamel
    \ :call <SID>Convert("ToUpperCamel")<cr>

nnoremap <plug>SnakeyCamelToKebab
    \ :call <SID>Convert("ToKebab")<cr>
nnoremap <plug>SnakeyCamelToScreamingKebab
    \ :call <SID>Convert("ToScreamingKebab")<cr>

nmap <leader>ss <plug>SnakeyCamelToSnake
nmap <leader>sS <plug>SnakeyCamelToScreamingSnake
nmap <leader>sc <plug>SnakeyCamelToCamel
nmap <leader>sC <plug>SnakeyCamelToUpperCamel
nmap <leader>sk <plug>SnakeyCamelToKebab
nmap <leader>sK <plug>SnakeyCamelToScreamingKebab

function! s:Convert(convertFunc) abort
    let oldIskeyword = &iskeyword
    set iskeyword+=-
    let cword = expand("<cword>")

    try
        let replacement = call("s:" . a:convertFunc, [cword])
        exec "normal ciw" . replacement
        normal b
        silent! call repeat#set("\<plug>SnakeyCamel" . a:convertFunc)
    finally
        exec 'set iskeyword=' . oldIskeyword
    endtry
endfunction

function! s:ToCamel(word) abort
    let result = s:ConvertAnythingToSnake(a:word)
    return substitute(result, '_\(\U\)', '\u\1', 'g')
endfunction

function! s:ToUpperCamel(word) abort
    return substitute(s:ToCamel(a:word), '^\(\U\)', '\u\1', '')
endfunction

function! s:ToSnake(word) abort
    return s:ConvertAnythingToSnake(a:word)
endfunction

function s:ToScreamingSnake(word) abort
    return toupper(s:ToSnake(a:word))
endfunction

function! s:ToKebab(word) abort
    let result = s:ConvertAnythingToSnake(a:word)
    return substitute(result, '_', '-', 'g')
endfunction

function s:ToScreamingKebab(word) abort
    return toupper(s:ToKebab(a:word))
endfunction

" Simplify other conversion functions by using snake case as our base format
function! s:ConvertAnythingToSnake(word) abort
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
