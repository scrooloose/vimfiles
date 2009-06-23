" ============================================================================
" File:        php_syntax_checking.vim
" Description: filtype plugin for php to add a syntax check flag to the
"              statusline
" Maintainer:  Martin Grenfell <martin_grenfell at msn dot com>
" Last Change: 23 Jun, 2009
" License:     This program is free software. It comes without any warranty,
"              to the extent permitted by applicable law. You can redistribute
"              it and/or modify it under the terms of the Do What The Fuck You
"              Want To Public License, Version 2, as published by Sam Hocevar.
"              See http://sam.zoy.org/wtfpl/COPYING for more details.
"
" ============================================================================
if exists("b:did_php_stl_syntax_warning_ftplugin")
    finish
endif
let b:did_php_stl_syntax_warning_ftplugin = 1

"bail if the user doesnt have php installed
if !executable("php")
    finish
endif

"inject the syntax warning into the statusline
let &l:statusline = substitute(&statusline, '\(%=\)',
            \ '%#warningmsg#%{StatuslinePhpSyntaxWarning()}%*\1', '')

"recalculate after saving
autocmd bufwritepost * unlet! b:statusline_php_syntax_warning

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
"from 'php -c'
function! s:ExtractErrorLine(error_msg)
    return substitute(a:error_msg, '\_.\{-}on line \(\d*\)\_.*', '\1', '')
endfunction
