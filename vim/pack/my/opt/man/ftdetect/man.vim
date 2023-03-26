" TODO for finding bolded entries in man
" https://unix.stackexchange.com/questions/271550/how-can-i-search-for-bolded-or-underlined-text
"if !empty($MAN_PN)
"  autocmd StdinReadPost * set ft=man | file $MAN_PN
"endif
