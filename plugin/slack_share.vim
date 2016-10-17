if exists("g:slack_share_loaded")
    finish
endif
let g:slack_share_loaded=1

command -complete=customlist,s:chanNameComplete -nargs=1 -range=% SlackUploadText call s:upload(<f-args>, <line1>, <line2>)
command -complete=customlist,s:chanNameComplete -nargs=1 SlackUploadFile call s:uploadFile(<f-args>, expand("%:p"))

function! s:chanNameComplete(A, L, P) abort
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
    if exists("s:chanNamesCache")
        return s:chanNamesCache
    endif

    let channels = json_decode(system('curl -s https://slack.com/api/channels.list?token=' . s:token()))
    let s:chanNamesCache = map(channels["channels"], 'v:val["name"]')

    return s:chanNamesCache
endfunction

function s:upload(chan, line1, line2) abort
    let tmpfile = tempname() . "-" . expand("%:t:r") . '.txt'
    exec a:line1 . "," . a:line2 . "write " . tmpfile
    let output = s:uploadFile(a:chan, tmpfile)
    echo output
endfunction

function! s:uploadFile(chan, fname) abort
    let cmd = 'curl -s -F file=@'.a:fname.' -F channels='.a:chan.' -F token='.s:token().' https://slack.com/api/files.upload'
    return json_decode(system(cmd))
endfunction
