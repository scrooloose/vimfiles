finish
"Chuck this in [a vim runtime]/nerdtree_plugin/gitignore_filter.vim

if exists("loaded_nerdtree_gitignore_filter")
    finish
endif
let loaded_nerdtree_gitignore_filter = 1

call NERDTreeAddPathFilter('NERDTreeGitIgnoreFilter')

function NERDTreeGitIgnoreFilter(params)
    let fname = a:params['nerdtree'].root.path.str() . '/.gitignore'
    if !filereadable(fname)
        return
    endif

    return a:params['path'].str() =~ g:GitIgnoreRegex(fname)
endfunction

"convert the gitignore file into a regex that we can match filenames against
function g:GitIgnoreRegex(fname)

    "the regex is expensive to build so we cache it
    if exists('b:NERDTreeGitIgnoreRegex')
        return b:NERDTreeGitIgnoreRegex
    endif

    let lines = readfile(a:fname)
    let regexes = []

    for l in lines
        if l =~ '^#' || l =~ '^\s*$'
            continue
        endif

        let regex = l
        let regex = substitute(regex, '\.', '\\.', 'g')
        let regex = substitute(regex, '*', '.*', 'g')
        let regex = substitute(regex, '?', '.', 'g')
        let regex = escape(regex, '/~')
        call add(regexes, regex)
    endfor

    let b:NERDTreeGitIgnoreRegex = '\(' . join(regexes, '\|') . '\)$'
    return b:NERDTreeGitIgnoreRegex
endfunction
