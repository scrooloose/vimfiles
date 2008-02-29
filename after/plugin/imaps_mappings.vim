function! s:SetupHTMLMaps(ft)
    call IMAP('divcf`', "<div class=\"aligned content-frame\">\<cr><div class=\"title\"><+title+></div>\<CR><+body+>\<CR></div>", a:ft)
    call IMAP('<p`', "<p><++></p>", a:ft)
    call IMAP('<label`', "<label for=\"<+id+>\"><+label_text+></label>", a:ft)

    call IMAP('<table`', "<table class=\"<++>\">\<CR><++>\<CR></table>", a:ft)
    call IMAP('<table2`', "<table cellspacing=\"0\" cellpadding=\"0\"<++>>\<CR><++>\<CR></table>", a:ft)
    call IMAP('<td`', "<td><++></td>", a:ft)
    call IMAP('<tr`', "<tr>\<CR><++>\<CR></tr>", a:ft)
    call IMAP('<th`', "<th><++></th>", a:ft)
    call IMAP('<thead`', "<thead>\<CR><++>\<CR></thead>", a:ft)
    call IMAP('<tbody`', "<tbody>\<CR><++>\<CR></tbody>", a:ft)

    call IMAP('<span`', "<span<++>><++></span>", a:ft)
    call IMAP('<div`', "<div<++>>\<CR><++>\<CR></div>", a:ft)
    call IMAP('id`', "id=\"<++>\"", a:ft)
    call IMAP('<pcf`', "<p>\<CR>  <label for=\"<+id+>\"><++></label>\<CR><++>\<CR></p>", a:ft)
    call IMAP('<img`', "<img src=\"<++>\"<++>/>", a:ft)
    call IMAP('<h1`', "<h1<++>><++></h1>", a:ft)
    call IMAP('<h2`', "<h2<++>><++></h2>", a:ft)
    call IMAP('<h3`', "<h3<++>><++></h3>", a:ft)
    call IMAP('<li`', "<li><++></li>", a:ft)
    call IMAP('<b`', "<b><++></b>", a:ft)
    call IMAP('<strong`', "<strong><++></strong>", a:ft)

    call IMAP('<title`', "<title><++></title>", a:ft)
    call IMAP('<select`', "<select name=\"<++>\"<++>><++></select>", a:ft)
    call IMAP('<script`', "<script type=\"text/javascript\">\<CR>//<![CDATA[<++>\<CR>//]]>\<CR></script>", a:ft)

endfunction


"html mappings 
call s:SetupHTMLMaps('html')

"ruby mappings 
call IMAP('vpo`', "validates_presence_of <++>", 'ruby')
call IMAP('vno`', "validates_numericality_of <++>", 'ruby')
call IMAP('vuo`', "validates_uniqueness_of <++>", 'ruby')
call IMAP('bvoc`', "before_validation_on_create <++>", 'ruby')
call IMAP('bv`', "before_validation <++>", 'ruby')

call IMAP('RDL`', "RAILS_DEFAULT_LOGGER.debug <++>", 'ruby')

call IMAP('rmc`', "remove_column :<+table+>, :<+column+>", 'ruby')
call IMAP('rnc`', "rename_column :<+table+>, :<+old+>, :<+new+>", 'ruby')
call IMAP('ac`', "add_column :<+table+>, :<+column+>, :<+type+>", 'ruby')
call IMAP('ct`', "create_table :<+table_name+> do |t|\<CR>t.column :<+name+>, :<+type+>\<CR>end", 'ruby')

call IMAP('chm`', "check_has_many :<+accessor+>, :<+fixture+>, <+klass+>, <+number+>", 'ruby')
call IMAP('cbt`', "check_belongs_to :<+accessor+>, :<+fixture+>, :<+expected_fixture+>", 'ruby')
call IMAP('cho`', "check_has_one :<+accessor+>, :<+fixture+>, :<+expected_fixture+>", 'ruby')

call IMAP('def`', "def <+function_name+>\<CR><++>\<CR>end\<CR>", 'ruby')
call IMAP('class`', "class <++>\<CR><++>\<CR>end\<CR>", 'ruby')
call IMAP('map`', "map {|<+var+>| <+body+>}", 'ruby')
call IMAP('mapb`', "map do |<+var+>|\<CR><+body+>\<CR>end\<CR>", 'ruby')
call IMAP('select`', "select {|<+var+>| <+body+>}", 'ruby')
call IMAP('selectb`', "select do |<+var+>|\<CR><+body+>\<CR>end\<CR>", 'ruby')
call IMAP('sort`', "sort {|<+var1+>,<+var2+>| <+body+>}", 'ruby')
call IMAP('sortb`', "sort do |<+var1+>,<+var2+>|\<CR><+body+>\<CR>end\<CR>", 'ruby')
call IMAP('each`', "each {|<+var+>| <+body+>}", 'ruby')
call IMAP('eachb`', "each do |<+var+>|\<CR><+body+>\<CR>end\<CR>", 'ruby')
call IMAP('each_with_index`', "each_with_index {|<+var+>,i| <++>}", 'ruby')
call IMAP('each_with_indexb`', "each_with_index do |<+var+>,i|\<CR><+body+>\<CR>end\<CR>", 'ruby')
call IMAP('inject`', "inject {|<+total+>,<+next_var+>| <+body+>}", 'ruby')
call IMAP('injectb`', "inject do |<+total+>,<+next_var+>|\<CR><+body+>\<CR>end\<CR>", 'ruby')
call IMAP('detect`', "detect {|<+var+>| <+body+>}", 'ruby')
call IMAP('detectb`', "detect do |<+var+>|\<CR><+body+>\<CR>end\<CR>", 'ruby')
call IMAP('do`', "do\<CR><++>\<CR>end\<CR>", 'ruby')

"eruby mappings 
call IMAP('rp`', "<%= render :partial => \"<+file+>\"<++> %>", 'eruby')
call IMAP('rt`', "<%= render :template => \"<+file+>\"<++> %>", 'eruby')
call IMAP('rf`', "<%= render :file => \"<+file+>\"<++> %>", 'eruby')
call IMAP('<%`', "<% <++> -%>", 'eruby')
call IMAP('<%=`', "<%= <++> %>", 'eruby')
call IMAP('<%=h`', "<%=h <++> %>", 'eruby')
call IMAP('cs`', "collection_select <+object+>, <+method+>, <+collection+>, <+value_method+>, <+text_method+>, <+[options]+>, <+[html_options]+>", 'eruby')
call IMAP('ofcfs`', "options_from_collection_for_select <+collection+>, <+value_method+>, <+text_method+>, <+[selected_value]+>", 'eruby')
call IMAP('sslt`', '<%= stylesheet_link_tag "<++>" %>', 'eruby')
call IMAP('jsit`', '<%= javascript_include_tag "<++>" %>', 'eruby')
call IMAP('it`', '<%= image_tag "<++>" %>', 'eruby')
call IMAP('lt`', '<%= link_to <++>, <+dest+> %>', 'eruby')
call s:SetupHTMLMaps('eruby')

"php mappings
call IMAP('func`', "function <+name+>(<++>) {\<CR><++>\<CR>}\<CR>", 'php')
call IMAP('log`', "error_log(var_export(<++>, true));", 'php')
call IMAP('var`', "var_export(<++>);", 'php')
