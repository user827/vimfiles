" NOTE need to set these before setting the colorscheme
" allow terminal to be transparent by disabling some background colors
" also breaks _flat and colorcolumn
let g:solarized_termtrans=0
let g:solarized_menu=0
let g:solarized_extra_hi_groups = 1

runtime colors/solarized8.vim
let g:colors_name = 'mysolarized8'

hi SignColumn ctermfg=11 guifg=#657b83 guibg=#073642
" This is starting to have a bit too little contrast
" hi Normal guifg=#839496 guibg=#002b36
hi SpellBad ctermfg=NONE guifg=NONE
hi SpellCap ctermfg=NONE guifg=NONE
hi SpellRare ctermfg=NONE guifg=NONE
hi SpellLocal ctermfg=NONE guifg=NONE
