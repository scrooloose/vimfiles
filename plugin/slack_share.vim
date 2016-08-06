if exists("g:slack_share_loaded")
    finish
endif
let g:slack_share_loaded=1

command -complete=customlist,s:chanNameComplete -nargs=1 -range=% SlackUpload call s:upload(<f-args>, <line1>, <line2>)
function! s:chanNameComplete(A, L, P)
    let rv = []
    for c in s:chanNames()
        if stridx(c, a:A) == 0
            call add(rv, c)
        endif
    endfor

    return rv
endfunction

function! s:token() abort
    if !exists("g:slack_token")
        throw "Set g:slack_token first"
    endif
    return g:slack_token
endfunction

function! s:chanNames() abort
    if exists("g:GetSlackChansCache")
        return g:GetSlackChansCache
    endif

    let channels = json_decode(system('curl -s https://slack.com/api/channels.list?token=' . s:token()))
    let g:GetSlackChansCache = map(channels["channels"], 'v:val["name"]')

    return g:GetSlackChansCache
endfunction

function s:upload(chan, line1, line2) abort
    let tmpfile = tempname() . "-" . expand("%:t.")
    exec a:line1 . "," . a:line2 . "write " . tmpfile
    let cmd = 'curl -s -F file=@'.tmpfile.' -F channels='.a:chan.' -F token='.s:token().' https://slack.com/api/files.upload'
    let output = json_decode(system(cmd))

    if output["ok"] == 1
        echomsg "OK"
    else
        echoerr "Failed"
    endif
endfunction
