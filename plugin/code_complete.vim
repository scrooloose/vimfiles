"==================================================
" File:         code_complete.vim
" Brief:        function parameter complete, code snippets, and much more.
" Author:       Mingbai <mbbill AT gmail DOT com>
" Last Change:  2007-07-20 17:39:10
" Version:      2.7
"
" Install:      1. Put code_complete.vim to plugin
"                  directory.
"               2. Use the command below to create tags
"                  file including signature field.
"                  ctags -R --c-kinds=+p --fields=+S .
"
" Usage:
"   hotkey:
"       "<tab>" (default value of g:completekey) Do all the jobs with this key
"
"   example:
"       press <tab> after function name and (
"         foo ( <tab>
"       becomes:
"         foo ( `<first param>`,`<second param>` )
"       press <tab> after code template
"         if <tab>
"       becomes:
"         if( `<...>` )
"         {
"             `<...>`
"         }
"
"
" Variables:
"   g:completekey
"       the key used to complete function parameters and key words.
"   g:rs
"       region start
"   g:re
"       region end
"   g:rsd
"       start a region with a default value
"
" Defining Templates:
"   Use the function CodeCompleteAddTemplate(filetype, keyword, expansion) for
"   filetype specific templates.
"
"   Use the function CodeCompleteAddGlobalTemplate(keyword, expansion) for
"   global templates (available for all filetypes)
"
"   Put all your templates in ~/.vim/after/plugin/ or split them up for each
"   filetype and put them in ~/.vim/ftplugin
"
"
" Example Template: a for loop template for java
"   call CodeCompleteAddTemplate("java", "for", "for(`<=int i=0>`; `<condition>`; `<=i++>`){\<CR>`<>`\<CR>}")
"
"   There are 4 markers:
"       1. `<=int i=0>`
"       2. `<condition>`
"       3. `<=i++>`
"       4. `<>`
"
"   1 and 3 have default values. If you "tab over" them, they will be replaced
"   with the text "int i=0" and "i++".
"
"   2 is a normal marker that must be replaced with the real for loop
"   condition
"
"   4 is an empty marker, these markers are removed when the cursor "arrives"
"   on them.
"
" Duplicate Keywords:
"   If multiple templates exist for the same keyword then the script will
"   ask you which one you want to insert.
"
"==================================================

if v:version < 700
    finish
endif

" Variable Definations: {{{1
" options, define them as you like in vimrc:
if !exists("g:completekey")
    let g:completekey = "<tab>"   "hotkey
endif

if !exists("g:rs")
    let g:rs = '`<'    "region start
endif

if !exists("g:re")
    let g:re = '>`'    "region stop
endif

if !exists("g:rsd")
    let g:rsd = '`<+'    "region start with default value
endif

" ----------------------------
let s:expanded = 0  "in case of inserting char after expand
let s:signature_list = []
let s:jumppos = -1
let s:doappend = 1
let s:templates = {}
let s:templates['_'] = {}

" Autocommands: {{{1
autocmd BufReadPost,BufNewFile * call CodeCompleteStart()

" Menus:
menu <silent>       &Tools.Code\ Complete\ Start          :call CodeCompleteStart()<CR>
menu <silent>       &Tools.Code\ Complete\ Stop           :call CodeCompleteStop()<CR>

" Function Definations: {{{1

function! CodeCompleteStart()
    exec "silent! iunmap  <buffer> ".g:completekey
    exec "silent! nunmap  <buffer> ".g:completekey
    exec "inoremap <buffer> ".g:completekey." <c-r>=CodeComplete()<cr><c-r>=SwitchRegion(0)<cr>"
    exec "nnoremap <buffer> ".g:completekey." i<c-r>=SwitchRegion(0)<cr>"
    exec "snoremap <buffer> ".g:completekey." <esc>i<c-r>=SwitchRegion(1)<cr>"
endfunction

function! CodeCompleteStop()
    exec "silent! iunmap <buffer> ".g:completekey
    exec "silent! nunmap <buffer> ".g:completekey
    exec "silent! sunmap <buffer> ".g:completekey
endfunction

function! FunctionComplete(fun)
    let s:signature_list=[]
    let signature_word=[]
    let ftags=taglist("^".a:fun."$")
    if type(ftags)==type(0) || ((type(ftags)==type([])) && ftags==[])
        return ''
    endif
    for i in ftags
        if has_key(i,'kind') && has_key(i,'name') && has_key(i,'signature')
            if (i.kind=='p' || i.kind=='f') && i.name==a:fun  " p is declare, f is defination
                if match(i.signature,'(\s*void\s*)')<0 && match(i.signature,'(\s*)')<0
                    let tmp=substitute(i.signature,',',g:re.','.g:rs,'g')
                    let tmp=substitute(tmp,'(\(.*\))',g:rs.'\1'.g:re.')','g')
                else
                    let tmp=''
                endif
                if (tmp != '') && (index(signature_word,tmp) == -1)
                    let signature_word+=[tmp]
                    let item={}
                    let item['word']=tmp
                    let item['menu']=i.filename
                    let s:signature_list+=[item]
                endif
            endif
        endif
    endfor
    if s:signature_list==[]
        return ')'
    endif
    if len(s:signature_list)==1
        return s:signature_list[0]['word']
    else
        call  complete(col('.'),s:signature_list)
        return ''
    endif
