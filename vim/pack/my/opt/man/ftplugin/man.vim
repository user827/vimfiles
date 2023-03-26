if exists('b:did_ftplugin') || &filetype !=# 'man'
  finish
endif
execute 'source' $VIMRUNTIME.'/ftplugin/man.vim'

" https://unix.stackexchange.com/questions/371062/grep-unexpected-results-when-searching-for-words-in-heading-from-man-page
" https://unix.stackexchange.com/questions/271550/how-can-i-search-for-bolded-or-underlined-text

"setlocal shiftwidth=2

setlocal conceallevel=3 synmaxcol& concealcursor=nvic
"setlocal concealcursor=nvi
"setlocal iskeyword+=-
"exe "setlocal iskeyword+=\b,_"

" so K and <c-]> include the section number in manpage(num)
" already set in man#read_page
" set ascii controle secuences so we can safely remove them
setlocal iskeyword+=(,),[,
" but that isn't done when opening man through pager for example...

"function! ManMan(keyword) abort
"  echom a:keyword
"  let l:keyword=substitute(a:keyword, '[134]m', '', '')
"  execute 'Man' l:keyword
"endfunction
"command! -buffer -nargs=1 ManMan :call ManMan('<args>')
"
""TODO does not stick
"setlocal keywordprg=:ManMan


function! ManFolds() abort
   let l:lines=(v:foldend - v:foldstart + 1)
   let l:first=substitute(getline(v:foldstart), '\v *', '', '')
   let l:first=substitute(l:first, '\e\[\d\d\=m', '', 'g')
   "let l:dashes=substitute(v:folddashes, '-', s:middot, 'g')
   return '+-'.v:folddashes . '  '.l:lines . ' lines: '  . l:first
endfunction
setlocal foldtext=ManFolds()

if get(g:, 'ft_man_folding_enable', 0)
  " TODO why is foldelvelmax not read?
  "setlocal foldlevel=99
  setlocal foldlevel=1
endif

function! ManGotoTag(pattern, flags, info) abort
  let l:pattern=substitute(a:pattern, '\e\\[\d\d\=m', '', 'g')
  return man#goto_tag(l:pattern, a:flags, a:info)
endfunction

setlocal tagfunc=ManGotoTag

"command! -buffer -nargs=1 Mk /^     \(\|  \)\e\[1m<args>\>
command! -buffer -nargs=1 Mk /^     \(\|  \)\e\[1m<args>\(\|\e\[\d\d\=m\)\>

let b:did_ftplugin = 1
