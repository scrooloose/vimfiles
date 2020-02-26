setl sts=4 sw=4

" should probably put this in vimrc, but feels better here
let g:pyindent_open_paren = 'shiftwidth()'
let g:pyindent_continue = 'shiftwidth()'

nnoremap <leader>l :exec "Tmux pylint " . expand("%")<cr>

autocmd bufenter,bufreadpost *.py call s:setup_qa_test_maps()

function! s:setup_qa_test_maps() abort
    if !s:file_in_qa_framework()
        return
    endif
    nnoremap <buffer> <leader>tt :call <SID>run_test("nearest")<cr>
    nnoremap <buffer> <leader>tf :call <SID>run_test("file")<cr>
endfunction

function! s:file_in_qa_framework() abort
    return expand("%:p") !~ "platform-wrapper\/qa"
endfunction

function! s:run_test(type) abort
    let position = { 'file': expand("%"), 'col': col("."), 'line': line(".") }
    let test_location = test#python#pyunit#build_position(a:type, position)[0]

    call Send_to_Tmux(
    \ "sed -i -e \"s/^\\( \\+'test_subset': \\)'.*'/\\1'". test_location ."'/\" configs/test_config.py\n"
    \ )

    call Send_to_Tmux("./run.py\n")
endfunction



