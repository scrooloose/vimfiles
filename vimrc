set nocompatible

"set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

"let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'derekwyatt/vim-fswitch'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'fisadev/vim-ctrlp-cmdpalette'
Plugin 'tpope/vim-endwise'
Plugin 'mzlogin/vim-markdown-toc'
Plugin 'tpope/vim-fugitive'
Plugin 'henrik/vim-indexed-search'
Plugin 'scrooloose/nerdtree'
Plugin 'scrooloose/vim-slumlord'
Plugin 'scrooloose/vim-snakey-camel'
Plugin 'Xuyuanp/nerdtree-git-plugin'
Plugin 'scrooloose/nerdcommenter'
Plugin 'scrooloose/syntastic'
Plugin 'scrooloose/vim-orgymode'
Plugin 'tpope/vim-rails'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-ragtag'
Plugin 'tpope/vim-repeat'
Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'
Plugin 'mbbill/undotree'
Plugin 'vim-scripts/YankRing.vim'
Plugin 'majutsushi/tagbar'
Plugin 'Valloric/MatchTagAlways'
Plugin 'EinfachToll/DidYouMean'
Plugin 'michaeljsmith/vim-indent-object'
Plugin 'christoomey/vim-tmux-navigator'
Plugin 'ludovicchabant/vim-gutentags'
Plugin 'airblade/vim-gitgutter'
Plugin 'godlygeek/tabular'
Plugin 'kana/vim-textobj-user'
Plugin 'nelstrom/vim-textobj-rubyblock'
Plugin 'dhruvasagar/vim-table-mode'
Plugin 'mattn/webapi-vim'
Plugin 'mattn/gist-vim'
Plugin 'AndrewRadev/sideways.vim'
Plugin 'janko-m/vim-test'
Plugin 'jgdavey/tslime.vim'
Plugin 'machakann/vim-highlightedyank'
Plugin 'FooSoft/vim-argwrap'
Plugin 'sheerun/vim-polyglot'
Plugin 'dkarter/bullets.vim'

"colours
Plugin 'morhetz/gruvbox'
Plugin 'danilo-augusto/vim-afterglow'
Plugin 'flazz/vim-colorschemes'
call vundle#end()

"not sure why this is getting unset by vundle
set rtp+=~/.vim

set rtp+=~/code/vim-colon-therapy

runtime macros/matchit.vim

"allow backspacing over everything in insert mode
set backspace=indent,eol,start

"store lots of :cmdline history
set history=1000

set showcmd     "show incomplete cmds down the bottom
set showmode    "show current mode down the bottom

set number      "show line numbers

"display tabs and trailing spaces
set list
set listchars=tab:▷⋅,trail:⋅,nbsp:⋅

set incsearch   "find the next match as we type the search
set hlsearch    "hilight searches by default
if has("nvim")
    set inccommand=nosplit
endif

set wrap        "dont wrap lines
set linebreak   "wrap lines at convenient points

if v:version >= 703
    "undo settings
    set undodir=~/.vim/undofiles
    set undofile

    set colorcolumn=+1 "mark the ideal max text width
endif

set directory=~/.vim/swapfiles//

"default indent settings
set shiftwidth=4
set softtabstop=4
set expandtab
set autoindent

"folding settings
set foldmethod=indent   "fold based on indent
set foldnestmax=3       "deepest fold is 3 levels
set nofoldenable        "dont fold by default
set foldtext=MyFoldText()
set fillchars=vert:\|

function! MyFoldText()
    let DeepestAssumedFoldLvl = 5

    let line = getline(v:foldstart)
    let align = repeat(" ", DeepestAssumedFoldLvl - strlen(v:folddashes))
    let rhs = " " . (v:foldend - v:foldstart) . " lines" . align . v:folddashes
    let spacer = repeat(' ', (winwidth(".") - len(line) - len(rhs) - 10))

    return line . spacer . rhs
endfunction

"This is mostly for airline - this was causing lag when moving the cursor
"between windows
set lazyredraw

set wildmode=list:longest,full   "make cmdline tab completion similar to bash
set wildmenu                     "enable ctrl-n and ctrl-p to scroll thru matches
set wildignore=*.o,*.obj,*~      "stuff to ignore when tab completing

set formatoptions-=o "dont continue comments when pushing /O

"vertical/horizontal scroll off settings
set scrolloff=3
set sidescrolloff=7
set sidescroll=1

"dont show epic message for swapfiles (most of these are bogus for me).
"Use :recover when we actually need to recover from swapfile
set shortmess+=A

"load ftplugins and indent files
filetype plugin on
filetype indent on

