if exists("loaded_bash_syntax_checker")
    finish
endif
let loaded_bash_syntax_checker = 1

"bail if the user doesnt have bash installed
if !executable("bash")
    finish
endif

"run the buffer through bash -n and return the line number of the first syntax
"error, or 0 if no errors
function! CheckSyntax_bash()
    let output = system("bash -n " . expand("%"))
    if v:shell_error != 0
        return s:extract_error_line(output)
    endif
endfunction

"extract the line num of the first syntax error for the given output
function! s:extract_error_line(error_msg)
    return substitute(a:error_msg, '.\{-}: line \(\d*\): .*', '\1', '')
endfunction
