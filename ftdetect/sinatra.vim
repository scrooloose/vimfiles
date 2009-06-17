autocmd BufNewFile,BufRead * call s:CheckForSinatraApp()

function! s:CheckForSinatraApp()
  if &filetype !~ '\(^sinatra$\|\.sinatra$\|^sinatra\.\|\.sinatra\.\)'
    if search(' < Sinatra::Base', 'nwc')
      set filetype+=.sinatra
    endif
  endif
endfunction