"turn on syntax highlighting
syntax on

"some stuff to get the mouse going in term
set mouse=a
if !has("nvim")
    set ttymouse=xterm2
endif

set termguicolors
"set background=dark
"colorscheme gruvbox
"hi Normal guibg=NONE ctermbg=NONE
"hi EndOfBuffer guibg=NONE ctermbg=NONE
"hi SpellBad ctermbg=NONE ctermfg=167 cterm=underline
let g:afterglow_inherit_background=1
color afterglow

"hide buffers when not displayed
set hidden

iabbrev teh the

set ignorecase
set smartcase

if filereadable('/usr/share/dict/words')
    set dictionary=/usr/share/dict/words
endif

"statusline setup
set statusline=%{expand('%:.')}
set statusline+=\ "whitespace

"display a warning if fileformat isnt unix
set statusline+=%#warningmsg#
set statusline+=%{&ff!='unix'?'['.&ff.']':''}
set statusline+=%*

"display a warning if file encoding isnt utf-8
set statusline+=%#warningmsg#
set statusline+=%{(&fenc!='utf-8'&&&fenc!='')?'['.&fenc.']':''}
set statusline+=%*

"read only flag
set statusline+=%#identifier#
set statusline+=%r
set statusline+=%*

"modified flag
set statusline+=%#warningmsg#
set statusline+=%m
set statusline+=%*

"display a warning if &et is wrong, or we have mixed-indenting
set statusline+=%#error#
set statusline+=%{StatuslineTabWarning()}
set statusline+=%*

set statusline+=%#error#
set statusline+=%{StatuslineTrailingSpaceWarning()}
set statusline+=%*

set statusline+=%{StatuslineLongLineWarning()}

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

"display a warning if &paste is set
set statusline+=%#error#
set statusline+=%{&paste?'[paste]':''}
set statusline+=%*

set statusline+=%=      "left/right separator
set statusline+=%{StatuslineCurrentHighlight()}\ \ "current highlight
set statusline+=%c,     "cursor column
set statusline+=%l/%L   "cursor line/total lines
set statusline+=\ %P    "percent through file
set laststatus=2

"recalculate the trailing whitespace warning when idle, and after saving
autocmd cursorhold,bufwritepost * unlet! b:statusline_trailing_space_warning

"return '[\s]' if trailing white space is detected
"return '' otherwise
function! StatuslineTrailingSpaceWarning()
    if !exists("b:statusline_trailing_space_warning")

        if !&modifiable
            let b:statusline_trailing_space_warning = ''
            return b:statusline_trailing_space_warning
        endif

        if search('\s\+$', 'nw') != 0
            let b:statusline_trailing_space_warning = '[\s]'
        else
            let b:statusline_trailing_space_warning = ''
        endif
    endif
    return b:statusline_trailing_space_warning
endfunction

"return the syntax highlight group under the cursor ''
function! StatuslineCurrentHighlight()
    if !exists('g:statusline_show_current_highlight')
        return ''
    endif

    let name = synIDattr(synID(line('.'),col('.'),1),'name')
    if name == ''
        return ''
    else
        return '[' . name . ']'
    endif
endfunction

"recalculate the tab warning flag when idle and after writing
autocmd cursorhold,bufwritepost * unlet! b:statusline_tab_warning

"return '[&et]' if &et is set wrong
"return '[mixed-indenting]' if spaces and tabs are used to indent
"return an empty string if everything is fine
function! StatuslineTabWarning()
    if !exists("b:statusline_tab_warning")
        let b:statusline_tab_warning = ''

        if !&modifiable
            return b:statusline_tab_warning
        endif

        let tabs = search('^\t', 'nw') != 0

        "find spaces that arent used as alignment in the first indent column
        let spaces = search('^ \{' . &ts . ',}[^\t]', 'nw') != 0

        if tabs && spaces
            let b:statusline_tab_warning =  '[mixed-indenting]'
        elseif (spaces && !&et) || (tabs && &et)
            let b:statusline_tab_warning = '[&et]'
        endif
    endif
    return b:statusline_tab_warning
endfunction

"recalculate the long line warning when idle and after saving
autocmd cursorhold,bufwritepost * unlet! b:statusline_long_line_warning

