" CSApprox:    Make gvim-only colorschemes work transparently in terminal vim
" Maintainer:  Matthew Wozniski (mjw@drexel.edu)
" Date:        Sun, 14 Dec 2008 06:12:55 -0500
" Version:     2.00
" History:     :help csapprox-changelog

" Whenever you change colorschemes using the :colorscheme command, this script
" will be executed.  If you're running in 256 color terminal or an 88 color
" terminal, as reported by the command ":set t_Co?", it will take the colors
" that the scheme specified for use in the gui and use an approximation
" algorithm to try to gracefully degrade them to the closest color available.
" If you are running in a gui or if t_Co is reported as less than 88 colors,
" no changes are made.  Also, no changes will be made if the colorscheme seems
" to have been high color already.

" {>1} Basic plugin setup

" {>2} Check preconditions
" Quit if the user doesn't want or need us or is missing the gui feature.  We
" need +gui to be able to check the gui color settings; vim doesn't bother to
" store them if it is not built with +gui.
if ! has("gui") || exists('g:CSApprox_loaded')
  " XXX This depends upon knowing the default for g:CSApprox_verbose_level
  let s:verbose = 1
  if exists("g:CSApprox_verbose_level")
    let s:verbose  = g:CSApprox_verbose_level
  endif

  if ! has('gui') && s:verbose > 0
    echomsg "CSApprox needs gui support - not loading."
    echomsg "  See :help |csapprox-+gui| for possible workarounds."
  endif

  unlet s:verbose

  finish
endif

" {1} Mark us as loaded, and disable all compatibility options for now.
let g:CSApprox_loaded = 1

let s:savecpo = &cpo
set cpo&vim

" {>1} Built-in approximation algorithm

" {>2} Cube definitions
let s:xterm_colors   = [ 0x00, 0x5F, 0x87, 0xAF, 0xD7, 0xFF ]
let s:eterm_colors   = [ 0x00, 0x2A, 0x55, 0x7F, 0xAA, 0xD4 ]
let s:konsole_colors = [ 0x00, 0x33, 0x66, 0x99, 0xCC, 0xFF ]
let s:xterm_greys    = [ 0x08, 0x12, 0x1C, 0x26, 0x30, 0x3A,
                       \ 0x44, 0x4E, 0x58, 0x62, 0x6C, 0x76,
                       \ 0x80, 0x8A, 0x94, 0x9E, 0xA8, 0xB2,
                       \ 0xBC, 0xC6, 0xD0, 0xDA, 0xE4, 0xEE ]

let s:urxvt_colors   = [ 0x00, 0x8B, 0xCD, 0xFF ]
let s:urxvt_greys    = [ 0x2E, 0x5C, 0x73, 0x8B,
                       \ 0xA2, 0xB9, 0xD0, 0xE7 ]

" {>2} Integer comparator
" Used to sort the complete list of possible colors
function! s:IntCompare(i1, i2)
  return a:i1 == a:i2 ? 0 : a:i1 > a:i2 ? 1 : -1
endfunc

