call NERDSnippetsReset()

function! s:AddHTMLMapsFor(ft)
    call NERDSnippet(a:ft, "label", "<label for=\"<+id+>\"><+label_text+></label>")
    call NERDSnippet(a:ft, "table", "<table class=\"<++>\">\<CR><++>\<CR></table>", 'simple')
    call NERDSnippet(a:ft, "table", "<table<+ width=\"<+100%+>\" border=\"<+0+>\" cellspacing=\"<+0+>\" cellpadding=\"<+5+>\"<++>+>>\<CR><tr>\<CR><th><++></th>\<CR></tr>\<CR>\<CR><tr>\<CR><td></td>\<CR></tr>\<CR></table>", 'hardcore')
    call NERDSnippet(a:ft, "span", "<span class=\"<++>\"><++></span>")
    call NERDSnippet(a:ft, "div", "<div<++>>\<CR><++>\<CR></div>")
    call NERDSnippet(a:ft, "id", "id=\"<++>\"")
    call NERDSnippet(a:ft, "img", "<img src=\"<++>\"<++> />")
    call NERDSnippet(a:ft, "select", "<select id=\"<++>\" name=\"<++>\"<++>>\<CR><option></option>\<CR><++>\<CR></select>")
    call NERDSnippet(a:ft, "option", "<option value=\"<++>\"<++>><++></option>")

    call NERDSnippet(a:ft, "script", "<script type=\"text/javascript\" language=\"javascript\" charset=\"utf-8\">\<CR>//<![CDATA[\<CR><++>\<CR>//]]>\<CR></script>", 'inline script')
    call NERDSnippet(a:ft, "script", "<script type=\"text/javascript\" src=\"<++>\"></script>", 'include script')

    call NERDSnippet(a:ft, "style", "<style type=\"text/css\" media=\"screen\">\<CR><++>\<CR></style>")
    call NERDSnippet(a:ft, "href", "<a href=\"<++>\"><++></a>")
    call NERDSnippet(a:ft, "link", "<link rel=\"stylesheet\" type=\"text/css\" href=\"<++>\" />")
    call NERDSnippet(a:ft, "doctype", "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\"><++>")
    call NERDSnippet(a:ft, "mailto", "<a href=\"mailto:<+email+><+?subject=<+subject+>+>\"><++></a>")

    call NERDSnippet(a:ft, "input", '<input type="text" name="<++>" <+value="<++>"+> <+size="<++>"+> <+maxlength="<++>"+> />')
endfunction

function! Snippet_ClassNameFromFilename()
    let name = expand("%:t")
    "chop off the extension
    let name = substitute(name, '^\(.*\)\..*$', '\1', '')

    return s:camelCase(name)
endfunction

function! s:camelCase(s)
    "upcase the first letter
    let toReturn = substitute(a:s, '^\(.\)', '\=toupper(submatch(1))', '')
    "turn all '_x' into 'X'
    return substitute(toReturn, '_\(.\)', '\=toupper(submatch(1))', 'g')
endfunction

function! s:underscore(s)
    "down the first letter
    let toReturn = substitute(a:s, '^\(.\)', '\=tolower(submatch(1))', '')
    "turn all 'X' into '_x'
    return substitute(toReturn, '\([A-Z]\)', '\=tolower("_".submatch(1))', 'g')
endfunction

function! s:inRailsEnv()
    return filereadable(getcwd() . '/config/environment.rb')
endfunction

function! Snippet_Sweeper()
    let class = s:camelCase(substitute(expand("%:t"), '^\(.*\)_sweeper\.rb', '\1', ''))
    let instance = s:underscore(class)
    return "class <+".class."+>Sweeper < ActionController::Caching::Sweeper\<CR>".
           \ "observe <+".class."+>\<CR>\<CR>".
           \ "def after_save(<+".instance."+>)\<CR>".
           \   "expire_cache(<+".instance."+>)\<CR>".
           \ "end\<CR>\<CR>".
           \ "def after_destroy(<+".instance."+>)\<CR>".
           \   "expire_cache(<+".instance."+>)\<CR>".
           \ "end\<CR>\<CR>".
           \ "def expire_cache(<+".instance."+>)\<CR>".
           \   "expire_page\<CR>".
           \ "end\<CR>".
           \"end\<CR>"
endfunction

"ruby {{{1

