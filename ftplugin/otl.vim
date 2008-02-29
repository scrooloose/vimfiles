" TVO: The Vim Outliner.
" Functions, mappings, and macros that implement an outliner similar to
" WinWord
"
" $Id: otl.vim,v 1.62 2003/12/23 23:45:18 ned Exp $
"
" Maintainer: Ned Konz <vim@bike-nomad.com>
"
" Uses marks o and p
"
if exists("b:did_ftplugin")
  finish
endif

let b:did_ftplugin = 1  " Don't load another plugin for this buffer

" Make sure the '<' and 'C' flags are not included in 'cpoptions', otherwise
" <CR> would not be recognized.  See ":help 'cpoptions'".
let s:cpo_save = &cpo
set cpo&vim

" Global Defaults
" These may be overridden in the user .vimrc file.
if !exists("g:otl_bold_headers")
  let g:otl_bold_headers = 1    " set to 0 if you don't want bold headers
endif
if !exists("g:otl_install_menu")
  let g:otl_install_menu = 1    " set to 0 if you don't want an Outliner menu
endif
if !exists("g:otl_install_toolbar")
  let g:otl_install_toolbar = 1 " set to 0 if you don't want Outliner toolbar buttons
  echo "setting install toolbar"
endif
" backwards compatibility:
if exists("g:otl_install_mappings") && !exists("g:no_otl_maps")
  let g:no_otl_maps = !g:otl_install_mappings
endif
if !exists("g:no_otl_maps")
  let g:no_otl_maps = 0         " set to 1 if you don't want TVO mappings installed
endif
if !exists("g:otl_map_tabs")
  let g:otl_map_tabs = 0     " set to 1 if you want TVO to map <Tab> and <S-Tab> to demote and promote
endif
if !exists("g:otl_text_view")
  let g:otl_text_view = 0       " set to 1 if you want to start in text view
endif
if !exists("g:otl_use_thlnk")
  let g:otl_use_thlnk = exists('*Thlnk_processUrl')   " set to 0 if you don't want to use thlnk and it's installed
endif
" backwards compatibility:
if exists("g:otl_install_insert_mappings") && !exists("g:no_otl_insert_maps")
  let g:no_otl_insert_maps = !g:otl_install_insert_mappings
endif
if !exists("g:no_otl_insert_maps")
  let g:no_otl_insert_maps = 0  " set to 1 if you don't want to install insert-mode mappings too
endif

" Define maplocalleader in your .vimrc if you want
" for instance:
"   let maplocalleader = ","
if !exists("maplocalleader")
  " it isn't set; use mapleader if set, or just backslash.
  if exists("mapleader")
    let maplocalleader = mapleader
  else
    let maplocalleader = "\\"
  endif
endif

