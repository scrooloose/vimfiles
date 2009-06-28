if exists("loaded_sass_syntax_checker")
    finish
endif
let loaded_sass_syntax_checker = 1

"bail if the user doesnt have the sass binary installed
if !executable("sass")
    finish
endif

"run the buffer through sass -c
"return the line num of the first error, or 0 if no errors
function! CheckSyntax_sass()
    let output = system("sass -c " . expand("%"))
    if v:shell_error != 0
        return s:ExtractErrorLine(output)
    endif
endfunction

"extract the line num of the first syntax error for the given output
"from 'sass -c'
function! s:ExtractErrorLine(error_msg)
    return substitute(a:error_msg, '^Syntax error on line \(\d*\):.*', '\1', '')
endfunction