"return a warning for "long lines" where "long" is either &textwidth or 80 (if
"no &textwidth is set)
"
"return '' if no long lines
"return '[#x,my,$z] if long lines are found, were x is the number of long
"lines, y is the median length of the long lines and z is the length of the
"longest line
function! StatuslineLongLineWarning()
    if !exists("b:statusline_long_line_warning")

        if !&modifiable
            let b:statusline_long_line_warning = ''
            return b:statusline_long_line_warning
        endif

        let long_line_lens = s:LongLines()

        if len(long_line_lens) > 0
            let b:statusline_long_line_warning = "[" .
                        \ '#' . len(long_line_lens) . "," .
                        \ 'm' . s:Median(long_line_lens) . "," .
                        \ '$' . max(long_line_lens) . "]"
        else
            let b:statusline_long_line_warning = ""
        endif
    endif
    return b:statusline_long_line_warning
endfunction

"return a list containing the lengths of the long lines in this buffer
function! s:LongLines()
    let threshold = (&tw ? &tw : 80)
    let spaces = repeat(" ", &ts)
    let line_lens = map(getline(1,'$'), 'len(substitute(v:val, "\\t", spaces, "g"))')
    return filter(line_lens, 'v:val > threshold')
endfunction

"find the median of the given array of numbers
function! s:Median(nums)
    let nums = sort(a:nums)
    let l = len(nums)

    if l % 2 == 1
        let i = (l-1) / 2
        return nums[i]
    else
        return (nums[l/2] + nums[(l/2)-1]) / 2
    endif
endfunction

"fswitch settings
command! -nargs=0 A FSHere
command! -nargs=0 AS FSSplitAbove
command! -nargs=0 AV FSSplitLeft

"sideways conf - for swapping arguments around
nnoremap <leader>sh :SidewaysLeft<cr>
nnoremap <leader>sl :SidewaysRight<cr>

"text objects for function args
omap aa <Plug>SidewaysArgumentTextobjA
xmap aa <Plug>SidewaysArgumentTextobjA
omap ia <Plug>SidewaysArgumentTextobjI
xmap ia <Plug>SidewaysArgumentTextobjI

"csv settings
let g:csv_nomap_space=1

"plantuml conf
let g:plantuml_executable_script = "$HOME/.vim/plantuml/uml.sh"

"use space as leader in sensible modes
nmap <space> <Leader>
vmap <space> <Leader>

"make wrapped lines more intuitive
noremap <silent> k gk
noremap <silent> j gj
noremap <silent> 0 g0
noremap <silent> $ g$

"fix for yankring and neovim
let g:yankring_clipboard_monitor=0

"vim-gist settings
let g:gist_post_private = 1
let g:gist_browser_command = 'sensible-browser %URL%'

"add new words (via zg) here
setlocal spellfile+=~/.vim/spell/en.utf-8.add

"make table-mode tables github-markdown compat
let g:table_mode_corner="|"

map <leader>T <Plug>(table-mode-tableize)

"syntastic settings
let syntastic_stl_format = '[Syntax: %E{line:%fe }%W{#W:%w}%B{ }%E{#E:%e}]'
let g:syntastic_mode_map = {
    \ "mode": "active",
    \ "passive_filetypes": ["python"] }

"nerdtree settings
let g:NERDTreeMouseMode = 2
let g:NERDTreeWinSize = 40
let g:NERDTreeMinimalUI=1
let g:NERDTreeIgnore=['\~$', '__pycache__']

"tagbar settings
let g:tagbar_sort = 0
if executable('ripper-tags')
    let g:tagbar_type_ruby = {
        \ 'kinds'      : ['m:modules',
                        \ 'c:classes',
                        \ 'C:constants',
                        \ 'F:singleton methods',
                        \ 'f:methods',
                        \ 'a:aliases'],
        \ 'kind2scope' : { 'c' : 'class',
                         \ 'm' : 'class' },
        \ 'scope2kind' : { 'class' : 'c' },
        \ 'ctagsbin'   : 'ripper-tags',
        \ 'ctagsargs'  : ['-f', '-']
        \ }
endif

"vim-test settings
let test#strategy = "tslime"
let g:test#ruby#use_spring_binstub=1
nnoremap <leader>tt :TestNearest<cr>
nnoremap <leader>tf :TestFile<cr>
nnoremap <leader>ta :TestSuite<cr>
nnoremap <leader>tl :TestLast<cr>
nnoremap <leader>tg :TestVisit<cr>