" Load functions
" Make sure we only load functions once, using script var
if !exists("s:otl_loaded_functions")
  let s:otl_loaded_functions = 1

  let s:spaces = "                                                                                "

  " Match the optional tabs at the beginning of header or text lines
  let s:tabsAtBeginningOfLine = '\_^\t*'
  let s:beginningOfHeaderLine = s:tabsAtBeginningOfLine . '\ze[^|\t]'
  let s:beginningOfTextLine = s:tabsAtBeginningOfLine . '\ze|\s*'
  let s:beginningOfAnyLine = s:tabsAtBeginningOfLine . '\%(|\s*\ze\|\ze[^|\t]\)'  "non-content prefix
  let s:textWithMarkers = '| [-*]'

  " Make a more outline-friendly fold view.
  " Must not be a script function
  function OtlFoldText()
    let originalLine = getline(v:foldstart)
    let line = substitute(originalLine, s:tabsAtBeginningOfLine, '', '')
    let prefix = strpart(s:spaces, 0, (&tabstop * (strlen(originalLine) - strlen(line))))
    return prefix . line
  endfunction

  " Group parents with their children.
  " Must not be a script function
  function OtlFoldLevel(n)
    let thisLine = getline(a:n)
    if (thisLine == '')
      return '='
    endif
    " Count tabs. Could be 0.
    let thisLevel = matchend(thisLine, s:tabsAtBeginningOfLine)
    " Recognize text lines, which start with optional tabs and a '|'
    " Text is considered foldlevel 10.
    if (thisLine[thisLevel] == '|')
      let priorLine = getline(a:n - 1)
      if (priorLine[thisLevel] == thisLine[thisLevel])
        return '10'
      else
        return '>10'
      endif
    " And headers have their own level. Each starts a new fold.
    else
      return '>' . (thisLevel + 1)
    endif
  endfunction

  " return true if the given string is a header
  function s:OtlIsHeaderString(string)
    return match(a:string, s:beginningOfHeaderLine) >= 0
  endfunction

  " return true if the given line (including '.') is a header
  function s:OtlIsHeaderLine(linenum)
    return s:OtlIsHeaderString(getline(a:linenum))
  endfunction

  " delete extra blank lines in current buffer
  " TODO: leaves two blank lines in some cases
  function s:OtlCompressBlankLines()
    exe "1,$s/\\m\\s\\{-}\\n\\{3,}/\<CR>\<CR>/"
  endfunction

  " Put in new blank lines between text blocks
  " before new markers
  function s:OtlInsertBreaks()
    set lz
    let i = 1
    let lastIndent = 0
    while (i < line('$'))
      let line = getline(i)
      let indent = matchend(line, s:tabsAtBeginningOfLine)
      if (indent >= 0)
        let marker = strpart(line, indent, 3)
        if ((indent != lastIndent) || (marker =~ s:textWithMarkers))
          call append(i-1, '')
          let i = i + 1
        endif
      endif
      let lastIndent = indent
      let i = i + 1
    endwhile
    set nolz
  endfunction

  " This copies just the text from the current window into a
  " new window and re-formats it.
  function s:OtlExtractText()
    set lz
    " get text from current buffer
    1,$yank
    " make a new window and switch to it
    new
    " put yanked text into new window
    put!
    " delete un-marked headers
    silent! g/\m^\t*[^|+\t]/s/.*//
    " remove heading markers
    silent! g/\m^\t*+\s*\(.*\)/s//\r== \1\r/
    " Put in new blank lines between text blocks with different markers
    call s:OtlInsertBreaks()
    call s:OtlCompressBlankLines()
    " remove text markers and tabs from lines
    silent! g/\m^\t*| \?/s///
    " kill off modelines (?)
    silent! $-4,$g/\m\<\%(vim\?\|ex\):\s*/d
    " set textwidth
    set tw=80
    " re-format buffer
    normal 1GgqG
    nohlsearch
    " return to last window
    " wincmd p
    " nohlsearch
    set nolz
  endfunction

  " This copies just the text from the current window into a
  " new window and re-formats it.
  function s:OtlExtractHeaders()
    set lz
    let ts = &tabstop
    " get text from current buffer
    1,$yank
    " make a new window and switch to it
    new
    " put yanked text into new window
    put!
    " delete text
    silent! g/\m^\t*|/d
    " kill heading markers
    silent! g/\m^\t*+\s*/s/+\s*//
    call s:OtlCompressBlankLines()
    exe "set syn=otl ts=" . ts . " sw=" . ts
    nohlsearch
    " return to last window
    " wincmd p
    set nolz
  endfunction

  " Try to find bracketed expression at cursor.
  " Returns expression that will set vars mode and tag.
  " This should then be executed.
  function s:OtlBracketTagAndModeAtCursor()
    let line = getline('.')
    let patt = '[[<][^]>]*\%' . col('.') . 'c[^]>]*[]>]'
    let tag = matchstr(line, patt)  " with brackets
    return "let mode=\"" . strpart(tag, 0, 1) . "\" | let tag=\"" . strpart(tag, 1, strlen(tag) - 2) . "\""
  endfunction

  " Handle a left double-click. Either follow a tag or toggle the folding.
  function s:OtlDoubleClick()
    execute s:OtlBracketTagAndModeAtCursor()
    if tag == ""
      normal! za
    else
      call s:OtlTagJump()
    end
  endfunction

  " Either do a tag-jump, or call Thlnk to do a jump.
  function s:OtlTagJump()
    execute s:OtlBracketTagAndModeAtCursor()
    if g:otl_use_thlnk && mode == '<'
      mark `
      return Thlnk_goUrl('edit')
    endif
    if tag == ""
      let tag = expand("<cword>")
    end
    let v:errmsg = ""
    silent! exe "tag " . tag
    if (v:errmsg != "")
      if filereadable(tag)
        exe "edit " . tag
      elseif (tag[0] == ":")
        exe tag
      else
        echom "tag \"" . tag . "\" not found"
      endif
    endif
  endfunction

  " Either do a tag-return, or  jump back
  function s:OtlTagReturn()
    if g:otl_use_thlnk
      exe "normal! \<C-O>"
    else
      exe "normal! \<C-T>"
    endif
  endfunction

  " Open a line after the current line
  function s:OtlOpenLineAfter(after)
    set lz
    let line = getline(a:after)
    let prefix = matchstr(line, s:beginningOfAnyLine)
    let prefixLength = strlen(prefix)
    if line[prefixLength-1] == '|'
      let prefix = prefix . ' '
    endif
    let d = append(a:after, prefix)
    call cursor( a:after+1, prefixLength )
    set nolz
  endfunction

  function s:OtlOpenLineBefore(n)
    call s:OtlOpenLineAfter(a:n-1)
  endfunction

  " Upon hitting a Ctrl-CR in insert mode, switch from header to text mode or
  " vice versa.
  function s:OtlSwitchOpen(here)
    set lz
    let prefix = matchstr(getline(a:here), s:beginningOfAnyLine)
    let len = strlen(prefix)
    if len == 0 || strpart(prefix, len-1) == "\t"
      let prefix = prefix . "| "
    else
      let prefix = substitute(prefix, '[^\t]*$', '', '')
    endif
    call append(a:here, prefix)
    call cursor(a:here+1, strlen(prefix) + 1)
    set nolz
  endfunction

  function s:OtlSavePos()
    normal! mp
    let b:saveHlsearch = &hlsearch
  endfunction

  function s:OtlRestorePos()
    normal! `p
    let &hlsearch = b:saveHlsearch
  endfunction

  " Toggle the text mode, and echo the new mode
  " Save the fold level for returning to outline mode
  function s:OtlToggleTextView()
    let g:otl_text_view = ! g:otl_text_view
    call s:OtlRefreshTextView()
  endfunction

  function s:OtlRefreshTextView()
    call s:OtlSavePos()
    if g:otl_text_view
      g/\m^\t*|/normal zO
    else
      normal zX
    endif
    call s:OtlRestorePos()
  endfunction

  function s:OtlJoinLines(line1, line2)
    let lastLine = a:line2 - 1
    if (lastLine < a:line1)
      let lastLine = a:line1
    endif
    call cursor(a:line1, 0)
    call s:OtlSavePos()
    set lz
    exe a:line1 . ',' . lastLine . 's/\m\s*\n\t*|\?\s*/ /e'
    set nolz
    call s:OtlRestorePos()
  endfunction

  function s:OtlSetFoldLevel(n)
    let &l:foldlevel = a:n
    call s:OtlRefreshTextView()
  endfunction

  " Make sure that all headers that are marked with a +
  " are visible
  function s:OtlViewSavedHeaders()
    g/\m^\t*+/normal zv
  endfunction

  " return the line number of the top of the fold at the given line
  function s:OtlTopOfFold(line)
    let line = a:line
    let thisLevel = foldlevel(line)
    let line = line - 1
    while foldlevel(line) == thisLevel
      let line = line - 1
    endwhile
    return line + 1
  endfunction

  function s:OtlTopOfCurrent()
    return s:OtlTopOfFold(line('.'))
  endfunction

  " return the line number of the bottom of the fold at the given line
  function s:OtlBottomOfFold(line)
    let line = a:line
    let thisLevel = foldlevel(line)
    let line = line + 1
    while foldlevel(line) == thisLevel
      let line = line + 1
    endwhile
    return line - 1
  endfunction

  function s:OtlBottomOfCurrent()
    return s:OtlBottomOfFold(line('.'))
  endfunction

  " Re-format the current fold, maintaining sentences on separate lines if
  " that's the way they were entered.
  function s:OtlReFormat()
    call s:OtlSavePos()
    set lz
    let top = s:OtlTopOfCurrent()
    let bot = s:OtlBottomOfCurrent()
    let bob = line('$')
    call cursor(top, 0)
    while line('.') <= bot && line('.') < bob
      " mark start
      normal! mo
      " find end of next sentence
      call search("[.!?][])\"']*\\($\\|\s\\)", 'W')
      if line('.') > bot
        exe 'normal! ' . bot . 'G'
      endif
      " format to start and move down a line
      normal! gqg`o
      let bot = s:OtlBottomOfCurrent()
      let bob = line('$')
      normal! j
    endwhile
    set nolz
    call s:OtlRestorePos()
  endfunction

  " Re-format the current fold, joining sentences
  function s:OtlReFormatAndJoin()
    call cursor(s:OtlTopOfCurrent(), 0)
    call s:OtlSavePos()
    exe "normal! gq" . s:OtlBottomOfCurrent() . "G"
    call s:OtlRestorePos()
  endfunction

  function s:OtlAddMenuEntry(str)
    exe 'nmenu ' . substitute(a:str, '\\\\', g:maplocalleader, '')
    exe 'vmenu ' . substitute(a:str, '\\\\', g:maplocalleader, '')
    exe 'imenu ' . substitute(a:str, '\\\\', g:maplocalleader, '')
  endfunction

  function s:OtlCreateMenu()
    call s:OtlAddMenuEntry('&Outliner.&Delete\ Level<tab>\\D      <LocalLeader>D')
    call s:OtlAddMenuEntry('&Outliner.&Change\ Level<tab>\\C      <LocalLeader>C')
    call s:OtlAddMenuEntry('&Outliner.&Yank\ Level<tab>\\y        <LocalLeader>y')
    call s:OtlAddMenuEntry('&Outliner.Change\ Text/Head<tab>\\b   <LocalLeader>b')
    call s:OtlAddMenuEntry('&Outliner.Put\ &Before<tab>\\P        <LocalLeader>P')
    call s:OtlAddMenuEntry('&Outliner.&Put\ After<tab>\\p         <LocalLeader>p')
    amenu &Outliner.-Sep1-                      :
    call s:OtlAddMenuEntry('&Outliner.Show\ &All<tab>\\a          <LocalLeader>a')
    call s:OtlAddMenuEntry('&Outliner.Toggle\ &Text\ View<tab>\\t <LocalLeader>t')
    call s:OtlAddMenuEntry('&Outliner.Level\ &1<tab>\\1           <LocalLeader>1')
    call s:OtlAddMenuEntry('&Outliner.Level\ &2<tab>\\2           <LocalLeader>2')
    call s:OtlAddMenuEntry('&Outliner.Level\ &3<tab>\\3           <LocalLeader>3')
    call s:OtlAddMenuEntry('&Outliner.Level\ &4<tab>\\4           <LocalLeader>4')
    call s:OtlAddMenuEntry('&Outliner.Level\ &5<tab>\\5           <LocalLeader>5')
    call s:OtlAddMenuEntry('&Outliner.Level\ &6<tab>\\6           <LocalLeader>6')
    call s:OtlAddMenuEntry('&Outliner.Level\ &7<tab>\\7           <LocalLeader>7')
    call s:OtlAddMenuEntry('&Outliner.Level\ &8<tab>\\8           <LocalLeader>8')
    call s:OtlAddMenuEntry('&Outliner.Level\ &9<tab>\\9           <LocalLeader>9')
    amenu &Outliner.-Sep2-                      :
    call s:OtlAddMenuEntry('&Outliner.Extract\ &Text<tab>\\T      <LocalLeader>T')
    call s:OtlAddMenuEntry('&Outliner.Extract\ &Headers<tab>\\H   <LocalLeader>H')
    amenu &Outliner.-Sep3-                      :
    amenu &Outliner.Help                        :he outliner<cr>

  endfunction

  function s:OtlCreateToolbar()
    amenu 1.140 ToolBar.-TVOsep0-      <Nop>
    vmenu 1.140 ToolBar.-TVOsep0-      <Nop>
    omenu 1.140 ToolBar.-TVOsep0-      <Nop>

    amenu icon=TVO/left       1.142 ToolBar.TVO/left        <LocalLeader><
    vmenu icon=TVO/left       1.142 ToolBar.TVO/left        <LocalLeader><
    amenu icon=TVO/right      1.144 ToolBar.TVO/right       <LocalLeader>>
    vmenu icon=TVO/right      1.144 ToolBar.TVO/right       <LocalLeader>>
    amenu icon=TVO/bodytext   1.146 ToolBar.TVO/bodytext    <LocalLeader>b
    vmenu icon=TVO/bodytext   1.146 ToolBar.TVO/bodytext    <LocalLeader>b
    amenu icon=TVO/up         1.148 ToolBar.TVO/up          <LocalLeader>u
    vmenu icon=TVO/up         1.148 ToolBar.TVO/up          <LocalLeader>u
    amenu icon=TVO/down       1.150 ToolBar.TVO/down        <LocalLeader>d
    vmenu icon=TVO/down       1.150 ToolBar.TVO/down        <LocalLeader>d

    amenu 1.152 ToolBar.-TVOsep1-      <Nop>
    vmenu 1.152 ToolBar.-TVOsep1-      <Nop>
    omenu 1.152 ToolBar.-TVOsep1-      <Nop>

    amenu icon=TVO/plus       1.154 ToolBar.TVO/plus        <LocalLeader>+
    amenu icon=TVO/minus      1.156 ToolBar.TVO/minus       <LocalLeader>-

    amenu 1.158 ToolBar.-TVOsep2-      <Nop>
    vmenu 1.158 ToolBar.-TVOsep2-      <Nop>
    omenu 1.158 ToolBar.-TVOsep2-      <Nop>

    amenu icon=TVO/1          1.160 ToolBar.TVO/1           <LocalLeader>1
    amenu icon=TVO/2          1.162 ToolBar.TVO/2           <LocalLeader>2
    amenu icon=TVO/3          1.164 ToolBar.TVO/3           <LocalLeader>3
    amenu icon=TVO/4          1.166 ToolBar.TVO/4           <LocalLeader>4
    amenu icon=TVO/5          1.168 ToolBar.TVO/5           <LocalLeader>5
    amenu icon=TVO/6          1.170 ToolBar.TVO/6           <LocalLeader>6
    amenu icon=TVO/7          1.172 ToolBar.TVO/7           <LocalLeader>7
    amenu icon=TVO/all        1.174 ToolBar.TVO/all         <LocalLeader>a
    amenu icon=TVO/firstline  1.176 ToolBar.TVO/firstline   <LocalLeader>t

    tmenu 1.142 ToolBar.TVO/left        Promote a heading and its subheads and text
    tmenu 1.144 ToolBar.TVO/right       Demote a heading and its subheads and text
    tmenu 1.146 ToolBar.TVO/bodytext    Convert a heading to body text
    tmenu 1.148 ToolBar.TVO/up          Move a heading up with its subheads and text
    tmenu 1.150 ToolBar.TVO/down        Move a heading down with its subheads and text
    tmenu 1.154 ToolBar.TVO/plus        Expand a heading or text block
    tmenu 1.156 ToolBar.TVO/minus       Collapse a heading or text block
    tmenu 1.160 ToolBar.TVO/1           Display outline level 1
    tmenu 1.162 ToolBar.TVO/2           Display outline level 2
    tmenu 1.164 ToolBar.TVO/3           Display outline level 3
    tmenu 1.166 ToolBar.TVO/4           Display outline level 4
    tmenu 1.168 ToolBar.TVO/5           Display outline level 5
    tmenu 1.170 ToolBar.TVO/6           Display outline level 6
    tmenu 1.172 ToolBar.TVO/7           Display outline level 7
    tmenu 1.174 ToolBar.TVO/all         Display all outline levels and text
    tmenu 1.176 ToolBar.TVO/firstline   Toggle view of full text
  endfunction

  function s:OtlRemoveToolbar()
    aunmenu ToolBar.-TVOsep0-
    aunmenu ToolBar.TVO/left
    aunmenu ToolBar.TVO/right
    aunmenu ToolBar.TVO/bodytext
    aunmenu ToolBar.TVO/up
    aunmenu ToolBar.TVO/down
    aunmenu ToolBar.-TVOsep1-
    aunmenu ToolBar.TVO/plus
    aunmenu ToolBar.TVO/minus
    aunmenu ToolBar.-TVOsep2-
    aunmenu ToolBar.TVO/1
    aunmenu ToolBar.TVO/2
    aunmenu ToolBar.TVO/3
    aunmenu ToolBar.TVO/4
    aunmenu ToolBar.TVO/5
    aunmenu ToolBar.TVO/6
    aunmenu ToolBar.TVO/7
    aunmenu ToolBar.TVO/all
    aunmenu ToolBar.TVO/firstline
  endfunction

  function s:OtlEnableToolbar()
    menu enable ToolBar.-TVOsep0-
    menu enable ToolBar.TVO/left
    menu enable ToolBar.TVO/right
    menu enable ToolBar.TVO/bodytext
    menu enable ToolBar.TVO/up
    menu enable ToolBar.TVO/down
    menu enable ToolBar.-TVOsep1-
    menu enable ToolBar.TVO/plus
    menu enable ToolBar.TVO/minus
    menu enable ToolBar.-TVOsep2-
    menu enable ToolBar.TVO/1
    menu enable ToolBar.TVO/2
    menu enable ToolBar.TVO/3
    menu enable ToolBar.TVO/4
    menu enable ToolBar.TVO/5
    menu enable ToolBar.TVO/6
    menu enable ToolBar.TVO/7
    menu enable ToolBar.TVO/all
    menu enable ToolBar.TVO/firstline
  endfunction

  function s:OtlDisableToolbar()
    menu disable ToolBar.-TVOsep0-
    menu disable ToolBar.TVO/left
    menu disable ToolBar.TVO/right
    menu disable ToolBar.TVO/bodytext
    menu disable ToolBar.TVO/up
    menu disable ToolBar.TVO/down
    menu disable ToolBar.-TVOsep1-
    menu disable ToolBar.TVO/plus
    menu disable ToolBar.TVO/minus
    menu disable ToolBar.-TVOsep2-
    menu disable ToolBar.TVO/1
    menu disable ToolBar.TVO/2
    menu disable ToolBar.TVO/3
    menu disable ToolBar.TVO/4
    menu disable ToolBar.TVO/5
    menu disable ToolBar.TVO/6
    menu disable ToolBar.TVO/7
    menu disable ToolBar.TVO/all
    menu disable ToolBar.TVO/firstline
  endfunction

  function s:OtlEnableMenus()
    amenu enable Outliner
    if g:otl_install_toolbar > 0
      if has("gui_win32")
        call s:OtlCreateToolbar()
      else
        call s:OtlEnableToolbar()
      endif
    endif
  endfunction

  function s:OtlDisableMenus()
    amenu disable Outliner
    if g:otl_install_toolbar > 0
      if has("gui_win32")
        call s:OtlRemoveToolbar()
      else
        call s:OtlDisableToolbar()
      endif
    endif
  endfunction

  " Make sure that the fold at the cursor is closed without closing the
  " parent. Returns non-zero if the fold was not closed.
  function s:OtlCloseThisFold()
    let foldWasClosed = foldclosed('.') > 0
    if (! foldWasClosed)
      normal zc
    endif
    return foldWasClosed
  endfunction
 
  " Make sure that the fold at the cursor is opened without opening the
  " parent. Returns non-zero if the fold was not closed
  function s:OtlOpenThisFold()
    let foldWasClosed = foldclosed('.') > 0
    if (foldWasClosed)
      normal zo
    endif
    return foldWasClosed
  endfunction

  " Make sure that the fold at the cursor is closed without closing the
  " parent. Then execute the given normal mode command.
  " Open up again afterwards.
  function s:OtlDoWhileClosed(cmd)
    set lz
    let foldWasClosed = foldclosed('.') > 0
    if (! foldWasClosed)
      normal zc
    endif
    set nolz
    exe 'normal ' . a:cmd
    if (! foldWasClosed)
      normal zo
    endif
  endfunction
 
  " Move the current head (and subheads/text) down by the
  " (possibly negative) given number of lines.
  function s:OtlMoveDownBy(lines)
    set lz
    " Delete the fold after making sure it's closed
    let foldWasClosed = s:OtlCloseThisFold()
    normal dd
    " Now find a good line to put the chunk after.
    let lines = a:lines
    if lines > 0
      let lines = lines - 1
    endif
    while (lines != 0)
      call s:OtlTopOfCurrent()
      if (lines > 0)
        normal j
        let lines = lines - 1
      else
        normal 2k
        let lines = lines + 1
      endif
    endwhile
    put
    if (! foldWasClosed)
      normal zo
    endif
    set nolz
    " redraw
  endfunction

  " Move the cursor to the next/previous heading
  function s:OtlJump(direction)
    if (a:direction > 0)
      call search("^\\t*[a-zA-Z]\\+", "W")
    else
      normal 0
      call search("^\\t*[a-zA-Z]\\+", "bW")
    endif
  endfunction

  " Move to the next heading within this block, skipping over subheadings.
  function s:OtlJumpLev(direction)
    let line = line('.')

    let lev = matchend(getline('.'), s:beginningOfHeaderLine)
    if (lev < 0)
      return -1   " not a heading
    endif

    while(line > 0 && line < line('$'))

     let line = line + a:direction

     let llev = matchend(getline(line), s:beginningOfAnyLine)

     if (llev >= -1)
       if (llev == lev)
         return line
       endif
       if (llev < lev)
         return -1
       endif
     endif

    endwhile

    return -1

  endfunction 

  " Move the current heading up or down by one heading
  function s:OtlShiftHeading(direction)

    set lz
    "If OtlJumpLev returns < 0, then either this line is
    "not a heading or there is no 'next' heading to swap with
    let dest = s:OtlJumpLev(a:direction)
    if (dest < 0)
      return
    endif

    if (a:direction < 0)

      let foldWasClosed = s:OtlCloseThisFold()
      normal dd
      exe "normal ".dest."G"
      normal P

    "moving a heading downwards requires a complicated series of
    "inserts and deletes...
    else

      let foldWasClosed = s:OtlCloseThisFold()
      normal yy
      let locationToDelete = line('.')
      exe "normal ".dest."G"
      
      let destFoldWasClosed = s:OtlCloseThisFold()
      normal p
      if (! destFoldWasClosed)
        normal k
        normal zO
      endif

      exe "normal ".locationToDelete."G"
      normal dd

      exe "normal ".s:OtlJumpLev(1)."G"
    endif

  if (! foldWasClosed)
      normal zo
    endif
    set nolz
  endfunction

  " Shift the current head (and subheads/text) left by the
  " (possibly negative) given number of levels.
  function s:OtlPromoteBy(levels)
    let levels = a:levels
    set lz
    " Make sure the fold is closed
    let foldWasClosed = s:OtlCloseThisFold()
    " now shift it left or right as required.
    while (levels != 0)
      if (levels > 0)
        normal <<
        let levels = levels - 1
      else
        normal >>
        let levels = levels + 1
      endif
    endwhile
    " and reopen the fold.
    if (! foldWasClosed)
      normal zo
    endif
    set nolz
    " redraw
  endfunction

  function s:OtlCountWords()
    call s:OtlExtractText()
    1,$!wc -w
    normal 0cwTotal words: 
    exe "normal z1\<CR>"
    set nomodified
    exe "normal \<c-w>\<c-p>"
  endfunction

  " uses '< and '> as bounds
  function s:OtlToggleBodyTextInRange(firstLine, lastLine)
    let lineNum = a:firstLine
    let block = ""
    while (lineNum <= a:lastLine)
      let line = getline(lineNum)
      if (line =~ s:beginningOfTextLine)
      else
      endif
    endwhile
  endfunction

  " Convert a heading to body text or back
  function s:OtlToggleBodyText()
    let lineNum = line('.')
    let line = getline(lineNum)
    if (line =~ s:beginningOfTextLine)
      normal zO
      let firstLine = lineNum
      let header = substitute(line, '^\(\t*\)|\s*\(.*\)', '\1\2', '')
      exe lineNum . 'd'
      while (lineNum <= line('$'))
        let line = getline(lineNum) 
        if (line !~ s:beginningOfTextLine)
          break
        endif
        exe lineNum . 'd'
        let header = header . substitute(line, s:beginningOfTextLine . '\ze', ' ', '')
      endwhile
      call append(firstLine - 1, header)
      call cursor(firstLine, 0)
    else
      s/^\(\t*\)\([^|\t]\)/\1| \2/
      normal gqj
      call cursor(lineNum, 0)
      nohlsearch
    endif
  endfunction

  " This deals with possible global changes that we have to override.
  " Set no smarttab in outlines.
  " Change the fill text at the end of a fold to be spaces instead of hyphens.
  function s:OtlEnterBuffer()
    let b:stsave=&sta
    set nosta
    let b:fcsave=&fillchars
    set fillchars-=fold:-
    set fillchars+=fold:\ " space
    " Deal with old format of 'backspace'
    let b:bssave=&backspace
    if b:bssave == "0"
      set backspace=""
    elseif b:bssave == "1" || b:bssave == "2"
      set backspace=eol
    endif
    set backspace+=indent
    set backspace+=start
    let b:mmsave=&mousemodel
    set mousemodel=popup_setpos
  endfunction

  function s:OtlExitBuffer()
    let &backspace=b:bssave
    let &fillchars=b:fcsave
    let &sta=b:stsave
    let &mousemodel=b:mmsave
  endfunction

  augroup tvo
    au!
    au BufEnter *.otl silent call <SID>OtlEnterBuffer()
    au BufLeave *.otl silent call <SID>OtlExitBuffer()
  augroup END

endif


" To get into normal mode from any other mode: <C-\><C-N>

" Set mappings (per-buffer)
if !exists("b:otl_installed_mappings")
  let b:otl_installed_mappings = 1

  command! -buffer -range OtlJoin :call s:OtlJoinLines(<line1>,<line2>)

  if !no_otl_maps && (!exists("no_plugin_maps") || !no_plugin_maps)
    " mouse double-click toggles folds.
    nnoremap <buffer><silent><script> <2-LeftMouse>     :call <SID>OtlDoubleClick()<Esc>
    nnoremap <buffer><silent> <3-LeftMouse>             <Nop>
    nnoremap <buffer><silent> <4-LeftMouse>             <Nop>

    " Toggle text mode
    nnoremap <buffer><silent><script> <LocalLeader>t    :call <SID>OtlToggleTextView()<Esc>

    " Open and switch mode
    nnoremap <buffer><silent><script> <C-CR>            :call <SID>OtlSwitchOpen(line('.'))<Esc>a

    " Alternate opens
    nnoremap <buffer><silent><script> <LocalLeader>o    :call <SID>OtlSwitchOpen(line('.'))<Esc>a
    nnoremap <buffer><silent><script> <LocalLeader>O    :call <SID>OtlSwitchOpen(line('.')-1)<Esc>a

    " Select folding level
    nnoremap <buffer><silent><script> <LocalLeader>1    :call <SID>OtlSetFoldLevel(0)<Esc>
    nnoremap <buffer><silent><script> <LocalLeader>2    :call <SID>OtlSetFoldLevel(1)<Esc>
    nnoremap <buffer><silent><script> <LocalLeader>3    :call <SID>OtlSetFoldLevel(2)<Esc>
    nnoremap <buffer><silent><script> <LocalLeader>4    :call <SID>OtlSetFoldLevel(3)<Esc>
    nnoremap <buffer><silent><script> <LocalLeader>5    :call <SID>OtlSetFoldLevel(4)<Esc>
    nnoremap <buffer><silent><script> <LocalLeader>6    :call <SID>OtlSetFoldLevel(5)<Esc>
    nnoremap <buffer><silent><script> <LocalLeader>7    :call <SID>OtlSetFoldLevel(6)<Esc>
    nnoremap <buffer><silent><script> <LocalLeader>8    :call <SID>OtlSetFoldLevel(7)<Esc>
    nnoremap <buffer><silent><script> <LocalLeader>9    :call <SID>OtlSetFoldLevel(8)<Esc>
    " And another one for \a meaning "see everything"
    nnoremap <buffer><silent><script> <LocalLeader>a    :call <SID>OtlSetFoldLevel(10)<CR>
    " Extract text
    nnoremap <buffer><silent><script> <LocalLeader>T    :silent! call <SID>OtlExtractText()<CR>
    " Extract headers
    nnoremap <buffer><silent><script> <LocalLeader>H    :silent! call <SID>OtlExtractHeaders()<CR>

    " Motion to top of current fold
    nnoremap <buffer><script> <SID>TopOfFold            :call cursor(<SID>OtlTopOfCurrent(),0)<CR>
    nnoremap <buffer><script> <Plug>OtlTopOfFold        <SID>TopOfFold
    nmap     <buffer><silent> <LocalLeader>[            <Plug>OtlTopOfFold

    " Motion to bottom of current fold
    nnoremap <buffer><script> <SID>BottomOfFold         :call cursor(<SID>OtlBottomOfCurrent(),0)<CR>
    nnoremap <buffer><script> <Plug>OtlBottomOfFold     <SID>BottomOfFold
    nmap     <buffer><silent> <LocalLeader>]            <Plug>OtlBottomOfFold

    " And simple movement up and down
    nnoremap <buffer><silent><script> <LocalLeader>k    :silent! call <SID>OtlJump(-1)<CR>
    nnoremap <buffer><silent><script> <LocalLeader>j    :silent! call <SID>OtlJump(1)<CR>

    " Move headings up or down
    nnoremap <buffer><silent> <LocalLeader>d            :call <SID>OtlShiftHeading(1)<CR>
    nnoremap <buffer><silent> <LocalLeader>u            :call <SID>OtlShiftHeading(-1)<CR>

    " Format current fold
    nnoremap <buffer><silent><script> <LocalLeader>f    :silent! call <SID>OtlReFormat()<CR>
    nnoremap <buffer><silent><script> <LocalLeader>F    :silent! call <SID>OtlReFormatAndJoin()<CR>

    vnoremap <buffer><silent><script> <LocalLeader>f    <Esc>:call <SID>OtlJoinLines(line("'<"),line("'>"))<CR>:silent! call <SID>OtlReFormat()<CR>
    vnoremap <buffer><silent><script> <LocalLeader>F    <Esc>:call <SID>OtlJoinLines(line("'<"),line("'>"))<CR>:silent! call <SID>OtlReFormat()<CR>

    " Toggle from text to head and back
    nnoremap <buffer><silent><script> <LocalLeader>b    :call <SID>OtlToggleBodyText()<CR>
    vnoremap <buffer><silent><script> <LocalLeader>b    <Esc>:call <SID>OtlJoinLines(line("'<"),line("'>"))<CR>:call <SID>OtlToggleBodyText()<CR>

    " Delete current fold
    nnoremap <buffer><silent> <LocalLeader>D            :call <SID>OtlCloseThisFold()<CR>dd
    " Delete current selection
    vnoremap <buffer><silent> <LocalLeader>D            :d<CR>

    " Substitute current fold
    nnoremap <buffer><silent> <LocalLeader>C            :call <SID>OtlCloseThisFold()<CR>cc
    " Substitute current selection
    vnoremap <buffer><silent> <LocalLeader>C            S

    " Yank current fold
    nnoremap <buffer><silent> <LocalLeader>y            :call <SID>OtlDoWhileClosed('yy')<CR>
    " Insert yanked/deleted fold after the current line and adjust the indent
    nnoremap <buffer><silent> <LocalLeader>p            ]p
    " Insert yanked/deleted fold before the current line and adjust the indent
    nnoremap <buffer><silent> <LocalLeader>P            ]P

    " Toggle bold headers
    nnoremap <buffer><silent> <LocalLeader>h            :let otl_bold_headers=!otl_bold_headers<CR>:syn enable<CR>

    " Word count
    nnoremap <buffer><silent> <LocalLeader>w	          :silent! call <SID>OtlCountWords()<CR>

    " Demote or promote current
    nnoremap <buffer><silent> <LocalLeader>>            :call <SID>OtlPromoteBy(-1)<CR>
    nnoremap <buffer><silent> <LocalLeader><            :call <SID>OtlPromoteBy(1)<CR>

    vnoremap <buffer><silent> <LocalLeader>>            :><CR>
    vnoremap <buffer><silent> <LocalLeader><            :<<CR>

    if otl_map_tabs
      " Demote or promote current using tab key
      nnoremap <buffer><silent> <Tab>                     :call <SID>OtlPromoteBy(-1)<CR>
      nnoremap <buffer><silent> <S-Tab>                   :call <SID>OtlPromoteBy(1)<CR>

      vnoremap <buffer><silent> <Tab>                     :><CR>
      vnoremap <buffer><silent> <S-Tab>                   :<<CR>
    end

    " Open and close current fold
    nnoremap <buffer><silent><script> =                 :call <SID>OtlOpenThisFold()<CR>
    nnoremap <buffer><silent><script> <LocalLeader>=    :call <SID>OtlOpenThisFold()<CR>
    nnoremap <buffer><silent><script> <LocalLeader>+    :call <SID>OtlOpenThisFold()<CR>
    nnoremap <buffer><silent><script> -                 :call <SID>OtlCloseThisFold()<CR>
    nnoremap <buffer><silent><script> <LocalLeader>-    :call <SID>OtlCloseThisFold()<CR>

    " Tag jumps
    nnoremap <buffer><silent><script> <C-]>             :call <SID>OtlTagJump()<CR>
    nnoremap <buffer><silent><script> g<C-]>            :call <SID>OtlTagJump()<CR>
    nnoremap <buffer><silent><script> g<LeftMouse>      :call <SID>OtlTagJump()<CR>
    " And returns
    nnoremap <buffer><silent><script> <C-T>             :call <SID>OtlTagReturn()<CR>
    nnoremap <buffer><silent><script> g<RightMouse>     :call <SID>OtlTagReturn()<CR>
    nnoremap <buffer><silent><script> <C-RightMouse>    :call <SID>OtlTagReturn()<CR>

    nnoremap <buffer><silent>J                          :OtlJoin<CR>
    vnoremap <buffer><silent>J                          <Esc>:call <SID>OtlJoinLines(line("'<"),line("'>"))<CR>

    " MS Word compatible level changing for Normal mode
    nnoremap <buffer><silent> <M-S-Down>                :call <SID>OtlShiftHeading(1)<CR>
    nnoremap <buffer><silent> <M-S-Up>                  :call <SID>OtlShiftHeading(-1)<CR>
    nnoremap <buffer><silent> <M-Down>                  :call <SID>OtlJump(1)<CR>
    nnoremap <buffer><silent> <M-Up>                    :call <SID>OtlJump(-1)<CR>
    nnoremap <buffer><silent> <M-S-Left>                :call <SID>OtlPromoteBy(1)<CR>
    nnoremap <buffer><silent> <M-S-Right>               :call <SID>OtlPromoteBy(-1)<CR>
    nnoremap <buffer><silent> <M-S-kPlus>               :call <SID>OtlOpenThisFold()<CR>
    nnoremap <buffer><silent> <M-S-kMinus>              :call <SID>OtlCloseThisFold()<CR>

    " Insert mode mappings
    imap     <buffer><silent> <2-LeftMouse>             <C-O>:call <SID>OtlDoubleClick()<CR>
    imap     <buffer><silent> <3-LeftMouse>             <Nop>
    imap     <buffer><silent> <4-LeftMouse>             <Nop>

    if !no_otl_insert_maps
      imap <buffer><silent> <LocalLeader>1                <C-O><LocalLeader>1
      imap <buffer><silent> <LocalLeader>2                <C-O><LocalLeader>2
      imap <buffer><silent> <LocalLeader>3                <C-O><LocalLeader>3
      imap <buffer><silent> <LocalLeader>4                <C-O><LocalLeader>4
      imap <buffer><silent> <LocalLeader>5                <C-O><LocalLeader>5
      imap <buffer><silent> <LocalLeader>6                <C-O><LocalLeader>6
      imap <buffer><silent> <LocalLeader>7                <C-O><LocalLeader>7
      imap <buffer><silent> <LocalLeader>8                <C-O><LocalLeader>8
      imap <buffer><silent> <LocalLeader>9                <C-O><LocalLeader>9
      imap <buffer><silent> <LocalLeader>t                <C-O><LocalLeader>t
      imap <buffer><silent> <LocalLeader>a                <C-O><LocalLeader>a
      imap <buffer><silent> <LocalLeader>T                <C-O><LocalLeader>T
      imap <buffer><silent> <LocalLeader>H                <C-O><LocalLeader>H
      imap <buffer><silent> <LocalLeader>k                <C-O><LocalLeader>k
      imap <buffer><silent> <LocalLeader>j                <C-O><LocalLeader>j
      inoremap <buffer><silent> <LocalLeader>D            <C-L>:call <SID>OtlCloseThisFold()<CR>dd<Esc>
      inoremap <buffer><silent> <LocalLeader>C            <C-L>:call <SID>OtlCloseThisFold()<CR>cc<Esc>
      inoremap <buffer><silent> <LocalLeader>y            <C-O>:call <SID>OtlDoWhileClosed('yy')<CR>
      inoremap <buffer><silent> <LocalLeader>p            <C-O>]p
      inoremap <buffer><silent> <LocalLeader>P            <C-O>]P

      " Format current fold
      imap <buffer><silent> <LocalLeader>f                <C-O><LocalLeader>f
      imap <buffer><silent> <LocalLeader>F                <C-O><LocalLeader>F
      imap <buffer><silent> <LocalLeader>b                <C-O><LocalLeader>b
      inoremap <buffer><silent> <LocalLeader>>            <C-O>:call <SID>OtlPromoteBy(-1)<CR>
      inoremap <buffer><silent> <LocalLeader>+            <C-O>:call <SID>OtlOpenThisFold()<CR>
      inoremap <buffer><silent> <LocalLeader>=            <C-O>:call <SID>OtlOpenThisFold()<CR>
      inoremap <buffer><silent> <LocalLeader>-            <C-O>:call <SID>OtlCloseThisFold()<CR>
      inoremap <buffer><silent> <LocalLeader><            <C-O>:call <SID>OtlPromoteBy(1)<CR>
      inoremap <buffer><silent> <LocalLeader>d            <C-O>:call <SID>OtlShiftHeading(1)<CR>
      inoremap <buffer><silent> <LocalLeader>u            <C-O>:call <SID>OtlShiftHeading(-1)<CR>
    endif " no_otl_insert_maps

    " Word-compatible keys
    inoremap <buffer><silent> <M-S-Right>               <C-O>:call <SID>OtlPromoteBy(-1)<CR>
    inoremap <buffer><silent> <M-S-Left>                <C-O>:call <SID>OtlPromoteBy(1)<CR>
    inoremap <buffer><silent> <M-Down>                  <C-O>:call <SID>OtlJump(1)<CR>
    inoremap <buffer><silent> <M-Up>                    <C-O>:call <SID>OtlJump(-1)<CR>
    inoremap <buffer><silent> <M-S-Down>                <C-O>:call <SID>OtlShiftHeading(1)<CR>
    inoremap <buffer><silent> <M-S-Up>                  <C-O>:call <SID>OtlShiftHeading(-1)<CR>
    inoremap <buffer><silent> <M-S-kPlus>               <C-O>:call <SID>OtlOpenThisFold()<CR>
    inoremap <buffer><silent> <M-S-kMinus>              <C-O>:call <SID>OtlCloseThisFold()<CR>
    if &insertmode
      " Demote to body text CTRL+SHIFT+N (actually CTRL+N)
      inoremap <buffer><silent> <C-N>                   <C-O>:call <SID>OtlTogglebodyText()<CR>
    endif
    inoremap <buffer><silent><script> <C-CR>            <C-O>:call <SID>OtlSwitchOpen(line('.'))<CR>
    inoremap <buffer><silent><script> <C-]>             <C-O>:call <SID>OtlTagJump()<CR>
    " Move selected paragraphs up ALT+SHIFT+UP ARROW
    " Move selected paragraphs down ALT+SHIFT+DOWN ARROW
    " Expand text under a heading ALT+SHIFT+PLUS SIGN
    " Collapse text under a heading ALT+SHIFT+MINUS SIGN
    " Expand or collapse all text or headings ALT+SHIFT+A or the asterisk (*) key on the numeric keypad
    " Hide or display character formatting  The slash (/) key on the numeric keypad
    " Show the first line of body text or all body text ALT+SHIFT+L
    " Show all headings with the Heading 1 style  ALT+SHIFT+1
    " Show all headings up to Heading n ALT+SHIFT+n
  endif
endif

if !exists("s:otl_installed_menu")
  if g:otl_install_menu == 1
  " Avoid installing the menus twice
    call s:OtlCreateMenu()
    if g:otl_install_toolbar > 0
      if !has("gui_win32")
        call s:OtlCreateToolbar()
      endif
    endif
    let s:otl_installed_menu = 1
    augroup tvo
      autocmd BufEnter *.otl silent call <SID>OtlEnableMenus()
      autocmd BufLeave *.otl silent call <SID>OtlDisableMenus()
    augroup END
  endif
endif

" Set up required settings (should not be overridden)
"
setlocal foldtext=OtlFoldText()
" set to a space, just in case it wasn't a dash.
setlocal foldmethod=expr
setlocal foldexpr=OtlFoldLevel(v:lnum)
setlocal formatoptions=crqno
" for wrapping headers too:
" setlocal formatoptions+=t
" whole must come before part:
setlocal comments=s:\|\ -,m:\|\ \ ,s:\|\ *,m:\|\ \ ,b:\|>>>>>,b:\|>>>>,b:\|>>>,b:\|>>,b:\|>,b:\|,f:*\ ,f:-\ 
" setlocal iskeyword=\ -~,^\|,^[,^*

" Set up file defaults (can be overridden by modelines)
setlocal ai
setlocal noexpandtab
setlocal softtabstop=0
setlocal foldcolumn=1
setlocal tabstop=4
setlocal shiftwidth=4
normal zR

call <SID>OtlEnterBuffer()

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: ts=2 sw=2 et
