" last modified on: 29/mar/04
" last modified by: marty

if exists("nerd_inserter")
   finish
endif
let nerd_inserter = 1

autocmd filetype sh :map \i :call InsertMenu() <CR>

function InsertMenu()
   redraw
   let resp = input("ARRRR Matie, what ye be needing to insert?\n
		     \ (1) - Brackets\n
		     \ (2) - Quotes\n")
   if resp == 1
      call BracketsMenu()
   elseif resp == 2
      call QuotesMenu()
   else
      echo "ARR BLAST YA! Dont ye know what yer DOIN?"
   endif
endfunction

   
function BracketsMenu()
   redraw
   let resp = input("ARRRG! Select yer brackets.\n
		     \ (1) - $[X]\t where X is an arithmetic expression to be evaluated\n
		     \ (2) - $((X))\t is equivalent to (1)\n
		     \ (3) - $(X)\t where X is a subshell (equiv to `X`)\n
		     \ (4) - [X]\t where X is a condition eg if [ \"i\" -lt \"10\"] equiv to: \t\t\t if test \"i\" -lt \"10\"\n")
   if resp == 1
      normal i$[   ]
      normal 2h
   elseif resp == 2
      normal i$((   ))
      normal 4h 
   elseif resp == 3
      normal i$(   )
      normal 2h
   elseif resp == 4
      normal i[   ]
      normal 2h
   else
      echo "ARR BLAST YA! Dont ye know what yer DOIN?"
   endif
endfunction

function QuotesMenu()
   redraw
   let resp = input("BLARRRR, select yer quotes\n
		     \ (1) - \"X\" where X can be interpreted eg echo \"$i\" prints the value of i\n
		     \ (2) - \'X\' where X is not interpreted eg echo \'$i\' prints $i\n
		     \ (3) - \`X\` Executes and substitutes in the value of the subshell X\n ")
   if resp == 1
      normal i" "
      normal h
   elseif resp == 2
      normal i' '
      normal h
   elseif resp == 3
      normal i` `
      normal h
   else
      echo "ARR BLAST YA! Dont ye know what yer DOIN?"
   endif
endfunction