autocmd bufenter,bufnewfile $HOME/code/labforge/tests/*.py call s:setup_labforge_tests()
function! s:setup_labforge_tests() abort
    let g:test#python#nose2#executable="python3 -munittest"
    let g:test#python#runner="Nose2"
endfunction

"explorer mappings
nnoremap <leader>nt :NERDTreeToggle<cr>
nnoremap <leader>nf :NERDTreeFind<cr>
nnoremap <leader>nn :e .<cr>
nnoremap <leader>nd :e %:h<cr>
nnoremap <leader>] :TagbarToggle<cr>
nnoremap <leader>f :CtrlP<cr>
nnoremap <leader>b :CtrlPBuffer<cr>
nnoremap <leader>p :CtrlPCmdPalette<cr>
nnoremap <c-f> :CtrlP<cr>
nnoremap <c-b> :CtrlPBuffer<cr>

"command abbrevs we can use `:E<space>` (and similar) to edit a file in the
"same dir as current file
cabbrev E <c-r>="e "  . expand("%:h") . "/"<cr><c-r>=<SID>Eatchar(' ')<cr>
cabbrev Sp <c-r>="sp " . expand("%:h") . "/"<cr><c-r>=<SID>Eatchar(' ')<cr>
cabbrev SP <c-r>="sp " . expand("%:h") . "/"<cr><c-r>=<SID>Eatchar(' ')<cr>
cabbrev Vs <c-r>="vs " . expand("%:h") . "/"<cr><c-r>=<SID>Eatchar(' ')<cr>
cabbrev VS <c-r>="vs " . expand("%:h") . "/"<cr><c-r>=<SID>Eatchar(' ')<cr>
cabbrev R <c-r>="r " . expand("%:h") . "/"<cr><c-r>=<SID>Eatchar(' ')<cr>
function! s:Eatchar(pat)
  let c = nr2char(getchar(0))
  return (c =~ a:pat) ? '' : c
endfunc

"argwrap settings
nnoremap <leader>w :ArgWrap<cr>

"ultisnips settings
let g:UltiSnipsListSnippets = "<c-s>"
augroup Ultisnips
    autocmd bufenter,bufnewfile */factories/*.rb UltiSnipsAddFiletypes factory_girl
    autocmd bufenter,bufnewfile */app/admin/*.rb,*/app/views/activeadmin/*.{rb,arb},*.erb UltiSnipsAddFiletypes formtastic
augroup END

if has("nvim")
    tnoremap <silent> <Esc> <C-\><C-n>`.$
    tnoremap <A-h> <C-\><C-n><C-w>h
    tnoremap <A-j> <C-\><C-n><C-w>j
    tnoremap <A-k> <C-\><C-n><C-w>k
    tnoremap <A-l> <C-\><C-n><C-w>l
    autocmd BufEnter term://* startinsert
endif

"source project specific config files
runtime! projects/**/*.vim

"dont load csapprox if we no gui support - silences an annoying warning
if !has("gui")
    let g:CSApprox_loaded = 1
endif

"ruby block textobj conf - remap from ar/ir to ab/ib
let g:textobj_rubyblock_no_default_key_mappings = 1
xmap ab  <Plug>(textobj-rubyblock-a)
omap ab  <Plug>(textobj-rubyblock-a)
xmap ib  <Plug>(textobj-rubyblock-i)
omap ib  <Plug>(textobj-rubyblock-i)

"make <c-l> clear the highlight as well as redraw
nnoremap <C-L> :nohls<CR><C-L>
inoremap <C-L> <C-O>:nohls<CR>

"map Q to something useful
noremap Q gq

"make Y consistent with C and D
nnoremap Y y$

