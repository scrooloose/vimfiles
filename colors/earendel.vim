hi clear

if exists("syntax_on")
    syntax reset
endif

let colors_name = "earendel"

execute "command! -nargs=1 Colo set background=<args>"

if &background == "light"
    hi Normal ctermbg=White ctermfg=Black guibg=#ffffff guifg=#000000 gui=none

    hi Cursor guibg=#000000 guifg=#ffffff gui=none
    hi CursorColumn ctermbg=LightGray ctermfg=fg guibg=#e5e5e5 gui=none
    hi CursorLine ctermbg=LightGray ctermfg=fg guibg=#e5e5e5 gui=none
    hi DiffAdd guibg=#c4ec93 guifg=fg gui=none
    hi DiffChange guibg=#abb1d3 guifg=fg gui=none
    hi DiffDelete guibg=#f499ba guifg=fg gui=none
    hi DiffText guibg=#95a4ea guifg=fg gui=bold
    hi Directory guibg=bg guifg=#272fc2 gui=none
    hi ErrorMsg guibg=#dc0023 guifg=#ffffff gui=bold
    hi FoldColumn ctermbg=bg guibg=bg guifg=#7f7f7f gui=none
    hi Folded guibg=#cccccc guifg=#4d4d4d gui=bold
    hi IncSearch guibg=#f4a88a gui=none
    hi LineNr guibg=bg guifg=#7f7f7f gui=none
    hi ModeMsg ctermbg=bg ctermfg=fg guibg=bg guifg=fg gui=bold
    hi MoreMsg guibg=bg guifg=#4d4d4d gui=bold
    hi NonText ctermfg=DarkGray guibg=bg guifg=#7f7f7f gui=bold
    hi Pmenu guibg=#bfbfbf guifg=fg gui=none
    hi PmenuSbar guibg=#8c8c8c guifg=fg gui=none
    hi PmenuSel guibg=#fbca01 guifg=fg gui=none
    hi PmenuThumb guibg=#d9d9d9 guifg=fg gui=none
    hi Question guibg=bg guifg=#4d4d4d gui=bold
    hi Search guibg=#fee481 gui=none
    hi SignColumn ctermbg=bg guibg=bg guifg=#7f7f7f gui=none
    hi SpecialKey guibg=bg guifg=#a3563d gui=none
    hi StatusLine ctermbg=Black ctermfg=White guibg=#556587 guifg=#ffffff gui=bold
    hi StatusLineNC ctermbg=LightGray ctermfg=fg guibg=#808080 guifg=#f0f0f0 gui=bold
    if has("spell")
        hi SpellBad guisp=#dc0023 gui=undercurl
        hi SpellCap guisp=#272fc2 gui=undercurl
        hi SpellLocal guisp=#119985 gui=undercurl
        hi SpellRare guisp=#d16c7a gui=undercurl
    endif
    hi TabLine guibg=#bfbfbf guifg=fg gui=underline
    hi TabLineFill guibg=#bfbfbf guifg=fg gui=underline
    hi TabLineSel guibg=bg guifg=fg gui=bold
    hi Title guifg=fg gui=bold
    hi VertSplit ctermbg=LightGray ctermfg=fg guibg=#808080 guifg=#f0f0f0 gui=bold
    if version >= 700
        hi Visual ctermbg=LightGray ctermfg=fg guibg=#cbd1de gui=none
    else
        hi Visual ctermbg=LightGray ctermfg=fg guibg=#cbd1de guifg=fg gui=none
    endif    
    hi VisualNOS ctermbg=DarkGray ctermfg=fg guibg=bg guifg=#62759d gui=bold,underline
    hi WarningMsg guibg=bg guifg=#dc0023 gui=bold
    hi WildMenu guibg=#fbca01 guifg=fg gui=bold

    hi Comment guibg=bg guifg=#619a1b gui=none
    hi Constant guibg=bg guifg=#c6780f gui=none
    hi Error guibg=bg guifg=#dc0023 gui=none
    hi Identifier guibg=bg guifg=#119985 gui=none
    hi Ignore guibg=bg guifg=#ffffff gui=none
    hi lCursor guibg=#79bf21 guifg=#ffffff gui=none
    hi MatchParen guibg=#119985 guifg=#ffffff gui=none
    hi PreProc guibg=bg guifg=#d16c7a gui=none
    hi Special guibg=bg guifg=#a3563d gui=none
    hi Statement guibg=bg guifg=#505b9a gui=bold
    hi Todo guibg=#fedc56 guifg=fg gui=none
    hi Type guibg=bg guifg=#505b9a gui=bold
    hi Underlined ctermbg=bg ctermfg=fg guibg=bg guifg=#272fc2 gui=underline

    hi htmlBold ctermbg=bg ctermfg=fg guibg=bg guifg=fg gui=bold
    hi htmlBoldItalic ctermbg=bg ctermfg=fg guibg=bg guifg=fg gui=bold,italic
    hi htmlBoldUnderline ctermbg=bg ctermfg=fg guibg=bg guifg=fg gui=bold,underline
    hi htmlBoldUnderlineItalic ctermbg=bg ctermfg=fg guibg=bg guifg=fg gui=bold,underline,italic
    hi htmlItalic ctermbg=bg ctermfg=fg guibg=bg guifg=fg gui=italic
    hi htmlUnderline ctermbg=bg ctermfg=fg guibg=bg guifg=fg gui=underline
    hi htmlUnderlineItalic ctermbg=bg ctermfg=fg guibg=bg guifg=fg gui=underline,italic
