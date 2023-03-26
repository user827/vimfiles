" Maintainer:          Anmol Sethi <hi@nhooyr.io>
" Previous Maintainer: SungHyun Nam <goweol@gmail.com>

if exists("b:current_syntax")
  finish
endif

syn case ignore

" modified from http://www.drchip.org/astronaut/vim/index.html#ANSIESC
syn match ansiSuppress conceal '\e\[2[234]m'
syn match ansiSuppress conceal '\e\[0m'
syn match ansiConceal contained conceal "\e\[\d*m"
syn match ansiUnderline display "\e\[4m.\{-}\ze\e\[" contains=ansiConceal
syn match ansiItalic display "\e\[3m.\{-}\ze\e\[" contains=ansiConceal
syn match ansiBold display "\e\[1m.\{-}\ze\e\[" contains=ansiConceal
" man should only have either bold or underline/italic on but somethimes it closes the
" other only after beginning another
syn match ansiUnderline display "\e\[4m\e\[22m.\{-}\ze\e\[" contains=ansiConceal
syn match ansiItalic display "\e\[3m\e\[22m.\{-}\ze\e\[" contains=ansiConceal



syntax match manReference      display '\e\[1m[^()[:space:]]\+\e\[22m([0-9nx][a-z]*)' contains=ansiConceal
syn match  manSectionHeading  display "^\e\[1m\S.*\e\[0m$" contains=ansiConceal
syntax match manTitle          display '^\%1l.*$'
syntax match manSubHeading     display '^ \{3\}\e\[1m\S.*\e\[0m$' contains=ansiConceal
syntax match manOptionDesc     display '^\s\+\e\[1m\%(+\|-\)[a-z0-9-]\+' contains=ansiConceal

" Define the default highlighting.
" Only when an item doesn't have highlighting yet

highlight default link manTitle Title
highlight default link manFooter PreProc
highlight default link manSectionHeading  Statement
highlight default link manOptionDesc	    Constant
highlight default link manReference	    PreProc
highlight default link manSubHeading      Function
highlight default link manCFuncDefinition Function

highlight default ansiUnderline cterm=underline gui=underline
highlight default ansiBold      cterm=bold      gui=bold
highlight default ansiItalic    cterm=italic    gui=italic

if &filetype != 'man'
  " May have been included by some other filetype.
  finish
endif

if !exists('b:man_sect')
  call man#init_pager()
endif

if b:man_sect =~# '^[023]'
  syntax case match
  syntax include @c $VIMRUNTIME/syntax/c.vim
  syntax match manCFuncDefinition display '\<\h\w*\>\ze\(\s\|\n\)*(' contained
  syntax match manLowerSentence /\n\s\{7}\l.\+[()]\=\%(\:\|.\|-\)[()]\=[{};]\@<!\n$/ display keepend contained contains=manReference
  syntax region manSentence start=/^\s\{7}\%(\u\|\*\)[^{}=]*/ end=/\n$/ end=/\ze\n\s\{3,7}#/ keepend contained contains=manReference
  syntax region manSynopsis start='^\%(
        \SYNOPSIS\|
        \SYNTAX\|
        \SINTASSI\|
        \SKŁADNIA\|
        \СИНТАКСИС\|
        \書式\)$' end='^\%(\S.*\)\=\S$' keepend contains=manLowerSentence,manSentence,manSectionHeading,@c,manCFuncDefinition
  highlight default link manCFuncDefinition Function

  syntax region manExample start='^EXAMPLES\=$' end='^\%(\S.*\)\=\S$' keepend contains=manLowerSentence,manSentence,manSectionHeading,manSubHeading,@c,manCFuncDefinition

  " XXX: groupthere doesn't seem to work
  syntax sync minlines=500
  "syntax sync match manSyncExample groupthere manExample '^EXAMPLES\=$'
  "syntax sync match manSyncExample groupthere NONE '^\%(EXAMPLES\=\)\@!\%(\S.*\)\=\S$'
endif

" Prevent everything else from matching the last line
execute 'syntax match manFooter display "^\%'.line('$').'l.*$"'

let b:current_syntax = 'man'
