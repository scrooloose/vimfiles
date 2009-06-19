if exists("b:did_ruby_statusline_ftplugin") || &filetype !~ '\<ruby\>'
    finish
endif
let b:did_ruby_statusline_ftplugin = 1

"bail if the user doesnt have ruby installed
if !executable("ruby")
    finish
endif

let &l:statusline = substitute(&statusline, '\(%=\)', '%#warningmsg#%{StatuslineRubySyntaxCheck()}%*\1', '')

"recalculate after saving
autocmd bufwritepost * unlet! b:statusline_ruby_syntax_check

function! StatuslineRubySyntaxCheck()
    if !exists("b:statusline_ruby_syntax_check")
        let b:statusline_ruby_syntax_check = ''
        if filereadable(expand("%"))
            let output = system("ruby -c " . expand("%"))
            if v:shell_error != 0
                let b:statusline_ruby_syntax_check = '[syntax:'. s:ExtractErrorLine(output) . ']'
            endif
        endif
    endif
    return b:statusline_ruby_syntax_check
endfunction

function! s:ExtractErrorLine(error_msg)
    return substitute(a:error_msg, '.\{-}:\(\d*\): syntax error,.*', '\1', '')
endfunction