endfunction

function! ExpandTemplate(cword)
    let snippets = []
    if has_key(s:templates,&ft)
        if has_key(s:templates[&ft],a:cword)
            let snippets = extend(snippets, s:templates[&ft][a:cword])
        endif
    endif
    if has_key(s:templates['_'],a:cword)
        let snippets = extend(snippets, s:templates['_'][a:cword])
    endif

    if len(snippets)
        let s:jumppos = line('.')
        if len(snippets) == 1
            return "\<c-w>" . snippets[0]
        else
            return "\<c-w>" . s:ChooseSnippet(snippets)
        endif
    endif

    return ''
endfunction

function! SwitchRegion(removeDefaults)
    if len(s:signature_list)>1
        let s:signature_list=[]
        return ''
    endif
    if s:jumppos != -1
        call cursor(s:jumppos,1)
        let s:jumppos = -1
    endif

    if a:removeDefaults
        call s:RemoveDefaultMarkers()
    endif

    if search(g:rs.'.\{-}'.g:re, 'c') != 0
        call search(g:rs,'c',line('.'))
        let start_col = col(".")
        normal v
        call search(g:re,'e',line('.'))
        let end_col = col(".")
        if &selection == "exclusive"
            exec "norm " . "\<right>"
        endif

        "if the place holders are empty
        if (end_col - start_col + 1) == strlen(g:rs) + strlen(g:re)
            return "\<c-\>\<c-n>gvc"
        else
            return "\<c-\>\<c-n>gvo\<c-g>"
        endif
    else
        if s:doappend == 1
            if g:completekey == "<tab>"
                return "\<tab>"
            endif
        endif
        return ''
    endif
endfunction

function! CodeComplete()
    let s:doappend = 1
    let function_name = matchstr(getline('.')[:(col('.')-2)],'\zs\w*\ze\s*(\s*$')
    if function_name != ''
        let funcres = FunctionComplete(function_name)
        if funcres != ''
            let s:doappend = 0
        endif
        return funcres
    else
        let template_name = substitute(getline('.')[:(col('.')-2)],'\zs.*\W\ze\w*$','','g')
        let tempres = ExpandTemplate(template_name)
        if tempres != ''
            let s:doappend = 0
        endif
        return tempres
    endif
endfunction


" [Get converted file name like __THIS_FILE__ ]
function! GetFileName()
    let filename=expand("%:t")
    let filename=toupper(filename)
    let _name=substitute(filename,'\.','_',"g")
    let _name="__"._name."__"
    return _name
endfunction

"asks the user to select a snippet from the given list
"
"returns the body of the chosen snippet
function! s:ChooseSnippet(snippets)
    "build the dialog/choice list
    let prompt = "Choose a snippet:\n\n"
    let i = 0
    while i < len(a:snippets)
        let prompt .= i+1 . "." . substitute(a:snippets[i], "\r", '<CR>', 'g') . "\n"
        let i += 1
    endwhile
    let prompt .= "\nType a number:"

    "input(save|restore) needed because this function is called during a
    "mapping
    redraw!
    echon prompt
    call inputsave()
    let choice = nr2char(getchar())
    call inputrestore()
    redraw!

    if choice !~ '^\d*$' || choice < 1 || choice > len(a:snippets)
        return ""
    endif

    return a:snippets[choice-1]
endfunction


"removes a set of default markers for the current cursor postion
"
"i.e. turn this
"   foo `<=foobar>` foo

"into this
"
"  foo foobar foo
function! s:RemoveDefaultMarkers()
    let col = col(".")

    "check for default markers at current position
    if strpart(getline('.'), col-1, strlen(g:rsd)) == g:rsd

        "remove them
        let line = getline(".")
        let start = col-1
        let startOfBody = start + strlen(g:rsd)
        let end = match(line, g:re, start)
        let line = strpart(line, 0, start) .
            \ strpart(line, startOfBody, end - startOfBody) .
            \ strpart(line, end+strlen(g:re))
        call setline(line("."), line)
    endif
endfunction

function! CodeCompleteAddTemplate(filetype, keyword, expansion)
    if !has_key(s:templates, a:filetype)
        let s:templates[a:filetype] = {}
    endif

    if !has_key(s:templates[a:filetype], a:keyword)
        let s:templates[a:filetype][a:keyword] = []
    endif

    call add(s:templates[a:filetype][a:keyword], a:expansion)
endfunction

function! CodeCompleteAddGlobalTemplate(keyword, expansion)
    call CodeCompleteAddTemplate('_', a:keyword, a:expansion)
endfunction

" vim: set ft=vim ff=unix fdm=marker :
