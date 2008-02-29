"=============================================================================
"    Copyright: Copyright (C) 2001-2007 Jeff Lanzarotta
"               Permission is hereby granted to use and distribute this code,
"               with or without modifications, provided that this copyright
"               notice is copied with it. Like anything else that's free,
"               bufexplorer.vim is provided *as is* and comes with no
"               warranty of any kind, either expressed or implied. In no
"               event will the copyright holder be liable for any damages
"               resulting from the use of this software.
" Name Of File: bufexplorer.vim
"  Description: Buffer Explorer Vim Plugin
"   Maintainer: Jeff Lanzarotta (delux256-vim at yahoo dot com)
" Last Changed: Sunday, 02 December 2007
"      Version: See g:bufexplorer_version for version number.
"        Usage: This file should reside in the plugin directory and be
"               automatically sourced.
"
"               You may use the default keymappings of
"
"                 <Leader>be  - Opens BufExplorer
"
"               Or you can use
"
"                 ":BufExplorer" - Opens BufExplorer
"
"               For more help see supplied documentation.
"      History: See supplied documentation.
"=============================================================================

" Exit quickly if already running or when 'compatible' is set. {{{1
if exists("g:bufexplorer_version") || &cp
  finish
endif
"1}}}

" Version number
let g:bufexplorer_version = "7.1.6"

" Check for Vim version 700 or greater {{{1
if v:version < 700
  echo "Sorry, bufexplorer ".g:bufexplorer_version."\nONLY runs with Vim 7.0 and greater."
  finish
endif

" Public Interface {{{1
nmap <silent> <unique> <Leader>be :BufExplorer<CR>

" Create commands {{{1
command BufExplorer :call StartBufExplorer(has ("gui") ? "drop" : "hide edit")

" Set {{{1
function s:Set(var, default)
  if !exists(a:var)
    if type(a:default)
      exec "let" a:var "=" string(a:default)
    else
      exec "let" a:var "=" a:default
    endif

    return 1
  endif

  return 0
endfunction
"1}}}

" Default values {{{1
call s:Set("g:bufExplorerDefaultHelp", 1) " Show default help?
call s:Set("g:bufExplorerDetailedHelp", 0) " Show detailed help?
call s:Set("g:bufExplorerFindActive", 1) " When selecting an active buffer, take you to the window where it is active?
call s:Set("g:bufExplorerReverseSort", 0) " sort reverse?
call s:Set("g:bufExplorerShowDirectories", 1) " (Dir's are added by commands like ':e .')
call s:Set("g:bufExplorerShowRelativePath", 0) " Show listings with relative or absolute paths?
call s:Set("g:bufExplorerShowUnlisted", 0) " Show unlisted buffers?
call s:Set("g:bufExplorerSortBy", "mru") " Sorting methods are in s:sort_by:
call s:Set("g:bufExplorerSplitOutPathName", 1) " Split out path and file name?

" Global variables {{{1
let s:MRUList = []
let s:running = 0
let s:sort_by = ["number", "name", "fullpath", "mru", "extension"]
let s:tabSpace = []
let s:types = {"fullname": ':p', "path": ':p:h', "relativename": ':~:.', "relativepath": ':~:.:h', "shortname": ':t'}

" Setup the autocommands that handle the MRUList and other stuff. {{{1
autocmd VimEnter * call s:Setup()

" Setup {{{1
function s:Setup()
  " Build initial MRUList.
  let s:MRUList = range(1, bufnr('$'))
  let s:tabSpace = []

  " Now that the MRUList is created, add the other autocmds.
  autocmd BufEnter,BufNew * call s:ActivateBuffer()
  autocmd BufWipeOut * call s:DeactivateBuffer(1)
  autocmd BufDelete * call s:DeactivateBuffer(0)

  autocmd BufWinEnter \[BufExplorer\] call s:Initialize()
  autocmd BufWinLeave \[BufExplorer\] call s:Cleanup()
endfunction

" ActivateBuffer {{{1
function s:ActivateBuffer()
  let b = bufnr("%")
  let l = get(s:tabSpace, tabpagenr(), [])

  if empty(l) || index(l, b) == -1
    call add(l, b)
    let s:tabSpace[tabpagenr()] = l
  endif

  call s:MRUPush(b)
endfunction

