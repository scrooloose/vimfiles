" Description: VimBuddy statusline character
" Author:      Flemming Madsen <fma@cci.dk>
" Modified:    June 2001
" Version:     0.9.1
"
" Usage:       Insert %{VimBuddy()} into your 'statusline'
"

function! VimBuddy()
    " Take a copy for others to see the messages
    if ! exists("g:vimbuddy_msg")
        let g:vimbuddy_msg = v:statusmsg
    endif
    if ! exists("g:vimbuddy_warn")
        let g:vimbuddy_warn = v:warningmsg
    endif
    if ! exists("g:vimbuddy_err")
        let g:vimbuddy_err = v:errmsg
    endif
    if ! exists("g:vimbuddy_onemore")
        let g:vimbuddy_onemore = ""
    endif

    if ( exists("g:actual_curbuf") && (g:actual_curbuf != bufnr("%")))
        " Not my buffer, sleeping
        return "|-o"
    elseif g:vimbuddy_err != v:errmsg
        let v:errmsg = v:errmsg . " "
        let g:vimbuddy_err = v:errmsg
        return ":-("
    elseif g:vimbuddy_warn != v:warningmsg
        let v:warningmsg = v:warningmsg . " "
        let g:vimbuddy_warn = v:warningmsg
        return "(-:"
    elseif g:vimbuddy_msg != v:statusmsg
        let v:statusmsg = v:statusmsg . " "
        let g:vimbuddy_msg = v:statusmsg
        let test = matchstr(v:statusmsg, 'lines *$')
        let num = substitute(v:statusmsg, '^\([0-9]*\).*', '\1', '') + 0
        " How impressed should we be
        if test != "" && num > 20
            let str = ":-O"
        elseif test != "" && num
            let str = ":-o"
        else
            let str = ":-/"
        endif
		  let g:vimbuddy_onemore = str
		  return str
	 elseif g:vimbuddy_onemore != ""
		let str = g:vimbuddy_onemore
		let g:vimbuddy_onemore = ""
		return str
    endif

    if ! exists("b:lastcol")
        let b:lastcol = col(".")
    endif
    if ! exists("b:lastlineno")
        let b:lastlineno = line(".")
    endif
    let num = b:lastcol - col(".")
    let b:lastcol = col(".")
    if (num == 1 || num == -1) && b:lastlineno == line(".")
        " Let VimBuddy rotate
        let num = b:lastcol % 4
        if num == 0
            let ch = '|'
         elseif num == 1
            let ch = '/'
        elseif num == 2
            let ch = '-'
        else
            let ch = '\'
        endif
        return ":" . ch . ")"
    endif
    let b:lastlineno = line(".")

    " Happiness is my favourite mood
    return ":-)"
endfunction

