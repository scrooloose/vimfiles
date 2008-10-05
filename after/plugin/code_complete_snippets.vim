function! s:AddHTMLMapsFor(ft)
    call CodeCompleteAddTemplate(a:ft, "label", "<label for=\"".g:rs."id".g:re."\">".g:rs."label_text".g:re."</label>")

    call CodeCompleteAddTemplate(a:ft, "table", "<table class=\"".g:rs.g:re."\">\<CR>".g:rs.g:re."\<CR></table>")
    call CodeCompleteAddTemplate(a:ft, "table2", "<table cellspacing=\"0\" cellpadding=\"0\"".g:rs.g:re.">\<CR>".g:rs.g:re."\<CR></table>")

    call CodeCompleteAddTemplate(a:ft, "span", "<span class=\"".g:rs.g:re."\">".g:rs.g:re."</span>")
    call CodeCompleteAddTemplate(a:ft, "div", "<div class=\"".g:rs.g:re."\">\<CR>".g:rs.g:re."\<CR></div>")
    call CodeCompleteAddTemplate(a:ft, "id", "id=\"".g:rs.g:re."\"")
    call CodeCompleteAddTemplate(a:ft, "img", "<img src=\"".g:rs.g:re."\"".g:rs.g:re." />")

    call CodeCompleteAddTemplate(a:ft, "select", "<select name=\"".g:rs.g:re."\"".g:rs.g:re.">".g:rs.g:re."</select>")
    call CodeCompleteAddTemplate(a:ft, "script", "<script type=\"text/javascript\">\<CR>//<![CDATA[\<cr>".g:rs.g:re."\<CR>//]]>\<CR></script>")
    call CodeCompleteAddTemplate(a:ft, "style", "<style type=\"text/css\">\<CR>".g:rs.g:re."\<CR></style>")


    call CodeCompleteAddTemplate(a:ft, "href", "<a href=\"".g:rs.g:re."\">".g:rs.g:re."</a>")
    call CodeCompleteAddTemplate(a:ft, "link", "<link rel=\"stylesheet\" type=\"text/css\" href=\"".g:rs.g:re."\" />")

endfunction

"ruby {{{1
call CodeCompleteAddTemplate("ruby", "vpo", "validates_presence_of ".g:rs.g:re)
call CodeCompleteAddTemplate("ruby", "vno", "validates_numericality_of ".g:rs.g:re)
call CodeCompleteAddTemplate("ruby", "vuo", "validates_uniqueness_of ".g:rs.g:re)
call CodeCompleteAddTemplate("ruby", "bvoc", "before_validation_on_create ".g:rs.g:re)
call CodeCompleteAddTemplate("ruby", "bv", "before_validation ".g:rs.g:re)

call CodeCompleteAddTemplate("ruby", "RDL", "RAILS_DEFAULT_LOGGER.".g:rsd."debug".g:re." ".g:rs.g:re)

call CodeCompleteAddTemplate("ruby", "rmc", "remove_column :".g:rs."table".g:re.", :".g:rs."column".g:re."")
call CodeCompleteAddTemplate("ruby", "rnc", "rename_column :".g:rs."table".g:re.", :".g:rs."old".g:re.", :".g:rs."new".g:re."")
call CodeCompleteAddTemplate("ruby", "ac", "add_column :".g:rs."table".g:re.", :".g:rs."column".g:re.", :".g:rs."type".g:re."")
call CodeCompleteAddTemplate("ruby", "ct", "create_table :".g:rs."table_name".g:re." do |t|\<CR>t.column :".g:rs."name".g:re.", :".g:rs."type".g:re."\<CR>end")

call CodeCompleteAddTemplate("ruby", "chm", "check_has_many :".g:rs."accessor".g:re.", :".g:rs."fixture".g:re.", ".g:rs."klass".g:re.", ".g:rs."number".g:re."")
call CodeCompleteAddTemplate("ruby", "cbt", "check_belongs_to :".g:rs."accessor".g:re.", :".g:rs."fixture".g:re.", :".g:rs."expected_fixture".g:re."")
call CodeCompleteAddTemplate("ruby", "cho", "check_has_one :".g:rs."accessor".g:re.", :".g:rs."fixture".g:re.", :".g:rs."expected_fixture".g:re."")

