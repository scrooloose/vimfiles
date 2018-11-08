set nocompatible

"set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

"let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'godlygeek/csapprox'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'fisadev/vim-ctrlp-cmdpalette'
Plugin 'tpope/vim-endwise'

Plugin 'tpope/vim-markdown'
Plugin 'rhysd/vim-gfm-syntax'
Plugin 'mzlogin/vim-markdown-toc'

Plugin 'tpope/vim-fugitive'
Plugin 'henrik/vim-indexed-search'
Plugin 'scrooloose/nerdtree'
Plugin 'Xuyuanp/nerdtree-git-plugin'
Plugin 'scrooloose/nerdcommenter'
Plugin 'scrooloose/syntastic'
Plugin 'tpope/vim-rails'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-ragtag'
Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'
Plugin 'mbbill/undotree'
Plugin 'vim-scripts/YankRing.vim'
Plugin 'majutsushi/tagbar'
Plugin 'Valloric/MatchTagAlways'
Plugin 'EinfachToll/DidYouMean'
Plugin 'michaeljsmith/vim-indent-object'
Plugin 'christoomey/vim-tmux-navigator'
Plugin 'chrisbra/csv.vim'
Plugin 'ludovicchabant/vim-gutentags'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'airblade/vim-gitgutter'
Plugin 'godlygeek/tabular'
Plugin 'kana/vim-textobj-user'
Plugin 'nelstrom/vim-textobj-rubyblock'
Plugin 'dhruvasagar/vim-table-mode'
Plugin 'mattn/webapi-vim'
Plugin 'mattn/gist-vim'
Plugin 'aklt/plantuml-syntax'
Plugin 'AndrewRadev/sideways.vim'
Plugin 'janko-m/vim-test'
Plugin 'jgdavey/tslime.vim'
Plugin 'machakann/vim-highlightedyank'
Plugin 'flazz/vim-colorschemes'
Plugin 'pangloss/vim-javascript'
Plugin 'mxw/vim-jsx'
Plugin 'FooSoft/vim-argwrap'
call vundle#end()

"not sure why this is getting unset by vundle
set rtp+=~/.vim

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

"tell the term has 256 colors
"set t_Co=256

set background=dark
colorscheme peaksea
hi Normal guibg=NONE ctermbg=NONE
hi EndOfBuffer guibg=NONE ctermbg=NONE

"hide buffers when not displayed
set hidden

iabbrev teh the

set ignorecase
set smartcase

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

"nerdtree settings
let g:NERDTreeMouseMode = 2
let g:NERDTreeWinSize = 40
let g:NERDTreeMinimalUI=1

