if exists("loaded_php_syntax_checker")
    finish
endif
let loaded_php_syntax_checker = 1

"bail if the user doesnt have php installed
if !executable("php")
    finish
endif
"run the buffer through php -l
"return the line num of the first error, or 0 if no errors
function! CheckSyntax_php()
    let output = system("php -l " . expand("%"))
    if v:shell_error != 0
        return s:ExtractErrorLine(output)
    endif
endfunction

"extract the line num of the first syntax error for the given output
"from 'php -l'
function! s:ExtractErrorLine(error_msg)
    return substitute(a:error_msg, '\_.\{-}on line \(\d*\)\_.*', '\1', '')
endfunction