call CodeCompleteAddTemplate("ruby", "def", "def ".g:rs."function_name".g:re."\<CR>".g:rs.g:re."\<CR>end\<CR>")
call CodeCompleteAddTemplate("ruby", "class", "class ".g:rs."Name".g:re."\<CR>def initialize".g:rs.g:re."\<CR>".g:rs.g:re."\<CR>end\<CR>end")
call CodeCompleteAddTemplate("ruby", "map", "map {|".g:rs."var".g:re."| ".g:rs."body".g:re."}")
call CodeCompleteAddTemplate("ruby", "mapb", "map do |".g:rs."var".g:re."|\<CR>".g:rs."body".g:re."\<CR>end\<CR>")
call CodeCompleteAddTemplate("ruby", "select", "select {|".g:rs."var".g:re."| ".g:rs."body".g:re."}")
call CodeCompleteAddTemplate("ruby", "selectb", "select do |".g:rs."var".g:re."|\<CR>".g:rs."body".g:re."\<CR>end\<CR>")
call CodeCompleteAddTemplate("ruby", "sort", "sort {|".g:rs."var1".g:re.",".g:rs."var2".g:re."| ".g:rs."body".g:re."}")
call CodeCompleteAddTemplate("ruby", "sortb", "sort do |".g:rs."var1".g:re.",".g:rs."var2".g:re."|\<CR>".g:rs."body".g:re."\<CR>end\<CR>")
call CodeCompleteAddTemplate("ruby", "each", "each {|".g:rsd."x".g:re."| ".g:rs."".g:re."}")
call CodeCompleteAddTemplate("ruby", "eachb", "each do |".g:rs."var".g:re."|\<CR>".g:rs."body".g:re."\<CR>end\<CR>")
call CodeCompleteAddTemplate("ruby", "each_with_index", "each_with_index {|".g:rs."var".g:re.",i| ".g:rs.g:re."}")
call CodeCompleteAddTemplate("ruby", "each_with_indexb", "each_with_index do |".g:rs."var".g:re.",i|\<CR>".g:rs."body".g:re."\<CR>end\<CR>")
call CodeCompleteAddTemplate("ruby", "inject", "inject {|".g:rs."total".g:re.",".g:rs."next_var".g:re."| ".g:rs."body".g:re."}")
call CodeCompleteAddTemplate("ruby", "injectb", "inject do |".g:rs."total".g:re.",".g:rs."next_var".g:re."|\<CR>".g:rs."body".g:re."\<CR>end\<CR>")
call CodeCompleteAddTemplate("ruby", "detect", "detect {|".g:rs."var".g:re."| ".g:rs."body".g:re."}")
call CodeCompleteAddTemplate("ruby", "detectb", "detect do |".g:rs."var".g:re."|\<CR>".g:rs."body".g:re."\<CR>end\<CR>")
call CodeCompleteAddTemplate("ruby", "do", "do\<CR>".g:rs.g:re."\<CR>end\<CR>")
call CodeCompleteAddTemplate("ruby", "if", "if ".g:rs."condition".g:re."\<CR>".g:rs.g:re."\<CR>end\<CR>")
call CodeCompleteAddTemplate("ruby", "ife", "if ".g:rs."condition".g:re."\<CR>".g:rs.g:re."\<CR>else\<CR>".g:rs.g:re."\<CR>end\<CR>")
call CodeCompleteAddTemplate("ruby", "case", "case ".g:rs."subject".g:re."\<CR>when ".g:rs."value".g:re."\<CR>".g:rs.g:re."\<CR>else\<CR>".g:rs.g:re."\<CR>end\<CR>")

"eruby {{{1

