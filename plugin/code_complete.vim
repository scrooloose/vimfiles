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
"       "<tab>" (default value of g:code_complete_complete_key) Do all the
"       jobs with this key
"
"   example:
"       press <tab> after function name and (
"         foo ( <tab>
"       becomes:
"         foo ( <+first param+>,<+second param+> )
"       press <tab> after code template
"         if <tab>
"       becomes:
"         if( <+...+> )
"         {
"             <+...+>
"         }
"
"
" Variables:
"   g:code_complete_complete_key               default: <tab>
"       the key used to complete function parameters and key words.
"   g:code_complete_marker_start               default: <+
"       region start
"   g:code_complete_marker_end                 default: +>
"       region end
"   g:code_complete_marker_start_default       default: <+=
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
"   call CodeCompleteAddTemplate("java", "for", "for(<+=int i=0+>; <+condition+>; <+=i+++>){\<CR><++>\<CR>}")
"
"   There are 4 markers:
"       1. <+=int i=0+>
"       2. <+condition+>
"       3. <+=i+++>
"       4. <++>
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

if exists("loaded_code_complete_plugin")
    finish
endif
let loaded_code_complete_plugin = 1

" Variable Definations: {{{1
" options, define them as you like in vimrc:
if !exists("g:code_complete_complete_key")
    let g:code_complete_complete_key = "<tab>"
endif

if !exists("g:code_complete_marker_start")
    let g:code_complete_marker_start = '<+'
endif
let s:rs = g:code_complete_marker_start

if !exists("g:code_complete_marker_end")
    let g:code_complete_marker_end = '+>'
endif
let s:re = g:code_complete_marker_end

if !exists("g:code_complete_marker_start_default")
    let g:code_complete_marker_start_default = '<+='
endif
let s:rsd = g:code_complete_marker_start_default

" ----------------------------
let s:expanded = 0  "in case of inserting char after expand
let s:signature_list = []
let s:jumppos = -1
let s:doappend = 1
let s:templates = {}
let s:templates['_'] = {}

command! -nargs=0 CodeCompleteStart call s:CodeCompleteStart()
command! -nargs=0 CodeCompleteStop call s:CodeCompleteStop()

" Autocommands: {{{1
autocmd BufReadPost,BufNewFile * CodeCompleteStart

" Menus:
menu <silent>       &Tools.Code\ Complete\ Start          :CodeCompleteStart<cr>
menu <silent>       &Tools.Code\ Complete\ Stop           :CodeCompleteStop<cr>

" Function Definations: {{{1

function! s:CodeCompleteStart()
    exec "silent! iunmap  <buffer> ".g:code_complete_complete_key
    exec "silent! nunmap  <buffer> ".g:code_complete_complete_key
    exec "inoremap <buffer> ".g:code_complete_complete_key." <c-r>=CodeComplete()<cr><c-r>=CodeComplete_SwitchRegion(0)<cr>"
    exec "nnoremap <buffer> ".g:code_complete_complete_key." i<c-r>=CodeComplete_SwitchRegion(0)<cr>"
    exec "snoremap <buffer> ".g:code_complete_complete_key." <esc>i<c-r>=CodeComplete_SwitchRegion(1)<cr>"
endfunction

function! s:CodeCompleteStop()
    exec "silent! iunmap <buffer> ".g:code_complete_complete_key
    exec "silent! nunmap <buffer> ".g:code_complete_complete_key
    exec "silent! sunmap <buffer> ".g:code_complete_complete_key
endfunction

function! s:FunctionComplete(fun)
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
                    let tmp=substitute(i.signature,',',s:re.','.s:rs,'g')
                    let tmp=substitute(tmp,'(\(.*\))',s:rs.'\1'.s:re.')','g')
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

function! s:ExpandTemplate(cword)
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

function! CodeComplete_SwitchRegion(removeDefaults)
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

    try
        let marker = s:NextMarker()

        call cursor(line("."), marker[0])
        normal v
        call cursor(line("."), marker[1] + strlen(s:re) - 1)
        if &selection == "exclusive"
            exec "norm " . "\<right>"
        endif

        "if the place holders are empty
        if (marker[1] + strlen(s:re) - marker[0]) == strlen(s:rs) + strlen(s:re)
            return "\<c-\>\<c-n>gvc"
        else
            return "\<c-\>\<c-n>gvo\<c-g>"
        endif
    catch /CodeComplete.NoMarkersFoundError/
        if s:doappend == 1
            if g:code_complete_complete_key == "<tab>"
                return "\<tab>"
            endif
        endif
        return ''
    endtry
endfunction

"jump the cursor to the start of the next marker and return an array of the
"for [start_column, end_column], where start_column points to the start of
"<+/<+= and end_column points to the start of +>
function! s:NextMarker()
    let start = searchpos('\V\('.s:rs.'\|'.s:rsd.'\)'.'\.\{-\}'.s:re, 'c')[1]
    if start == 0
        throw "CodeComplete.NoMarkersFoundError"
    endif

    let l = getline(".")
    let balance = 0
    let i = start-1
    while i < strlen(l)
        if strpart(l, i, strlen(s:rs)) == s:rs
            let balance += 1
        elseif strpart(l, i, strlen(s:rsd)) == s:rsd
            let balance += 1
        elseif strpart(l, i, strlen(s:re)) == s:re
            let balance -= 1
        endif

        if balance == 0
            "add 1 for 'string index' => 'column number' conversion
            return [start,i+1]
        endif

        let i += 1

    endwhile
    throw "CodeComplete.MalformedMarkersError"
endfunction


function! CodeComplete()
    let s:doappend = 1
    let function_name = matchstr(getline('.')[:(col('.')-2)],'\zs\w*\ze\s*(\s*$')
    if function_name != ''
        let funcres = s:FunctionComplete(function_name)
        if funcres != ''
            let s:doappend = 0
        endif
        return funcres
    else
        let template_name = substitute(getline('.')[:(col('.')-2)],'\zs.*\W\ze\w*$','','g')
        let tempres = s:ExpandTemplate(template_name)
        if tempres != ''
            let s:doappend = 0
        endif
        return tempres
    endif
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
"   foo <+=foobar+> foo

"into this
"
"  foo foobar foo
function! s:RemoveDefaultMarkers()
    "try
        let marker = s:NextMarker()
        if strpart(getline('.'), marker[0]-1, strlen(s:rsd)) == s:rsd

            "remove them
            let line = getline(".")
            let start = marker[0] - 1
            let startOfBody = start + strlen(s:rsd)
            let end = marker[1] - 1
            let line = strpart(line, 0, start) .
                        \ strpart(line, startOfBody, end - startOfBody) .
                        \ strpart(line, end+strlen(s:re))
            call setline(line("."), line)
        endif
    "catch /CodeComplete.NoMarkersFoundError/
    "endtry
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
