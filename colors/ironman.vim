" Vim color file
" Maintainer:  Michael Boehler
" Mail:        michael@familie-boehler.de
" Last Change: 2005-11-16
" Version:     2.0
" This color scheme uses a light background.
" GUI only

set background=light
hi clear
if exists("syntax_on")
   syntax reset
endif

let colors_name = "ironman"

hi Normal       guifg=#222222 guibg=#fafafa

" Search
hi IncSearch    gui=NONE guifg=#303040 guibg=#ccff00
hi Search       gui=NONE guifg=#303040 guibg=#ffff00

" Messages
hi ErrorMsg     gui=NONE guifg=#FF0000 guibg=NONE    
hi WarningMsg   gui=NONE guifg=#FF6600 guibg=NONE
hi ModeMsg      gui=NONE guifg=#0070ff guibg=NONE
hi MoreMsg      gui=NONE guifg=#a800ff guibg=NONE
hi Question     gui=NONE guifg=#008050 guibg=NONE

" Split area
hi StatusLine   gui=BOLD guifg=#fffacd guibg=#0080FF
hi StatusLineNC gui=NONE guifg=#52627D guibg=#b2bbcc
hi VertSplit    gui=NONE guifg=#fffacd guibg=#b2bbcc
hi WildMenu     gui=NONE guifg=#ffffff guibg=#3399cc

" Diff
hi DiffText     gui=NONE guifg=#f83010 guibg=#ffeae0
hi DiffChange   gui=NONE guifg=#006800 guibg=#d0ffd0
hi DiffDelete   gui=NONE guifg=#2020ff guibg=#c8f2ea
hi DiffAdd      gui=NONE guifg=#2020ff guibg=#c8f2ea

" Cursor
hi Cursor       gui=NONE guifg=#ffffff guibg=#DF6A6A
hi lCursor      gui=NONE guifg=#f8f8f8 guibg=#8000ff
hi CursorIM     gui=NONE guifg=#f8f8f8 guibg=#8000ff

" Fold
hi Folded       gui=NONE guifg=#3399ff guibg=#EAF5FF
hi FoldColumn   gui=NONE guifg=#3399ff guibg=#EAF5FF

" Other
hi Directory    gui=NONE guifg=#0000ff guibg=NONE
hi LineNr       gui=NONE guifg=#0033aa guibg=#ccdcff
hi NonText      gui=NONE guifg=#cccccc guibg=NONE
hi SpecialKey   gui=NONE guifg=#66cccc guibg=NONE
hi Title        gui=NONE guifg=#004060 guibg=#c8f0f8
hi Visual       gui=NONE guifg=#ffffff guibg=#6889de

" Syntax group
hi Comment      gui=NONE guifg=#ff5050 guibg=#ffebeb
hi Constant     gui=NONE guifg=#333333 guibg=#ededed
hi Error        gui=BOLD guifg=#ffffff guibg=#ff4080
hi Identifier   gui=NONE guifg=#339933 guibg=NONE
hi Ignore       gui=NONE guifg=#f8f8f8 guibg=NONE
hi PreProc      gui=NONE guifg=#0070e6 guibg=NONE
hi Special      gui=NONE guifg=#0000ff guibg=#ccf7ee
hi Statement    gui=NONE guifg=#0000FF guibg=NONE
hi Todo         gui=NONE guifg=#ff0070 guibg=#ffe0f4
hi Type         gui=NONE guifg=#eb7950 guibg=NONE
hi Underlined   gui=UNDERLINE guifg=#0000ff guibg=NONE

" HTML
hi htmlLink                 gui=UNDERLINE guifg=#0000ff guibg=NONE
hi htmlBold                 gui=BOLD
hi htmlBoldItalic           gui=BOLD,ITALIC
hi htmlBoldUnderline        gui=BOLD,UNDERLINE
hi htmlBoldUnderlineItalic  gui=BOLD,UNDERLINE,ITALIC
hi htmlItalic               gui=ITALIC
hi htmlUnderline            gui=UNDERLINE
hi htmlUnderlineItalic      gui=UNDERLINE,ITALIC
