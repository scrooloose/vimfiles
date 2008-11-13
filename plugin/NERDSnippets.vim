" ============================================================================
" File:        NERDSnippets.vim
" Description: vim global plugin for snippets that own hard
" Maintainer:  Martin Grenfell <martin_grenfell at msn dot com>
" Last Change: 18 October, 2008
" License:     This program is free software. It comes without any warranty,
"              to the extent permitted by applicable law. You can redistribute
"              it and/or modify it under the terms of the Do What The Fuck You
"              Want To Public License, Version 2, as published by Sam Hocevar.
"              See http://sam.zoy.org/wtfpl/COPYING for more details.
"
" Installation:
"   Put this file in your ~/.vim/plugin dir.
"
"
" Defining Snippets:
"   Put all your snippets in ~/.vim/after/plugin/ or split them up for each
"   filetype and put them in ~/.vim/ftplugin
"
"   Use the function NERDSnippet(filetype, keyword, expansion [, name]) for filetype
"   specific snippets.
"
"   Use the function NERDSnippetGlobal(keyword, expansion [, name]) for global
"   snippets (available for all filetypes)
"
"
" Example Snippet: a for loop snippet for java
"   call NERDSnippet("java", "for", "for(<+int i=0+>; <+condition+>; <+i+++>){\<CR><++>\<CR>}")
"
"   There are 4 markers:
"       1. <+int i=0+>
"       2. <+condition+>
"       3. <+i+++>
"       4. <++>
"
"   1, 2 and 3 have default values. When you tab to them, they will be
"   replaced with the text "int i=0", "condition" and "i++".
"
"   4 is an empty marker, these markers are removed when the cursor arrives on
"   them.
"
"
" Example Snippet: validates_presence_of for rails
"   call NERDSnippet("ruby", "vpo", "validates_presence_of :<++><+, :message => '<++>', :on => <++>, :if => <++>+>")
"
"   Notice how the second marker:
"   "<+, :message => '<++>', :on => <++>, :if => <++>+>"
"   has 3 markers nested inside it. When you tab to this marker you can either
"   hit tab again to "tab into" it, or hit backspace/ctrl-h or enter to delete
"   it and move on. This way you can create "optional" parts to a snippet.
"
"
" Example Snippet: global modeline snippet
"   function! ModelineSnippet()
"       let start = substitute(&commentstring, '^\([^ ]*\)\s*%s\(.*\)$', '\1', '')
"       let end = substitute(&commentstring, '^.*%s\(.*\)$', '\1', '')
"       return start . " vim: set <+settings+>:" . end
"   endfunction

"   call NERDSnippetGlobal("modeline", "\<c-r>=ModelineSnippet()\<CR>")
"
"   Here we have a snippet that uses some more complex logic, so we get a
"   function to generate the snippet code for us.
"
"
" Duplicate Keywords:
"   If multiple snippets exist for the same keyword then the script will
"   ask you which one you want to insert.
"
"   You can have up to 9 snippets bound to a single keyword.
"
"   When binding multiple snippets to one keyword, you can assign the snippets
"   a name to make it easier for the user to identify which snippet to use.
"
" Example Snippet: two named snippets bound to a single keyword
"
"   call NERDSnippet("html", "table", "<table>\<CR><++></table>", "simple table")
"   call NERDSnippet("html", "table", "<table class=\"<++>\">\<CR><++></table>", "table with class")
"
"   Notice that we pass the name in as the last argument.
"
"
" Variables:
"   g:NERDSnippets_key                        default: <tab>
"       expands snippets and jumps to markers
"   g:NERDSnippets_marker_start               default: <+
"       start of marker tags
"   g:NERDSnippets_marker_end                 default: +>
"       end of marker tags
"
"==================================================

if v:version < 700
    finish
endif

if exists("loaded_nerd_snippets_plugin")
    finish
endif
let loaded_nerd_snippets_plugin = 1

" Variable Definations: {{{1
" options, define them as you like in vimrc:
if !exists("g:NERDSnippets_key")
    let g:NERDSnippets_key = "<tab>"
