if exists("b:did_ruby_stl_syntax_warning_ftplugin") || &filetype !~ '\<ruby\>'
    finish
endif
let b:did_ruby_stl_syntax_warning_ftplugin = 1

"bail if the user doesnt have ruby installed
if !executable("ruby")
    finish
endif

let &l:statusline = substitute(&statusline, '\(%=\)', '%#warningmsg#%{StatuslineRubySyntaxWarning()}%*\1', '')

"recalculate after saving
autocmd bufwritepost * unlet! b:statusline_ruby_syntax_warning

function! StatuslineRubySyntaxWarning()
    if !exists("b:statusline_ruby_syntax_warning")
        let b:statusline_ruby_syntax_warning = ''
        if filereadable(expand("%"))
            let output = system("ruby -c " . expand("%"))
            if v:shell_error != 0
                let b:statusline_ruby_syntax_warning = '[syntax:'. s:ExtractErrorLine(output) . ']'
            endif
        endif
    endif
    return b:statusline_ruby_syntax_warning
endfunction

function! s:ExtractErrorLine(error_msg)
    return substitute(a:error_msg, '.\{-}:\(\d*\): syntax error,.*', '\1', '')
endfunction
