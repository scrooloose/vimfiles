if exists("loaded_haml_syntax_checker")
    finish
endif
let loaded_haml_syntax_checker = 1

"bail if the user doesnt have the haml binary installed
if !executable("haml")
    finish
endif

"run the buffer through haml -c
"return the line num of the first error, or 0 if no errors
function! CheckSyntax_haml()
    let output = system("haml -c " . expand("%"))
    if v:shell_error != 0
        return s:ExtractErrorLine(output)
    endif
endfunction

"extract the line num of the first syntax error for the given output
"from 'haml -c'
function! s:ExtractErrorLine(error_msg)
    return substitute(a:error_msg, '^Syntax error on line \(\d*\):.*', '\1', '')
endfunction