endif

if !exists("g:NERDSnippets_marker_start")
    let g:NERDSnippets_marker_start = '<+'
endif
let s:start = g:NERDSnippets_marker_start

if !exists("g:NERDSnippets_marker_end")
    let g:NERDSnippets_marker_end = '+>'
endif
let s:end = g:NERDSnippets_marker_end

let s:topOfSnippet = -1
let s:appendTab = 1
let s:snippets = {}
let s:snippets['_'] = {}

exec "inoremap ".g:NERDSnippets_key." <c-r>=NERDSnippets_ExpandSnippet()<cr><c-r>=NERDSnippets_SwitchRegion(1)<cr>"
exec "nnoremap ".g:NERDSnippets_key." i<c-r>=NERDSnippets_SwitchRegion(0)<cr>"
exec "snoremap ".g:NERDSnippets_key." <esc>i<c-r>=NERDSnippets_SwitchRegion(0)<cr>"


" Snippet class {{{1
let s:Snippet = {}

function s:Snippet.New(expansion, ...)
    let newSnippet = copy(self)
    let newSnippet.expansion = a:expansion
    if a:0
        let newSnippet.name = a:1
    else
        let newSnippet.name = ''
    endif
    return newSnippet
endfunction

function s:Snippet.stringForPrompt()
    if self.name != ''
        return self.name
    else
        return substitute(self.expansion, "\r", '<CR>', 'g')
    endif
endfunction
"}}}1

function! NERDSnippets_ExpandSnippet()
    let snippet_name = substitute(getline('.')[:(col('.')-2)],'\zs.*\W\ze\w*$','','g')
    let snippet = s:SnippetFor(snippet_name)
    if snippet != ''
        let s:appendTab = 0
        let s:topOfSnippet = line('.')
        let snippet = "\<c-w>" . snippet
    else
        let s:appendTab = 1
    endif
    return snippet
endfunction

"jump to the next marker, remove the delimiters and select the text inside in
"select mode
"
"if no markers are found, a <tab> may be inserted into the text
function! NERDSnippets_SwitchRegion(allowAppend)
    if s:topOfSnippet != -1
        call cursor(s:topOfSnippet,1)
        let s:topOfSnippet = -1
    endif

    try
        let markerPos = s:NextMarker()
        let markersEmpty = stridx(getline("."), s:start.s:end) == markerPos[0]-1

        let removedMarkers = 0
        if s:RemoveMarkers()
            let markerPos[1] -= (strlen(s:start) + strlen(s:end))
            let removedMarkers = 1
        endif

        call cursor(line("."), markerPos[0])
        normal! v
        call cursor(line("."), markerPos[1] + strlen(s:end) - 1 + (&selection == "exclusive"))

        if removedMarkers && markersEmpty
            return "\<right>"
        else
            return "\<c-\>\<c-n>gvo\<c-g>"
        endif

    catch /NERDSnippets.NoMarkersFoundError/
        if s:appendTab && a:allowAppend
            if g:NERDSnippets_key == "<tab>"
                return "\<tab>"
            endif
        endif
        "we were called from normal mode so return to normal and move the
        "cursor forward again
        return "\<ESC>l"
    endtry
endfunction

"jump the cursor to the start of the next marker and return an array of the
"for [start_column, end_column], where start_column points to the start of
"<+ and end_column points to the start of +>
function! s:NextMarker()
    let start = searchpos('\V'.s:start.'\.\{-\}'.s:end, 'c')[1]
    if start == 0
        throw "NERDSnippets.NoMarkersFoundError"
    endif

    let l = getline(".")
    let balance = 0
    let i = start-1
    while i < strlen(l)
        if strpart(l, i, strlen(s:start)) == s:start
            let balance += 1
        elseif strpart(l, i, strlen(s:end)) == s:end
            let balance -= 1
        endif

        if balance == 0
            "add 1 for 'string index' => 'column number' conversion
            return [start,i+1]
        endif

        let i += 1

    endwhile
    throw "NERDSnippets.MalformedMarkersError"
