let g:template['ruby'] = {}

let g:template['ruby']['vpo'] ="validates_presence_of ".g:rs.g:re
let g:template['ruby']['vno'] ="validates_numericality_of ".g:rs.g:re
let g:template['ruby']['vuo'] ="validates_uniqueness_of ".g:rs.g:re
let g:template['ruby']['bvoc'] ="before_validation_on_create ".g:rs.g:re
let g:template['ruby']['bv'] ="before_validation ".g:rs.g:re

let g:template['ruby']['RDL'] ="RAILS_DEFAULT_LOGGER.debug ".g:rs.g:re

let g:template['ruby']['rmc'] ="remove_column :".g:rs."table".g:re.", :".g:rs."column".g:re.""
let g:template['ruby']['rnc'] ="rename_column :".g:rs."table".g:re.", :".g:rs."old".g:re.", :".g:rs."new".g:re.""
let g:template['ruby']['ac'] ="add_column :".g:rs."table".g:re.", :".g:rs."column".g:re.", :".g:rs."type".g:re.""
let g:template['ruby']['ct'] ="create_table :".g:rs."table_name".g:re." do |t|\<CR>t.column :".g:rs."name".g:re.", :".g:rs."type".g:re."\<CR>end"

let g:template['ruby']['chm'] ="check_has_many :".g:rs."accessor".g:re.", :".g:rs."fixture".g:re.", ".g:rs."klass".g:re.", ".g:rs."number".g:re.""
let g:template['ruby']['cbt'] ="check_belongs_to :".g:rs."accessor".g:re.", :".g:rs."fixture".g:re.", :".g:rs."expected_fixture".g:re.""
let g:template['ruby']['cho'] ="check_has_one :".g:rs."accessor".g:re.", :".g:rs."fixture".g:re.", :".g:rs."expected_fixture".g:re.""

let g:template['ruby']['def'] ="def ".g:rs."function_name".g:re."\<CR>".g:rs.g:re."\<CR>end\<CR>"
let g:template['ruby']['class'] ="class ".g:rs.g:re."\<CR>".g:rs.g:re."\<CR>end\<CR>"
let g:template['ruby']['map'] ="map {|".g:rs."var".g:re."| ".g:rs."body".g:re."}"
let g:template['ruby']['mapb'] ="map do |".g:rs."var".g:re."|\<CR>".g:rs."body".g:re."\<CR>end\<CR>"
let g:template['ruby']['select'] ="select {|".g:rs."var".g:re."| ".g:rs."body".g:re."}"
let g:template['ruby']['selectb'] ="select do |".g:rs."var".g:re."|\<CR>".g:rs."body".g:re."\<CR>end\<CR>"
let g:template['ruby']['sort'] ="sort {|".g:rs."var1".g:re.",".g:rs."var2".g:re."| ".g:rs."body".g:re."}"
let g:template['ruby']['sortb'] ="sort do |".g:rs."var1".g:re.",".g:rs."var2".g:re."|\<CR>".g:rs."body".g:re."\<CR>end\<CR>"
let g:template['ruby']['each'] ="each {|".g:rs."var".g:re."| ".g:rs."body".g:re."}"
let g:template['ruby']['eachb'] ="each do |".g:rs."var".g:re."|\<CR>".g:rs."body".g:re."\<CR>end\<CR>"
let g:template['ruby']['each_with_index'] ="each_with_index {|".g:rs."var".g:re.",i| ".g:rs.g:re."}"
let g:template['ruby']['each_with_indexb'] ="each_with_index do |".g:rs."var".g:re.",i|\<CR>".g:rs."body".g:re."\<CR>end\<CR>"
let g:template['ruby']['inject'] ="inject {|".g:rs."total".g:re.",".g:rs."next_var".g:re."| ".g:rs."body".g:re."}"
let g:template['ruby']['injectb'] ="inject do |".g:rs."total".g:re.",".g:rs."next_var".g:re."|\<CR>".g:rs."body".g:re."\<CR>end\<CR>"
let g:template['ruby']['detect'] ="detect {|".g:rs."var".g:re."| ".g:rs."body".g:re."}"
let g:template['ruby']['detectb'] ="detect do |".g:rs."var".g:re."|\<CR>".g:rs."body".g:re."\<CR>end\<CR>"
let g:template['ruby']['do'] ="do\<CR>".g:rs.g:re."\<CR>end\<CR>"




