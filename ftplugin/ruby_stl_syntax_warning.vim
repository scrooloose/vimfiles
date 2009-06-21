" ============================================================================
" File:        ruby_stl_syntax_warning.vim
" Description: filtype plugin for ruby to add a syntax check flag to the
"              statusline
" Maintainer:  Martin Grenfell <martin_grenfell at msn dot com>
" Last Change: 21 Jun, 2009
" License:     This program is free software. It comes without any warranty,
"              to the extent permitted by applicable law. You can redistribute
"              it and/or modify it under the terms of the Do What The Fuck You
"              Want To Public License, Version 2, as published by Sam Hocevar.
"              See http://sam.zoy.org/wtfpl/COPYING for more details.
"
" ============================================================================
if exists("b:did_ruby_stl_syntax_warning_ftplugin") || &filetype !~ '\<ruby\>'
    finish
endif
let b:did_ruby_stl_syntax_warning_ftplugin = 1

"bail if the user doesnt have ruby installed
if !executable("ruby")
    finish
endif

"inject the syntax warning into the statusline
let &l:statusline = substitute(&statusline, '\(%=\)',
            \ '%#warningmsg#%{StatuslineRubySyntaxWarning()}%*\1', '')

"recalculate after saving
autocmd bufwritepost * unlet! b:statusline_ruby_syntax_warning

"run the buffer through ruby -c
"
"return '' if no syntax errors detected
"return '[syntax:xxx]' if errors are detected, where xxx is the line num of
"the first error
function! StatuslineRubySyntaxWarning()
    if !exists("b:statusline_ruby_syntax_warning")
        let b:statusline_ruby_syntax_warning = ''
        if filereadable(expand("%"))
            let output = system("ruby -c " . expand("%"))
            if v:shell_error != 0
                let b:statusline_ruby_syntax_warning =
                            \ '[syntax:'. s:ExtractErrorLine(output) . ']'
            endif
        endif
    endif
    return b:statusline_ruby_syntax_warning
endfunction

"extract the line num of the first syntax error for the given output
"from 'ruby -c'
function! s:ExtractErrorLine(error_msg)
    return substitute(a:error_msg, '.\{-}:\(\d*\): syntax error,.*', '\1', '')
endfunction