if s:inRailsEnv()
    call NERDSnippet("ruby", "vpo", "validates_presence_of :<+attr_names+><+, :message => '<+error message+>', :on => <+:save|:create|:update+>, :if => <+method|proc+>+>")
    call NERDSnippet("ruby", "vno", "validates_numericality_of <++>")
    call NERDSnippet("ruby", "vuo", "validates_uniqueness_of <++>")
    call NERDSnippet("ruby", "flash", "flash[:<+notice+>] = '<++>'")
    call NERDSnippet("ruby", "bt", "belongs_to :<+association_name+><+, :class_name => '<++>', :foreign_key => '<++>'+>")
    call NERDSnippet("ruby", "hm", "has_many :<+association_name+><+, :class_name => '<++>'+>")

    call NERDSnippet("ruby", "log", "RAILS_DEFAULT_LOGGER.<+debug+> <++>")

    call NERDSnippet("ruby", "mrmc", "remove_column :<+table+>, :<+column+>")
    call NERDSnippet("ruby", "mrnc", "rename_column :<+table+>, :<+old+>, :<+new+>")
    call NERDSnippet("ruby", "mac", "add_column :<+table+>, :<+column+>, :<+type+>")
    call NERDSnippet("ruby", "mct", "create_table :<+table_name+> do |t|\<CR>t.column :<+name+>, :<+type+>\<CR>end")

    call NERDSnippet("ruby", "chm", "check_has_many :<+accessor+>, :<+fixture+>, <+klass+>, <+number+>")
    call NERDSnippet("ruby", "cbt", "check_belongs_to :<+accessor+>, :<+fixture+>, :<+expected_fixture+>")
    call NERDSnippet("ruby", "cho", "check_has_one :<+accessor+>, :<+fixture+>, :<+expected_fixture+>")

    call NERDSnippet("ruby", "sweeper", "\<c-r>=Snippet_Sweeper()\<CR>")
endif

call NERDSnippet("ruby", "require", "require '<++>'")

call NERDSnippet("ruby", "def", "def <+function_name+>\<CR><++>\<CR>end\<CR>")
call NERDSnippet("ruby", "class", "class <+\<c-r>=Snippet_ClassNameFromFilename()\<CR>+>\<CR>def initialize<++>\<CR><++>\<CR>end\<CR>end")

call NERDSnippet("ruby", "map", "map {|<+element+>| <+body+>}")
call NERDSnippet("ruby", "mapo", "map do |<+element+>|\<CR><+body+>\<CR>end\<CR>")
call NERDSnippet("ruby", "select", "select {|<+element+>| <+body+>}")
call NERDSnippet("ruby", "selecto", "select do |<+element+>|\<CR><+body+>\<CR>end\<CR>")
call NERDSnippet("ruby", "reject", "reject {|<+element+>| <+body+>}")
call NERDSnippet("ruby", "rejecto", "reject do |<+element+>|\<CR><+body+>\<CR>end\<CR>")
call NERDSnippet("ruby", "sort", "sort {|<+x+>,<+y+>| <+body+>}")
call NERDSnippet("ruby", "sorto", "sort do |<+x+>,<+y+>|\<CR><+body+>\<CR>end\<CR>")
call NERDSnippet("ruby", "each", "each {|<+element+>| <+body+>}")
call NERDSnippet("ruby", "eacho", "each do |<+element+>|\<CR><+body+>\<CR>end\<CR>")
call NERDSnippet("ruby", "each_with_index", "each_with_index {|<+element+>,<+i+>| <++>}")
call NERDSnippet("ruby", "each_with_indexo", "each_with_index do |<+element+>,<+i+>|\<CR><+body+>\<CR>end\<CR>")
call NERDSnippet("ruby", "inject", "inject {|<+total+>,<+next+>| <+body+>}")
call NERDSnippet("ruby", "injecto", "inject do |<+total+>,<+next+>|\<CR><+body+>\<CR>end\<CR>")
call NERDSnippet("ruby", "detect", "detect {|<+element+>| <+body+>}")
call NERDSnippet("ruby", "detecto", "detect do |<+element+>|\<CR><+body+>\<CR>end\<CR>")

call NERDSnippet("ruby", "do", "do\<CR><++>\<CR>end\<CR>")
call NERDSnippet("ruby", "case", "case <++>\<CR>when <++>\<CR>else\<CR><++>\<CR>end\<CR>")

call NERDSnippet("ruby", "if", "if <++>\<CR>end\<CR>")
call NERDSnippet("ruby", "ife", "if <++>\<CR>else\<CR><++>\<CR>end\<CR>")

call NERDSnippet("ruby", "unless", "unless <++>\<CR>end\<CR>")
call NERDSnippet("ruby", "unlesse", "unless <++>\<CR>else\<CR><++>\<CR>end\<CR>")

"eruby {{{1

"eruby mappings
call NERDSnippet("eruby", "if", "<% if <++> -%>\<CR><++>\<CR><% end -%>")
call NERDSnippet("eruby", "ife", "<% if <++> -%>\<CR><++>\<CR><% else -%>\<CR><++>\<CR><% end -%>")

