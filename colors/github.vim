" Vim color file
" Maintainer: Ricardo Valeriano <ricardo.valeriano@gmail.com>
"     Based on the work by: Bruno Michel <bmichel@menfin.info>
" Last Change: Mar, 01, 2012
" Version: 0.2
" Homepage: http://github.com/ricardovaleriano/vim-github-theme

" This is a ViM's version of the github color theme.

set background=light
hi clear
if exists("syntax_on")
    syntax reset
endif

let g:colors_name = "github"
set t_Co=256

hi Comment              guifg=#999988 ctermfg=102 gui=italic

hi Constant             guifg=#008080 ctermfg=30
    hi String           guifg=#dd1144 ctermfg=161
    hi Character        guifg=#dd1144 ctermfg=161
    hi Number           guifg=#009999 ctermfg=30
    hi Boolean          gui=bold cterm=bold
    hi Float            guifg=#009999 ctermfg=30
    hi RubySymbol       guifg=#990073 ctermfg=90

hi Identifier           guifg=#008080 ctermfg=30
    hi Function         guifg=#990000 ctermfg=88 gui=bold cterm=bold

hi Statement            guifg=#000000 ctermfg=16 gui=bold cterm=bold
    hi Conditional      guifg=#000000 ctermfg=16 gui=bold cterm=bold
    hi Repeat           guifg=#000000 ctermfg=16 gui=bold cterm=bold
    hi Label            guifg=#000000 ctermfg=16 gui=bold cterm=bold
    hi Operator         guifg=#000000 ctermfg=16 gui=bold cterm=bold
    hi Keyword          guifg=#000000 ctermfg=16 gui=bold cterm=bold
    hi Exception        guifg=#990000 ctermfg=88 gui=bold cterm=bold

hi PreProc              guifg=#999999 ctermfg=102 gui=bold cterm=bold
    hi Include          guifg=#999999 ctermfg=102 gui=bold cterm=bold
    hi Define           guifg=#000000 ctermfg=16 gui=bold cterm=bold
    hi Macro            guifg=#999999 ctermfg=102 gui=bold cterm=bold
    hi PreCondit        guifg=#999999 ctermfg=102 gui=bold cterm=bold

hi Type                 guifg=#445588 ctermfg=60 gui=bold cterm=bold
    hi StorageClass     guifg=#000000 ctermfg=16 gui=bold cterm=bold
    hi Structure        guifg=#000000 ctermfg=16 gui=bold cterm=bold
    hi Typedef          guifg=#000000 ctermfg=16 gui=bold cterm=bold

hi Special              guifg=#dd1144 ctermfg=161
    hi SpecialChar      guifg=#dd1144 ctermfg=161
    hi Tag              guifg=#000080 ctermfg=18
    hi Delimiter        guifg=#dd1144 ctermfg=161
    hi SpecialComment   guifg=#999999 ctermfg=102 gui=bold,italic cterm=bold,italic
    hi Debug            guifg=#aa0000 ctermfg=124

hi Underlined           gui=underline cterm=underline

hi Ignore               guifg=bg

hi Error                guifg=#a61717 ctermfg=124 guibg=#e3d2d2 ctermbg=188

hi Todo                 guifg=#999988 ctermfg=102 gui=italic cterm=italic

hi Cursor               guifg=NONE ctermfg=NONE guibg=#ff9900 ctermbg=227
hi CursorLine           guifg=NONE ctermfg=NONE guibg=#ffffcc ctermbg=230
hi Directory            guifg=#4183c4 ctermfg=68
hi DiffAdd              guifg=#000000 ctermfg=16 guibg=#ddffdd ctermbg=194
hi DiffDelete           guifg=#000000 ctermfg=16 guibg=#ffdddd ctermbg=224
hi DiffText             guibg=#666666 ctermbg=59
hi ErrorMsg             guifg=#a61717 ctermfg=124 guibg=#e3d2d2 ctermbg=188 gui=bold cterm=bold
hi VertSplit            guifg=#666666 ctermfg=59 guibg=#eaeaea ctermbg=188
hi LineNr               guifg=#666666 ctermfg=59 guibg=#eaeaea ctermbg=188
hi ModeMsg              gui=bold cterm=bold
hi Normal               guifg=#000000 ctermfg=16 guibg=#f8f8ff ctermbg=231
hi Pmenu                guibg=#babdb6 ctermbg=145 guifg=#555753 ctermfg=59
hi StatusLine           guifg=#666666 ctermfg=59 guibg=#eaeaea ctermbg=188
hi Visual               guifg=NONE ctermfg=NONE guibg=#ffffcc ctermbg=228

"this is a workaround to show the cursor on the Terminal.app
"thanks to: http://www.damtp.cam.ac.uk/user/rbw/vim-osx-cursor.html
if $TERM_PROGRAM == "Apple_Terminal" && !has("gui_running")
  hi CursorLine term=none cterm=none "Invisible CursorLine
  hi Cursor     ctermfg=none ctermbg=85

  set cursorline
  match Cursor /\%#/
endif