else
    hi Normal ctermbg=Black ctermfg=LightGray guibg=#101010 guifg=#cdcdcd gui=none

    hi Cursor guibg=#e5e5e5 guifg=#000000 gui=none
    hi CursorColumn ctermbg=DarkGray ctermfg=White guibg=#404040 gui=none
    hi CursorLine ctermbg=DarkGray ctermfg=White guibg=#404040 gui=none
    hi DiffAdd guibg=#00aa66 guifg=#d9d9d9 gui=none
    hi DiffChange guibg=#20369f guifg=fg gui=none
    hi DiffDelete guibg=#bf001d guifg=fg gui=none
    hi DiffText guibg=#0078bf guifg=#e5e5e5 gui=bold
    hi Directory guibg=bg guifg=#7277e2 gui=none
    hi ErrorMsg guibg=#dc0023 guifg=#e5e5e5 gui=bold
    hi FoldColumn ctermbg=bg guibg=bg guifg=#737373 gui=none
    hi Folded guibg=#595959 guifg=fg gui=bold
    hi IncSearch guibg=#ee6c3c guifg=#f2f2f2 gui=none
    hi LineNr guibg=bg guifg=#7f7f7f gui=none
    hi ModeMsg ctermbg=bg ctermfg=fg guibg=bg guifg=fg gui=bold
    hi MoreMsg guibg=bg guifg=#b3b3b3 gui=bold
    hi NonText ctermfg=DarkGray guibg=bg guifg=#7f7f7f gui=bold
    hi Pmenu guibg=#595959 guifg=fg gui=none
    hi PmenuSbar guibg=#737373 guifg=fg gui=none
    hi PmenuSel guibg=#fbca01 guifg=#000000 gui=none
    hi PmenuThumb guibg=#262626 guifg=fg gui=none
    hi Question guibg=bg guifg=#b3b3b3 gui=bold
    hi Search guibg=#8b4a34 guifg=#e5e5e5 gui=none
    hi SignColumn ctermbg=bg guibg=bg guifg=#7f7f7f gui=none
    hi SpecialKey guibg=bg guifg=#d3a901 gui=none
    hi StatusLine ctermbg=LightGray ctermfg=Black guibg=#556587 guifg=#ffffff gui=bold
    hi StatusLineNC ctermbg=LightGray ctermfg=Black guibg=#808080 guifg=#f0f0f0 gui=bold
    if has("spell")
        hi SpellBad guisp=#ea0023 gui=undercurl
        hi SpellCap guisp=#7277e2 gui=undercurl
        hi SpellLocal guisp=#16c9ae gui=undercurl
        hi SpellRare guisp=#f499ba gui=undercurl
    endif
    hi TabLine guibg=#4d4d4d guifg=fg gui=underline
    hi TabLineFill guibg=#4d4d4d guifg=fg gui=underline
    hi TabLineSel guibg=bg guifg=fg gui=bold
    hi Title ctermbg=bg ctermfg=White guifg=fg gui=bold
    hi VertSplit ctermbg=LightGray ctermfg=Black guibg=#808080 guifg=#f0f0f0 gui=bold
    if version >= 700
        hi Visual ctermbg=LightGray ctermfg=Black guibg=#45526d gui=none
    else
        hi Visual ctermbg=LightGray ctermfg=Black guibg=#45526d guifg=fg gui=none
    endif    
    hi VisualNOS ctermbg=DarkGray ctermfg=Black guibg=bg guifg=#62759d gui=bold,underline
    hi WarningMsg guibg=bg guifg=#ea0023 gui=bold
    hi WildMenu guibg=#fbca01 guifg=#000000 gui=bold

    hi Comment guibg=bg guifg=#7dc723 gui=none
    hi Constant guibg=bg guifg=#ed8f12 gui=none
    hi Error guibg=bg guifg=#ea0023 gui=none
    hi Identifier guibg=bg guifg=#16c9ae gui=none
    hi Ignore guibg=bg guifg=fg gui=none
    hi lCursor guibg=#c4ec93 guifg=#000000 gui=none
    hi MatchParen guibg=#17d2b7 guifg=#000000 gui=none
    hi PreProc guibg=bg guifg=#e09ea8 gui=none
    hi Special guibg=bg guifg=#d3a901 gui=none
    hi Statement guibg=bg guifg=#a7aaed gui=none
    hi Todo guibg=#fedc56 guifg=bg gui=none
    hi Type guibg=bg guifg=#a7aaed gui=none
    hi Underlined ctermbg=bg ctermfg=White guibg=bg guifg=#7277e2 gui=underline

    hi htmlBold ctermbg=bg ctermfg=White guibg=bg guifg=fg gui=bold
    hi htmlBoldItalic ctermbg=bg ctermfg=White guibg=bg guifg=fg gui=bold,italic
    hi htmlBoldUnderline ctermbg=bg ctermfg=White guibg=bg guifg=fg gui=bold,underline
    hi htmlBoldUnderlineItalic ctermbg=bg ctermfg=White guibg=bg guifg=fg gui=bold,underline,italic
    hi htmlItalic ctermbg=bg ctermfg=White guibg=bg guifg=fg gui=italic
    hi htmlUnderline ctermbg=bg ctermfg=White guibg=bg guifg=fg gui=underline
    hi htmlUnderlineItalic ctermbg=bg ctermfg=White guibg=bg guifg=fg gui=underline,italic
endif

hi! default link bbcodeBold htmlBold
hi! default link bbcodeBoldItalic htmlBoldItalic
hi! default link bbcodeBoldItalicUnderline htmlBoldUnderlineItalic
hi! default link bbcodeBoldUnderline htmlBoldUnderline
hi! default link bbcodeItalic htmlItalic
hi! default link bbcodeItalicUnderline htmlUnderlineItalic
hi! default link bbcodeUnderline htmlUnderline