call NERDSnippet("eruby", "unless", "<% unless <++> -%>\<CR><++>\<CR><% end -%>")
call NERDSnippet("eruby", "unlesse", "<% if <++> -%>\<CR><++>\<CR><% else -%>\<CR><++>\<CR><% end -%>")

if s:inRailsEnv()
    call NERDSnippet("eruby", "rp", "<%= render :partial => \"<+file+>\"<++> %>")
    call NERDSnippet("eruby", "rt", "<%= render :template => \"<+file+>\"<++> %>")
    call NERDSnippet("eruby", "rf", "<%= render :file => \"<+file+>\"<++> %>")
    call NERDSnippet("eruby", "cs", "<%= collection_select <+object+>, <+method+>, <+collection+>, <+value_method+>, <+text_method+><+, <+[options]+>, <+[html_options]+>+> %>")
    call NERDSnippet("eruby", "ofcfs", "<%= options_from_collection_for_select <+collection+>, <+value_method+>, <+text_method+><+, <+[selected_value]+>+> %>")
    call NERDSnippet("eruby", "sslt", "<%= stylesheet_link_tag \"<++>\" %>")
    call NERDSnippet("eruby", "jsit", "<%= javascript_include_tag \"<++>\" %>")
    call NERDSnippet("eruby", "it", "<%= image_tag \"<++>\" %>")
    call NERDSnippet("eruby", "lt", "<%= link_to \"<++>\", <+dest+> %>")
else
    "create merb snippets

endif
call s:AddHTMLMapsFor('eruby')

"html {{{1
call s:AddHTMLMapsFor('html')

"xhtml {{{1
call s:AddHTMLMapsFor('xhtml')


"php mappings {{{1
call NERDSnippet("php", "func", "function <+name+>(<++>) {\<CR><++>\<CR>}\<CR>")
call NERDSnippet("php", "log", "error_log(var_export(<++>, true));")
call NERDSnippet("php", "var", "var_export(<++>);")
call s:AddHTMLMapsFor('php')


"vim {{{1
call NERDSnippet("vim", "if", "if <++>\<CR>endif\<CR>")
call NERDSnippet("vim", "ife", "if <++>\<CR>else\<CR><++>\<CR>endif\<CR>")
call NERDSnippet("vim", "func", "function! <++>(<++>)\<CR><++>\<CR>endfunction\<CR>")
call NERDSnippet("vim", "au", "autocmd <+events+> <+pattern+> <+command+>")
call NERDSnippet("vim", "com", "command! -nargs=<+number_of_args+> <+other_params+> <+name+> <+command+>")
call NERDSnippet("vim", "try", "try\<CR><++>\<CR>catch /<++>/\<CR><++>\<CR>endtry")
call NERDSnippet("vim", "log", "echomsg <++>")

"java {{{1
call NERDSnippet("java", "for", "for(<+int i=0+>; <+condition+>; <+i+++>){\<CR><++>\<CR>}")
call NERDSnippet("java", "ife", "if(<++>){\<CR><++>\<CR>}else{\<CR><++>\<CR>}")
call NERDSnippet("java", "log", "System.<+out+>.println(<++>)")
call NERDSnippet("java", "m", "<+public+> <+void+> <+methodName+>(<+args+>) {\<CR><++>\<CR>}")


"global {{{1

function! s:start_comment()
    return substitute(&commentstring, '^\([^ ]*\)\s*%s\(.*\)$', '\1', '')
endfunction

function! s:end_comment()
    return substitute(&commentstring, '^.*%s\(.*\)$', '\1', '')
endfunction

function! Snippet_Modeline()
    return s:start_comment() . " vim: set <+settings+>:" . s:end_comment()
endfunction


call NERDSnippetGlobal("modeline", "\<c-r>=Snippet_Modeline()\<cr>")
call NERDSnippetGlobal("date", "\<c-r>=strftime(\"%Y-%m-%d\")\<cr><++>", 'date')
call NERDSnippetGlobal("date", "\<c-r>=strftime(\"%Y-%m-%d %H:%M:%S\")\<cr><++>", 'date + time')
call NERDSnippetGlobal("lorem", "Lorem ipsum dolor sit amet, consectetur magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.  Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum<++>\<c-o>:normal! gqq\<CR>")

call NERDSnippetGlobal("todo", "\<c-r>=Snippet_Todo()\<cr>")
function! Snippet_Todo()
    if s:end_comment() == ''
        return s:start_comment() . "\<CR> TODO:\<CR> - <++>"
    endif
endfunction


" modeline {{{1
" vim: set fdm=marker:
