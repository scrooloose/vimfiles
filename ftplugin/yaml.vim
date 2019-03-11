command! -nargs=0 YamlPath call s:yaml_path()
nnoremap <leader>yp :call <sid>yaml_path()<cr>

function! s:yaml_path() abort
    let winview = winsaveview()

    let yaml_keys = []
    call add(yaml_keys, s:yaml_key_for(getline(".")))

    let cur_indent = s:indent(getline(".")) - 1
    while cur_indent >= 0
        let indent_str = repeat(repeat(' ', &sts), cur_indent)
        call search('^' . indent_str . '\w*:', 'bW')
        call add(yaml_keys, s:yaml_key_for(getline(".")))

        let cur_indent -= 1
    endwhile

    echo join(reverse(yaml_keys), '.')

    call winrestview(winview)
endfunction

function! s:indent(line) abort
    return match(getline("."), '[^ ]') / &sts
endfunction

function! s:yaml_key_for(line) abort
    return substitute(a:line, '^\s*\(.\{-}\):.*', '\1', '')
endfunction
