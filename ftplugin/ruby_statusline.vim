if exists("b:did_ruby_statusline_ftplugin")
    finish
endif
let b:did_ruby_statusline_ftplugin = 1

let &l:statusline = substitute(&statusline, '\(%=\)', '%{StatuslineRubySyntaxCheck()}\1', '')

"recalculate after saving
autocmd bufwritepost * unlet! b:statusline_ruby_syntax_check

function! StatuslineRubySyntaxCheck()
    if !exists("b:statusline_ruby_syntax_check")
        let b:statusline_ruby_syntax_check = ''
        if filereadable(expand("%")) && executable("ruby")
            call system("ruby -c " . expand("%"))
            if v:shell_error != 0
                let b:statusline_ruby_syntax_check = '[invalid-syntax]'
            endif
        endif
    endif
    return b:statusline_ruby_syntax_check
endfunction
