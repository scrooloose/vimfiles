if has("ruby")

" ====================================================================================
" COPIED FROM FUZZYFINDER.VIM {{{
" since they can't be called from outside fuzzyfinder.vim
" ====================================================================================
function! s:GetCurrentTagFiles()
  return sort(filter(map(tagfiles(), 'fnamemodify(v:val, '':p'')'), 'filereadable(v:val)'))
endfunction

function! s:HighlightPrompt(prompt, highlight)
  syntax clear
  execute printf('syntax match %s /^\V%s/', a:highlight, escape(a:prompt, '\'))
endfunction

function! s:HighlightError()
  syntax clear
  syntax match Error  /^.*$/
endfunction
" ------------------------------------------------------------------------------------
" }}}
" ====================================================================================

command! -bang -narg=? -complete=file   FuzzyFinderTextMate   call FuzzyFinderTextMateLauncher(<q-args>, len(<q-bang>), bufnr('%'), s:GetCurrentTagFiles())

function! InstantiateTextMateMode() "{{{
ruby << RUBY
  $LOAD_PATH << "#{ENV['HOME']}/.vim/ruby"

  begin
    require 'rubygems'
    gem 'fuzzy_file_finder'
  rescue LoadError
  end

  require 'fuzzy_file_finder'
RUBY

  ruby def finder; @finder ||= FuzzyFileFinder.new; end

  let g:FuzzyFinderMode.TextMate = copy(g:FuzzyFinderMode.Base)

  " ================================================================================
  " This function is copied almost whole-sale from fuzzyfinder.vim. Ideally, I could
  " used the on_complete callback to more cleanly add the new behavior, but the
  " TextMate-style completion broke a few of fuzzyfinder.vim's assumptions, and the
  " only way to patch that up was to override Base.complete...which required me to
  " copy-and-paste much of the original implementation.
  "
  " Ugly. But effective.
  " ================================================================================
  function! g:FuzzyFinderMode.TextMate.complete(findstart, base)
    if a:findstart
      return 0
    elseif  !self.exists_prompt(a:base) || len(self.remove_prompt(a:base)) < self.min_length
      return []
    endif
    call s:HighlightPrompt(self.prompt, self.prompt_highlight)

    let result = []
    ruby << RUBY
      matches = finder.find(VIM.evaluate('self.remove_prompt(a:base)'), VIM.evaluate('self.matching_limit').to_i + 1)
      matches.sort_by { |a| [-a[:score], a[:path]] }[0,50].each_with_index do |match, index|
        word = match[:path]
        abbr = "%2d: %s" % [index+1, match[:abbr]]
        menu = "[%5d]" % [match[:score] * 10000]
        VIM.evaluate("add(result, { 'word' : #{word.inspect}, 'abbr' : #{abbr.inspect}, 'menu' : #{menu.inspect} })")
      end
RUBY
    if empty(result) || len(result) >= self.matching_limit
      call s:HighlightError()
    endif

    if !empty(result)
      call feedkeys("\<C-p>\<Down>", 'n')
    endif

    return result
  endfunction

  function! FuzzyFinderTextMateLauncher(initial_text, partial_matching, prev_bufnr, tag_files)
    call g:FuzzyFinderMode.TextMate.launch(a:initial_text, a:partial_matching, a:prev_bufnr, a:tag_files)
  endfunction

  let g:FuzzyFinderOptions.TextMate = copy(g:FuzzyFinderOptions.File)
endfunction "}}}

if !exists('loaded_fuzzyfinder') "{{{
  function! FuzzyFinderTextMateLauncher(initial_text, partial_matching, prev_bufnr, tag_files)
    call InstantiateTextMateMode()
    function! FuzzyFinderTextMateLauncher(initial_text, partial_matching, prev_bufnr, tag_files)
      call g:FuzzyFinderMode.TextMate.launch(a:initial_text, a:partial_matching, a:prev_bufnr, a:tag_files)
    endfunction
    call g:FuzzyFinderMode.TextMate.launch(a:initial_text, a:partial_matching, a:prev_bufnr, a:tag_files)
  endfunction
  finish
end "}}}

call InstantiateTextMateMode()

endif
