"chuck this in ~/.vim/nerdtree_plugin/coffee_filter.vim (see what I did there?)

if exists("g:loaded_nerdtree_js_filter")
    finish
endif
let g:loaded_nerdtree_js_filter = 1

let s:extMatch = '\.\(js\|js\.map\)$'

call g:NERDTree.AddPathFilter("FilterCoffee")

"for each '.js' or '.js.map' file, check for the corresponding .coffee file.
"If found, ignore this file
function! FilterCoffee(params)
    let path = a:params['path']

    if path.isDirectory
        return
    endif

    if path.getLastPathComponent(0) !~ s:extMatch
        return
    endif

    let coffeeFilesInDir = split(globpath(path.getParent().str({'format': 'Glob'}), '*.coffee'))
    let srcCoffeeFile = substitute(path.str(), s:extMatch, '.coffee', '')

    return index(coffeeFilesInDir, srcCoffeeFile) != -1
endfunction
