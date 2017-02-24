if exists("b:loaded_my_plantuml_ft_hacks")
    finish
endif
let b:loaded_my_plantuml_ft_hacks=1

"there is a Title entity in a system at work and I keep forgetting this is a
"reserved word in plantuml
autocmd syntax <buffer> syn keyword plantumlKeyword Title

nnoremap <buffer> <f10> :call <sid>ViewPNG()<cr>
command! -buffer Automake autocmd BufWritePost <buffer> silent make

function! s:ViewPNG() abort
    let fname = expand("%:p:r") . ".png"
    call system("rm " . fname)
    call system("java -jar ~/.vim/plantuml/plantuml.jar -tpng " . expand("%:p"))
    call system("gnome-open " . fname)
endfunction

command! -buffer ToggleMembers call s:toggle("members")
command! -buffer ToggleMethods call s:toggle("methods")
command! -buffer ToggleCircle call s:toggle("circle")

function! s:toggle(flag) abort
    if search("^hide ". a:flag , 'nw')
        exec "g/^hide ". a:flag ."/d"
    else
        exec "g/@enduml/normal Ohide " . a:flag
    endif
endfunction

nnoremap <buffer> <leader>ur :call <SID>insertSeqReturn()<cr>A
function! s:insertSeqReturn() abort
    let rv = substitute(getline("."), '^\(.*\)->\(.*\):.*$', '\1<--\2: ', '')
    exec 'normal o' . rv
endfunction