endfunction

"asks the user to select a snippet from the given list
"
"returns the body of the chosen snippet
function! s:ChooseSnippet(snippets)
    "build the dialog/choice list
    let prompt = ""
    let i = 0
    while i < len(a:snippets)
        let prompt .= i+1 . ". " . a:snippets[i].stringForPrompt() . "\n"
        let i += 1
    endwhile
    let prompt .= "\nSelect a snippet:"

    "input(save|restore) needed because this function is called during a
    "mapping
    redraw!
    call inputsave()
    if len(a:snippets) < 10
        echon prompt
        let choice = nr2char(getchar())
    else
        let choice = input(prompt)
    endif
    call inputrestore()
    redraw!

    if choice !~ '^\d*$' || choice < 1 || choice > len(a:snippets)
        return ""
    endif

    return a:snippets[choice-1].expansion
endfunction

"get a snippet for the given keyword, if multiple snippets are found then prompt
"the user to choose.
"
"if no snippets are found, return ''
function! s:SnippetFor(keyword)
    let snippets = []
    if has_key(s:snippets,&ft)
        if has_key(s:snippets[&ft],a:keyword)
            let snippets = extend(snippets, s:snippets[&ft][a:keyword])
        endif
    endif
    if has_key(s:snippets['_'],a:keyword)
        let snippets = extend(snippets, s:snippets['_'][a:keyword])
    endif

    if len(snippets)
        if len(snippets) == 1
            return snippets[0].expansion
        else
            return s:ChooseSnippet(snippets)
        endif
    endif

    return ''
endfunction

"removes a set of markers from the current cursor postion
"
"i.e. turn this
"   foo <+foobar+> foo

"into this
"
"  foo foobar foo
function! s:RemoveMarkers()
    try
        let marker = s:NextMarker()
        if strpart(getline('.'), marker[0]-1, strlen(s:start)) == s:start

            "remove them
            let line = getline(".")
            let start = marker[0] - 1
            let startOfBody = start + strlen(s:start)
            let end = marker[1] - 1
            let line = strpart(line, 0, start) .
                        \ strpart(line, startOfBody, end - startOfBody) .
                        \ strpart(line, end+strlen(s:end))
            call setline(line("."), line)
            return 1
        endif
    catch /NERDSnippets.NoMarkersFoundError/
    endtry
endfunction

"add a new snippet for the given filetype and keyword
function! NERDSnippet(filetype, keyword, expansion, ...)
    if !has_key(s:snippets, a:filetype)
        let s:snippets[a:filetype] = {}
    endif

    if !has_key(s:snippets[a:filetype], a:keyword)
        let s:snippets[a:filetype][a:keyword] = []
    endif

    let snippetName = ''
    if a:0
        let snippetName = a:1
    endif

    let newSnippet = s:Snippet.New(a:expansion, snippetName)

    call add(s:snippets[a:filetype][a:keyword], newSnippet)
endfunction

function! Snippets()
    return s:snippets
endfunction


"add a new global snippet for the given keyword
function! NERDSnippetGlobal(keyword, expansion, ...)
    let snippetName = ''
    if a:0
        let snippetName = a:1
    endif
    call NERDSnippet('_', a:keyword, a:expansion, snippetName)
endfunction

"remove all snippets
function! NERDSnippetsReset()
    let s:snippets = {}
    let s:snippets['_'] = {}
endfunction