" DeactivateBuffer {{{1
function s:DeactivateBuffer(remove)
  "echom "afile:" expand("<afile>")
  "echom "bufnr, afile:" bufnr(expand("<afile>"))
  "echom "buffers:" string(tabpagebuflist())
  "echom "MRU before:" string(s:MRUList)

  if a:remove
    call s:MRUPop(bufnr(expand("<afile>")))
  end

  "echom "MRU after:" string(s:MRUList)
endfunction

" MRUPop {{{1
function s:MRUPop(buf)
  call filter(s:MRUList, 'v:val != '.a:buf)
endfunction

" MRUPush {{{1
function s:MRUPush(buf)
  " Skip temporary buffer with buftype set.
  " Don't add the BufExplorer window to the list.
  if !empty(getbufvar(a:buf, "&buftype")) ||
      \ !buflisted(a:buf) || empty(bufname(a:buf)) ||
      \ fnamemodify(bufname(a:buf), ":t") == "[BufExplorer]"
    return
  end

  call s:MRUPop(a:buf)
  call insert(s:MRUList,a:buf)
endfunction

" Initialize {{{1
function s:Initialize()
  let s:_insertmode = &insertmode
  set noinsertmode

  let s:_showcmd = &showcmd
  set noshowcmd

  let s:_cpo = &cpo
  set cpo&vim

  let s:_report = &report
  let &report = 10000

  let s:_list = &list
  set nolist

  setlocal nonumber
  setlocal foldcolumn=0
  setlocal nofoldenable
  setlocal cursorline
  setlocal nospell

  set nobuflisted

  let s:running = 1
endfunction

" Cleanup {{{1
function s:Cleanup()
  let &insertmode = s:_insertmode
  let &showcmd = s:_showcmd
  let &cpo = s:_cpo
  let &report = s:_report
  let &list = s:_list
  let s:running = 0

  delmarks!
endfunction

" StartBufExplorer {{{1
function StartBufExplorer(open)
  let name = '[BufExplorer]'

  if !has("win32")
    " On non-Windows boxes, escape the name so that is shows up correctly.
    let name = escape(name, "[]")
  endif

  " Make sure there is only one explorer open at a time.
  if s:running == 1
    " Go to the open buffer.
    if has("gui")
      exec "drop" name
    endif

    return
  endif

  silent let s:raw_buffer_listing = s:GetBufferInfo()

  let copy = copy(s:raw_buffer_listing)

  if (g:bufExplorerShowUnlisted == 0)
    call filter(copy, 'v:val.attributes !~ "u"')
  endif

  if (!empty(copy))
    call filter(copy, 'v:val.shortname !~ "\\\[No Name\\\]"')
  endif

  if len(copy) <= 1
    echo "\r"
    call s:Warn("Sorry, there are no more buffers to explore")

    return
  endif

  if !exists("b:displayMode") || b:displayMode != "winmanager"
    " Do not use keepalt when opening bufexplorer to allow the buffer that we
    " are leaving to become the new alternate buffer
    exec "silent keepjumps ".a:open." ".name
  endif

  call s:DisplayBufferList()
endfunction

" DisplayBufferList {{{1
function s:DisplayBufferList()
  setlocal bufhidden=delete
  setlocal buftype=nofile
  setlocal modifiable
  setlocal noswapfile
  setlocal nowrap

  call s:SetupSyntax()
  call s:MapKeys()
  call setline(1, s:CreateHelp())
  call s:BuildBufferList()
  call cursor(s:firstBufferLine, 1)

  if !g:bufExplorerResize
    normal! zz
  endif

  setlocal nomodifiable
endfunction

