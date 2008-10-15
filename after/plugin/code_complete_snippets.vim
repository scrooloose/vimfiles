let s:rs = g:code_complete_marker_start
let s:rsd = g:code_complete_marker_start_default
let s:re = g:code_complete_marker_end

function! s:AddHTMLMapsFor(ft)
    call CodeCompleteAddTemplate(a:ft, "label", "<label for=\"".s:rs."id".s:re."\">".s:rs."label_text".s:re."</label>")
    call CodeCompleteAddTemplate(a:ft, "table", "<table class=\"".s:rs.s:re."\">\<CR>".s:rs.s:re."\<CR></table>")
    call CodeCompleteAddTemplate(a:ft, "table", "<table".s:rsd." width=\"".s:rsd."100%".s:re."\" border=\"".s:rsd."0".s:re."\" cellspacing=\"".s:rsd."0".s:re."\" cellpadding=\"".s:rsd."5".s:re."\"".s:rs.s:re.s:re.">\<CR><tr>\<CR><th>".s:rs.s:re."</th>\<CR></tr>\<CR>\<CR><tr>\<CR><td></td>\<CR></tr>\<CR></table>")
    call CodeCompleteAddTemplate(a:ft, "span", "<span class=\"".s:rs.s:re."\">".s:rs.s:re."</span>")
    call CodeCompleteAddTemplate(a:ft, "div", "<div".s:rsd.s:re.">\<CR>".s:rs.s:re."\<CR></div>")
    call CodeCompleteAddTemplate(a:ft, "id", "id=\"".s:rs.s:re."\"")
    call CodeCompleteAddTemplate(a:ft, "img", "<img src=\"".s:rs.s:re."\"".s:rs.s:re." />")
    call CodeCompleteAddTemplate(a:ft, "select", "<select id=\"".s:rs.s:re."\" name=\"".s:rs.s:re."\"".s:rs.s:re.">\<CR><option></option>\<CR>".s:rs.s:re."\<CR></select>")
    call CodeCompleteAddTemplate(a:ft, "option", "<option value=\"".s:rs.s:re."\"".s:rs.s:re.">".s:rs.s:re."</option>")
    call CodeCompleteAddTemplate(a:ft, "script", "<script type=\"text/javascript\" language=\"javascript\" charset=\"utf-8\">\<CR>//<![CDATA[\<CR>".s:rs.s:re."\<CR>//]]>\<CR></script>")
    call CodeCompleteAddTemplate(a:ft, "style", "<style type=\"text/css\" media=\"screen\">\<CR>/*<![CDATA[*/\<CR>".s:rs.s:re."\<CR>/*]]>*/\<CR></style>\<CR>")
    call CodeCompleteAddTemplate(a:ft, "href", "<a href=\"".s:rs.s:re."\">".s:rs.s:re."</a>")
    call CodeCompleteAddTemplate(a:ft, "link", "<link rel=\"stylesheet\" type=\"text/css\" href=\"".s:rs.s:re."\" />")
    call CodeCompleteAddTemplate(a:ft, "doctype", "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">".s:rs.s:re)
    call CodeCompleteAddTemplate(a:ft, "mailto", "<a href=\"mailto:".s:rs."email".s:re.s:rsd."?subject=".s:rs."subject".s:re.s:re."\">".s:rs.s:re."</a>")
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
    return "class ".s:rsd.class.s:re."Sweeper < ActionController::Caching::Sweeper\<CR>".
           \ "observe ".s:rsd.class.s:re."\<CR>\<CR>".
           \ "def after_save(".s:rsd.instance.s:re.")\<CR>".
           \   "expire_cache(".s:rsd.instance.s:re.")\<CR>".
           \ "end\<CR>\<CR>".
           \ "def after_destroy(".s:rsd.instance.s:re.")\<CR>".
           \   "expire_cache(".s:rsd.instance.s:re.")\<CR>".
           \ "end\<CR>\<CR>".
           \ "def expire_cache(".s:rsd.instance.s:re.")\<CR>".
           \   "expire_page\<CR>".
           \ "end\<CR>".
           \"end\<CR>"
endfunction

"ruby {{{1

if s:inRailsEnv()
    call CodeCompleteAddTemplate("ruby", "vpo", "validates_presence_of :".s:rs."attr_names".s:re.s:rsd.", :message => '".s:rs."error message".s:re."', :on => ".s:rs.":save|:create|:update".s:re.", :if => ".s:rs."method|proc".s:re.s:re)
    call CodeCompleteAddTemplate("ruby", "vno", "validates_numericality_of ".s:rs.s:re)
    call CodeCompleteAddTemplate("ruby", "vuo", "validates_uniqueness_of ".s:rs.s:re)
    call CodeCompleteAddTemplate("ruby", "flash", "flash[".s:rsd.":notice".s:re."] = '".s:rs.s:re."'")
    call CodeCompleteAddTemplate("ruby", "bt", "belongs_to :".s:rs."association_name".s:re.s:rsd.", :class_name => '".s:rs.s:re."', :foreign_key => '".s:rs.s:re."'".s:re)
    call CodeCompleteAddTemplate("ruby", "hm", "has_many :".s:rs."association_name".s:re.s:rsd.", :class_name => '".s:rs.s:re."'".s:re)

    call CodeCompleteAddTemplate("ruby", "log", "RAILS_DEFAULT_LOGGER.".s:rsd."debug".s:re." ".s:rs.s:re)

    call CodeCompleteAddTemplate("ruby", "mrmc", "remove_column :".s:rs."table".s:re.", :".s:rs."column".s:re."")
    call CodeCompleteAddTemplate("ruby", "mrnc", "rename_column :".s:rs."table".s:re.", :".s:rs."old".s:re.", :".s:rs."new".s:re."")
    call CodeCompleteAddTemplate("ruby", "mac", "add_column :".s:rs."table".s:re.", :".s:rs."column".s:re.", :".s:rs."type".s:re."")
    call CodeCompleteAddTemplate("ruby", "mct", "create_table :".s:rs."table_name".s:re." do |t|\<CR>t.column :".s:rs."name".s:re.", :".s:rs."type".s:re."\<CR>end")

    call CodeCompleteAddTemplate("ruby", "chm", "check_has_many :".s:rs."accessor".s:re.", :".s:rs."fixture".s:re.", ".s:rs."klass".s:re.", ".s:rs."number".s:re."")
    call CodeCompleteAddTemplate("ruby", "cbt", "check_belongs_to :".s:rs."accessor".s:re.", :".s:rs."fixture".s:re.", :".s:rs."expected_fixture".s:re."")
    call CodeCompleteAddTemplate("ruby", "cho", "check_has_one :".s:rs."accessor".s:re.", :".s:rs."fixture".s:re.", :".s:rs."expected_fixture".s:re."")

    call CodeCompleteAddTemplate("ruby", "sweeper", "\<c-r>=Snippet_Sweeper()\<CR>")
endif

call CodeCompleteAddTemplate("ruby", "require", "require '".s:rs.s:re."'")

call CodeCompleteAddTemplate("ruby", "def", "def ".s:rs."function_name".s:re."\<CR>".s:rs.s:re."\<CR>end\<CR>")
call CodeCompleteAddTemplate("ruby", "class", "class ".s:rsd."\<c-r>=Snippet_ClassNameFromFilename()\<CR>".s:re."\<CR>def initialize".s:rs.s:re."\<CR>".s:rs.s:re."\<CR>end\<CR>end")

call CodeCompleteAddTemplate("ruby", "map", "map {|".s:rsd."element".s:re."| ".s:rs."body".s:re."}")
call CodeCompleteAddTemplate("ruby", "mapo", "map do |".s:rsd."element".s:re."|\<CR>".s:rs."body".s:re."\<CR>end\<CR>")
call CodeCompleteAddTemplate("ruby", "select", "select {|".s:rsd."element".s:re."| ".s:rs."body".s:re."}")
call CodeCompleteAddTemplate("ruby", "selecto", "select do |".s:rsd."element".s:re."|\<CR>".s:rs."body".s:re."\<CR>end\<CR>")
call CodeCompleteAddTemplate("ruby", "reject", "reject {|".s:rsd."element".s:re."| ".s:rs."body".s:re."}")
call CodeCompleteAddTemplate("ruby", "rejecto", "reject do |".s:rsd."element".s:re."|\<CR>".s:rs."body".s:re."\<CR>end\<CR>")
call CodeCompleteAddTemplate("ruby", "sort", "sort {|".s:rsd."x".s:re.",".s:rsd."y".s:re."| ".s:rs."body".s:re."}")
call CodeCompleteAddTemplate("ruby", "sorto", "sort do |".s:rsd."x".s:re.",".s:rsd."y".s:re."|\<CR>".s:rs."body".s:re."\<CR>end\<CR>")
call CodeCompleteAddTemplate("ruby", "each", "each {|".s:rsd."element".s:re."| ".s:rs."body".s:re."}")
call CodeCompleteAddTemplate("ruby", "eacho", "each do |".s:rsd."element".s:re."|\<CR>".s:rs."body".s:re."\<CR>end\<CR>")
call CodeCompleteAddTemplate("ruby", "each_with_index", "each_with_index {|".s:rsd."element".s:re.",".s:rsd."i".s:re."| ".s:rs.s:re."}")
call CodeCompleteAddTemplate("ruby", "each_with_indexo", "each_with_index do |".s:rsd."element".s:re.",".s:rsd."i".s:re."|\<CR>".s:rs."body".s:re."\<CR>end\<CR>")
call CodeCompleteAddTemplate("ruby", "inject", "inject {|".s:rsd."total".s:re.",".s:rsd."next".s:re."| ".s:rs."body".s:re."}")
call CodeCompleteAddTemplate("ruby", "injecto", "inject do |".s:rsd."total".s:re.",".s:rsd."next".s:re."|\<CR>".s:rs."body".s:re."\<CR>end\<CR>")
call CodeCompleteAddTemplate("ruby", "detect", "detect {|".s:rsd."element".s:re."| ".s:rs."body".s:re."}")
call CodeCompleteAddTemplate("ruby", "detecto", "detect do |".s:rsd."element".s:re."|\<CR>".s:rs."body".s:re."\<CR>end\<CR>")

call CodeCompleteAddTemplate("ruby", "do", "do\<CR>".s:rs.s:re."\<CR>end\<CR>")
call CodeCompleteAddTemplate("ruby", "case", "case ".s:rs.s:re."\<CR>when ".s:rs.s:re."\<CR>else\<CR>".s:rs.s:re."\<CR>end\<CR>")

call CodeCompleteAddTemplate("ruby", "if", "if ".s:rs.s:re."\<CR>end\<CR>")
call CodeCompleteAddTemplate("ruby", "ife", "if ".s:rs.s:re."\<CR>else\<CR>".s:rs.s:re."\<CR>end\<CR>")

call CodeCompleteAddTemplate("ruby", "unless", "unless ".s:rs.s:re."\<CR>end\<CR>")
call CodeCompleteAddTemplate("ruby", "unlesse", "unless ".s:rs.s:re."\<CR>else\<CR>".s:rs.s:re."\<CR>end\<CR>")

"eruby {{{1

"eruby mappings
call CodeCompleteAddTemplate("eruby", "if", "<% if ".s:rs.s:re." -%>\<CR>".s:rs.s:re."\<CR><% end -%>")
call CodeCompleteAddTemplate("eruby", "ife", "<% if ".s:rs.s:re." -%>\<CR>".s:rs.s:re."\<CR><% else -%>\<CR>".s:rs.s:re."\<CR><% end -%>")

call CodeCompleteAddTemplate("eruby", "unless", "<% unless ".s:rs.s:re." -%>\<CR>".s:rs.s:re."\<CR><% end -%>")
call CodeCompleteAddTemplate("eruby", "unlesse", "<% if ".s:rs.s:re." -%>\<CR>".s:rs.s:re."\<CR><% else -%>\<CR>".s:rs.s:re."\<CR><% end -%>")

if s:inRailsEnv()
    call CodeCompleteAddTemplate("eruby", "rp", "<%= render :partial => \"".s:rs."file".s:re."\"".s:rs.s:re." %>")
    call CodeCompleteAddTemplate("eruby", "rt", "<%= render :template => \"".s:rs."file".s:re."\"".s:rs.s:re." %>")
    call CodeCompleteAddTemplate("eruby", "rf", "<%= render :file => \"".s:rs."file".s:re."\"".s:rs.s:re." %>")
    call CodeCompleteAddTemplate("eruby", "cs", "<%= collection_select ".s:rs."object".s:re.", ".s:rs."method".s:re.", ".s:rs."collection".s:re.", ".s:rs."value_method".s:re.", ".s:rs."text_method".s:re.s:rsd.", ".s:rs."[options]".s:re.", ".s:rs."[html_options]".s:re.s:re." %>")
    call CodeCompleteAddTemplate("eruby", "ofcfs", "<%= options_from_collection_for_select ".s:rs."collection".s:re.", ".s:rs."value_method".s:re.", ".s:rs."text_method".s:re.", ".s:rs."[selected_value]".s:re." %>")
    call CodeCompleteAddTemplate("eruby", "sslt", "<%= stylesheet_link_tag \"".s:rs.s:re."\" %>")
    call CodeCompleteAddTemplate("eruby", "jsit", "<%= javascript_include_tag \"".s:rs.s:re."\" %>")
    call CodeCompleteAddTemplate("eruby", "it", "<%= image_tag \"".s:rs.s:re."\" %>")
    call CodeCompleteAddTemplate("eruby", "lt", "<%= link_to \"".s:rs.s:re."\", ".s:rs."dest".s:re." %>")
else
    "create merb snippets

endif
call s:AddHTMLMapsFor('eruby')

"html {{{1

"html mappings
call s:AddHTMLMapsFor('html')


"php mappings {{{1
call CodeCompleteAddTemplate("php", "func", "function ".s:rs."name".s:re."(".s:rs.s:re.") {\<CR>".s:rs.s:re."\<CR>}\<CR>")
call CodeCompleteAddTemplate("php", "log", "error_log(var_export(".s:rs.s:re.", true));")
call CodeCompleteAddTemplate("php", "var", "var_export(".s:rs.s:re.");")


"vim {{{1
call CodeCompleteAddTemplate("vim", "if", "if ".s:rs.s:re."\<CR>endif\<CR>")
call CodeCompleteAddTemplate("vim", "ife", "if ".s:rs.s:re."\<CR>else\<CR>".s:rs.s:re."\<CR>endif\<CR>")
call CodeCompleteAddTemplate("vim", "func", "function! ".s:rs.s:re."(".s:rs.s:re.")\<CR>".s:rs.s:re."\<CR>endfunction\<CR>")
call CodeCompleteAddTemplate("vim", "au", "autocmd ".s:rs."events".s:re." ".s:rs."pattern".s:re." ".s:rs."command".s:re)
call CodeCompleteAddTemplate("vim", "com", "command! -nargs=".s:rs."number_of_args".s:re." ".s:rs."other_params".s:re." ".s:rs."name".s:re." ".s:rs."command".s:re)
call CodeCompleteAddTemplate("vim", "try", "try\<CR>".s:rs.s:re."\<CR>catch /".s:rs.s:re."/\<CR>".s:rs.s:re."\<CR>endtry")

"java {{{1
call CodeCompleteAddTemplate("java", "for", "for(".s:rsd."int i".s:re."; ".s:rs."condition".s:re."; ".s:rsd."i++".s:re."){\<CR>".s:rs.s:re."\<CR>}")
call CodeCompleteAddTemplate("java", "ife", "if(".s:rs.s:re."){\<CR>".s:rs.s:re."\<CR>}else{\<CR>".s:rs.s:re."\<CR>}")


"global {{{1

function! Snippet_Modeline()
    let start_comment = substitute(&commentstring, '^\([^ ]*\)\s*%s\(.*\)$', '\1', '')
    let end_comment = substitute(&commentstring, '^.*%s\(.*\)$', '\1', '')
    return start_comment . " vim: set " . s:rs."settings".s:re . ":" . end_comment
endfunction


call CodeCompleteAddGlobalTemplate("modeline", "\<c-r>=Snippet_Modeline()\<cr>")
call CodeCompleteAddGlobalTemplate("time", "\<c-r>=strftime(\"%Y-%m-%d %H:%M:%S\")\<cr>".s:rs.s:re)
call CodeCompleteAddGlobalTemplate("lorem", "Lorem ipsum dolor sit amet, consectetur magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.  Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum".s:rs.s:re."\<c-o>:normal! gqq\<CR>")


" modeline {{{1
" vim: set fdm=marker:
