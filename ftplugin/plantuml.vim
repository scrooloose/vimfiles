nnoremap <f10> :call <sid>ViewPNG()<cr>

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
