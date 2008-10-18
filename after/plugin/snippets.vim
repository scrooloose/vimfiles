let s:rs = g:NERDSnippets_marker_start
"let s:rs = g:NERDSnippets_marker_start_default
let s:re = g:NERDSnippets_marker_end

function! s:AddHTMLMapsFor(ft)
    call NERDSnippet(a:ft, "label", "<label for=\"".s:rs."id".s:re."\">".s:rs."label_text".s:re."</label>")
    call NERDSnippet(a:ft, "table", "<table class=\"".s:rs.s:re."\">\<CR>".s:rs.s:re."\<CR></table>")
    call NERDSnippet(a:ft, "table", "<table".s:rs." width=\"".s:rs."100%".s:re."\" border=\"".s:rs."0".s:re."\" cellspacing=\"".s:rs."0".s:re."\" cellpadding=\"".s:rs."5".s:re."\"".s:rs.s:re.s:re.">\<CR><tr>\<CR><th>".s:rs.s:re."</th>\<CR></tr>\<CR>\<CR><tr>\<CR><td></td>\<CR></tr>\<CR></table>")
    call NERDSnippet(a:ft, "span", "<span class=\"".s:rs.s:re."\">".s:rs.s:re."</span>")
    call NERDSnippet(a:ft, "div", "<div".s:rs.s:re.">\<CR>".s:rs.s:re."\<CR></div>")
    call NERDSnippet(a:ft, "id", "id=\"".s:rs.s:re."\"")
    call NERDSnippet(a:ft, "img", "<img src=\"".s:rs.s:re."\"".s:rs.s:re." />")
    call NERDSnippet(a:ft, "select", "<select id=\"".s:rs.s:re."\" name=\"".s:rs.s:re."\"".s:rs.s:re.">\<CR><option></option>\<CR>".s:rs.s:re."\<CR></select>")
    call NERDSnippet(a:ft, "option", "<option value=\"".s:rs.s:re."\"".s:rs.s:re.">".s:rs.s:re."</option>")
    call NERDSnippet(a:ft, "script", "<script type=\"text/javascript\" language=\"javascript\" charset=\"utf-8\">\<CR>//<![CDATA[\<CR>".s:rs.s:re."\<CR>//]]>\<CR></script>")
    call NERDSnippet(a:ft, "style", "<style type=\"text/css\" media=\"screen\">\<CR>/*<![CDATA[*/\<CR>".s:rs.s:re."\<CR>/*]]>*/\<CR></style>\<CR>")
    call NERDSnippet(a:ft, "href", "<a href=\"".s:rs.s:re."\">".s:rs.s:re."</a>")
    call NERDSnippet(a:ft, "link", "<link rel=\"stylesheet\" type=\"text/css\" href=\"".s:rs.s:re."\" />")
    call NERDSnippet(a:ft, "doctype", "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">".s:rs.s:re)
    call NERDSnippet(a:ft, "mailto", "<a href=\"mailto:".s:rs."email".s:re.s:rs."?subject=".s:rs."subject".s:re.s:re."\">".s:rs.s:re."</a>")
endfunction

function! Snippet_ClassNameFromFilename()
    let name = expand("%:t")
    "chop off the extension
    let name = substitute(name, '^\(.*\)\..*$', '\1', '')

    return s:camelCase(name)
endfunction

function s:camelCase(s)
    "upcase the first letter
    let toReturn = substitute(a:s, '^\(.\)', '\=toupper(submatch(1))', '')
    "turn all '_x' into 'X'
    return substitute(toReturn, '_\(.\)', '\=toupper(submatch(1))', 'g')
endfunction

function s:underscore(s)
    "down the first letter
    let toReturn = substitute(a:s, '^\(.\)', '\=tolower(submatch(1))', '')
    "turn all 'X' into '_x'
    return substitute(toReturn, '\([A-Z]\)', '\=tolower("_".submatch(1))', 'g')
endfunction

function s:inRailsEnv()
    return filereadable(getcwd() . '/config/environment.rb')
endfunction

function Snippet_Sweeper()
    let class = s:camelCase(substitute(expand("%:t"), '^\(.*\)_sweeper\.rb', '\1', ''))
    let instance = s:underscore(class)
    return "class ".s:rs.class.s:re."Sweeper < ActionController::Caching::Sweeper\<CR>".
           \ "observe ".s:rs.class.s:re."\<CR>\<CR>".
           \ "def after_save(".s:rs.instance.s:re.")\<CR>".
           \   "expire_cache(".s:rs.instance.s:re.")\<CR>".
           \ "end\<CR>\<CR>".
           \ "def after_destroy(".s:rs.instance.s:re.")\<CR>".
           \   "expire_cache(".s:rs.instance.s:re.")\<CR>".
           \ "end\<CR>\<CR>".
           \ "def expire_cache(".s:rs.instance.s:re.")\<CR>".
           \   "expire_page\<CR>".
           \ "end\<CR>".
           \"end\<CR>"
endfunction

"ruby {{{1

if s:inRailsEnv()
    call NERDSnippet("ruby", "vpo", "validates_presence_of :".s:rs."attr_names".s:re.s:rs.", :message => '".s:rs."error message".s:re."', :on => ".s:rs.":save|:create|:update".s:re.", :if => ".s:rs."method|proc".s:re.s:re)
    call NERDSnippet("ruby", "vno", "validates_numericality_of ".s:rs.s:re)
    call NERDSnippet("ruby", "vuo", "validates_uniqueness_of ".s:rs.s:re)
    call NERDSnippet("ruby", "flash", "flash[".s:rs.":notice".s:re."] = '".s:rs.s:re."'")
    call NERDSnippet("ruby", "bt", "belongs_to :".s:rs."association_name".s:re.s:rs.", :class_name => '".s:rs.s:re."', :foreign_key => '".s:rs.s:re."'".s:re)
    call NERDSnippet("ruby", "hm", "has_many :".s:rs."association_name".s:re.s:rs.", :class_name => '".s:rs.s:re."'".s:re)

    call NERDSnippet("ruby", "log", "RAILS_DEFAULT_LOGGER.".s:rs."debug".s:re." ".s:rs.s:re)

    call NERDSnippet("ruby", "mrmc", "remove_column :".s:rs."table".s:re.", :".s:rs."column".s:re."")
    call NERDSnippet("ruby", "mrnc", "rename_column :".s:rs."table".s:re.", :".s:rs."old".s:re.", :".s:rs."new".s:re."")
    call NERDSnippet("ruby", "mac", "add_column :".s:rs."table".s:re.", :".s:rs."column".s:re.", :".s:rs."type".s:re."")
    call NERDSnippet("ruby", "mct", "create_table :".s:rs."table_name".s:re." do |t|\<CR>t.column :".s:rs."name".s:re.", :".s:rs."type".s:re."\<CR>end")

    call NERDSnippet("ruby", "chm", "check_has_many :".s:rs."accessor".s:re.", :".s:rs."fixture".s:re.", ".s:rs."klass".s:re.", ".s:rs."number".s:re."")
    call NERDSnippet("ruby", "cbt", "check_belongs_to :".s:rs."accessor".s:re.", :".s:rs."fixture".s:re.", :".s:rs."expected_fixture".s:re."")
    call NERDSnippet("ruby", "cho", "check_has_one :".s:rs."accessor".s:re.", :".s:rs."fixture".s:re.", :".s:rs."expected_fixture".s:re."")

    call NERDSnippet("ruby", "sweeper", "\<c-r>=Snippet_Sweeper()\<CR>")
endif

call NERDSnippet("ruby", "require", "require '".s:rs.s:re."'")

call NERDSnippet("ruby", "def", "def ".s:rs."function_name".s:re."\<CR>".s:rs.s:re."\<CR>end\<CR>")
call NERDSnippet("ruby", "class", "class ".s:rs."\<c-r>=Snippet_ClassNameFromFilename()\<CR>".s:re."\<CR>def initialize".s:rs.s:re."\<CR>".s:rs.s:re."\<CR>end\<CR>end")

call NERDSnippet("ruby", "map", "map {|".s:rs."element".s:re."| ".s:rs."body".s:re."}")
call NERDSnippet("ruby", "mapo", "map do |".s:rs."element".s:re."|\<CR>".s:rs."body".s:re."\<CR>end\<CR>")
call NERDSnippet("ruby", "select", "select {|".s:rs."element".s:re."| ".s:rs."body".s:re."}")
call NERDSnippet("ruby", "selecto", "select do |".s:rs."element".s:re."|\<CR>".s:rs."body".s:re."\<CR>end\<CR>")
call NERDSnippet("ruby", "reject", "reject {|".s:rs."element".s:re."| ".s:rs."body".s:re."}")
call NERDSnippet("ruby", "rejecto", "reject do |".s:rs."element".s:re."|\<CR>".s:rs."body".s:re."\<CR>end\<CR>")
call NERDSnippet("ruby", "sort", "sort {|".s:rs."x".s:re.",".s:rs."y".s:re."| ".s:rs."body".s:re."}")
call NERDSnippet("ruby", "sorto", "sort do |".s:rs."x".s:re.",".s:rs."y".s:re."|\<CR>".s:rs."body".s:re."\<CR>end\<CR>")
call NERDSnippet("ruby", "each", "each {|".s:rs."element".s:re."| ".s:rs."body".s:re."}")
call NERDSnippet("ruby", "eacho", "each do |".s:rs."element".s:re."|\<CR>".s:rs."body".s:re."\<CR>end\<CR>")
call NERDSnippet("ruby", "each_with_index", "each_with_index {|".s:rs."element".s:re.",".s:rs."i".s:re."| ".s:rs.s:re."}")
call NERDSnippet("ruby", "each_with_indexo", "each_with_index do |".s:rs."element".s:re.",".s:rs."i".s:re."|\<CR>".s:rs."body".s:re."\<CR>end\<CR>")
call NERDSnippet("ruby", "inject", "inject {|".s:rs."total".s:re.",".s:rs."next".s:re."| ".s:rs."body".s:re."}")
call NERDSnippet("ruby", "injecto", "inject do |".s:rs."total".s:re.",".s:rs."next".s:re."|\<CR>".s:rs."body".s:re."\<CR>end\<CR>")
call NERDSnippet("ruby", "detect", "detect {|".s:rs."element".s:re."| ".s:rs."body".s:re."}")
call NERDSnippet("ruby", "detecto", "detect do |".s:rs."element".s:re."|\<CR>".s:rs."body".s:re."\<CR>end\<CR>")

call NERDSnippet("ruby", "do", "do\<CR>".s:rs.s:re."\<CR>end\<CR>")
call NERDSnippet("ruby", "case", "case ".s:rs.s:re."\<CR>when ".s:rs.s:re."\<CR>else\<CR>".s:rs.s:re."\<CR>end\<CR>")

call NERDSnippet("ruby", "if", "if ".s:rs.s:re."\<CR>end\<CR>")
call NERDSnippet("ruby", "ife", "if ".s:rs.s:re."\<CR>else\<CR>".s:rs.s:re."\<CR>end\<CR>")

call NERDSnippet("ruby", "unless", "unless ".s:rs.s:re."\<CR>end\<CR>")
call NERDSnippet("ruby", "unlesse", "unless ".s:rs.s:re."\<CR>else\<CR>".s:rs.s:re."\<CR>end\<CR>")

"eruby {{{1

"eruby mappings
call NERDSnippet("eruby", "if", "<% if ".s:rs.s:re." -%>\<CR>".s:rs.s:re."\<CR><% end -%>")
call NERDSnippet("eruby", "ife", "<% if ".s:rs.s:re." -%>\<CR>".s:rs.s:re."\<CR><% else -%>\<CR>".s:rs.s:re."\<CR><% end -%>")

call NERDSnippet("eruby", "unless", "<% unless ".s:rs.s:re." -%>\<CR>".s:rs.s:re."\<CR><% end -%>")
call NERDSnippet("eruby", "unlesse", "<% if ".s:rs.s:re." -%>\<CR>".s:rs.s:re."\<CR><% else -%>\<CR>".s:rs.s:re."\<CR><% end -%>")

if s:inRailsEnv()
    call NERDSnippet("eruby", "rp", "<%= render :partial => \"".s:rs."file".s:re."\"".s:rs.s:re." %>")
    call NERDSnippet("eruby", "rt", "<%= render :template => \"".s:rs."file".s:re."\"".s:rs.s:re." %>")
    call NERDSnippet("eruby", "rf", "<%= render :file => \"".s:rs."file".s:re."\"".s:rs.s:re." %>")
    call NERDSnippet("eruby", "cs", "<%= collection_select ".s:rs."object".s:re.", ".s:rs."method".s:re.", ".s:rs."collection".s:re.", ".s:rs."value_method".s:re.", ".s:rs."text_method".s:re.s:rs.", ".s:rs."[options]".s:re.", ".s:rs."[html_options]".s:re.s:re." %>")
    call NERDSnippet("eruby", "ofcfs", "<%= options_from_collection_for_select ".s:rs."collection".s:re.", ".s:rs."value_method".s:re.", ".s:rs."text_method".s:re.s:rs.", ".s:rs."[selected_value]".s:re.s:re." %>")
    call NERDSnippet("eruby", "sslt", "<%= stylesheet_link_tag \"".s:rs.s:re."\" %>")
    call NERDSnippet("eruby", "jsit", "<%= javascript_include_tag \"".s:rs.s:re."\" %>")
    call NERDSnippet("eruby", "it", "<%= image_tag \"".s:rs.s:re."\" %>")
    call NERDSnippet("eruby", "lt", "<%= link_to \"".s:rs.s:re."\", ".s:rs."dest".s:re." %>")
else
    "create merb snippets

endif
call s:AddHTMLMapsFor('eruby')

"html {{{1

"html mappings
call s:AddHTMLMapsFor('html')


"php mappings {{{1
call NERDSnippet("php", "func", "function ".s:rs."name".s:re."(".s:rs.s:re.") {\<CR>".s:rs.s:re."\<CR>}\<CR>")
call NERDSnippet("php", "log", "error_log(var_export(".s:rs.s:re.", true));")
call NERDSnippet("php", "var", "var_export(".s:rs.s:re.");")


"vim {{{1
call NERDSnippet("vim", "if", "if ".s:rs.s:re."\<CR>endif\<CR>")
call NERDSnippet("vim", "ife", "if ".s:rs.s:re."\<CR>else\<CR>".s:rs.s:re."\<CR>endif\<CR>")
call NERDSnippet("vim", "func", "function! ".s:rs.s:re."(".s:rs.s:re.")\<CR>".s:rs.s:re."\<CR>endfunction\<CR>")
call NERDSnippet("vim", "au", "autocmd ".s:rs."events".s:re." ".s:rs."pattern".s:re." ".s:rs."command".s:re)
call NERDSnippet("vim", "com", "command! -nargs=".s:rs."number_of_args".s:re." ".s:rs."other_params".s:re." ".s:rs."name".s:re." ".s:rs."command".s:re)
call NERDSnippet("vim", "try", "try\<CR>".s:rs.s:re."\<CR>catch /".s:rs.s:re."/\<CR>".s:rs.s:re."\<CR>endtry")
call NERDSnippet("vim", "log", "echomsg ".s:rs.s:re)

"java {{{1
call NERDSnippet("java", "for", "for(".s:rs."int i".s:re."; ".s:rs."condition".s:re."; ".s:rs."i++".s:re."){\<CR>".s:rs.s:re."\<CR>}")
call NERDSnippet("java", "ife", "if(".s:rs.s:re."){\<CR>".s:rs.s:re."\<CR>}else{\<CR>".s:rs.s:re."\<CR>}")
call NERDSnippet("java", "log", "System.".s:rs."out".s:re.".println(".s:rs.s:re.")")


"global {{{1

function! s:start_comment()
    return substitute(&commentstring, '^\([^ ]*\)\s*%s\(.*\)$', '\1', '')
endfunction

function! s:end_comment()
    return substitute(&commentstring, '^.*%s\(.*\)$', '\1', '')
endfunction

function! Snippet_Modeline()
    return s:start_comment() . " vim: set " . s:rs."settings".s:re . ":" . s:end_comment()
endfunction


call NERDSnippetGlobal("modeline", "\<c-r>=Snippet_Modeline()\<cr>")
call NERDSnippetGlobal("time", "\<c-r>=strftime(\"%Y-%m-%d %H:%M:%S\")\<cr>".s:rs.s:re)
call NERDSnippetGlobal("lorem", "Lorem ipsum dolor sit amet, consectetur magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.  Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum".s:rs.s:re."\<c-o>:normal! gqq\<CR>")

call NERDSnippetGlobal("todo", "\<c-r>=Snippet_Todo()\<cr>")
function! Snippet_Todo()
    if s:end_comment() == ''
        return s:start_comment() . "\<CR> TODO:\<CR> - " . s:rs.s:re
    endif
endfunction


" modeline {{{1
" vim: set fdm=marker:
