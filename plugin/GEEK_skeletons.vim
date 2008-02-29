" vim global plugin that provides code skeletons that are preprocessed making
" them like little wizards
" Last Change:  25 jun 2005
" Maintainer:   Martin Grenfell <mrg39 at student.canterbury.ac.nz>
let s:GEEK_skeletons_version = 1.3

if exists("loaded_geek_skeletons")
   finish
endif
let loaded_geek_skeletons = 1


" For help documentation type :help GEEK_skeletons. If this fails, Restart vim
" and try again. If it sill doesnt work... the help page is at the bottom 
" of this file.

"Section: Script level variable set up {{{1 
"============================================================================
"find the right char to use as the path seperator 
let s:pathSep='/'
if has('dos32') || has('dos16') || has('win16') || has('win32') || has('win32unix') || has('win95')
    let s:pathSep='\\'
endif

"the directory that contains the skeletons directories for each filetype 
if !exists("g:skelsDir")
    let g:skelsDir= expand('<sfile>:h') . s:pathSep . 'GEEK_skel' . s:pathSep
else
    if g:skelsDir !~ '.*' . s:pathSep . '$'
        let g:skelsDir = g:skelsDir . s:pathSep
    endif
endif

"the char that will be used to seperate elements of lists
let s:listSep="\n"

"all markup in the skeletons must be prefixed by this 
let s:optionPrefix = 'GEEK_'

"the strings that signal the begin/end of a yes or no option 
let s:optionYNBegin = 'YN'
let s:optionYNEnd = 'END_YN'

"the string that signals a value option 
let s:optionValPrefix = 'VAL'

"the strings that signal the begin/end of a switch and individual cases of
"that switch  
let s:optionSwitchBegin = 'BEGIN_SWITCH'
let s:optionSwitchEnd = 'END_SWITCH'
let s:optionCasePrefix = 'CASE'

"the string that signals that a line in a skel is a comment
let s:commentPrefix = 'COMMENT'

let s:optionMultipleBegin = 'MULTIPLE'
let s:optionMultipleEnd = 'END_MULTIPLE'

let s:optionMultipleUniqueBegin = 'MULTIPLE_UNIQUE'
let s:optionMultipleUniqueEnd = 'END_MULTIPLE_UNIQUE'

"the string that seperates option names from option values 
"eg the GEEK_CASE from the actual case name
let s:opSep = ':'

"the file extension for skeleton files 
let s:geekFileExt = 'geek'


"Section: Key mapping set up {{{1 
"============================================================================
nmap <leader>gg :call <SID>RequestSkeleton()<CR>
nmap <leader>gp :call <SID>RequestParseSkeleton()<CR>

"Section: Geek filetype and syntax highlighting set up{{{1 
"============================================================================
autocmd BufEnter *.geek :setf geek | :call <SID>SetupGeekSyntax()  

"Function: s:SetupGeekSyntax(){{{2
"This function is responsible for setting up all the syntax highlighting
"needed for geek skeleton files
function s:SetupGeekSyntax()
    syntax clear
    syntax case match
    
    execute 'syntax match geekComment /^.*' . s:optionPrefix . s:commentPrefix . '.*$/'
    highlight link geekComment Comment

    execute 'syntax match geekKeyword /' . s:optionPrefix . s:optionYNBegin . '/ nextgroup=geekOpSep'
    execute 'syntax match geekKeyword /' . s:optionPrefix . s:optionYNEnd . '/ nextgroup=geekOpSep'
    execute 'syntax match geekKeyword /' . s:optionPrefix . s:optionValPrefix . '/ nextgroup=geekOpSep'
    execute 'syntax match geekKeyword /' . s:optionPrefix . s:optionSwitchBegin . '/ nextgroup=geekOpSep'
    execute 'syntax match geekKeyword /' . s:optionPrefix . s:optionCasePrefix . '/ nextgroup=geekOpSep'
    execute 'syntax match geekKeyword /' . s:optionPrefix . s:optionSwitchEnd . '/ nextgroup=geekOpSep'
    execute 'syntax match geekKeyword /' . s:optionPrefix . s:optionMultipleBegin . '/ nextgroup=geekOpSep'
    execute 'syntax match geekKeyword /' . s:optionPrefix . s:optionMultipleEnd . '/ nextgroup=geekOpSep'
    execute 'syntax match geekKeyword /' . s:optionPrefix . s:optionMultipleUniqueBegin . '/ nextgroup=geekOpSep'
    execute 'syntax match geekKeyword /' . s:optionPrefix . s:optionMultipleUniqueEnd . '/ nextgroup=geekOpSep'
    highlight link geekKeyword Keyword

    execute 'syntax match geekOpSep /' . s:opSep . '/ contained nextgroup=geekIdentifier'
    highlight link geekOpSep operator

    execute 'syntax match geekIdentifier /.*/ contained'
    highlight link geekIdentifier identifier
endfunction


"Section: Skeleton/option related functions {{{1 
"============================================================================
"Function: s:ExtractOption(str, optionBeginning) {{{2
"Takes in a string and returns the first option found on it that begins with
"the given option beginning. If no
"option is found then -1 is returned
"Args: 
"-str: the string to check for an option
"-optionBeginning: the string that the option begins with
function s:ExtractOption(str, optionBeginning)
    if a:str !~ a:optionBeginning
        return -1
    endif

    let optionName = substitute(a:str, '.\{-\}\<' . a:optionBeginning . s:opSep . '\(.\{-\}\>\).*', '\1', '')
    if optionName == a:str
        return -1
    else
        return optionName
    endif

endfunction
" Function: s:GetEndOptionLine(startOptionStr, endOptionStr, firstLine) {{{2
" Gets the end of the option beginning on the given line. Handles nesting of
" options. -1 is returned if the option does not end.
" Args:
" -startOptionStr: the string that signals the beginning of this option
"  (needed to handle nested versions of the option)
" -endOptionStr: the string that signals the end of this option (needed to
"  handle nested versions of the option)
" -firstLine: the line that this option begins on
function s:GetEndOptionLine(startOptionStr, endOptionStr, firstLine)
    let nestLevel = 0

    let currentLine = a:firstLine + 1
    let theLine = getline(currentLine)

    "keep going down lines while we havent found the end of this option 
    while !(nestLevel == 0 && theLine =~ a:endOptionStr . '\>' && !<SID>IsLineCommented(theLine)) && currentLine <= <SID>GetNumLinesInBuf()

        "if we find the start/end of another option of the same type then
        "inc/dec the nestLevel counter
        if theLine =~ a:startOptionStr && !<SID>IsLineCommented(theLine)
            let nestLevel = nestLevel + 1
        else
            if theLine =~ a:endOptionStr && !<SID>IsLineCommented(theLine)
                let nestLevel = nestLevel - 1
            endif
        endif

        "move onto the next line 
        let currentLine = currentLine + 1
        let theLine = getline(currentLine)
    endwhile

    if nestLevel == 0 && theLine =~ a:endOptionStr . '\>' && !<SID>IsLineCommented(theLine)
        return currentLine
    else
        return -1
    endif
endfunction

"" Function: s:GetEndOption(startOptionStr, endOptionStr, startLine, startCol) {{{2
"" Args:
"function s:GetEndOption(startOptionStr, endOptionStr, startLine, startCol)
    "let nestLevel = 0

    "let curCol = startCol
    "let curLine = startLine

    "let done = 0
    "while !done
        "let theLine = getline(curLine)
        "let theLine = strpart(theLine, curCol-1)

        "let indxStartOp = stridx(theLine, a:startOptionStr)
        "let indxEndOp = stridx(theLine, a:endOptionStr)

        "let indxNxtOp = 0
        
        "if indxStartOp == -1 && indxEndOp == -1
            "let curLine = curLine + 1
            "continue
        "elseif indxStartOp != -1
            "let indxNxtOp = indxStartOp
            "let nestLevel = nestLevel + 1
        "elseif indxEndOp != -1
            "let indxNxtOp = indxEndOp
            "let nestLevel = nestLevel - 1
        "else
            "if indxStartOp < indxEndOp
                "let nestLevel = nestLevel + 1
            "else
                "let nestLevel = nestLevel - 1
            "endif
        "endif

    "endwhile

"endfunction


"Function: s:GetListOfSkeletonsForFiletype(ft) {{{2
"Returns a list containing paths to all the skeletons for the given filetype
"Args: 
"-ft: The filetype that the skeleton paths are to be gotten for
function s:GetListOfSkeletonsForFiletype(ft)

    "if there is no dir for the given filetype or the given filetype is ''
    "then bail
    if isdirectory(g:skelsDir . a:ft) == 0 || a:ft == ''
        return -1
    endif

    "get all the files in the dir for the given filetype 
    let allFiles=globpath(g:skelsDir . a:ft, "*") . s:listSep
    let validSkelFiles = ''
    
    "loop thru all the files getting the valid ones and adding them to
    "validSkelFiles 
    let i = 1
    while i <= <SID>GetNumElems(allFiles)

        "get the next file and make sure it is a valid skel 
        let current = <SID>GetElem(allFiles, i)

        if current =~ '.*\.geek$' && !isdirectory(current)
            let validSkelFiles = <SID>AppendToList(validSkelFiles, current)
        endif

        "move onto the next file 
        let i = i + 1
    endwhile

    "if we have no valid skels then return -1 else return the skels 
    if validSkelFiles == ''
        return -1
    else
        return validSkelFiles
    endif
endfunction


" Function: s:GetStartOptionLine(startOptionStr, endOptionStr, firstLine) {{{2
" Gets the start of the option ending on the given line. Handles nesting of
" options. -1 is returned if the option does not end.
" Args:
" -startOptionStr: the string that signals the beginning of this option
"  (needed to handle nested versions of the option)
" -endOptionStr: the string that signals the end of this option (needed to
"  handle nested versions of the option)
" -firstLine: the line that this ends begins on
function s:GetStartOptionLine(startOptionStr, endOptionStr, firstLine)
    let nestLevel = 0

    let currentLine = a:firstLine - 1
    let theLine = getline(currentLine)

    "keep going up lines while we havent found the start of this option 
    while !(nestLevel == 0 && theLine =~ a:startOptionStr . '\>' && !<SID>IsLineCommented(theLine)) && currentLine >= 1

        "if we find the start/end of another option of the same type then
        "inc/dec the nestLevel counter
        if theLine =~ a:endOptionStr && !<SID>IsLineCommented(theLine)
            let nestLevel = nestLevel + 1
        else
            if theLine =~ a:startOptionStr && !<SID>IsLineCommented(theLine)
                let nestLevel = nestLevel - 1
            endif
        endif

        "move onto the next line 
        let currentLine = currentLine - 1
        let theLine = getline(currentLine)
    endwhile

    if nestLevel == 0 && theLine =~ a:startOptionStr . '\>' && !<SID>IsLineCommented(theLine)
        return currentLine
    else
        return -1
    endif
endfunction


"Function: s:HandleMultipleOption(multOpNames, multOpVals, currentLine, totalLines) {{{2
"Takes the apprioriate action when there is a "multiple" option at the given
"line in the current buffer.
"Args: 
"-multOpNames: Passed 'by reference'. A List of all names of all the multiple options so
" far
"-multOpVal: Passed 'by reference'. A List of all values of all the multiple
" options so far.  Each entry in the list corresponds to the option name in
" multOpNames at the same indx.
"-currentLine: the line that the multiple option to be handled is on
"-totalLines: Passed 'by reference'. The total number of lines in the skel buffer.
function s:HandleMultipleOption(multOpNames, multOpVals, currentLine, totalLines)

    "make local copies of the args passed "by reference"
    exe 'let multOpNames = ' . a:multOpNames
    exe 'let multOpVals = ' . a:multOpVals
    exe 'let totalLines = ' . a:totalLines

    let currentLine = a:currentLine

    let theLine = getline(currentLine)

    let optionName = <SID>ExtractOption(theLine, s:optionPrefix . s:optionMultipleBegin)

    "the num of copies of the text of the option that the user wants 
    let numCopies = ''

    "check if we have seen this option before 
    if <SID>ListContains(multOpNames, optionName) 
        let numCopies = <SID>GetElem(multOpVals, <SID>GetListIndex(multOpNames, optionName))
    else
        let multOpNames = <SID>AppendToList(multOpNames, optionName)

        "we havent seen this option so get the user to tell us
        let numCopies = input('enter number of copies to make of: "'. optionName . '": ', '')

        "check input validity and add it to the list 
        if numCopies =~ '^[0-9]*$' && numCopies >= 0 
            let multOpVals = <SID>AppendToList(multOpVals, numCopies)
        else
            let multOpVals = <SID>AppendToList(multOpVals, 0)
        endif
    endif 
        
    "get the number of lines till the end of the option 
    let offsetToEndOfOption = <SID>GetEndOptionLine(s:optionPrefix . s:optionMultipleBegin, s:optionPrefix . s:optionMultipleEnd, currentLine) - currentLine

    if numCopies > 0

        "delete the markup for the option 
        silent execute ':' . (currentLine+offsetToEndOfOption) . ',' . (currentLine+offsetToEndOfOption) . 'delete'
        silent execute ':' . currentLine . ',' . currentLine . 'delete'

        "make the copies of the option text 
        if numCopies > 1
            call cursor(currentLine, 1)
            if offsetToEndOfOption > 2
                silent execute 'normal V' . (offsetToEndOfOption-2) . 'jy' . (numCopies-1) . 'P'
            else
                silent execute 'normal Y' . (numCopies-1) . 'P'
            endif
        endif

        "alter the totalLines and currentLine flags as needed 
        let totalLines = totalLines + ((offsetToEndOfOption - 1) * (numCopies-1))
        let currentLine = currentLine - 1

    "if the user wants 0 copies of the option then just delete it 
    else
        silent execute ':' . (currentLine) . ',' . (currentLine+offsetToEndOfOption) . 'delete'

        "alter the totalLines and currentLine flags as needed 
        let totalLines = totalLines - (offsetToEndOfOption - 1)
    endif

    "set up the return values for the args passed "by reference"
    exe 'let ' . a:multOpNames . '=' . "'" . multOpNames . "'"
    exe 'let ' . a:multOpVals . '=' . "'" . multOpVals . "'"
    exe 'let ' . a:totalLines . '=' . "'" . totalLines . "'"
endfunction


"Function: s:HandleMultipleUniqueOption(multUniqOpNames, multUniqOpVals, currentLine, totalLines) {{{2
"Takes the apprioriate action when there is a 'multiple unique' option at the given
"line in the current buffer.
"Args: 
"-multUniqOpNames: Passed 'by reference'. A List of all names of all the
" multiple unique options so far
"-multUniqOpVal: Passed 'by reference'. A List of all values of all the
" multiple unique options so far.  Each entry in the list corresponds to the option
" name in multUniqOpNames at the same indx.
"-currentLine: the line that the multiple option to be handled is on
"-totalLines: Passed 'by reference'. The total number of lines in the skel buffer.
function s:HandleMultipleUniqueOption(multUniqOpNames, multUniqOpVals, currentLine, totalLines)

    "make local copies of the args passed "by reference"
    exe 'let multUniqOpNames = ' . a:multUniqOpNames
    exe 'let multUniqOpVals = ' . a:multUniqOpVals
    exe 'let totalLines = ' . a:totalLines

    let currentLine = a:currentLine

    let theLine = getline(currentLine)

    let optionName = <SID>ExtractOption(theLine, s:optionPrefix . s:optionMultipleUniqueBegin)

    "the number of copies the user wants of the text of the option 
    let numCopies = ''

    "check if we have seen this option before 
    if <SID>ListContains(multUniqOpNames, optionName) 
        let numCopies = <SID>GetElem(multUniqOpVals, <SID>GetListIndex(multUniqOpNames, optionName))
    else
        let multUniqOpNames = <SID>AppendToList(multUniqOpNames, optionName)

        "we havent seen this option so get the user to tell us
        let numCopies = input('Enter number of copies to make of: "'. optionName . '": ', '')

        "check input validity and add it to the list 
        if numCopies =~ '^[0-9]*$' && numCopies >= 0 
            let multUniqOpVals = <SID>AppendToList(multUniqOpVals, numCopies)
        else
            let multUniqOpVals = <SID>AppendToList(multUniqOpVals, 0)
        endif

    endif 

    "get the number of lines till the end of the option  
    let offsetToEndOfOption = <SID>GetEndOptionLine(s:optionPrefix . s:optionMultipleUniqueBegin, s:optionPrefix . s:optionMultipleUniqueEnd, currentLine) - currentLine

    if numCopies > 0

        "delete the markup for the option  
        silent execute ':' . (currentLine+offsetToEndOfOption) . ',' . (currentLine+offsetToEndOfOption) . 'delete'
        silent execute ':' . currentLine . ',' . currentLine . 'delete'

        if numCopies > 1
            
            "make the copies 
            call cursor(currentLine, 1)
            if offsetToEndOfOption > 2
                silent execute 'normal V' . (offsetToEndOfOption-2) . 'jy' . (numCopies-1) . 'P'
            else
                silent execute 'normal Y' . (numCopies-1) . 'P'
            endif
        endif

        "the number of lines the text of the option takes up 
        let numLinesInCopy = offsetToEndOfOption - 1

        "go thru each copy of the option changing the markup so the
        "options are unique 
        let i = 1
        while i < numCopies

            "get the start of this copy and the start of the next copy 
            let currentLine2 = currentLine + (i * numLinesInCopy) 
            let startNextCopy = currentLine + ((i + 1) * numLinesInCopy)

            "for each line in the copy make all options on that line
            "unique 
            while currentLine2 < startNextCopy
                let theLine2 = getline(currentLine2)

                "rename all markup except cases in switches
                let theLine2 =  substitute(theLine2, '\(.\{-\}\)\(\<' . s:optionPrefix . '\(' . s:optionCasePrefix . '\)\@!' . '.\{-\}' . s:opSep . '.\{-\}' . '\>\)', '\1\2_' . i , 'g')
                
                call setline(currentLine2, theLine2)
                let currentLine2 = currentLine2 + 1
            endwhile

            let i = i + 1
        endwhile

        "adjust the total number of lines in the file and the
        "currentline accordingly 
        let totalLines = totalLines + ((offsetToEndOfOption - 1) * (numCopies-1))
    else
        silent execute ':' . (currentLine) . ',' . (currentLine+offsetToEndOfOption) . 'delete'

        "alter the totalLines and currentLine flags as needed 
        let totalLines = totalLines - (offsetToEndOfOption - 1)
    endif

    "set up the return values for the args passed "by reference"
    exe 'let ' . a:multUniqOpNames . '=' . "'" . multUniqOpNames . "'"
    exe 'let ' . a:multUniqOpVals . '=' . "'" . multUniqOpVals . "'"
    exe 'let ' . a:totalLines . '=' . "'" . totalLines . "'"
endfunction


"Function: s:HandleSwitchOption(switchOpNames, switchOpVals, currentLine, totalLines) {{{2 
"Takes the apprioriate action when there is a 'switch' option at the given
"line in the current buffer.
"Args: 
"-switchOpNames: Passed 'by reference'. A List of all names of all the
" switch options so far
"-switchOpVal: Passed 'by reference'. A List of all chosen values for all the
" switch options so far.  Each entry in the list corresponds to the option
" name in switchOpNames at the same indx.
"-currentLine: the line that the multiple option to be handled is on
"-totalLines: Passed 'by reference'. The total number of lines in the skel buffer.
function s:HandleSwitchOption(switchOpNames, switchOpVals, currentLine, totalLines)

    "make local copies of the args passed "by reference"
    exe 'let switchOpNames = ' . a:switchOpNames
    exe 'let switchOpVals = ' . a:switchOpVals
    exe 'let totalLines = ' . a:totalLines

    let currentLine = a:currentLine

    let theLine = getline(a:currentLine)

    "get the name of the option 
    let optionName = <SID>ExtractOption(theLine, s:optionPrefix . s:optionSwitchBegin)

    let choice = ''

    if <SID>ListContains(switchOpNames, optionName)
        let choice = <SID>GetElem(switchOpVals, <SID>GetListIndex(switchOpNames, optionName))
    else

        let caseList = ''

        "look thru the following lines getting the cases for the
        "switch and adding then to caseList
        let currentLine2 = currentLine + 1
        let theLine2 = getline(currentLine2)
        while theLine2 !~ s:optionPrefix . s:optionSwitchEnd

            "if we find another switch then skip past it 
            if theLine2 =~ s:optionPrefix . s:optionSwitchBegin
                let currentLine2 = <SID>GetEndOptionLine(s:optionSwitchBegin, s:optionSwitchEnd, currentLine2) + 1

            "if we find a case for the switch then add it to the
            "caseList
            elseif theLine2 =~ s:optionPrefix . s:optionCasePrefix
                let newSwitch = <SID>ExtractOption(theLine2, s:optionPrefix . s:optionCasePrefix)
                let newSwitch = substitute(newSwitch, s:optionPrefix . s:optionCasePrefix . '\(.*\)', '\1', '')
                let caseList = <SID>AppendToListUnique(caseList, newSwitch)
            endif

            "move onto the next line 
            let currentLine2 = currentLine2 + 1
            let theLine2 = getline(currentLine2)
        endwhile

        "get the user to select a case they want 
        let shortOptionName = substitute(optionName, s:optionPrefix . s:optionSwitchBegin . '\(.*\)', '\1', '')
        let userInput = <SID>GetUserToChooseFromList(caseList, 'Enter number of choice for option "' . shortOptionName . '":')

        "if the user makes an invalid choice assume 1 
        if userInput !~ '^[0-9]\{1,\}$' || userInput > <SID>GetNumElems(caseList) || userInput <= 0
            let userInput = 1
        endif
        let choice = <SID>GetElem(caseList, userInput)

        "add the switch name and the chosen value to the appropriate
        "lists so we can use the val if the same switch comes up again
        let switchOpNames = <SID>AppendToList(switchOpNames, optionName)
        let switchOpVals = <SID>AppendToList(switchOpVals, choice)
    endif

    "go thru the following lines again deleting the ones that arent
    "part of the case
    let currentLine2 = currentLine+1
    let theLine2 = getline(currentLine2)
    let isLineInCase = 0
    while theLine2 !~ s:optionPrefix . s:optionSwitchEnd

        "check if we have found a case 
        if theLine2 =~ s:optionPrefix . s:optionCasePrefix 

            "get the case name and check if it is the one we want to
            "keep
            let optionName = <SID>ExtractOption(theLine2, s:optionPrefix . s:optionCasePrefix)
            if optionName == choice

                "the case is the one to keep so set isLineInCase and
                "delete the case line
                let isLineInCase = 1
                silent execute ':' . currentLine2 . ',' . currentLine2 . 'delete'
                let totalLines = totalLines - 1
            else
                "we are not currently on a line in the chosen case
                let isLineInCase = 0
                silent execute ':' . currentLine2 . ',' . currentLine2 . 'delete'
            endif

        "if we have found the beginning of another switch then skip
        "over it or delete it if it is not in the chosen case
        elseif theLine2 =~ s:optionPrefix . s:optionSwitchBegin 
            if isLineInCase == 1
                let currentLine2 = <SID>GetEndOptionLine(s:optionSwitchBegin, s:optionSwitchEnd, currentLine2) + 1
            else
                let endNestedSwitch = <SID>GetEndOptionLine(s:optionSwitchBegin, s:optionSwitchEnd, currentLine2)
                silent execute ':' . currentLine2 . ',' . endNestedSwitch . 'delete'
            endif

        "if currentLine2 isnt inside the chosen case then delete it 
        elseif !isLineInCase 
            silent execute ':' . currentLine2 . ',' . currentLine2 . 'delete'
            let totalLines = totalLines - 1
        
        "if currentLine2 isnt any valid markup then move to the next
        "line
        else
            let currentLine2 = currentLine2 + 1
        endif

        let theLine2 = getline(currentLine2)
    endwhile

    "delete the open and closing lines of the switch 
    silent execute ':' . currentLine . ',' . currentLine . 'delete'
    silent execute ':' . (currentLine2-1) . ',' . (currentLine2-1) . 'delete'
    let totalLines = totalLines - 2

    "set up the return values for the args passed "by reference"
    exe 'let ' . a:switchOpNames . '=' . "'" . switchOpNames . "'"
    exe 'let ' . a:switchOpVals . '=' . "'" . switchOpVals . "'"
    exe 'let ' . a:totalLines . '=' . "'" . totalLines . "'"
endfunction


"Function: s:HandleValOption(valOpNames, valOpVals, currentLine, totalLines) {{{2 
"Takes the apprioriate action when there is a 'val' option at the given
"line in the current buffer.
"Args: 
"-valOpNames: Passed 'by reference'. A List of all names of all the
" val options so far
"-valOpVals: Passed 'by reference'. A List of all chosen values for all the
" val options so far.  Each entry in the list corresponds to the option
" name in valOpNames at the same indx.
"-currentLine: the line that the multiple option to be handled is on
"-totalLines: Passed 'by reference'. The total number of lines in the skel buffer.
function s:HandleValOption(valOpNames, valOpVals, currentLine)

    "make local copies of the args passed "by reference"
    exe 'let valOpNames = ' . a:valOpNames
    exe 'let valOpVals = ' . a:valOpVals

    let theLine = getline(a:currentLine)
            
    "get the name of the option 
    let optionName = <SID>ExtractOption(theLine, s:optionPrefix . s:optionValPrefix)
    
    "this will hold the value of the option when we know what it
    "is
    let optionVal = ''

    "check if our list of VAL option names contains this new one
    if !<SID>ListContains(valOpNames, optionName)
        "the list doesnt contain this option so we ask the user
        "for its corresponding value 
        let shortOpName = substitute(optionName, s:optionPrefix . s:optionValPrefix . '\(.*\)', '\1', '')
        let optionVal = input('Enter value for '. shortOpName . ': ', '')
        echo ''

        "add the option name and value to the appropriate lists 
        let valOpNames = <SID>AppendToList(valOpNames, optionName)
        let valOpVals = <SID>AppendToList(valOpVals, optionVal)
    else
        "we have already seen this option before so just get its
        "value 
        let optionVal = <SID>GetElem(valOpVals, <SID>GetListIndex(valOpNames, optionName))
    endif

    "replace the option name on the line with its value 
    let theLine =  substitute(theLine, '\(.*\)\<' . s:optionPrefix . s:optionValPrefix . s:opSep . optionName . '\>\(.*\)' , '\1' . optionVal . '\2', 'g')

    call setline(a:currentLine, theLine)

    "set up the return values for the args passed "by reference"
    exe 'let ' . a:valOpNames . '=' . "'" . valOpNames . "'"
    exe 'let ' . a:valOpVals . '=' . "'" . valOpVals . "'"
endfunction


"Function: s:HandleYNOption(confirmedYNOPs, deniedYNOPs, currentLine, totalLines) {{{2
"Takes the apprioriate action when there is a 'yes/no' option at the given
"line in the current buffer.
"Args: 
"-confirmedYNOPs: Passed 'by reference'. A List of all yes/no options that the
" user has said yes to so far.
"-deniedYNOPs: Passed 'by reference'. A list of all the yes/no options that
" the user has said no to so far.
"-currentLine: the line that the multiple option to be handled is on
"-totalLines: Passed 'by reference'. The total number of lines in the skel buffer.
function s:HandleYNOption(confirmedYNOPs, deniedYNOPs, currentLine, totalLines)

    "make local copies of the args passed "by reference"
    exe 'let confirmedYNOPs = ' . a:confirmedYNOPs
    exe 'let deniedYNOPs = ' . a:deniedYNOPs
    exe 'let totalLines = ' . a:totalLines

    let currentLine = a:currentLine

    let theLine = getline(currentLine)

    let optionName = <SID>ExtractOption(theLine, s:optionPrefix . s:optionYNBegin)

    "check if we have seen this option before 
    if !<SID>ListContains(confirmedYNOPs,optionName) && !<SID>ListContains(deniedYNOPs, optionName)

        "we havent seen this option so get the user to tell us
        echo 'Use option "'. optionName . '" (y/n):'
        if nr2char(getchar()) == 'y'
            let confirmedYNOPs = <SID>AppendToList(confirmedYNOPs, optionName)
        else
            let deniedYNOPs = <SID>AppendToList(deniedYNOPs, optionName)
        endif
    endif 

    "get the number of lines till the end of the YN option 
    let offsetToEndOfOption = <SID>GetEndOptionLine(s:optionPrefix . s:optionYNBegin, s:optionPrefix . s:optionYNEnd, currentLine) - currentLine

    "check if the option we have found has been confirmed 
    if <SID>ListContains(confirmedYNOPs, optionName)
        "it has been confirmed so delete the opening and closing lines
        "of the YN option and leave the guts there
        silent execute ':' . (currentLine+offsetToEndOfOption) . ',' . (currentLine+offsetToEndOfOption) . 'delete'
        silent execute ':' . currentLine . ',' . currentLine . 'delete'

        "we have removed 2 lines from the skel 
        let totalLines = totalLines - 2
    else
        "the option had been denied so delete the whole thing from the
        "skel
        silent execute ':' . currentLine . ',' . (currentLine+offsetToEndOfOption) . 'delete'

        "we have removed all lines of the option from the skel 
        let totalLines = totalLines - offsetToEndOfOption
    endif

    "set up the return values for the args passed "by reference"
    exe 'let ' . a:confirmedYNOPs . '=' . "'" . confirmedYNOPs . "'"
    exe 'let ' . a:deniedYNOPs . '=' . "'" . deniedYNOPs . "'"
    exe 'let ' . a:totalLines . '=' . "'" . totalLines . "'"
endfunction

"Function: s:IsLineCommented(str){{{2
"Args: 
"Return:
function s:IsLineCommented(str)
    return a:str =~ s:optionPrefix . s:commentPrefix
endfunction


"Function: s:ParseSkeleton(){{{2
"Parses the skeleton file in the current buffer and returns a list of syntax
"errors found in the skel. If no errors are found '0' is returned.
function s:ParseSkeleton()
    let toReturn = ''

    "go thru the skel one line at a time 
    let totalLines = <SID>GetNumLinesInBuf()
    let currentLine = 1
    while currentLine <= totalLines
        let theLine = getline(currentLine)

        "if the line is commented do nothing 
        if <SID>IsLineCommented(theLine)

        "check if this line has a begin YN option on it 
        elseif theLine =~ s:optionPrefix . s:optionYNBegin . '\>'

            "make sure the yn option has a corresponding end yn line 
            let endOptionLine = <SID>GetEndOptionLine(s:optionPrefix . s:optionYNBegin, s:optionPrefix . s:optionYNEnd, currentLine)
            if endOptionLine == -1
                let toReturn = <SID>AppendToList(toReturn, 'Missing ' . s:optionPrefix . s:optionYNEnd . ' for ' . s:optionPrefix . s:optionYNBegin . ' on line:' . currentLine)
            endif

        "if the line has an end yn option on it 
        elseif theLine =~ s:optionPrefix . s:optionYNEnd . '\>'

            "make sure the skel has a corresponding start yn option
            let startOptionLine = <SID>GetStartOptionLine(s:optionPrefix . s:optionYNBegin, s:optionPrefix . s:optionYNEnd, currentLine)
            if startOptionLine == -1
                let toReturn = <SID>AppendToList(toReturn, 'Missing ' . s:optionPrefix . s:optionYNBegin . ' for ' . s:optionPrefix . s:optionYNEnd . ' on line:' . currentLine)
            endif

        "check if there is a switch option on this line 
        elseif theLine =~ s:optionPrefix . s:optionSwitchBegin . '\>'
            "check the switch has a corresponding end switch line
            let endOptionLine = <SID>GetEndOptionLine(s:optionPrefix . s:optionSwitchBegin, s:optionPrefix . s:optionSwitchEnd, currentLine)
            if endOptionLine == -1
                let toReturn = <SID>AppendToList(toReturn, 'Missing ' . s:optionPrefix . s:optionSwitchEnd . ' for ' . s:optionPrefix . s:optionSwitchBegin . ' on line:' . currentLine)
            endif

            "check the switch has a name 
            let optionName = <SID>ExtractOption(theLine, s:optionPrefix . s:optionSwitchBegin)
            if optionName == -1
                let toReturn = <SID>AppendToList(toReturn, 'Switch has no name on line:' . currentLine)
            endif

        "check if there is an end switch option on this line 
        elseif theLine =~ s:optionPrefix . s:optionSwitchEnd . '\>'

            "make sure the skel has a corresponding start switch option
            let startOptionLine = <SID>GetStartOptionLine(s:optionPrefix . s:optionSwitchBegin, s:optionPrefix . s:optionSwitchEnd, currentLine)
            if startOptionLine == -1
                let toReturn = <SID>AppendToList(toReturn, 'Missing ' . s:optionPrefix . s:optionSwitchBegin . ' for ' . s:optionPrefix . s:optionSwitchEnd . ' on line:' . currentLine)
            endif

        "check if there is a case option on this line 
        elseif theLine =~ s:optionPrefix . s:optionCasePrefix . '\>'

            "make sure the case has a name 
            let optionName = <SID>ExtractOption(theLine, s:optionPrefix . s:optionCasePrefix)
            if optionName == -1
                let toReturn = <SID>AppendToList(toReturn, 'Case has no name on line:' . currentLine)
            endif

            "make sure the case is inside a switch option 
            let startOptionLine = <SID>GetStartOptionLine(s:optionPrefix . s:optionSwitchBegin, s:optionPrefix . s:optionSwitchEnd, currentLine)
            let endOptionLine = <SID>GetEndOptionLine(s:optionPrefix . s:optionSwitchBegin, s:optionPrefix . s:optionSwitchEnd, currentLine)
            if startOptionLine == -1 || endOptionLine == -1
                let toReturn = <SID>AppendToList(toReturn, 'Case not inside switch on line:' . currentLine)
            endif

        "check if the line has "multiple" markup on it 
        elseif theLine =~ s:optionPrefix . s:optionMultipleBegin . '\>'

            "make sure the skel has a corresponding end multiple option 
            let endOptionLine = <SID>GetEndOptionLine(s:optionPrefix . s:optionMultipleBegin, s:optionPrefix . s:optionMultipleEnd, currentLine)
            if endOptionLine == -1
                let toReturn = <SID>AppendToList(toReturn, 'Missing ' . s:optionPrefix . s:optionMultipleEnd . ' for ' . s:optionPrefix . s:optionMultipleBegin . ' on line:' . currentLine)
            endif

            "make sure the multiple option has a name 
            let optionName = <SID>ExtractOption(theLine, s:optionPrefix . s:optionMultipleBegin)
            if optionName == -1
                let toReturn = <SID>AppendToList(toReturn, 'Multiple has no name on line:' . currentLine)
            endif

        "check if the line has an end multiple on it 
        elseif theLine =~ s:optionPrefix . s:optionMultipleEnd . '\>'

            "make sure the skel has a corresponding begin multiple  
            let startOptionLine = <SID>GetStartOptionLine(s:optionPrefix . s:optionMultipleBegin, s:optionPrefix . s:optionMultipleEnd, currentLine)
            if startOptionLine == -1
                let toReturn = <SID>AppendToList(toReturn, 'Missing ' . s:optionPrefix . s:optionMultipleBegin . ' for ' . s:optionPrefix . s:optionMultipleEnd . ' on line:' . currentLine)
            endif

        "check if the line has "multiple unique" markup on it
        elseif theLine =~ s:optionPrefix . s:optionMultipleUniqueBegin . '\>'

            "make sure the unique mult has a corresponding end unique
            "multiple 
            let endOptionLine = <SID>GetEndOptionLine(s:optionPrefix . s:optionMultipleUniqueBegin, s:optionPrefix . s:optionMultipleUniqueEnd, currentLine)
            if endOptionLine == -1
                let toReturn = <SID>AppendToList(toReturn, 'Missing ' . s:optionPrefix . s:optionMultipleUniqueEnd . ' for ' . s:optionPrefix . s:optionMultipleUniqueBegin . ' on line:' . currentLine)
            endif

            "make sure the multiple unique is named 
            let optionName = <SID>ExtractOption(theLine, s:optionPrefix . s:optionMultipleUniqueBegin)
            if optionName == -1
                let toReturn = <SID>AppendToList(toReturn, 'Multiple unique has no name on line:' . currentLine)
            endif

        "check if the line has an end multiple unique on it 
        elseif theLine =~ s:optionPrefix . s:optionMultipleUniqueEnd . '\>'

            "make sure the skel has a corresponding start multiple unique 
            let startOptionLine = <SID>GetStartOptionLine(s:optionPrefix . s:optionMultipleUniqueBegin, s:optionPrefix . s:optionMultipleUniqueEnd, currentLine)
            if startOptionLine == -1
                let toReturn = <SID>AppendToList(toReturn, 'Missing ' . s:optionPrefix . s:optionMultipleUniqueBegin . ' for ' . s:optionPrefix . s:optionMultipleUniqueEnd . ' on line:' . currentLine)
            endif
        endif

        "move onto the next line 
        let currentLine = currentLine + 1
    endwhile

    "if there are no errors to return then return 0 else return the errors 
    return (toReturn == '' ? 0 : toReturn)
endfunction

"Function: s:RequestParseSkeleton() {{{2
"Calls the parse skel function if appropriate for this buffer and displays the
"result
function s:RequestParseSkeleton()
    if &filetype != 'geek'
        echohl WarningMsg
        echo "Parses may only be done on 'geek' files."
        echohl None
        return
    endif

    let result = <SID>ParseSkeleton()

    echo 'Results of parse:'
    if result == '0'
        echo 'No syntax errors detected by parse'
    else
        echo result
    endif
endfunction

"Function: s:RequestSkeleton() {{{2
"The entry function when a caller wants to see the list of available skeletons
"and use one from the list.
function s:RequestSkeleton()
    "get al the skels for this filetype 
    let allSkels = <SID>GetListOfSkeletonsForFiletype(&filetype)

    "check if there isnt any available 
    if allSkels == -1
        echohl WarningMsg
        echo 'No skeletons available for filetype:' . &filetype
        echohl None
    else

        "we have got some skels for this filetype so go thru the list trimming
        "all but the filename off the skel paths.
        let trimmedAllSkels = ''
        let i = 1
        while i <= <SID>GetNumElems(allSkels)

            "grab a skel from the list and trim it  
            let current = <SID>GetElem(allSkels, i)
            let current2 = substitute(current, '^.*' . s:pathSep . '\(.*\)', '\1', '')
            let trimmedAllSkels = <SID>AppendToList(trimmedAllSkels, current2)

            let i = i + 1
        endwhile

        "prompt the user for the desired skel and then call UseSkeleton with
        "it 
        let skelToUse = <SID>GetElem(allSkels, <SID>GetUserToChooseFromList(trimmedAllSkels, "Type the number of the desired skeleton:"))
        if skelToUse != -1
            call <SID>UseSkeleton(skelToUse)
        endif
    endif
endfunction

"Function: s:UseSkeleton(pathToSkel) {{{2
"Takes in a full path to a skeleton file and loads and does all necessary
"preprocesssing of the skeleton file prompting the user for input as needed.
"Args: 
"-pathToSkel: the path to the skeleton file that is to be loaded
"Return:
"-1 if failed
function s:UseSkeleton(pathToSkel)

    "open a new window and read the skeleton into it 
    :new
    silent execute ':r ' . a:pathToSkel
    silent normal kdd

    "make sure the skel is valid. Bail if not 
    let parseResult = <SID>ParseSkeleton()
    if parseResult != '0'
        echohl WarningMsg
        echo 'Error(s) in skeleton: ' 
        echo parseResult  
        echo 'Aborting.'
        echo ''
        echohl None
        "echoerr ''
        silent normal :q!
        return -1
    endif

    "we need to store lists of the YN options that the user has confirmed and
    "denied so that we dont ask them the same options twice if the option is
    "used more than once in the skel
    let g:confirmedYNOPs = ''
    let g:deniedYNOPs = ''

    "we store lists of VAL option names and their corresponding values. These
    "lists are maintained so that eg the 3rd elem in valOpVals is the value
    "for the 3rd elem in valOpNames
    let g:valOpNames = ''
    let g:valOpVals = ''

    "store a list of all the switches so far and what the user picked for them.
    "Then when we come across the same switch again we can pick the same thing
    "automatically 
    let g:switchOpNames = ''
    let g:switchOpVals = ''

    "store a list of all the multiple option names and vals so we can choose
    "the same val for the same multiple if it is encountered again 
    let g:multOpNames = ''
    let g:multOpVals = ''
    
    "store a list of all the multiple option names and vals so we can choose
    "the same val for the same multiple if it is encountered again 
    let g:multUniqOpNames = ''
    let g:multUniqOpVals = ''

    "go thru the skel and remove all the comments 
    let g:currentLine = 1
    let g:totalLines = <SID>GetNumLinesInBuf()
    while g:currentLine <= g:totalLines
        let theLine = getline(g:currentLine)

        "remove this line if it is a comment
        if <SID>IsLineCommented(theLine)
            silent execute ':' . g:currentLine . ',' . g:currentLine . 'delete'
            let g:totalLines = g:totalLines - 1
        else
            let g:currentLine = g:currentLine + 1
        endif
    endwhile

    "go thru the skel and process it one line at a time
    let g:currentLine = 1
    let g:totalLines = <SID>GetNumLinesInBuf()
    while g:currentLine <= g:totalLines
        let theLine = getline(g:currentLine)

        "check if this line as a YN option on it 
        if theLine =~ s:optionPrefix . s:optionYNBegin . s:opSep
            call <SID>HandleYNOption('g:confirmedYNOPs', 'g:deniedYNOPs', g:currentLine, 'g:totalLines')

        "check if there is a VAL option on this line 
        elseif theLine =~ s:optionPrefix . s:optionValPrefix . s:opSep
            call <SID>HandleValOption('g:valOpNames', 'g:valOpVals', g:currentLine)

        "check if there is a switch option on this line 
        elseif theLine =~ s:optionPrefix . s:optionSwitchBegin . s:opSep
            call <SID>HandleSwitchOption('g:switchOpNames', 'g:switchOpVals', g:currentLine, 'g:totalLines')

        "check if the line has "multiple" markup on it 
        elseif theLine =~ s:optionPrefix . s:optionMultipleBegin . s:opSep
            call <SID>HandleMultipleOption('g:multOpNames', 'g:multOpVals', g:currentLine, 'g:totalLines')

        "check if the line has "multiple unique" markup on it
        elseif theLine =~ s:optionPrefix . s:optionMultipleUniqueBegin . s:opSep
            call <SID>HandleMultipleUniqueOption('g:multUniqOpNames', 'g:multUniqOpVals', g:currentLine, 'g:totalLines')

        else
            "move onto the next line 
            let g:currentLine = g:currentLine + 1
        endif
    endwhile

    "copy the edited template into the current buffer 
    silent normal ggVGy:q!
    silent normal P

    "these vars are only global so they can be passed "by reference" to other
    "functions. They need only exist inside this function.
    unlet g:confirmedYNOPs g:deniedYNOPs g:valOpNames g:valOpVals g:switchOpNames 
    unlet g:switchOpVals g:multOpNames g:multOpVals g:multUniqOpNames g:multUniqOpVals 
endfunction

"Section: List related functions {{{1 
"============================================================================
"Function: s:AppendToList(theList, toAppend) {{{2
"Returns theList with toAppend appended on the end
"Args: 
"-theList: the list that the elem is to be appended to
"-toAppend: the element that is to be appended to the list
function s:AppendToList(theList, toAppend)
    return a:theList . a:toAppend . s:listSep
endfunction

"Function: s:AppendToListUnique(theList, toAppend) {{{2
"Returns theList with toAppend appended on the end if the element is not
"already in the list. If it is already in the list then the list is returned
"Args: 
"-theList: the list that the elem is to be appended to
"-toAppend: the element that is to be appended to the list
function s:AppendToListUnique(theList, toAppend)
    if !<SID>ListContains(a:theList, a:toAppend)
        return a:theList . a:toAppend . s:listSep
    else
        return a:theList
    endif
endfunction

"Function: s:GetElem(theList, elemNum) {{{2
"Returns the list element from theList which is at the given position. Assumes
"that the elements in theList are seperated by s:listSep chars.
"Args: 
"-theList: the list that the element is to be retrieved from
"-elemNum: the position of the desired element in theList. Must be in the
"range (0 < elemNum <= number of elements in theList)
function s:GetElem(theList, elemNum)
    if a:elemNum <= 0
        return -1
    endif

    "this is the string index of the current element in theList 
    let indx=0

    "keep skipping thru the elements in theList till we get to the given
    "element 
    let curElemNum = 1
    while curElemNum < a:elemNum

        "get the offset from indx to the end of the next element after indx
        let indx2 = stridx(strpart(a:theList, indx), s:listSep) 

        "if there are no elements after indx then the user has requested an
        "element that is off the end of the list 
        if indx2 == -1
            return -1
        endif

        "move indx along to the next element 
        let indx = indx + indx2 + strlen(s:listSep)

        "we have moved past another elem so inc curElemNum 
        let curElemNum = curElemNum + 1
    endwhile

    "now we have the indx of the start of the desired element we have to get
    "it out of theList. To do this we get the indx of the start of the next
    "elem and get the chars in between. If there is no next elem we just
    "return the rest of theList
    let nextStrIndx = stridx(strpart(a:theList, indx), s:listSep)
    if nextStrIndx != -1
        return strpart(a:theList, indx, nextStrIndx)
    else
        return strpart(a:theList, indx)
    endif
endfunction

"Function: s:GetListIndex(theList, elem) {{{2
"Returns the position of the element in the list. Indexes start from 1.
"returns -1 if elem isnt in the list
"Args: 
"-theList: the list that the index of elem is to be gotten for
"-elem: the element to get the index of
function s:GetListIndex(theList, elem)
    let i = 1
    while i <= <SID>GetNumElems(a:theList)
        if <SID>GetElem(a:theList, i) == a:elem
            return i
        endif
        let i = i + 1
    endwhile

    return -1
endfunction

"Function: s:GetNumElems(theList) {{{2
"Returns the number of elements in the given list. Assumes these elements are
"seperated by the s:listSep char. Assumes the list is terminated with
"s:listSep
"Args: 
"-theList: the list that the length is to be retrieved for
function s:GetNumElems(theList)
    "an empty list has no elems 
    if a:theList == ''
        return 0
    endif

    "if there is no seperator chars in the list then assume there is only one
    "element in the list
    if a:theList !~ s:listSep
        return 1
    endif

    "this is the string index of the current element in theList 
    let indx=0

    "keep skipping thru the elements in theList till we get to the end
    let curElemNum = 0
    while 1

        "get the offset from indx to the end of the next element after indx
        let indx2 = stridx(strpart(a:theList, indx), s:listSep) 

        "if there are no elements after indx then the user has requested an
        "element that is off the end of the list 
        if indx2 == -1
            return curElemNum
        endif

        "move indx along to the next element 
        let indx = indx + indx2 + strlen(s:listSep)

        "we have moved past another elem so inc curElemNum 
        let curElemNum = curElemNum + 1
    endwhile
endfunction

"Function: s:GetUserToChooseFromList(choices, userPrompt) {{{2
"Displays the given list of choices and gets the user to select one. The index
"of the element in the choice list that the user selected is returned.
"Args: 
"-choices: the list of choices that is to be displayed to the user.
"-userPrompt: the string that is to be displayed to the user to tell them to
" choose from the list, eg: "choose your weapon from the list"
function s:GetUserToChooseFromList(choices, userPrompt)
    "the list with additional markup that is to be displayed to the user. 
    let listInputText = "\n\n" . '--------------------' . "\n"

    "go thru all the elements in the choices list 
    let i = 1
    while i <= <SID>GetNumElems(a:choices)


        "get the current choice and add it (plus additional markup) to
        "listInputText 
        let current = <SID>GetElem(a:choices, i)
        let listInputText = listInputText . '(' . i . ') ' . current . "\n"

        let i = i + 1
    endwhile

    "get the user to choose ... 
    let choiceNum = ''
    if <SID>GetNumElems(a:choices)
        echo listInputText . "\n" . a:userPrompt . ' '
        let choiceNum = nr2char(getchar())
    else
        let choiceNum = input(listInputText . "\n" . a:userPrompt . ' ')
    endif

    return choiceNum
endfunction

"Function: s:ListContains(theList, elem) {{{2
"Returns 1 if the given list contains the given element
"Args: 
"-theList: the list that the elem is to be checked for
"-elem: the element to check the list for
function s:ListContains(theList, elem)
    return (a:theList =~ '^' . a:elem . s:listSep || a:theList =~ s:listSep . a:elem . s:listSep)
endfunction

"Section: other functions {{{1 
"============================================================================
" Function: s:GetNumLinesInBuf() {{{2
" Returns the number of lines in the current buffer
function s:GetNumLinesInBuf()
    let oldLine = line(".")
    let oldCol = col(".")

    normal G
    let toReturn = line(".")

    call cursor(oldLine, oldCol)

    return toReturn
endfunction

" Function: s:InstallDocumentation(full_name, revision)              {{{2
"   Install help documentation.
" Arguments:
"   full_name: Full name of this vim plugin script, including path name.
"   revision:  Revision of the vim script. #version# mark in the document file
"              will be replaced with this string with 'v' prefix.
" Return:
"   1 if new document installed, 0 otherwise.
" Note: Cleaned and generalized by guo-peng Wen.
"
" Note about authorship: this function was taken from the vimspell plugin
" which can be found at http://www.vim.org/scripts/script.php?script_id=465
"
function s:InstallDocumentation(full_name, revision)
    " Name of the document path based on the system we use:
    if (has("unix"))
        " On UNIX like system, using forward slash:
        let l:slash_char = '/'
        let l:mkdir_cmd  = ':silent !mkdir -p '
    else
        " On M$ system, use backslash. Also mkdir syntax is different.
        " This should only work on W2K and up.
        let l:slash_char = '\'
        let l:mkdir_cmd  = ':silent !mkdir '
    endif

    let l:doc_path = l:slash_char . 'doc'
    let l:doc_home = l:slash_char . '.vim' . l:slash_char . 'doc'

    " Figure out document path based on full name of this script:
    let l:vim_plugin_path = fnamemodify(a:full_name, ':h')
    let l:vim_doc_path    = fnamemodify(a:full_name, ':h:h') . l:doc_path
    if (!(filewritable(l:vim_doc_path) == 2))
        echomsg "Doc path: " . l:vim_doc_path
        execute l:mkdir_cmd . '"' . l:vim_doc_path . '"'
        if (!(filewritable(l:vim_doc_path) == 2))
            " Try a default configuration in user home:
            let l:vim_doc_path = expand("~") . l:doc_home
            if (!(filewritable(l:vim_doc_path) == 2))
                execute l:mkdir_cmd . '"' . l:vim_doc_path . '"'
                if (!(filewritable(l:vim_doc_path) == 2))
                    " Put a warning:
                    echomsg "Unable to open documentation directory"
                    echomsg " type :help add-local-help for more informations."
                    echo l:vim_doc_path
                    return 0
                endif
            endif
        endif
    endif

    " Exit if we have problem to access the document directory:
    if (!isdirectory(l:vim_plugin_path)
        \ || !isdirectory(l:vim_doc_path)
        \ || filewritable(l:vim_doc_path) != 2)
        return 0
    endif

    " Full name of script and documentation file:
    let l:script_name = fnamemodify(a:full_name, ':t')
    let l:doc_name    = fnamemodify(a:full_name, ':t:r') . '.txt'
    let l:plugin_file = l:vim_plugin_path . l:slash_char . l:script_name
    let l:doc_file    = l:vim_doc_path    . l:slash_char . l:doc_name

    " Bail out if document file is still up to date:
    if (filereadable(l:doc_file)  &&
        \ getftime(l:plugin_file) < getftime(l:doc_file))
        return 0
    endif

    " Prepare window position restoring command:
    if (strlen(@%))
        let l:go_back = 'b ' . bufnr("%")
    else
        let l:go_back = 'enew!'
    endif

    " Create a new buffer & read in the plugin file (me):
    setl nomodeline
    exe 'enew!'
    exe 'r ' . l:plugin_file

    setl modeline
    let l:buf = bufnr("%")
    setl noswapfile modifiable

    norm zR
    norm gg

    " Delete from first line to a line starts with
    " === START_DOC
    1,/^=\{3,}\s\+START_DOC\C/ d

    " Delete from a line starts with
    " === END_DOC
    " to the end of the documents:
    /^=\{3,}\s\+END_DOC\C/,$ d

    " Remove fold marks:
    % s/{\{3}[1-9]/    /

    " Add modeline for help doc: the modeline string is mangled intentionally
    " to avoid it be recognized by VIM:
    call append(line('$'), '')
    call append(line('$'), ' v' . 'im:tw=78:ts=8:ft=help:norl:')

    " Replace revision:
    "exe "normal :1s/#version#/ v" . a:revision . "/\<CR>"
    exe "normal :%s/#version#/ v" . a:revision . "/\<CR>"

    " Save the help document:
    exe 'w! ' . l:doc_file
    exe l:go_back
    exe 'bw ' . l:buf

    " Build help tags:
    exe 'helptags ' . l:vim_doc_path

    return 1
endfunction

" Section: Doc installation call {{{1
silent call s:InstallDocumentation(expand('<sfile>:p'), s:GEEK_skeletons_version)


finish
"=============================================================================
" Section: The help file {{{1 
" Title {{{2
" ============================================================================
=== START_DOC
*GEEK_skeletons.txt*                                                 #version#


                       GEEK_SKELETONS REFERENCE MANUAL~





==============================================================================
CONTENTS {{{2                                         *GEEK_skels-contents* 

    1.Intro                               : |GEEK_skels|
    2.Functionality provided              : |GEEK_skels-Functionality|
     2.1. Reading/processing skeletons    : |GEEK_skels-processing-skels|
     2.2. Parsing skeletons               : |GEEK_skels-parsing|
    3.Writing skeleton files              : |GEEK_skels-writing-skels|
     3.1. Comment markup                  : |GEEK_skels-comments|
     3.2. Yes/no option markup            : |GEEK_skels-yes-no-options|
     3.3. Switch markup                   : |GEEK_skels-switch-options|
     3.4. Value markup                    : |GEEK_skels-value-options|
     3.5. Multiple markup                 : |GEEK_skels-multiple|
     3.6. Multiple unique markup          : |GEEK_skels-multiple-unique|
     3.7. Nesting options                 : |GEEK_skels-nesting|
     3.8. Syntax hightlighting .geek files: |GEEK_skels-highlighting|
    4.Customisation options               : |GEEK_skels-options|
    5.Credits                             : |GEEK_skels-credits|

==============================================================================
1. Intro {{{2                                                     *GEEK_skels*

Geek skeletons is a utility that reads in a chosen skeleton file and
preprocesses it according to markup in the file. The script uses this markup
to get input from the user which it uses to alter the skeleton before copying
it into the current buffer. The markup allows the skeleton files to act kind of
like little wizards.

==============================================================================
2. Functionality provided {{{2                      *GEEK_skels-Functionality*

Currently there are two major pieces of functionality that GEEK_skeletons
provides: the reading and processing of skeleton files and parsing of skeleton
files.

------------------------------------------------------------------------------
2.1. Reading/processing skeletons                *GEEK_skels-processing-skels*

This functionality is accessed with the <leader>gg mapping while in normal
mode. This causes the script to for all available skeletons in a directory
called GEEK_skel which is in the same directory as the plugin file. Inside
this directory the script looks for a directory matching the filetype of the
current buffer as given by the vim option: &filetype. Then, from this
directory it gets all files with an extension of .geek and presents these to
the user to choose the desired skeleton file. For example, if we are editing a
c++ file and the script is in ~/.vim/plugin then, when <leader>gg is pressed,
the script will get all .geek files in ~/.vim/plugin/GEEK_skel/cpp and, after
filtering some files out, present this list of files to the user who will
select the desired skeleton.

When a file is selected from the list it is parsed for syntactical correctness
and, if no errors are detected, preprocessed according to markup contained in
it (see |GEEK_skels-writing-skels| for a detailed description of this markup).
The script processes the file line by line asking the user questions according
to the markup as needed and then copies a version of the skeleton file into
the file being edited. This version of the skeleton will change depending on
the users input.

------------------------------------------------------------------------------
2.2. Parsing skeletons                                    *GEEK_skels-parsing*

When editing a .geek file you may get GEEK_skeletons to parse the file to
check for syntax errors. This is done by pressing <leader>gp

==============================================================================
3. Writing skeleton files {{{2                      *GEEK_skels-writing-skels*

Writing a skeleton consists of two parts. Firstly you have to write the actual
code/text that will be in it and secondly you have to write the markup. The
markup will be used by the script to ask the user for input in order to
customise the skeleton file that will be added to their current file.

There are four types of markup which are explained in subsequent sections.

----------------------------------------------------------------------------~
3.1 Comment markup                                     *GEEK_skels-comments*

This is the simplest markup and is designed to be used to comment skelton
files in the same way as people comment their code. The syntax is: >
    GEEK_COMMENT <comment>
<
All lines containing GEEK_COMMENT are not included in the final skeleton.

----------------------------------------------------------------------------~
3.2. Yes/no option markup                        *GEEK_skels-yes-no-options*

Yes or no options are used to simply include parts of the skeleton file or not
at the users discretion.
The syntax is: >
    GEEK_YN:<name of option>
    <lines that will be included>
    GEEK_END_YN
<
Note that <name of option> must be all one word as recognised by vim.

For example: >
    GEEK_YN:include_foo_and_bar
    FOO
    BAR!!
    GEEK_END_YN
<
Will cause the script to ask the user if they want to use the option
"include_foo_and_bar" and if they type "y" then the lines: >
    FOO
    BAR!!
<
will be included in the final skeleton. If the user enters anything other than
"y" or "n" then "n" will be assumed.
The script remembers what the users response was so if the same yes or no
option is later encountered the same response will be assumed automatically.

In the final version of the skeleton that is included in the file being
edited, the lines containing the GEEK_YN: and GEEK_END_YN will be removed.

----------------------------------------------------------------------------~
3.3. Switch markup                               *GEEK_skels-switch-options*

The switch markup is like a yes or no option |GEEK_skels-yes-no-options| but
with an arbitrary number of possible choices. 

The syntax is: >
    GEEK_BEGIN_SWITCH:<option name>
        GEEK_CASE:<case name 1>
        <lines to be included for case 1>
        GEEK_CASE:<case name 2>
        <lines to be included for case 2>
         ...
    GEEK_END_SWITCH
<
Note that both <option name> and <case name .*> must be one word each as
recognised by vim.

For example if we have the following: >
    GEEK_BEGIN_SWITCH:favourite_super_hero
        GEEK_CASE:superman
        nice choice!
        superman is cool
        GEEK_CASE:wonderwoman
        ohhh yeah WONDERWOMAN!!
        whip me baby!!
        GEEK_CASE:batman
        I dont like men who dress up in latex
    GEEK_END_SWITCH
<
Then the user will be given a list of options corresponding to the GEEK_CASEs.
So in this example the user will be given a list of 3 things: superman,
wonderwoman and batman. The text that will be included for each option is
simply the text under the GEEK_CASE and before the next GEEK_CASE (or
GEEK_END_SWITCH if it is the last CASE). So if they choose wonderwoman from
the list then >
        ohhh yeah WONDERWOMAN!!
        whip me baby!!
<
will be included in the final skeleton. If the user enters an invalid choice
then the first of the cases will be included in the final skeleton.

Similarly to yes or no options |GEEK_skels-yes-no-options| the script
remembers what the users choice was and, if another switch with the same name
(favourite_super_hero in the example) is encountered then the same choice is
assumed.

In the final version of the skeleton that is included in the file being
edited, the lines containing the GEEK_BEGIN_SWITCH:, GEEK_CASE: and
GEEK_END_SWITCH are removed.

----------------------------------------------------------------------------~
3.4. Value markup                                  *GEEK_skels-value-options*

This markup is used just to substitute a value into the skeleton. The syntax is:>
    GEEK_VAL_<option name>
<
Note that <option name> must be one word as recognised by vim.

For example: >
    class GEEK_VAL_class_name{
        public:
            GEEK_VAL_class_name();
            virtual ~GEEK_VAL_class_name();
    };
<
will cause the user to be asked to enter a value for "class_name" which will
be substituted where ever GEEK_VAL_class_name is found in the skeleton.

----------------------------------------------------------------------------~
3.5. Multiple markup                             *GEEK_skels-multiple*

Multiple markup, as the name suggests, is used to make multiple copies of
text. They syntax is: >
    GEEK_MULTIPLE:<option name>
    <text>
    GEEK_END_MULTIPLE
<
Note that <option name> must be one word as recognised by vim.

For example the following code: >
    GEEK_MULTIPLE:how_many_foos
    foo
    GEEK_END_MULTIPLE
<
will ask prompt the user to enter a number for the option "how many foos"
and will then include <text> that many times. For this example if the user
typed 5 then the text: >
    foo
    foo
    foo
    foo
    foo
<
would be included in the final skeleton.

The script remembers the user response so if another multiple is found with
the same <option name> then the same response will be assumed.

----------------------------------------------------------------------------~
3.6. Multiple unique markup               *GEEK_skels-multiple-unique*

Multiple unique markup is exactly the same as normal multiple markup except
that all option names in the markup in resulting copies are made unique. This
is done my just appending a number to the end of the copied option names.

The syntax is: >
    GEEK_MULTIPLE_UNIQUE:<option name>
    <text>
    GEEK_END_MULTIPLE_UNIQUE
<
Note that <option name> must be one word as recognised by vim.

So if we have the following code: >
    GEEK_MULTIPLE_UNIQUE:how_many_classes
    GEEK_BEGIN_SWITCH:is_class_public
        GEEK_CASE:yes
    public abstract class GEEK_VAL:class_name{
        GEEK_CASE:no
    abstract class GEEK_VAL:class_name{
    GEEK_END_SWITCH
    }
    GEEK_END_MULTIPLE_UNIQUE
<
The user will be prompted for a value of "how_many_classes" and if they type 2
then the script will expand the above code to: >
    GEEK_BEGIN_SWITCH:is_class_public
        GEEK_CASE:yes
    public abstract class GEEK_VAL:class_name{
        GEEK_CASE:no
    abstract class GEEK_VAL:class_name{
    GEEK_END_SWITCH
    }
    GEEK_BEGIN_SWITCH:is_class_public_1
        GEEK_CASE:yes
    public abstract class GEEK_VAL:class_name_1{
        GEEK_CASE:no
    abstract class GEEK_VAL:class_name_1{
    GEEK_END_SWITCH
    }
<
Note that the option names in the second copy are different from that of the
first in that they have "_1" appended to them. If 3 copies were made then the
3rd copy would have "_2" appended to the options and so on. This is useful
because the script will consider the options in each copy to have different
names and will hence not assume the same value for all options. In the above
example this will allow us specify FOR EACH COPY a different value for
class_name and is_class_public.

----------------------------------------------------------------------------~
3.7. Nesting options                                    *GEEK_skels-nesting*

Yes/no and switch options can be nested. For example if we have: >

    GEEK_BEGIN_SWITCH:favourite_gun
        GEEK_CASE:submachine_gun
            GEEK_BEGIN_SWITCH:favourite_submachine_gun
                GEEK_CASE:mp40
                    fast fire rate, low stability
                GEEK_CASE:uzi
                    very stable with good recovery...
                GEEK_CASE:UMP
                    stable, med firerate and accuracy, not bad
            GEEK_END_SWITCH
        
        GEEK_CASE:pistol
            pussy
        GEEK_CASE:rocket_launcher
            HARCORE!!
    GEEK_END_SWITCH
<
Then the user will be prompted as to what their favourite gun is and if (and
only if) they choose submachinegun they will be further prompted as to their
favourite submachine gun.

----------------------------------------------------------------------------~
3.8. Syntax hightlighting .geek files              *GEEK_skels-highlighting*

Support for syntax highlighting of .geek files is included in the script. This
is to make editing skeleton files easier. Just thought i'd mention it to show
off!! :P

==============================================================================
4.Customisation options                                   *GEEK_skels-options*

To set these options just put the given line in your .vimrc.

The Skeleton Directory~
To change where the script looks for the skeletons stick use this line: >
    let g:skelsDir='<new location>'
<
This will cause the script to look in <new location>/&filetype/ for skeleton
files.


==============================================================================
5. Credits {{{2                                           *GEEK_skels-credits*

Nick Brettell for being my experimental monkey boy and writing templates to
test my crap.

Igor Prischepoff for pointing out bugs and making suggestions.

Coldplay (im listening to them right now).
==============================================================================

=== END_DOC
" vim: set foldmethod=marker :
