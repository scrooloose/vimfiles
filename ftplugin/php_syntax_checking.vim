" ============================================================================
" File:        php_syntax_checking.vim
" Description: Filtype plugin for php to provide syntax checking hacks
" Maintainer:  Martin Grenfell <martin_grenfell at msn dot com>
" Last Change: 23 Jun, 2009
" License:     This program is free software. It comes without any warranty,
"              to the extent permitted by applicable law. You can redistribute
"              it and/or modify it under the terms of the Do What The Fuck You
"              Want To Public License, Version 2, as published by Sam Hocevar.
"              See http://sam.zoy.org/wtfpl/COPYING for more details.
"
" ============================================================================
if exists("b:did_php_syntax_checking_ftplugin")
    finish
endif
let b:did_php_syntax_checking_ftplugin = 1

"bail if the user doesnt have php installed
if !executable("php")
    finish
endif

"inject the syntax warning into the statusline
let &l:statusline = substitute(&statusline, '\(%=\)',
            \ '%#warningmsg#%{StatuslinePhpSyntaxWarning()}%*\1', '')

"recalculate after saving
autocmd bufwritepost <buffer> unlet! b:statusline_php_syntax_warning

"run the buffer through php -l
"
"return '' if no syntax errors detected
"return '[syntax:xxx]' if errors are detected, where xxx is the line num of
"the first error
function! StatuslinePhpSyntaxWarning()
    if !exists("b:statusline_php_syntax_warning")
        let b:statusline_php_syntax_warning = ''
        if filereadable(expand("%"))
            let output = system("php -l " . expand("%"))
            if v:shell_error != 0
                let b:statusline_php_syntax_warning =
                            \ '[syntax:'. s:ExtractErrorLine(output) . ']'
            endif
        endif
    endif
    return b:statusline_php_syntax_warning
endfunction

"extract the line num of the first syntax error for the given output
"from 'php -l'
function! s:ExtractErrorLine(error_msg)
    return substitute(a:error_msg, '\_.\{-}on line \(\d*\)\_.*', '\1', '')
endfunction

"if syntax errors are found in the current buffer, show them in the quickfix
"window
function! s:ShowSyntaxErrors()
    let old_errorformat = &l:errorformat
    setl errorformat=Parse\ error:\ syntax\ error\\,\ %m\ in\ %f\ on\ line\ %l,%-G%.%#

    let old_makeprg = &l:makeprg
    setl makeprg=php\ -l\ %

    silent make
    redraw!

    let &l:makeprg = old_makeprg
    let &l:errorformat = old_errorformat

    if !empty(getqflist())
        copen
    endif
endfunction

command! -nargs=0 -buffer SyntaxErrors call s:ShowSyntaxErrors()
