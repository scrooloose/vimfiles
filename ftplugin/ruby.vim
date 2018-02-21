setl et sts=2 sw=2

function! s:rails() abort
    return filereadable("config/boot.rb")
endfunction

function! s:rspec() abort
    return expand("%") =~ '_spec.rb$\|shared_examples'
endfunction

if s:rails()
    nnoremap <buffer> <leader>rr :silent !touch tmp/restart.txt<cr>
endif

if s:rspec()
    nnoremap <buffer> <leader>p :call <SID>SpecToggle("Pending")<cr>
    nnoremap <buffer> <leader>j :call <SID>SpecToggle("JS")<cr>
    nnoremap <buffer> <leader>f :call <SID>SpecToggle("Focus")<cr>
endif

function! s:SpecToggle(subfunc) abort
    let oldhls = &hls
    set nohls
    let oldpos = getpos(".")

    normal! $
    call search('^\s*\(scenario\|it\|feature\|describe\|context\|pending\) ', 'b')

    exec "call s:Toggle" . a:subfunc . "()"

    write

    call setpos(".", oldpos)
    let &hls = oldhls
endfunction

function! s:TogglePending() abort
    if match(getline("."), '^\s*\zs\(it\|scenario\)') >= 0
        s/^\s*\zs\(it\|scenario\)/pending/
    else
        let replace = search('^\s*#\?\s*\(scenario\|feature\)', 'wn') ? 'scenario' : 'it'
        exec 's/^\s*\zspending/' . replace . '/'
    endif
endfunction

function! s:ToggleFocus() abort
    if match(getline("."), 'focus: true') >= 0
        s/,\s*focus: true//
    else
        s/.*\zs\s\+do/, focus: true do/
    endif
endfunction

function! s:ToggleJS() abort
    if match(getline("."), 'js: true') >= 0
        s/,\s*js: true\s*/ /
    else
        s/.*\zs\s\+\zedo/, js: true /
    endif
endfunction