"Extract snippets from the given directory. The snippet filetype, keyword, and
"possibly name, are all inferred from the path of the .snippet files relative
"to a:dir.
"
"This assumes a precise file naming scheme:
"
"For single snippets
"    a:dir/<filetype>/<keyword>.snippet
"
"eg
"    a:dir/html/href.snippet
"
"For multiple snippets bound to a single keyword
"    a:dir/<filetype>/<keyword>/<snippet-name>.snippet
"
"eg
"    a:dir/html/table/simple.snippet
"    a:dir/html/table/hardcore.snippet
function! NERDSnippetsFromDirectory(dir)
    let snippetFiles = split(globpath(expand(a:dir), '**/*.snippet'), '\n')
    for fullpath in snippetFiles
        let tail = strpart(fullpath, strlen(expand(a:dir)))
        let filetype = substitute(tail, '^/\([^/]*\).*', '\1', '')
        let keyword = substitute(tail, '^/[^/]*\(.*\)', '\1', '')
        call s:extractSnippetFor(fullpath, filetype, keyword)
    endfor
endfunction

"Extract snippets from the given directory for the given filetype.
"
"The snippet keywords (and possibly names) are interred from the path of the
".snippet files relative to a:dir
"
"This assumes a precise file naming scheme:
"
"For single snippets
"    a:dir/<keyword>.snippet
"
"eg
"    a:dir/href.snippet
"
"For multiple snippets bound to a single keyword
"    a:dir/<keyword>/<snippet-name>.snippet
"
"eg
"    a:dir/table/simple.snippet
"    a:dir/table/hardcore.snippet
"
"The main purpose of this function is to allow users to manually associate a
"collection of snippets with a filetype. For example, you probably want all
"your html snippets to also be used for the xhtml filetype. So (somewhere like
" ~/.vim/after/plugin/snippet_setup.vim) you could call this:
"
"    NERDSnippetsFromDirectoryForFiletype('~/.vim/snippets/html', 'xhtml')
"
function! NERDSnippetsFromDirectoryForFiletype(dir, filetype)
    let snippetFiles = split(globpath(expand(a:dir), '**/*.snippet'), '\n')
    for i in snippetFiles
        let base = expand(a:dir)
        let fullpath = expand(i)
        let tail = strpart(fullpath, strlen(base))
        call s:extractSnippetFor(fullpath, a:filetype, tail)
    endfor
endfunction

"create a snippet from the given file
"
"Args:
"fullpath: full path to snippet file
"filetype: the filetype for the new snippet
"tail: the last part of the path containing the keyword and possibly name. eg
" '/class.snippet'   or  '/class/with_constructor.snippet'
function! s:extractSnippetFor(fullpath, filetype, tail)
    let keyword = ""
    let name = ""

    let slashes = strlen(substitute(a:tail, '[^/]', '', 'g'))
    if slashes == 1
        let keyword = substitute(a:tail, '^/\(.*\)\.snippet', '\1', '')
    elseif slashes == 2
        let keyword = substitute(a:tail, '^/\([^/]*\)/.*$', '\1', '')
        let name = substitute(a:tail, '^/[^/]*/\(.*\)\.snippet', '\1', '')
    else
        throw 'NERDSnippets.ScrewedSnippetPathError ' . a:fullpath
    endif

    let snippetContent = s:parseSnippetFile(a:fullpath)

    call NERDSnippet(a:filetype, keyword, snippetContent, name)
endfunction


"Extract and munge the body of the snippet from the given file.
function! s:parseSnippetFile(path)
    try
        let lines = readfile(a:path)
    catch /E484/
        throw "NERDSnippet.ScrewedSnippetPathError " . a:path
    endtry

    let i = 0
    while i < len(lines)
        "remove leading whitespace and add \<CR> to the end of the lines
        if i < len(lines)-1
            let lines[i] = substitute(lines[i], '^\s*\(.*\)$', '\1' . "\<CR>", "")
        endif

        "make \<C-R>= function in the templates
        let lines[i] = substitute(lines[i], '\c\\<c-r>=', "\<c-r>=", "g")

        "make \<C-O>= function in the templates
        let lines[i] = substitute(lines[i], '\c\\<c-o>', "\<c-o>", "g")

        "make \<CR> function in templates
        let lines[i] = substitute(lines[i], '\c\\<cr>', "\<cr>", "g")

        let i += 1
    endwhile

    return join(lines, '')
endfunction

" vim: set ft=vim ff=unix fdm=marker :
