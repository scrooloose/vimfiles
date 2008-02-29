if exists("java_ftplugin")
    finish
endif
let java_ftplugin = 1



" turn on the print typer so that, when in insert mode, if you type type <A-p>
" it slaps down a System.out.println(); for you
:imap <A-p> System.out.println();<ESC>hi
