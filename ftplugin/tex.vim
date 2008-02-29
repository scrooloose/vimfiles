if exists("tex_ftplugin")
    finish
endif
let tex_ftplugin = 1

set wrap

    if has("win16") || has("win32") || has("win64")
        let g:tskelDir = $VIM ."/vimfiles/skeletons/"
    else
        let g:tskelDir = $HOME ."/.vim/skeletons/"
    endif

" enable spelling corrections
"call EnableSpellingCorrections()

"autocmd BufEnter *.tex call CheckForAddTemplate()
"function CheckForAddTemplate()
    "" if bufsize is -1 then the file cant be found and therfore is a new file
    "" so we dump the template down
    "let bufsize = getfsize(bufname("%"))
    "if bufsize=='-1' && &modified=='0'
        ":r ~/.vim/ftplugin/texTemplate.tex
        "normal kdd
    "endif
"endfunction

" this function creates a new line below the current one and leaves the cursor
" there
function s:NewLineBelow()
    normal o 
    call setline(line("."), "")
endfunction

" this function is used to create the latex code for a generic table given the
" number of columns and rows
function CreateTable(numRows, numCols)
    " create a new line and stick the tabular environment declaration on it
    call <SID>NewLineBelow()
    call setline(line("."), "\\begin{tabular}{")

    " now we want to stick the column specs on the end of the tabular environ
    " line. When doing this we assume the user wants their columns centered
    let i=1
    " loop numCols-1 times adding 'c|' onto the current line each time
    while i < a:numCols
	call setline(line("."), getline(".") . "c|")
	let i=i+1
    endwhile

    " stick the final column spec on the tabular environ line and then close
    " the declaration with the '}'
    call setline(line("."), getline(".") . "c}")

    " now we wanna add the column headings on to the line below the tabular
    " environ declaration
    call <SID>NewLineBelow()
    let i=1
    while i < a:numCols
	" loop numCols-1 times adding a column heading each time
	call setline(line("."), getline(".") . "heading" . i . " & ")
	let i=i+1
    endwhile
    " add the final heading and a horizontal line on the end
    call setline(line("."), getline(".") . "heading" . i . "\\\\ \\hline")

   
    " now we wanna generate all the cells in the table. To do this we use 2
    " loops (nested)
    let j=0
    " loop thru each row
    while j < a:numRows
	" go down to the next line so we can add the cells to that column of
	" the table
	call <SID>NewLineBelow()

	" loop thru the columns adding cells as we go
	let i=1
	while i < a:numCols
	    " add a cell onto the end of the current line
	    call setline(line("."), getline(".") . "        " . " & ")
	    let i=i+1
	endwhile
	" we have finished this row of cells so add the \\ to move to the next
	" row
	call setline(line("."), getline(".") . "        " . " \\\\")

	let j=j+1

    endwhile

    " finally we move to the next line and close the tabular environ
    call <SID>NewLineBelow()
    call setline(line("."), "\\end{tabular}")
endfunction 

function s:LayDownListFrameWork()
    " lay down the framework for the itemize environment
    normal o\begin{itemize}
    normal o\item 
    normal o\end{itemize}
    normal kA

    "" indent the \item and place the cursor there ready to start typing the
    "" first item
    "normal k>>
    startinsert!
endfunction


" some convenient mappings that provide shortcuts for commonly typed stuff
"imap <C-s> \section{}<ESC>i
"imap <C-s><C-s> \subsection{}<ESC>i
"imap <C-s><C-s><C-s> \subsubsection{}<ESC>i
imap <C-e> \emph{}<ESC>i
imap <C-u> \underline{}<ESC>i
imap <C-b> \textbf{}<ESC>i
imap <C-l> <ESC>:call <SID>LayDownListFrameWork()<CR>

