command! -nargs=1 -complete=customlist,s:ListGems BundleOpen :exec "sp ". s:VendorDir() ."/<args>"

function! s:ListGems(lead, cmdline, cursorpos)
    let lead = !empty(a:lead) ? a:lead : ''
    let matches = split(globpath(s:VendorDir(), lead . '*'), "\n")
    return map(matches, 'fnamemodify(v:val, ":t")')
endfunction

function! s:VendorDir()
    let currentDir = fnamemodify(expand("%:p"), ":h")

    while !isdirectory(currentDir . '/vendor')
        let currentDir = fnamemodify(currentDir, ":h")

        if currentDir == '/'
            throw "Couldn't find vendor directory"
        endif
    endwhile

    return currentDir . '/vendor/bundle/gems'
endfunction
