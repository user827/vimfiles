function! s:SetUpLoupeHighlight()
  " bug? the lua version only extract guifg
  execute 'highlight! QuickFixLine ' . pinnacle#extract_highlight('Search')
  execute 'highlight! Substitute ' . pinnacle#extract_highlight('Search')

  highlight! clear Search
  execute 'highlight! Search ' . pinnacle#decorate('bold,underline', 'Underlined')
  "highlight! Search cterm=undercurl,bold gui=undercurl,bold guifg=#dc322f guisp=#dc322f
endfunction

augroup WincentLoupe
  autocmd!
  autocmd ColorScheme * call s:SetUpLoupeHighlight()
augroup END
call s:SetUpLoupeHighlight()