" MapKeys {{{1
function s:MapKeys()
  if exists("b:displayMode") && b:displayMode == "winmanager"
    nnoremap <buffer> <silent> <tab> :call <SID>SelectBuffer()<cr>
  endif

  nnoremap <buffer> <silent> <F1>          :call <SID>ToggleHelp()<cr>
  nnoremap <buffer> <silent> <2-leftmouse> :call <SID>SelectBuffer()<cr>
  nnoremap <buffer> <silent> <cr>          :call <SID>SelectBuffer()<cr>
  nnoremap <buffer> <silent> t             :call <SID>SelectBuffer("tab")<cr>
  nnoremap <buffer> <silent> <s-cr>        :call <SID>SelectBuffer("tab")<cr>
  nnoremap <buffer> <silent> d             :call <SID>RemoveBuffer("wipe")<cr>
  nnoremap <buffer> <silent> D             :call <SID>RemoveBuffer("delete")<cr>
  nnoremap <buffer> <silent> m             :call <SID>MRUListShow()<cr>
  nnoremap <buffer> <silent> p             :call <SID>ToggleSplitOutPathName()<cr>
  nnoremap <buffer> <silent> q             :call <SID>Close()<cr>
  nnoremap <buffer> <silent> r             :call <SID>SortReverse()<cr>
  nnoremap <buffer> <silent> R             :call <SID>ToggleShowRelativePath()<cr>
  nnoremap <buffer> <silent> s             :call <SID>SortSelect()<cr>
  nnoremap <buffer> <silent> u             :call <SID>ToggleShowUnlisted()<cr>
  nnoremap <buffer> <silent> f             :call <SID>ToggleFindActive()<cr>

  for k in ["G", "n", "N", "L", "M", "H"]
    exec "nnoremap <buffer> <silent>" k ":keepjumps normal!" k."<cr>"
  endfor
endfunction

" SetupSyntax {{{1
function s:SetupSyntax()
  if has("syntax")
    syn match bufExplorerHelp     "^\".*" contains=bufExplorerSortBy,bufExplorerMapping,bufExplorerTitle,bufExplorerSortType,bufExplorerToggleSplit,bufExplorerToggleOpen
    syn match bufExplorerOpenIn   "Open in \w\+ window" contained
    syn match bufExplorerSplit    "\w\+ split" contained
    syn match bufExplorerSortBy   "Sorted by .*" contained contains=bufExplorerOpenIn,bufExplorerSplit
    syn match bufExplorerMapping  "\" \zs.\+\ze :" contained
    syn match bufExplorerTitle    "Buffer Explorer.*" contained
    syn match bufExplorerSortType "'\w\{-}'" contained
    syn match bufExplorerBufNbr   /^\s*\d\+/
    syn match bufExplorerToggleSplit  "toggle split type" contained
    syn match bufExplorerToggleOpen   "toggle open mode" contained

    syn match bufExplorerModBuf    /^\s*\d\+.\{4}+.*/
    syn match bufExplorerLockedBuf /^\s*\d\+.\{3}[\-=].*/
    syn match bufExplorerHidBuf    /^\s*\d\+.\{2}h.*/
    syn match bufExplorerActBuf    /^\s*\d\+.\{2}a.*/
    syn match bufExplorerCurBuf    /^\s*\d\+.%.*/
    syn match bufExplorerAltBuf    /^\s*\d\+.#.*/
    syn match bufExplorerUnlBuf    /^\s*\d\+u.*/

    hi def link bufExplorerBufNbr Number
    hi def link bufExplorerMapping NonText
    hi def link bufExplorerHelp Special
    hi def link bufExplorerOpenIn Identifier
    hi def link bufExplorerSortBy String
    hi def link bufExplorerSplit NonText
    hi def link bufExplorerTitle NonText
    hi def link bufExplorerSortType bufExplorerSortBy
    hi def link bufExplorerToggleSplit bufExplorerSplit
    hi def link bufExplorerToggleOpen bufExplorerOpenIn

    hi def link bufExplorerActBuf Identifier
    hi def link bufExplorerAltBuf String
    hi def link bufExplorerCurBuf Type
    hi def link bufExplorerHidBuf Constant
    hi def link bufExplorerLockedBuf Special
    hi def link bufExplorerModBuf Exception
    hi def link bufExplorerUnlBuf Comment
  endif
endfunction

