call NERDSnippetsReset()
call NERDSnippetsFromDirectory("~/.vim/snippets")

function! s:camelCase(s)
    "upcase the first letter
    let toReturn = substitute(a:s, '^\(.\)', '\=toupper(submatch(1))', '')
    "turn all '_x' into 'X'
    return substitute(toReturn, '_\(.\)', '\=toupper(submatch(1))', 'g')
endfunction

function! s:underscore(s)
    "down the first letter
    let toReturn = substitute(a:s, '^\(.\)', '\=tolower(submatch(1))', '')
    "turn all 'X' into '_x'
    return substitute(toReturn, '\([A-Z]\)', '\=tolower("_".submatch(1))', 'g')
endfunction

function! s:inRailsEnv()
    return filereadable(getcwd() . '/config/environment.rb')
endfunction

function! Snippet_Sweeper()
    let class = s:camelCase(substitute(expand("%:t"), '^\(.*\)_sweeper\.rb', '\1', ''))
    let instance = s:underscore(class)
    return "class <+".class."+>Sweeper < ActionController::Caching::Sweeper\<CR>".
           \ "observe <+".class."+>\<CR>\<CR>".
           \ "def after_save(<+".instance."+>)\<CR>".
           \   "expire_cache(<+".instance."+>)\<CR>".
           \ "end\<CR>\<CR>".
           \ "def after_destroy(<+".instance."+>)\<CR>".
           \   "expire_cache(<+".instance."+>)\<CR>".
           \ "end\<CR>\<CR>".
           \ "def expire_cache(<+".instance."+>)\<CR>".
           \   "expire_page\<CR>".
           \ "end\<CR>".
           \"end\<CR>"
endfunction

"ruby {{{1
function! Snippet_RubyClassNameFromFilename()
    let name = expand("%:t:r")
    return s:camelCase(name)
endfunction

if s:inRailsEnv()
    call NERDSnippetsFromDirectoryForFiletype('~/.vim/snippets/ruby-rails', 'ruby')
else
    "create merb snippets
endif

"eruby {{{1
if s:inRailsEnv()
    call NERDSnippetsFromDirectoryForFiletype('~/.vim/snippets/eruby-rails', 'ruby')
else
    "create merb snippets
endif
call NERDSnippetsFromDirectoryForFiletype('~/.vim/snippets/html', 'eruby')

"xhtml {{{1
call NERDSnippetsFromDirectoryForFiletype('~/.vim/snippets/html', 'xhtml')

"php {{{1
call NERDSnippetsFromDirectoryForFiletype('~/.vim/snippets/html', 'php')


"java {{{1
function! Snippet_JavaClassNameFromFilename()
    return expand("%:t:r")
endfunction

"global {{{1

function! s:start_comment()
    return substitute(&commentstring, '^\([^ ]*\)\s*%s\(.*\)$', '\1', '')
endfunction

function! s:end_comment()
    return substitute(&commentstring, '^.*%s\(.*\)$', '\1', '')
endfunction

function! Snippet_Modeline()
    return s:start_comment() . " vim: set <+settings+>:" . s:end_comment()
endfunction

"call NERDSnippetGlobal("modeline", "\<c-r>=Snippet_Modeline()\<cr>")


" modeline {{{1
" vim: set fdm=marker:
