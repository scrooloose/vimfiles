if exists("loaded_eruby_syntax_checker")
    finish
endif
let loaded_eruby_syntax_checker = 1

"bail if the user doesnt have ruby or cat installed
if !executable("ruby") || !executable("cat")
    finish
endif

"run the erb sections of the buffer though ruby -c and return the line num of
"the first error, or 0 if no errors
function! CheckSyntax_eruby()
    let output = s:CheckSyntax(expand("%"))
    if v:shell_error != 0
        return s:ExtractErrorLine(output)
    endif
endfunction

"extract the line num of the first syntax error for the given output
"from 'ruby -c'
function! s:ExtractErrorLine(error_msg)
    return substitute(a:error_msg, '.\{-}:\(\d*\): syntax error,.*', '\1', '')
endfunction

"run the erb sections of the given file through ruby -c and return the result
function! s:CheckSyntax(filename)
    return system('cat '. a:filename . ' | ruby -e "require \"erb\"; puts ERB.new(ARGF.read, nil, \"-\").src" | ruby -c')
endfunction
