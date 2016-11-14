setl et sts=2 sw=2

if expand("%") =~ '_spec.rb$'
    nnoremap <buffer> <leader>f :call <SID>SpecToggleFocus()<cr>
    nnoremap <buffer> <leader>p :call <SID>SpecTogglePending()<cr>
endif

function! s:SpecTogglePending() abort
    let oldpos = getpos(".")
    normal! $
    call search('^\s*\(scenario\|it\|feature\|describe\|context\|pending\) ', 'b')

    let line = getline(".")

    if match(line, '^\s*\zs\(it\|scenario\)') >= 0
        s/^\s*\zs\(it\|scenario\)/pending/

    else
        let replace = search('^\s*#\?\s*scenario', 'wn') ? 'scenario' : 'it'
        exec 's/^\s*\zspending/' . replace . '/'
    endif

    call setpos(".", oldpos)
    write
endfunction

function! s:SpecToggleFocus() abort
    let oldpos = getpos(".")
    normal! $
    call search('^\s*\(scenario\|it\|feature\|describe\|context\|pending\) ', 'b')

    let line = getline(".")

    if match(line, 'focus: true') >= 0
        s/,\s*focus: true\s*do/ do/
    else
        s/.*\zs\s\+do/, focus: true do/
    endif

    call setpos(".", oldpos)
    write
endfunction