" {>2} Approximator
" Takes 3 decimal values for r, g, and b, and returns the closest cube number.
" Uses &term to determine which cube should be used, though if &term is set to
" "xterm" the variables g:CSApprox_eterm and g:CSApprox_konsole can be used to
" change the default palette.
"
" This approximator considers closeness based upon the individiual components.
" For each of r, g, and b, it finds the closest cube component available on
" the cube.  If the three closest matches can combine to form a valid color,
" this color is used, otherwise we repeat the search with the greys removed,
" meaning that the three new matches must make a valid color when combined.
function! s:ApproximatePerComponent(r,g,b)
  let hex = printf("%02x%02x%02x", a:r, a:g, a:b)

  let greys  = (&t_Co == 88 ? s:urxvt_greys : s:xterm_greys)

  if &t_Co == 88
    let colors = s:urxvt_colors
    let type = 'urxvt'
  elseif ((&term ==# 'xterm' || &term =~# '^screen')
       \   && exists('g:CSApprox_konsole'))
       \ || &term =~? '^konsole'
    let colors = s:konsole_colors
    let type = 'konsole'
  elseif ((&term ==# 'xterm' || &term =~# '^screen')
       \   && exists('g:CSApprox_eterm'))
       \ || &term =~? '^eterm'
    let colors = s:eterm_colors
    let type = 'eterm'
  else
    let colors = s:xterm_colors
    let type = 'xterm'
  endif

  if !exists('s:approximator_cache_'.type)
    let s:approximator_cache_{type} = {}
  endif

  let rv = get(s:approximator_cache_{type}, hex, -1)
  if rv != -1
    return rv
  endif

  " Only obtain sorted list once
  if !exists("s:".type."_greys_colors")
    let s:{type}_greys_colors = sort(greys + colors, "s:IntCompare")
  endif

  let greys_colors = s:{type}_greys_colors

  let r = s:NearestElemInList(a:r, greys_colors)
  let g = s:NearestElemInList(a:g, greys_colors)
  let b = s:NearestElemInList(a:b, greys_colors)

  let len = len(colors)
  if (r == g && g == b && index(greys, r) > 0)
    let rv = 16 + len * len * len + index(greys, r)
  else
    let r = s:NearestElemInList(a:r, colors)
    let g = s:NearestElemInList(a:g, colors)
    let b = s:NearestElemInList(a:b, colors)
    let rv = index(colors, r) * len * len
         \ + index(colors, g) * len
         \ + index(colors, b)
         \ + 16
  endif

  let s:approximator_cache_{type}[hex] = rv
  return rv
endfunction

" {>2} Color comparator
" Finds the nearest element to the given element in the given list
function! s:NearestElemInList(elem, list)
  let len = len(a:list)
  for i in range(len-1)
    if (a:elem <= (a:list[i] + a:list[i+1]) / 2)
      return a:list[i]
    endif
  endfor
  return a:list[len-1]
endfunction

" {>1} Collect info for the set highlights

" {>2} Determine if synIDattr is usable
" synIDattr() couldn't support 'guisp' until 7.2.052.  This function returns
" true if :redir is needed to find the 'guisp' attribute, false if synIDattr()
" is functional.  This test can be overridden by setting the global variable
" g:CSApprox_redirfallback to 1 (to force use of :redir) or to 0 (to force use
" of synIDattr()).
function! s:NeedRedirFallback()
  if !exists("g:CSApprox_redirfallback")
    let g:CSApprox_redirfallback = (v:version == 702 && !has('patch52'))
                                 \  || v:version < 702
  endif
  return g:CSApprox_redirfallback
endfunction

" {>2} Collect and store the highlights
" Get a dictionary containing information for every highlight group not merely
" linked to another group.  Return value is a dictionary, with highlight group
" numbers for keys and values that are dictionaries with four keys each,
" 'name', 'term', 'cterm', and 'gui'.  'name' holds the group name, and each
" of the others holds highlight information for that particular mode.
function! s:Highlights()
  let rv = {}

  let i = 0
  while 1
    let i += 1

    " Only interested in groups that exist and aren't linked
    if synIDtrans(i) == 0
      break
    endif

    " Handle vim bug allowing groups with name == "" to be created
    if synIDtrans(i) != i || len(synIDattr(i, "name")) == 0
      continue
    endif

    let rv[i] = {}
    let rv[i].name = synIDattr(i, "name")

    for where in [ "term", "cterm", "gui" ]
      let rv[i][where]  = {}
      for attr in [ "bold", "italic", "reverse", "underline", "undercurl" ]
        let rv[i][where][attr] = synIDattr(i, attr, where)
      endfor

      for attr in [ "fg", "bg", "sp" ]
        let rv[i][where][attr] = synIDattr(i, attr.'#', where)
      endfor

      if s:NeedRedirFallback()
        redir => temp
        exe 'sil hi ' . rv[i].name
        redir END
        let temp = matchstr(temp, where.'sp=\zs.*')
        if len(temp) == 0 || temp[0] =~ '\s'
          let temp = ""
        else
          " Make sure we can handle guisp='dark red'
          let temp = substitute(temp, '[\x00].*', '', '')
          let temp = substitute(temp, '\s*\(c\=term\|gui\).*', '', '')
          let temp = substitute(temp, '\s*$', '', '')
        endif
        let rv[i][where]["sp"] = temp
      endif

      for attr in [ "fg", "bg", "sp" ]
        if rv[i][where][attr] == -1
          let rv[i][where][attr] = ''
        endif
      endfor
    endfor
  endwhile

  return rv
endfunction

" {>1} Handle color names

" Place to store rgb.txt name to color mappings - lazy loaded if needed
let s:rgb = {}

" {>2} Builtin gui color names
" gui_x11.c and gui_gtk_x11.c have some default colors names that are searched
" if a color is not in rgb.txt. We'll pretend they're in rgb.txt with these
" values, and overwrite them with a different value if we find them...
let s:rgb_defaults = { "lightred"     : "#FFBBBB",
                     \ "lightgreen"   : "#88FF88",
                     \ "lightmagenta" : "#FFBBFF",
                     \ "darkcyan"     : "#008888",
                     \ "darkblue"     : "#0000BB",
                     \ "darkred"      : "#BB0000",
                     \ "darkmagenta"  : "#BB00BB",
                     \ "darkgrey"     : "#BBBBBB",
                     \ "darkyellow"   : "#BBBB00",
                     \ "gray10"       : "#1A1A1A",
                     \ "grey10"       : "#1A1A1A",
                     \ "gray20"       : "#333333",
                     \ "grey20"       : "#333333",
                     \ "gray30"       : "#4D4D4D",
                     \ "grey30"       : "#4D4D4D",
                     \ "gray40"       : "#666666",
                     \ "grey40"       : "#666666",
                     \ "gray50"       : "#7F7F7F",
                     \ "grey50"       : "#7F7F7F",
                     \ "gray60"       : "#999999",
                     \ "grey60"       : "#999999",
                     \ "gray70"       : "#B3B3B3",
                     \ "grey70"       : "#B3B3B3",
                     \ "gray80"       : "#CCCCCC",
                     \ "grey80"       : "#CCCCCC",
                     \ "gray90"       : "#E5E5E5",
                     \ "grey90"       : "#E5E5E5" }

" {>2} Find and parse rgb.txt
" Search for an rgb.txt in a set of default directories.  If the user wishes
" to override the default search path, he can specify a list of other
" directories to search first in g:CSApprox_extra_rgb_txt_dirs.  When rgb.txt
" has been located, and verified to be good (by having enough non-blank
" non-comment correctly formatted lines), the parsed information is stored to
" the dictionary s:rgb - the keys are color names (in lowercase), the values
" are strings representing color values (as '#rrggbb').
function! s:UpdateRgbHash()
  " Pattern for ignored lines - all blanks, or blanks then !
  let ignorepat = '^\s*\%(!.*\)\=$'
  " fmt is (blanks?)(red)(blanks)(green)(blanks)(blue)(blanks)(name)
  let parsepat  = '^\s*\(\d\+\)\s\+\(\d\+\)\s\+\(\d\+\)\s\+\(.*\)$'

  let user = []
  if exists("g:CSApprox_extra_rgb_txt_dirs")
    if type(g:CSApprox_extra_rgb_txt_dirs) == type([])
      let user = g:CSApprox_extra_rgb_txt_dirs
    else
      let user = [ g:CSApprox_extra_rgb_txt_dirs ]
    endif
  endif

  for dir in user + [ '/usr/local/share/X11',
                    \ '/usr/share/X11',
                    \ '/etc/X11',
                    \ '/usr/local/lib/X11',
                    \ '/usr/lib/X11',
                    \ '/usr/local/X11R6/lib/X11',
                    \ '/usr/X11R6/lib/X11' ]
                    \ + split(globpath(&rtp, ''), '\n')
    let s:rgb = copy(s:rgb_defaults)
    sil! let lines = readfile(dir . '/rgb.txt')

    for line in lines
      if line =~ ignorepat
        continue " Line is blank, entirely spaces, or a comment
      endif
      let v = matchlist(line, parsepat)
      if len(v) > 0
        let s:rgb[tolower(v[4])] = printf("#%02x%02x%02x", v[1], v[2], v[3])
      endif
    endfor

    if len(s:rgb) > 50
      return 0 " Long enough, must have been valid
    endif
  endfor

  let s:rgb = {}
  throw "Failed to find a valid rgb.txt!"
endfunction

" {>1} Derive and set cterm attributes

" {>2} Attribute overrides
" Allow the user to override a specified attribute with another attribute.
" For example, the default is to map 'italic' to 'underline' (since many
" terminals cannot display italic text, and gvim itself will replace italics
" with underlines where italicizing is impossible), and to replace 'sp' with
" 'fg' (since terminals can't use one color for the underline and another for
" the foreground, we color the entire word).  This default can of course be
" overridden by the user, by setting g:CSApprox_attr_map.  This map must be
" a dictionary of string keys, representing the same attributes that synIDattr
" can look up, to string values, representing the attribute mapped to or an
" empty string to disable the given attribute entirely.
function! s:attr_map(attr)
  let attr = tolower(a:attr)

  if attr == 'inverse'
    let attr = 'reverse'
  endif

  let valid_attrs = [ 'bg', 'fg', 'sp', 'bold', 'italic',
                    \ 'reverse', 'underline', 'undercurl' ]

  if index(valid_attrs, attr) == -1
    throw "Looking up invalid attribute '" . attr . "'"
  endif

  if !exists("g:CSApprox_attr_map") || type(g:CSApprox_attr_map) != type({})
    let g:CSApprox_attr_map = { 'italic' : 'underline', 'sp' : 'fg' }
  endif

  let rv = get(g:CSApprox_attr_map, attr, attr)

  if index(valid_attrs, rv) == -1 && rv != ''
    " The user mapped 'attr' to something invalid
    throw "Bad attr map: '" . attr . "' to unknown attribute '" . rv . "'"
  endif

  let colorattrs = [ 'fg', 'bg', 'sp' ]
  if rv != '' && !!(index(colorattrs, attr)+1) != !!(index(colorattrs, rv)+1)
    " The attribute the user mapped to was valid, but of a different type.
    throw "Bad attr map: Can't map color attr to boolean (".attr."->".rv.")"
  endif

  if rv == 'inverse'
    let rv = 'reverse' " Internally always use 'reverse' instead of 'inverse'
  elseif rv == 'sp'
    " Terminals can't handle the guisp attribute; disable it if it was left on
    let rv = ''
  endif

  return rv
endfunction

" {>2} Normalize the GUI settings of a highlight group
" If the Normal group is cleared, set it to gvim's default, black on white
" Though this would be a really weird thing for a scheme to do... *shrug*
function! s:FixupGuiInfo(highlights)
  if a:highlights[s:hlid_normal].gui.bg == ''
    let a:highlights[s:hlid_normal].gui.bg = 'white'
  endif

  if a:highlights[s:hlid_normal].gui.fg == ''
    let a:highlights[s:hlid_normal].gui.fg = 'black'
  endif
endfunction

" {>2} Map gui settings to cterm settings
" Given information about a highlight group, replace the cterm settings with
" the mapped gui settings, applying any attribute overrides along the way.  In
" particular, this gives special treatment to the 'reverse' attribute and the
" 'guisp' attribute.  In particular, if the 'reverse' attribute is set for
" gvim, we unset it for the terminal and instead set ctermfg to match guibg
" and vice versa, since terminals can consider a 'reverse' flag to mean using
" default-bg-on-default-fg instead of current-bg-on-current-fg.  We also
" ensure that the 'sp' attribute is never set for cterm, since no terminal can
" handle that particular highlight.  If the user wants to display the guisp
" color, he should map it to either 'fg' or 'bg' using g:CSApprox_attr_map.
function! s:FixupCtermInfo(highlights)
  for hl in values(a:highlights)

    " Find attributes to be set in the terminal
    for attr in [ "bold", "italic", "reverse", "underline", "undercurl" ]
      let hl.cterm[attr] = ''
      if hl.gui[attr] == 1
        if s:attr_map(attr) != ''
          let hl.cterm[ s:attr_map(attr) ] = 1
        endif
      endif
    endfor

    for color in [ "bg", "fg" ]
      let eff_color = color
      if hl.cterm['reverse']
        let eff_color = (color == 'bg' ? 'fg' : 'bg')
      endif

      let hl.cterm[color] = get(hl.gui, s:attr_map(eff_color), '')
    endfor

    if hl.gui['sp'] != '' && s:attr_map('sp') != ''
      let hl.cterm[s:attr_map('sp')] = hl.gui['sp']
    endif

    if hl.cterm['reverse'] && hl.cterm.bg == ''
      let hl.cterm.bg = 'fg'
    endif

    if hl.cterm['reverse'] && hl.cterm.fg == ''
      let hl.cterm.fg = 'bg'
    endif

    if hl.cterm['reverse']
      let hl.cterm.reverse = ''
    endif
  endfor
endfunction

" {>2} Set cterm colors for a highlight group
" Given the information for a single highlight group (ie, the value of
" one of the items in s:Highlights() already normalized with s:FixupCtermInfo
" and s:FixupGuiInfo), handle matching the gvim colors to the closest cterm
" colors by calling the appropriate approximator as specified with the
" g:CSApprox_approximator_function variable and set the colors and attributes
" appropriately to match the gui.
function! s:SetCtermFromGui(hl)
  let hl = a:hl

  " Set up the default approximator function, if needed
  if !exists("g:CSApprox_approximator_function")
    let g:CSApprox_approximator_function=function("s:ApproximatePerComponent")
  endif

  " Clear existing highlights
  exe 'hi ' . hl.name . ' cterm=NONE ctermbg=NONE ctermfg=NONE'

  for which in [ 'bg', 'fg' ]
    let val = hl.cterm[which]

    " Skip unset colors
    if val == -1 || val == ""
      continue
    endif

    " Try translating anything but 'fg', 'bg', #rrggbb, and rrggbb from an
    " rgb.txt color to a #rrggbb color
    if val !~? '^[fb]g$' && val !~ '^#\=\x\{6}$'
      if empty(s:rgb)
        call s:UpdateRgbHash()
      endif
      try
        let val = s:rgb[tolower(val)]
      catch
        if &verbose
          echomsg "CSApprox: Colorscheme uses unknown color \"" . val . "\""
        endif
        continue
      endtry
    endif

    if val =~? '^[fb]g$'
      exe 'hi ' . hl.name . ' cterm' . which . '=' . val
      let hl.cterm[which] = val
    elseif val =~ '^#\=\x\{6}$'
      let val = substitute(val, '^#', '', '')
      let r = str2nr(val[0] . val[1], 16)
      let g = str2nr(val[2] . val[3], 16)
      let b = str2nr(val[4] . val[5], 16)
      let hl.cterm[which] = g:CSApprox_approximator_function(r, g, b)
      exe 'hi ' . hl.name . ' cterm' . which . '=' . hl.cterm[which]
    else
      throw "Internal error handling color: " . val
    endif
  endfor

  " Finally, set the attributes
  let attrs = [ 'bold', 'italic', 'underline', 'undercurl' ]
  call filter(attrs, 'hl.cterm[v:val] == 1')

  if !empty(attrs)
    exe 'hi ' . hl.name . ' cterm=' . join(attrs, ',')
  endif
endfunction


" {>1} Top-level control

" Cache the highlight ID of the normal group; it's used often and won't change
let s:hlid_normal = hlID('Normal')

" {>2} Builtin cterm color names above 15
" Vim defines some color name to high color mappings internally (see
" syntax.c:do_highlight).  Since we don't want to overwrite a colorscheme that
" was actually written for a high color terminal with our choices, but have no
" way to tell if a colorscheme was written for a high color terminal, we fall
" back on guessing.  If any highlight group has a cterm color set to 16 or
" higher, we assume that the user has used a high color colorscheme - unless
" that color is one of the below, which vim can set internally when a color is
" requested by name.
let s:presets_88  = []
let s:presets_88 += [32] " Brown
let s:presets_88 += [72] " DarkYellow
let s:presets_88 += [84] " Gray
let s:presets_88 += [84] " Grey
let s:presets_88 += [82] " DarkGray
let s:presets_88 += [82] " DarkGrey
let s:presets_88 += [43] " LightBlue
let s:presets_88 += [61] " LightGreen
let s:presets_88 += [63] " LightCyan
let s:presets_88 += [74] " LightRed
let s:presets_88 += [75] " LightMagenta
let s:presets_88 += [78] " LightYellow

let s:presets_256  = []
let s:presets_256 += [130] " Brown
let s:presets_256 += [130] " DarkYellow
let s:presets_256 += [248] " Gray
let s:presets_256 += [248] " Grey
let s:presets_256 += [242] " DarkGray
let s:presets_256 += [242] " DarkGrey
let s:presets_256 += [ 81] " LightBlue
let s:presets_256 += [121] " LightGreen
let s:presets_256 += [159] " LightCyan
let s:presets_256 += [224] " LightRed
let s:presets_256 += [225] " LightMagenta
let s:presets_256 += [229] " LightYellow

" {>2} Highlight comparator
" Comparator that sorts numbers matching the highlight id of the 'Normal'
" group before anything else; all others stay in random order.  This allows us
" to ensure that the Normal group is the first group we set.  If it weren't,
" we could get E419 or E420 if a later color used guibg=bg or the likes.
function! s:SortNormalFirst(num1, num2)
  if a:num1 == s:hlid_normal && a:num1 != a:num2
    return -1
  elseif a:num2 == s:hlid_normal && a:num1 != a:num2
    return 1
  else
    return 0
  endif
endfunction

" {>2} Wrapper around :exe to allow :executing multiple commands.
" "cmd" is the command to be :executed.
" If the variable is a String, it is :executed.
" If the variable is a List, each element is :executed.
function! s:exe(cmd)
  if type(a:cmd) == type('')
    exe a:cmd
  else
    for cmd in a:cmd
      call s:exe(cmd)
    endfor
  endif
endfunction

" {>2} Function to handle hooks
" Prototype: HandleHooks(type [, scheme])
" "type" is the type of hook to be executed, ie. "pre" or "post"
" "scheme" is the name of the colorscheme that is currently active, if known
"
" If the variables g:CSApprox_hook_{type} and g:CSApprox_hook_{scheme}_{type}
" exist, this will :execute them in that order.  If one does not exist, it
" will silently be ignored.
"
" If the scheme name contains characters that are invalid in a variable name,
" they will simply be removed.  Ie, g:colors_name = "123 foo_bar-baz456"
" becomes "foo_barbaz456"
"
" NOTE: Exceptions will be printed out, rather than end processing early.  The
" rationale is that it is worse for the user to fix the hook in an editor with
" broken colors.  :)
function! s:HandleHooks(type, ...)
  let type = a:type
  let scheme = (a:0 == 1 ? a:1 : "")
  let scheme = substitute(scheme, '[^[:alnum:]_]', '', 'g')
  let scheme = substitute(scheme, '^\d\+', '', '')

  for cmd in [ 'g:CSApprox_hook_' . type,
             \ 'g:CSApprox_' . scheme . '_hook_' . type,
             \ 'g:CSApprox_hook_' . scheme . '_' . type ]
    if exists(cmd)
      try
        call s:exe(eval(cmd))
      catch
        echomsg "Error processing " . cmd . ":"
        echomsg v:exception
      endtry
    endif
  endfor
endfunction

" {>2} Main function
" Wrapper around the actual implementation to make it easier to ensure that
" all temporary settings are restored by the time we return, whether or not
" something was thrown.  Additionally, sets the 'verbose' option to the max of
" g:CSApprox_verbose_level (default 1) and &verbose for the duration of the
" main function.  This allows us to default to a message whenever any error,
" even a recoverable one, occurs, meaning the user quickly finds out when
" something's wrong, but makes it very easy for the user to make us silent.
function! s:CSApprox()
  try
    let savelz  = &lz

    set lz

    " colors_name must be unset and reset, or vim will helpfully reload the
    " colorscheme when we set the background for the Normal group.
    " See the help entries ':hi-normal-cterm' and 'g:colors_name'
    if exists("g:colors_name")
      let colors_name = g:colors_name
      unlet g:colors_name
    endif

    " Similarly, the global variable "syntax_cmd" must be set to something vim
    " doesn't recognize, lest vim helpfully switch all colors back to the
    " default whenever the Normal group is changed (in syncolor.vim)...
    if exists("g:syntax_cmd")
      let syntax_cmd = g:syntax_cmd
    endif
    let g:syntax_cmd = "PLEASE DON'T CHANGE ANY COLORS!!!"

    " Set up our verbosity level, if needed.
    " Default to 1, so the user can know if something's wrong.
    if !exists("g:CSApprox_verbose_level")
      let g:CSApprox_verbose_level = 1
    endif

    call s:HandleHooks("pre", (exists("colors_name") ? colors_name : ""))

    " Set 'verbose' set to the maximum of &verbose and CSApprox_verbose_level
    exe max([&vbs, g:CSApprox_verbose_level]) 'verbose call s:CSApproxImpl()'

    call s:HandleHooks("post", (exists("colors_name") ? colors_name : ""))
  finally
    if exists("colors_name")
      let g:colors_name = colors_name
    endif

    unlet g:syntax_cmd
    if exists("syntax_cmd")
      let g:syntax_cmd = syntax_cmd
    endif

    let &lz   = savelz
  endtry
endfunction

" {>2} CSApprox implementation
" Verifies that the user has not started the gui, and that vim recognizes his
" terminal as having enough colors for us to go on, then gathers the existing
" highlights and sets the cterm colors to match the gui colors for all those
" highlights (unless the colorscheme was already high-color).
function! s:CSApproxImpl()
  " Return if not running in an 88/256 color terminal
  if &t_Co != 256 && &t_Co != 88 && !has('gui_running')
    if &verbose && !has('gui_running')
      echomsg "CSApprox skipped; terminal only has" &t_Co "colors, not 88/256"
      echomsg "Try checking :help csapprox-terminal for workarounds"
    endif

    return
  endif

  " Get the current highlight colors
  let highlights = s:Highlights()

  let hinums = keys(highlights)

  " Make sure that the script is not already 256 color by checking to make
  " sure that no groups are set to a value above 256, unless the color they're
  " set to can be set internally by vim (gotten by scraping
  " color_numbers_{88,256} in syntax.c:do_highlight)
  for hlid in hinums
    let val = highlights[hlid]
    if   (    val.cterm.bg > 15
         \ && index(s:presets_{&t_Co}, str2nr(val.cterm.bg)) < 0)
    \ || (    val.cterm.fg > 15
         \ && index(s:presets_{&t_Co}, str2nr(val.cterm.fg)) < 0)
      " The value is set above 15, and wasn't set by vim.
      if &verbose >= 2
        echomsg 'CSApprox: Exiting - high color found for' val.name
      endif
      return
    endif
  endfor

  call s:FixupGuiInfo(highlights)
  call s:FixupCtermInfo(highlights)

  " We need to set the Normal group first so 'bg' and 'fg' work as colors
  call sort(hinums, "s:SortNormalFirst")

  " then set each color's cterm attributes to match gui
  for hlid in hinums
    call s:SetCtermFromGui(highlights[hlid])
  endfor
endfunction

" {>2} Write out the current colors to an 88/256 color colorscheme file.
" "file" - destination filename
" "overwrite" - overwrite an existing file
function! s:CSApproxSnapshot(file, overwrite)
  let force = a:overwrite
  let file = fnamemodify(a:file, ":p")

  if empty(file)
    throw "Bad file name: \"" . file . "\""
  elseif (filewritable(fnamemodify(file, ':h')) != 2)
    throw "Cannot write to directory \"" . fnamemodify(file, ':h') . "\""
  elseif (glob(file) || filereadable(file)) && !force
    " TODO - respect 'confirm' here and prompt if it's set.
    echohl ErrorMsg
    echomsg "E13: File exists (add ! to override)"
    echohl None
    return
  endif

  " Sigh... This is basically a bug, but one that I have no chance of fixing.
  " Vim decides that Pmenu should be highlighted in 'LightMagenta' in terminal
  " vim and as 'Magenta' in gvim...  And I can't ask it what color it actually
  " *wants*.  As far as I can see, there's no way for me to learn that
  " I should output 'Magenta' when 'LightMagenta' is provided by vim for the
  " terminal.
  if !has('gui_running')
    echohl WarningMsg
    echomsg "Warning: The written colorscheme may have incorrect colors"
    echomsg "         when CSApproxSnapshot is used in terminal vim!"
    echohl None
  endif

  let save_t_Co = &t_Co

  try
    let lines = []
    let lines += [ '" This scheme was created by CSApproxSnapshot' ]
    let lines += [ '" on ' . strftime("%a, %d %b %Y") ]
    let lines += [ '' ]
    let lines += [ 'hi clear' ]
    let lines += [ 'if exists("syntax_on")' ]
    let lines += [ '    syntax reset' ]
    let lines += [ 'endif' ]
    let lines += [ '' ]
    let lines += [ 'let g:colors_name = ' . string(fnamemodify(file, ':t:r')) ]
    let lines += [ '' ]

    let lines += [ 'if 0' ]
    for &t_Co in [ 256, 88 ]
      let highlights = s:Highlights()
      call s:FixupGuiInfo(highlights)
      let lines += [ 'elseif has("gui_running") || &t_Co == ' . &t_Co ]
      for hlnum in sort(keys(highlights), "s:SortNormalFirst")
        let hl = highlights[hlnum]
        let line = '    highlight ' . hl.name
        for type in [ 'term', 'cterm', 'gui' ]
          let attrs = [ 'reverse', 'bold', 'italic', 'underline', 'undercurl' ]
          call filter(attrs, 'hl[type][v:val] == 1')
          let line .= ' ' . type . '=' . (empty(attrs) ? 'NONE' : join(attrs, ','))
          if type != 'term'
            let line .= ' ' . type . 'bg=' . (len(hl[type].bg) ? hl[type].bg : 'bg')
            let line .= ' ' . type . 'fg=' . (len(hl[type].fg) ? hl[type].fg : 'fg')
            if type == 'gui' && hl.gui.sp !~ '^\s*$'
              let line .= ' ' . type . 'sp=' . hl[type].sp
            endif
          endif
        endfor
        let lines += [ line ]
      endfor
    endfor
    let lines += [ 'endif' ]
    call writefile(lines, file)
  finally
    let &t_Co = save_t_Co
  endtry
endfunction

" {>2} Snapshot user command
command! -bang -nargs=1 -complete=file -bar CSApproxSnapshot
        \ call s:CSApproxSnapshot(<f-args>, strlen("<bang>"))

" {>1} Hooks

" {>2} Autocmds
" Set up an autogroup to hook us on the completion of any :colorscheme command
augroup CSApprox
  au!
  au ColorScheme * call s:CSApprox()
  "au User CSApproxPost highlight Normal ctermbg=none | highlight NonText ctermbg=None
augroup END

" {>2} Execute
" The last thing to do when sourced is to run and actually fix up the colors.
if !has('gui_running')
  call s:CSApprox()
endif

" {>1} Restore compatibility options
let &cpo = s:savecpo
unlet s:savecpo


" {0} vim:sw=2:sts=2:et:fdm=expr:fde=substitute(matchstr(getline(v\:lnum),'^\\s*"\\s*{\\zs.\\{-}\\ze}'),'^$','=','')