" ToggleHelp {{{1
function s:ToggleHelp()
  let g:bufExplorerDetailedHelp = !g:bufExplorerDetailedHelp

  setlocal modifiable

  " Save position
  normal! ma

  " Remove old header
  if (s:firstBufferLine > 1)
    exec "keepjumps 1,".(s:firstBufferLine - 1) "d _"
  endif

  call append(0, s:CreateHelp())

  silent! normal! g`a
  delmarks a

  setlocal nomodifiable

  if exists("b:displayMode") && b:displayMode == "winmanager"
    call WinManagerForceReSize("BufExplorer")
  end
endfunction

" GetHelpStatus {{{1
function s:GetHelpStatus()
  let ret = '" Sorted by '.((g:bufExplorerReverseSort == 1) ? "reverse " : "").g:bufExplorerSortBy
  let ret .= ' | '.((g:bufExplorerFindActive == 0) ? "Don't " : "")."Locate buffer"
  let ret .= ((g:bufExplorerShowUnlisted == 0) ? "" : " | Show unlisted")
  let ret .= ' | '.((g:bufExplorerShowRelativePath == 0) ? "Absolute" : "Relative")
  let ret .= ' '.((g:bufExplorerSplitOutPathName == 0) ? "Full" : "Split")." path"

  return ret
endfunction

" CreateHelp {{{1
function s:CreateHelp()
  if g:bufExplorerDefaultHelp == 0 && g:bufExplorerDetailedHelp == 0
    let s:firstBufferLine = 1
    return []
  endif

  let header = []

  if g:bufExplorerDetailedHelp == 1
    call add(header, '" Buffer Explorer ('.g:bufexplorer_version.')')
    call add(header, '" --------------------------')
    call add(header, '" <F1> : toggle this help')
    call add(header, '" <enter> or Mouse-Double-Click : open buffer under cursor')
    call add(header, '" <shift-enter> or t : open buffer in another tab')
    call add(header, '" d : wipe buffer')
    call add(header, '" D : delete buffer')
    call add(header, '" p : toggle spliting of file and path name')
    call add(header, '" q : quit')
    call add(header, '" r : reverse sort')
    call add(header, '" R : toggle showing relative or full paths')
    call add(header, '" u : toggle showing unlisted buffers')
    call add(header, '" s : select sort field '.string(s:sort_by).'')
    call add(header, '" f : toggle find active buffer')
  else
    call add(header, '" Press <F1> for Help')
  endif

  call add(header, s:GetHelpStatus())
  call add(header, '"=')

  let s:firstBufferLine = len(header) + 1

  return header
endfunction

" GetBufferInfo {{{1
function s:GetBufferInfo()
  redir => bufoutput
  buffers!
  redir END

  let [all, allwidths, listedwidths] = [[], {}, {}]

  for n in keys(s:types)
    let allwidths[n] = []
    let listedwidths[n] = []
  endfor

  for buf in split(bufoutput, '\n')
    let bits = split(buf, '"')
    let b = {"attributes": bits[0], "line": substitute(bits[2], '\s*', '', '')}

    for [key, val] in items(s:types)
      let b[key] = fnamemodify(bits[1], val)
    endfor

    if getftype(b.fullname) == "dir" && g:bufExplorerShowDirectories == 1
      let b.shortname = "<DIRECTORY>"
    end

    call add(all, b)

    for n in keys(s:types)
      call add(allwidths[n], len(b[n]))

      if b.attributes !~ "u"
        call add(listedwidths[n], len(b[n]))
      endif
    endfor
  endfor

  let [s:allpads, s:listedpads] = [{}, {}]

  for n in keys(s:types)
    let s:allpads[n] = repeat(' ', max(allwidths[n]))
    let s:listedpads[n] = repeat(' ', max(listedwidths[n]))
  endfor

  return all
endfunction

" BuildBufferList {{{1
function s:BuildBufferList()
  let lines = []

  " Loop through every buffer.
  for buf in s:raw_buffer_listing
    if (!g:bufExplorerShowUnlisted && buf.attributes =~ "u")
      " skip unlisted buffers if we are not to show them
      continue
    endif

    let line = buf.attributes." "

    if g:bufExplorerSplitOutPathName
      let type = (g:bufExplorerShowRelativePath) ? "relativepath" : "path"
      let path = buf[type]
      let pad  = (g:bufExplorerShowUnlisted) ? s:allpads.shortname : s:listedpads.shortname
      let line .= buf.shortname." ".strpart(pad.path, len(buf.shortname))
    else
      let type = (g:bufExplorerShowRelativePath) ? "relativename" : "fullname"
      let path = buf[type]
      let line .= path
    endif

    let pads = (g:bufExplorerShowUnlisted) ? s:allpads : s:listedpads

    if !empty(pads[type])
      let line .= strpart(pads[type], len(path))." "
    endif

    let line .= buf.line

    call add(lines, line)
  endfor

  call setline(s:firstBufferLine, lines)

  call s:SortListing()
endfunction

" SelectBuffer {{{1
function s:SelectBuffer(...)
  " Sometimes messages are not cleared when we get here so it looks like an
  " error has occurred when it really has not.
  echo ""

  " Are we on a line with a file name?
  if line('.') < s:firstBufferLine
    exec "normal! \<cr>"
    return
  endif

  let _bufNbr = str2nr(getline('.'))

  if exists("b:displayMode") && b:displayMode == "winmanager"
    let bufname = expand("#"._bufNbr.":p")

    call WinManagerFileEdit(bufname, 0)

    return
  end

  if bufexists(_bufNbr)
    if bufnr("#") == _bufNbr
      return s:Close()
    endif

    " If the buf is active, then go to the tab where it is opened.
    if bufloaded(_bufNbr) && g:bufExplorerFindActive
      call s:Close()
      let bufname = expand("#"._bufNbr.":p")
"      exec "drop" substitute(bufname, "\\s", "\\\\ ", "g")
      exec bufname ? "drop ".substitute(bufname, "\\s", "\\\\ ", "g") : "buffer "._bufNbr
    elseif (a:0)
      call s:Close()
      tabnew
    endif

    " Make the buffer 'listed' again.
    call setbufvar(_bufNbr, "&buflisted", "1")

    " Switch to the buffer.
    exec "keepalt keepjumps silent b!" _bufNbr
  else
    call s:Error("Sorry, that buffer no longer exists, please select another")
    call s:DeleteBuffer(_bufNbr, "wipe")
  endif
endfunction

" RemoveBuffer {{{1
function s:RemoveBuffer(mode)
  " Are we on a line with a file name?
  if line('.') < s:firstBufferLine
    return
  endif

  " Do not allow this buffer to be deleted if it is the last one.
  if len(s:MRUList) == 1
    call s:Error("Sorry, you are not allowed to delete the last buffer")
    return
  endif

  " These commands are to temporarily suspend the activity of winmanager.
  if exists("b:displayMode") && b:displayMode == "winmanager"
    call WinManagerSuspendAUs()
  end

  let _bufNbr = str2nr(getline('.'))

  if getbufvar(_bufNbr, '&modified') == 1
    call s:Error("Sorry, no write since last change for buffer "._bufNbr.", unable to delete")
    return
  else
    " Okay, everything is good, delete or wipe the buffer.
    call s:DeleteBuffer(_bufNbr, a:mode)
  endif

  " Reactivate winmanager autocommand activity.
  if exists("b:displayMode") && b:displayMode == "winmanager"
    call WinManagerForceReSize("BufExplorer")
    call WinManagerResumeAUs()
  end
endfunction

" DeleteBuffer {{{1
function s:DeleteBuffer(buf, mode)
  " This routine assumes that the buffer to be removed is on the current line.
  try
    if a:mode == "wipe"
      exe "silent bw" a:buf
    else
      exe "silent bd" a:buf
    end

    setlocal modifiable
    normal! "_dd
    setlocal nomodifiable

    " Delete the buffer from the raw buffer list.
    call filter(s:raw_buffer_listing, 'v:val.attributes !~ " '.a:buf.' "')
  catch
    call s:Error(v:exception)
  endtry
endfunction

" Close {{{1
function s:Close()
  " Get only the listed buffers.
  let listed = filter(copy(s:MRUList), "buflisted(v:val)")

  for b in reverse(listed[0:1])
    exec "keepjumps silent b ".b
  endfor
endfunction

" ToggleSplitOutPathName {{{1
function s:ToggleSplitOutPathName()
  let g:bufExplorerSplitOutPathName = !g:bufExplorerSplitOutPathName
  call s:RebuildBufferList()
  call s:UpdateHelpStatus()
endfunction

" ToggleShowRelativePath {{{1
function s:ToggleShowRelativePath()
  let g:bufExplorerShowRelativePath = !g:bufExplorerShowRelativePath
  call s:RebuildBufferList()
  call s:UpdateHelpStatus()
endfunction

" ToggleShowUnlisted {{{1
function s:ToggleShowUnlisted()
  let g:bufExplorerShowUnlisted = !g:bufExplorerShowUnlisted
  let num_bufs = s:RebuildBufferList(g:bufExplorerShowUnlisted == 0)
  call s:UpdateHelpStatus()
endfunction

" ToggleFindActive {{{1
function s:ToggleFindActive()
  let g:bufExplorerFindActive = !g:bufExplorerFindActive
  call s:UpdateHelpStatus()
endfunction

" RebuildBufferList {{{1
function s:RebuildBufferList(...)
  setlocal modifiable

  let curPos = getpos('.')

  if a:0
    " Clear the list first.
    exec "keepjumps ".s:firstBufferLine.',$d "_'
  endif

  let num_bufs = s:BuildBufferList()

  call setpos('.', curPos)

  setlocal nomodifiable

  return num_bufs
endfunction

" UpdateHelpStatus {{{1
function s:UpdateHelpStatus()
  setlocal modifiable

  let text = s:GetHelpStatus()
  call setline(s:firstBufferLine - 2, text)

  setlocal nomodifiable
endfunction

" MRUCmp {{{1
function s:MRUCmp(line1, line2)
  return index(s:MRUList, str2nr(a:line1)) - index(s:MRUList, str2nr(a:line2))
endfunction

" SortReverse {{{1
function s:SortReverse()
  let g:bufExplorerReverseSort = !g:bufExplorerReverseSort

  call s:ReSortListing()
endfunction

" SortSelect {{{1
function s:SortSelect()
  let g:bufExplorerSortBy = get(s:sort_by, index(s:sort_by, g:bufExplorerSortBy)+1, s:sort_by[0])

  call s:ReSortListing()
endfunction

" ReSortListing {{{1
function s:ReSortListing()
  setlocal modifiable

  let curPos = getpos('.')

  call s:SortListing()
  call s:UpdateHelpStatus()

  call setpos('.', curPos)

  setlocal nomodifiable
endfunction

" SortListing {{{1
function s:SortListing()
  let sort = s:firstBufferLine.",$sort".((g:bufExplorerReverseSort == 1) ? "!": "")

  if g:bufExplorerSortBy == "number"
    " Easiest case.
    exec sort 'n'
  elseif g:bufExplorerSortBy == "name"
    if g:bufExplorerSplitOutPathName
      exec sort 'ir /\d.\{7}\zs\f\+\ze/'
    else
      exec sort 'ir /\zs[^\/\\]\+\ze\s*line/'
    endif
  elseif g:bufExplorerSortBy == "fullpath"
    if g:bufExplorerSplitOutPathName
      " Sort twice - first on the file name then on the path.
      exec sort 'ir /\d.\{7}\zs\f\+\ze/'
    endif

    exec sort 'ir /\zs\f\+\ze\s\+line/'
  elseif g:bufExplorerSortBy == "extension"
    exec sort 'ir /\.\zs\w\+\ze\s/'
  elseif g:bufExplorerSortBy == "mru"
    let l = getline(s:firstBufferLine, "$")

    call sort(l, "<SID>MRUCmp")

    if g:bufExplorerReverseSort
      call reverse(l)
    endif

    call setline(s:firstBufferLine, l)
  endif
endfunction

" MRUListShow {{{1
function s:MRUListShow()
  echomsg "MRUList=".string(s:MRUList)
endfunction

" Error {{{1
function s:Error(msg)
  echohl ErrorMsg | echo a:msg | echohl none
endfunction

" Warn {{{1
function s:Warn(msg)
  echohl WarningMsg | echo a:msg | echohl none
endfunction

" Winmanager Integration {{{1
let g:BufExplorer_title = "\[Buf\ List\]"
call s:Set("g:bufExplorerResize", 1)
call s:Set("g:bufExplorerMaxHeight", 25) " Handles dynamic resizing of the window.

" Function to start display. Set the mode to 'winmanager' for this buffer.
" This is to figure out how this plugin was called. In a standalone fashion
" or by winmanager.
function BufExplorer_Start()
  let b:displayMode = "winmanager"
  call StartBufExplorer("e")
endfunction

" Returns whether the display is okay or not.
function BufExplorer_IsValid()
  return 0
endfunction

" Handles dynamic refreshing of the window.
function BufExplorer_Refresh()
  let b:displayMode = "winmanager"
  call StartBufExplorer("e")
endfunction

function BufExplorer_ReSize()
  if !g:bufExplorerResize
    return
  end

  let nlines = min([line("$"), g:bufExplorerMaxHeight])

  exe nlines." wincmd _"

  " The following lines restore the layout so that the last file line is also
  " the last window line. Sometimes, when a line is deleted, although the
  " window size is exactly equal to the number of lines in the file, some of
  " the lines are pushed up and we see some lagging '~'s.
  let pres = getpos(".")

  exe $

  let _scr = &scrolloff
  let &scrolloff = 0

  normal! z-

  let &scrolloff = _scr

  call setpos(".", pres)
endfunction
"1}}}

" vim:ft=vim foldmethod=marker sw=2