"make & highlight the current word, but not move cursor
nnoremap + :let @/='\V\<'.escape(expand('<cword>'), '\').'\>'<cr>:set hls<cr>:ShowSearchIndex<cr>

"visual search mappings
function! s:VSetSearch()
    let temp = @@
    norm! gvy
    let @/ = '\V' . substitute(escape(@@, '\'), '\n', '\\n', 'g')
    let @@ = temp
endfunction
vnoremap * :<C-u>call <SID>VSetSearch()<CR>//<CR>:ShowSearchIndex<CR>
vnoremap # :<C-u>call <SID>VSetSearch()<CR>??<CR>:ShowSearchIndex<CR>
vnoremap + :<C-u>call <SID>VSetSearch()<CR>:set hls<CR>:ShowSearchIndex<CR>

"indexed search settings
"
"disable defaults, otherwise it blows away the * and # mappings above
let g:indexed_search_mappings=0
nnoremap n n:ShowSearchIndex<cr>
nnoremap N N:ShowSearchIndex<cr>

"gutentags settings
let g:gutentags_ctags_exclude = ['vendor/*', 'tmp/*', 'log/*', 'coverage/*', 'doc/*']
let g:gutentags_generate_on_missing=0
let g:gutentags_generate_on_new=0

"tmux-vim-navigator setup
let g:tmux_navigator_no_mappings = 1
nnoremap <silent> <m-h> :TmuxNavigateLeft<cr>
nnoremap <silent> <m-j> :TmuxNavigateDown<cr>
nnoremap <silent> <m-k> :TmuxNavigateUp<cr>
nnoremap <silent> <m-l> :TmuxNavigateRight<cr>
nnoremap <silent> <m-w> :TmuxNavigatePrevious<cr>

"ctrlp settings
let g:ctrlp_custom_ignore = '\(\/vendor\/bundle\|db\/migrate\)'
let g:ctrlp_max_files = 40000
let g:ctrlp_user_command = {
\ 'types': {
  \ 1: ['.git', 'cd %s && git ls-files'],
  \ 2: ['.hg', 'hg --cwd %s locate -I .'],
  \ },
\ 'fallback': 'find %s -type f'
\ }

"jump to last cursor position when opening a file
"dont do it when writing a commit log entry
autocmd BufReadPost * call SetCursorPosition()
function! SetCursorPosition()
    if &filetype !~ 'svn\|commit\c'
        if line("'\"") > 0 && line("'\"") <= line("$")
            exe "normal! g`\""
            normal! zz
        endif
    else
        call cursor(1,1)
    endif
endfunction

"spell check when writing commit logs
autocmd filetype svn,*commit* setlocal spell

"ruby settings
let g:ruby_indent_access_modifier_style = 'normal'

"markdown settings
let g:markdown_fenced_languages = ['ruby', 'json', 'python']

" these things are handled by bullets.vim
let g:vim_markdown_auto_insert_bullets = 0
let g:vim_markdown_new_list_item_indent = 0

let g:bullets_outline_levels = ['ROM', 'ABC', 'num', 'abc', 'rom', 'std*', 'std-']

"add :Efactory and Eadmin etc for rails
let g:rails_projections = {
    \ "spec/factories/*.rb": {
    \   "command": "factory",
    \   "template":
    \     ["FactoryGirl.define do", "  factory :{} do", "  end", "end"]
    \ },
    \ "app/admin/*.rb": {
    \   "command": "admin",
    \   "template":
    \     ["ActiveAdmin.register {camelcase|singular|capitalize} do", "end"],
    \ },
    \ "app/graphql/resolvers/*.rb": {
    \   "command": "resolver"
    \ },
    \ "app/graphql/inputs/*.rb": {
    \   "command": "input"
    \ },
    \ "app/graphql/types/*.rb": {
    \   "command": "type"
    \ },
    \ "app/graphql/mutations/*.rb": {
    \   "command": "mutation"
    \ },
    \ "app/controllers/api/v5/*.rb": {
    \   "command": "api"
    \ }}

"activate rainbow parens for clojure
autocmd syntax clojure call s:ActivateRainbowParens()
function! s:ActivateRainbowParens() abort
    RainbowParenthesesToggle
    RainbowParenthesesLoadRound
    RainbowParenthesesLoadSquare
    RainbowParenthesesLoadBraces
endfunction

nnoremap <F12> :NotesToggle<cr>
command! -nargs=0 NotesToggle call <sid>toggleNotes()
function! s:toggleNotes() abort
    botright silent 90vs ~/notes
    setl wfw

    "hack to make nerdtree et al not split the window
    silent! setl previewwindow

    "for some reason this doesnt get run automatically and the cursor
    "position doesn't get set
    doautocmd bufreadpost %
endfunction

"command to filter :scriptnames output by a regex
command! -nargs=1 Scriptnames call <sid>scriptnames(<f-args>)
function! s:scriptnames(re) abort
    redir => scriptnames
        silent scriptnames
    redir END

    let filtered = filter(split(scriptnames, "\n"), "v:val =~ '" . a:re . "'")
    echo join(filtered, "\n")
endfunction

" set the arglist to all conflicting files in the current repo
command! GitLoadConflicts call s:loadGitConfictsIntoArglist()
function! s:loadGitConfictsIntoArglist() abort
    silent! argdel *
    let conflicted_files = system('git diff --name-only --diff-filter=U | tr "\n" " "')
    exec 'argadd ' . conflicted_files
    rewind
    call search('=======')
    echomsg "Use <leader>gn to Gwrite and go to next conflict"
endfunction

nnoremap <leader>gn :Gwrite \| next \| call search('=======')<cr>

" I typo this enough to be worthwhile aliasing it
command! W :write

" Decode the big blobs of base64 encoded saml that we get in the logs
" Install xmllint on ubuntu with: apt-get install libxml2-utils
nnoremap <leader>sd "+p:SamlDecode<cr>
command! SamlDecode :call s:SamlDecode()
function! s:SamlDecode() abort
    %!base64 -d
    %!xmllint --format -
    setf xml
endfunction