function! s:AddHTMLMapsFor(ft)
    let g:template[a:ft]['label'] ="<label for=\"".g:rs."id".g:re."\">".g:rs."label_text".g:re."</label>"

    let g:template[a:ft]['table'] ="<table class=\"".g:rs.g:re."\">\<CR>".g:rs.g:re."\<CR></table>"
    let g:template[a:ft]['table2'] ="<table cellspacing=\"0\" cellpadding=\"0\"".g:rs.g:re.">\<CR>".g:rs.g:re."\<CR></table>"

    let g:template[a:ft]['span'] ="<span class=\"".g:rs.g:re."\">".g:rs.g:re."</span>"
    let g:template[a:ft]['div'] ="<div class=\"".g:rs.g:re."\">\<CR>".g:rs.g:re."\<CR></div>"
    let g:template[a:ft]['id'] ="id=\"".g:rs.g:re."\""
    let g:template[a:ft]['img'] ="<img src=\"".g:rs.g:re."\"".g:rs.g:re." />"

    let g:template[a:ft]['select'] ="<select name=\"".g:rs.g:re."\"".g:rs.g:re.">".g:rs.g:re."</select>"
    let g:template[a:ft]['script'] ="<script type=\"text/javascript\">\<CR>//<![CDATA[\<cr>".g:rs.g:re."\<CR>//]]>\<CR></script>"
    let g:template[a:ft]['style'] ="<style type=\"text/css\">\<CR>".g:rs.g:re."\<CR></style>"


    let g:template[a:ft]['href'] ='<a href="".g:rs.g:re."">".g:rs.g:re."</a>'
    let g:template[a:ft]['link'] ='<link rel="stylesheet" type="text/css" href="".g:rs.g:re."" />'

endfunction

"html mappings
let g:template['html'] = {}
call s:AddHTMLMapsFor('html')


"eruby mappings
let g:template['eruby'] = copy(g:template['ruby'])
let g:template['eruby']['rp'] ="<%= render :partial => \"".g:rs."file".g:re."\"".g:rs.g:re." %>"
let g:template['eruby']['rt'] ="<%= render :template => \"".g:rs."file".g:re."\"".g:rs.g:re." %>"
let g:template['eruby']['rf'] ="<%= render :file => \"".g:rs."file".g:re."\"".g:rs.g:re." %>"
let g:template['eruby']['<%'] ="<% ".g:rs.g:re." -%>"
let g:template['eruby']['<%='] ="<%= ".g:rs.g:re." %>"
let g:template['eruby']['<%=h'] ="<%=h ".g:rs.g:re." %>"
let g:template['eruby']['cs'] ="<%= collection_select ".g:rs."object".g:re.", ".g:rs."method".g:re.", ".g:rs."collection".g:re.", ".g:rs."value_method".g:re.", ".g:rs."text_method".g:re.", ".g:rs."[options]".g:re.", ".g:rs."[html_options]".g:re." %>"
let g:template['eruby']['ofcfs'] ="<%= options_from_collection_for_select ".g:rs."collection".g:re.", ".g:rs."value_method".g:re.", ".g:rs."text_method".g:re.", ".g:rs."[selected_value]".g:re." %>"
let g:template['eruby']['sslt'] ='<%= stylesheet_link_tag "".g:rs.g:re."" %>'
let g:template['eruby']['jsit'] ='<%= javascript_include_tag "".g:rs.g:re."" %>'
let g:template['eruby']['it'] ='<%= image_tag "".g:rs.g:re."" %>'
let g:template['eruby']['lt'] ='<%= link_to ".g:rs.g:re.", ".g:rs."dest".g:re." %>'
call s:AddHTMLMapsFor('eruby')

"php mappings
let g:template['php'] = {}
let g:template['php']['func'] ="function ".g:rs."name".g:re."(".g:rs.g:re.") {\<CR>".g:rs.g:re."\<CR>}\<CR>"
let g:template['php']['log'] ="error_log(var_export(".g:rs.g:re.", true));"
let g:template['php']['var'] ="var_export(".g:rs.g:re.");"



