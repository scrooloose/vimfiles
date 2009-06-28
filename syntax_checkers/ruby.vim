if exists("loaded_ruby_syntax_checker")
    finish
endif
let loaded_ruby_syntax_checker = 1

"bail if the user doesnt have ruby installed
if !executable("ruby")
    finish
endif

"run the buffer through ruby -c and return the line number of the first syntax
"error
function! CheckSyntax_ruby()
    let output = system("ruby -c " . expand("%"))
    if v:shell_error != 0
        return s:extract_error_line(output)
    endif
endfunction

"extract the line num of the first syntax error for the given output
"from 'ruby -c'
function! s:extract_error_line(error_msg)
    return substitute(a:error_msg, '.\{-}:\(\d*\): .*', '\1', '')
endfunction
