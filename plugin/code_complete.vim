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
"           hotkey:
"               "<tab>" (default value of g:completekey)
"               Do all the jobs with this key, see
"           example:
"               press <tab> after function name and (
"                 foo ( <tab>
"               becomes:
"                 foo ( `<first param>`,`<second param>` )
"               press <tab> after code template
"                 if <tab>
"               becomes:
"                 if( `<...>` )
"                 {
"                     `<...>`
"                 }
"
"
"           variables:
"
"               g:completekey
"                   the key used to complete function
"                   parameters and key words.
"
"               g:rs, g:re
"                   region start and stop
"               you can change them as you like.
"
"           key words:
"               see "templates" section.
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
    exec "inoremap <buffer> ".g:completekey." <c-r>=CodeComplete()<cr><c-r>=SwitchRegion()<cr>"
endfunction

function! CodeCompleteStop()
    exec "silent! iunmap <buffer> ".g:completekey
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
    if has_key(s:templates,&ft)
        if has_key(s:templates[&ft],a:cword)
            let s:jumppos = line('.')

            if len(s:templates[&ft][a:cword]) == 1
                return "\<c-w>" . s:templates[&ft][a:cword][0]
            else
                return "\<c-w>" . s:ChooseSnippet(&filetype, a:cword)
            endif
        endif
    endif
    if has_key(s:templates['_'],a:cword)
        let s:jumppos = line('.')
        if len(s:templates['_'][a:cword]) == 1
            return "\<c-w>" . s:templates['_'][a:cword][0]
        else
            return "\<c-w>" . s:ChooseSnippet('_', a:cword)
        endif
    endif
    return ''
endfunction

function! SwitchRegion()
    if len(s:signature_list)>1
        let s:signature_list=[]
        return ''
    endif
    if s:jumppos != -1
        call cursor(s:jumppos,0)
        let s:jumppos = -1
    endif
    if match(getline('.'),g:rs.'.*'.g:re)!=-1 || search(g:rs.'.\{-}'.g:re)!=0
        normal 0
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

"asks the user to select a snippet for the given keyword
"
"returns the body of the chosen snippet
function! s:ChooseSnippet(filetype, keyword)
    "build the dialog/choice list
    let choices = ["Choose a snippet:"]
    let i = 0
    while i < len(s:templates[a:filetype][a:keyword])
        call add(choices, i+1 . "." . substitute(s:templates[a:filetype][a:keyword][i], "\r", '<CR>', 'g'))
        let i += 1
    endwhile

    "input(save|restore) needed because this function is called during a
    "mapping
    call inputsave()
    let choice = inputlist(choices)
    call inputrestore()
    redraw!

    if choice <= 0 || choice >= len(choices)
        echoerr "Invalid choice"
        return ""
    endif

    return s:templates[a:filetype][a:keyword][choice-1]
endfunction

" Templates: {{{1
"
" To add new templates, use the CodeCompleteAddTemplate() function below.
"
" Example:
"
"  call CodeCompleteAddTemplate('java', 'println', 'System.out.println('.g:rs.g:re.')')
"
function! CodeCompleteAddTemplate(filetype, keyword, expansion)
    if !has_key(s:templates, a:filetype)
        let s:templates[a:filetype] = {}
    endif

    if !has_key(s:templates[a:filetype], a:keyword)
        let s:templates[a:filetype][a:keyword] = []
    endif

    call add(s:templates[a:filetype][a:keyword], a:expansion)
endfunction

" vim: set ft=vim ff=unix fdm=marker :
