if &background == "dark"
    set background=light
endif

hi clear

if exists("syntax_on")
    syntax reset
endif

let colors_name = "earendel"

hi Normal ctermbg=White ctermfg=Black guibg=White guifg=Black gui=none

hi Cursor guibg=Black guifg=White gui=none
hi CursorColumn ctermbg=LightGray ctermfg=fg guibg=Gray90 gui=none
hi CursorLine ctermbg=LightGray ctermfg=fg guibg=Gray90 gui=none
hi DiffAdd guibg=PaleGreen2 guifg=fg gui=none
hi DiffChange guibg=LightBlue guifg=fg gui=none
hi DiffDelete guibg=LightRed guifg=fg gui=none
hi DiffText guibg=LightSlateBlue guifg=fg gui=bold
hi Directory guibg=bg guifg=Blue2 gui=none
hi ErrorMsg guibg=Red2 guifg=White gui=bold
hi FoldColumn ctermbg=bg guibg=bg guifg=Gray50 gui=none
hi Folded guibg=Gray80 guifg=Gray30 gui=bold
hi IncSearch guibg=LightGreen gui=none
hi LineNr guibg=bg guifg=Gray50 gui=none
hi ModeMsg ctermbg=bg ctermfg=fg guibg=bg guifg=fg gui=bold
hi MoreMsg guibg=bg guifg=Gray30 gui=bold
hi NonText ctermfg=DarkGray guibg=bg guifg=Gray50 gui=bold
hi Pmenu guibg=Gray75 guifg=fg gui=none
hi PmenuSbar guibg=Gray55 guifg=fg gui=none
hi PmenuSel guibg=Yellow guifg=fg gui=none
hi PmenuThumb guibg=Gray85 guifg=fg gui=none
hi Question guibg=bg guifg=Gray30 gui=bold
hi Search guibg=LightYellow gui=none
hi SignColumn ctermbg=bg guibg=bg guifg=Gray50 gui=none
hi SpecialKey guibg=bg guifg=DarkOrange4 gui=none
hi StatusLine ctermbg=Black ctermfg=White guibg=Gray70 guifg=fg gui=bold
hi StatusLineNC ctermbg=LightGray ctermfg=fg guibg=Gray70 guifg=fg gui=none
if has("spell")
    hi SpellBad guisp=Red gui=undercurl
    hi SpellCap guisp=Blue gui=undercurl
    hi SpellLocal guisp=DarkCyan gui=undercurl
    hi SpellRare guisp=Magenta gui=undercurl
endif
hi TabLine guibg=Gray75 guifg=fg gui=underline
hi TabLineFill guibg=Gray75 guifg=fg gui=underline
hi TabLineSel guibg=bg guifg=fg gui=bold
hi Title guifg=fg gui=bold
hi VertSplit ctermbg=LightGray ctermfg=fg guibg=Gray70 guifg=fg gui=none
if version >= 700
    hi Visual ctermbg=LightGray ctermfg=fg guibg=Gray85 gui=none
else
    hi Visual ctermbg=LightGray ctermfg=fg guibg=Gray85 guifg=fg gui=none
endif    
hi VisualNOS ctermbg=DarkGray ctermfg=fg guibg=bg guifg=Gray50 gui=bold,underline
hi WarningMsg guibg=bg guifg=Red2 gui=bold
hi WildMenu guibg=Yellow guifg=fg gui=bold

hi Comment guibg=bg guifg=DarkGreen gui=none
hi Constant guibg=bg guifg=DarkOrange3 gui=none
hi Error guibg=bg guifg=Red gui=none
hi Identifier guibg=bg guifg=DarkCyan gui=none
hi Ignore guibg=bg guifg=White gui=none
hi lCursor guibg=DarkGreen guifg=White gui=none
hi MatchParen guibg=Cyan4 guifg=White gui=none
hi PreProc guibg=bg guifg=Purple3 gui=none
hi Special guibg=bg guifg=DarkOrange4 gui=none
hi Statement guibg=bg guifg=Blue2 gui=none
hi Todo guibg=Yellow guifg=fg gui=none
hi Type guibg=bg guifg=Blue3 gui=none
hi Underlined ctermbg=bg ctermfg=fg guibg=bg guifg=Blue2 gui=underline

hi htmlBold ctermbg=bg ctermfg=fg guibg=bg guifg=fg gui=bold
hi htmlBoldItalic ctermbg=bg ctermfg=fg guibg=bg guifg=fg gui=bold,italic
hi htmlBoldUnderline ctermbg=bg ctermfg=fg guibg=bg guifg=fg gui=bold,underline
hi htmlBoldUnderlineItalic ctermbg=bg ctermfg=fg guibg=bg guifg=fg gui=bold,underline,italic
hi htmlItalic ctermbg=bg ctermfg=fg guibg=bg guifg=fg gui=italic
hi htmlUnderline ctermbg=bg ctermfg=fg guibg=bg guifg=fg gui=underline
hi htmlUnderlineItalic ctermbg=bg ctermfg=fg guibg=bg guifg=fg gui=underline,italic

hi! default link bbcodeBold htmlBold
hi! default link bbcodeBoldItalic htmlBoldItalic
hi! default link bbcodeBoldItalicUnderline htmlBoldUnderlineItalic
hi! default link bbcodeBoldUnderline htmlBoldUnderline
hi! default link bbcodeItalic htmlItalic
hi! default link bbcodeItalicUnderline htmlUnderlineItalic
hi! default link bbcodeUnderline htmlUnderline
