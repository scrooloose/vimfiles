if exists("loaded_sh_syntax_checker")
    finish
endif
let loaded_sh_syntax_checker = 1

"use the bash syntax checking
runtime! syntax_checkers/bash.vim
function! CheckSyntax_sh()
    return CheckSyntax_bash()
endfunction
