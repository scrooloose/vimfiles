if exists("loaded_python_syntax_checker")
    finish
endif
let loaded_python_syntax_checker = 1

"bail if the user doesnt have pyflakes installed
if !executable("pyflakes")
    finish
endif

"run the buffer through 'pyflakes' and return the line number of the first
"syntax error, or 0 if no errors
function! CheckSyntax_python()
    let output = system("pyflakes " . expand("%"))
    if v:shell_error != 0
        return s:extract_error_line(output)
    endif
endfunction

"extract the line num of the first syntax error for the given output
"from 'pyflakes'
function! s:extract_error_line(error_msg)
    return substitute(a:error_msg, '.\{-}:\(\d*\): .*', '\1', '')
endfunction