"eruby mappings
call CodeCompleteAddTemplate("eruby", "rp", "<%= render :partial => \"".g:rs."file".g:re."\"".g:rs.g:re." %>")
call CodeCompleteAddTemplate("eruby", "rt", "<%= render :template => \"".g:rs."file".g:re."\"".g:rs.g:re." %>")
call CodeCompleteAddTemplate("eruby", "rf", "<%= render :file => \"".g:rs."file".g:re."\"".g:rs.g:re." %>")
call CodeCompleteAddTemplate("eruby", "<%", "<% ".g:rs.g:re." -%>")
call CodeCompleteAddTemplate("eruby", "<%=", "<%= ".g:rs.g:re." %>")
call CodeCompleteAddTemplate("eruby", "<%=h", "<%=h ".g:rs.g:re." %>")
call CodeCompleteAddTemplate("eruby", "cs", "<%= collection_select ".g:rs."object".g:re.", ".g:rs."method".g:re.", ".g:rs."collection".g:re.", ".g:rs."value_method".g:re.", ".g:rs."text_method".g:re.", ".g:rs."[options]".g:re.", ".g:rs."[html_options]".g:re." %>")
call CodeCompleteAddTemplate("eruby", "ofcfs", "<%= options_from_collection_for_select ".g:rs."collection".g:re.", ".g:rs."value_method".g:re.", ".g:rs."text_method".g:re.", ".g:rs."[selected_value]".g:re." %>")
call CodeCompleteAddTemplate("eruby", "sslt", "<%= stylesheet_link_tag \"".g:rs.g:re."\" %>")
call CodeCompleteAddTemplate("eruby", "jsit", "<%= javascript_include_tag \"".g:rs.g:re."\" %>")
call CodeCompleteAddTemplate("eruby", "it", "<%= image_tag \"".g:rs.g:re."\" %>")
call CodeCompleteAddTemplate("eruby", "lt", "<%= link_to \"".g:rs.g:re."\", ".g:rs."dest".g:re." %>")
call s:AddHTMLMapsFor('eruby')

"html {{{1

"html mappings
call s:AddHTMLMapsFor('html')


"php mappings
call CodeCompleteAddTemplate("php", "func", "function ".g:rs."name".g:re."(".g:rs.g:re.") {\<CR>".g:rs.g:re."\<CR>}\<CR>")
call CodeCompleteAddTemplate("php", "log", "error_log(var_export(".g:rs.g:re.", true));")
call CodeCompleteAddTemplate("php", "var", "var_export(".g:rs.g:re.");")


"vim {{{
call CodeCompleteAddTemplate("vim", "if", "if ".g:rs."condition".g:re."\<CR>".g:rs.g:re."\<CR>endif\<CR>")
call CodeCompleteAddTemplate("vim", "ife", "if ".g:rs."condition".g:re."\<CR>".g:rs.g:re."\<CR>else\<CR>".g:rs.g:re."\<CR>endif\<CR>")
call CodeCompleteAddTemplate("vim", "func", "function! ".g:rs."name".g:re."(".g:rs.g:re.")\<CR>".g:rs.g:re."\<CR>endfunction\<CR>")
call CodeCompleteAddTemplate("vim", "au", "autocmd ".g:rs."events".g:re." ".g:rs."pattern".g:re." ".g:rs."command".g:re)
call CodeCompleteAddTemplate("vim", "com", "command! -nargs=".g:rs."number_of_args".g:re." ".g:rs."other_params".g:re." ".g:rs."name".g:re." ".g:rs."command".g:re)

"java {{{
call CodeCompleteAddTemplate("java", "for", "for(".g:rsd."int i".g:re."; ".g:rs."condition".g:re."; ".g:rsd."i++".g:re."){\<CR>".g:rs.g:re."\<CR>}")


"global {{{1

function! ModelineSnippet()
    let start_comment = substitute(&commentstring, '^\([^ ]*\)\s*%s\(.*\)$', '\1', '')
    let end_comment = substitute(&commentstring, '^\(.*\)%s\(.*\)$', '\2', '')
    return start_comment . " vim: set " . g:rs."settings".g:re . ":" . end_comment
endfunction


call CodeCompleteAddTemplate("_", "modeline", "\<c-r>=ModelineSnippet()\<cr>")


" modeline {{{1
" vim: set fdm=marker:
