if exists("loaded_bindzone_syntax_checker")
    finish
endif
let loaded_bindzone_syntax_checker = 1

"bail if the user doesnt have named-checkzone installed
if !executable("named-checkzone")
    finish
endif

"run the buffer through named-checkzone and return the line number of the first syntax
"error, or 0 if no errors
function! CheckSyntax_bindzone()
    let domain = substitute(expand("%:t"), '\.zone$', '', '')

    let output = system("named-checkzone " . domain . " " . expand("%"))
    if v:shell_error != 0
        return s:extract_error_line(output)
    endif
endfunction

"extract the line num of the first syntax error for the given output
"from 'named-checkzone'
function! s:extract_error_line(error_msg)
    return substitute(a:error_msg, '.\{-}:\(\d*\): .*', '\1', '')
endfunction