"tagbar settings
let g:tagbar_sort = 0
if executable("ripper-tags")
    let g:tagbar_type_ruby = {
                \ 'kinds' : [
                    \ 'm:modules',
                    \ 'c:classes',
                    \ 'f:methods',
                    \ 'F:singleton methods',
                    \ 'C:constants'
                \ ],
                \ 'ctagsbin':  'ripper-tags',
                \ 'ctagsargs': ['-f', '-']
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

"explorer mappings
nnoremap <leader>bb :BufExplorer<cr>
nnoremap <leader>bs :BufExplorerHorizontalSplit<cr>
nnoremap <leader>bv :BufExplorerVerticalSplit<cr>
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
nnoremap & :let @/='\V\<'.escape(expand('<cword>'), '\').'\>'<cr>:set hls<cr>

"visual search mappings
function! s:VSetSearch()
    let temp = @@
    norm! gvy
    let @/ = '\V' . substitute(escape(@@, '\'), '\n', '\\n', 'g')
    let @@ = temp
endfunction
vnoremap * :<C-u>call <SID>VSetSearch()<CR>//<CR>
vnoremap # :<C-u>call <SID>VSetSearch()<CR>??<CR>

"indexed search settings
"
"disable defaults, otherwise it blows away the * and # mappings above
let g:indexed_search_mappings=0
nnoremap n n:ShowSearchIndex<cr>
nnoremap N N:ShowSearchIndex<cr>

"gutentags settings
let g:gutentags_ctags_exclude = ['vendor/*', 'tmp/*', 'log/*', 'coverage/*', 'doc/*']

"tmux-vim-navigator setup
let g:tmux_navigator_no_mappings = 1
nnoremap <silent> <m-h> :TmuxNavigateLeft<cr>
nnoremap <silent> <m-j> :TmuxNavigateDown<cr>
nnoremap <silent> <m-k> :TmuxNavigateUp<cr>
nnoremap <silent> <m-l> :TmuxNavigateRight<cr>
nnoremap <silent> <m-w> :TmuxNavigatePrevious<cr>

"ctrlp settings
let g:ctrlp_custom_ignore = '\v\/vendor\/bundle'

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

"http://vimcasts.org/episodes/fugitive-vim-browsing-the-git-object-database/
"hacks from above (the url, not jesus) to delete fugitive buffers when we
"leave them - otherwise the buffer list gets poluted
"
"add a mapping on .. to view parent tree
autocmd BufReadPost fugitive://* set bufhidden=delete
autocmd BufReadPost fugitive://*
  \ if fugitive#buffer().type() =~# '^\%(tree\|blob\)$' |
  \   nnoremap <buffer> .. :edit %:h<CR> |
  \ endif


"ruby settings
let g:ruby_indent_access_modifier_style = 'normal'

"markdown settings
let g:markdown_fenced_languages = ['ruby', 'json']

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

"when copying/pasting from the term into :e from a git diff or rspec or
"similar we edit things like
"
"./app/models/foo.rb:10:in
"
"Save the time of stripping trailing shit and just make this edit and go to
"line 10.
autocmd bufenter * call s:checkForLnum()
function! s:checkForLnum() abort
    let fname = expand("%:f")
    if fname =~ ':\d\+\(:.*\)\?$'
        let lnum = substitute(fname, '^.*:\(\d\+\)\(:.*\)\?$', '\1', '')
        let realFname = substitute(fname, '^\(.*\):\d\+\(:.*\)\?$', '\1', '')
        exec "edit " . realFname

        if bufnr(fname) != -1
            exec "bdelete " . bufnr(fname)
        endif

        silent doautocmd bufread
        silent doautocmd bufreadpre
        call cursor(lnum, 1)
        normal! zz
    endif
endfunction

"toggle a markdown notes file in a fixed window on the right with f12
nnoremap <F12> :NotesToggle<cr>
command! -nargs=0 NotesToggle call <sid>toggleNotes()
function! s:toggleNotes() abort
    let winnr = bufwinnr("notes.md")
    if winnr > 0
        exec winnr . "wincmd c"
        return
    endif

    botright 100vs notes.md
    setl wfw
    setl nonu

    "hack to make nerdtree et al not split the window
    setl previewwindow

    "for some reason this doesnt get run automatically and the cursor
    "position doesn't get set
    doautocmd bufreadpost %

    setf markdown

    silent! normal zMzO
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

function! ToCamel(str) abort
    if a:str =~ '_'
        return substitute(a:str, '\(\%(\<\l\+\)\%(_\)\@=\)\|_\(\l\)', '\u\1\2', 'g')
    else
        return substitute(a:str, '^\(.\)', '\u\1', '')
    endif
endfunction

" set the arglist to all conflicting files in the current repo
command! GitLoadConflicts call s:loadGitConfictsIntoArglist()
function! s:loadGitConfictsIntoArglist() abort
    argdel *
    let conflicted_files = system('git diff --name-only --diff-filter=U | tr "\n" " "')
    exec 'argadd ' . conflicted_files
    rewind
    call search('=======')
    echomsg "Use <leader>gn to Gwrite and go to next conflict"
endfunction

nnoremap <leader>gn :Gwrite \| next \| call search('=======')<cr>
