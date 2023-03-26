if exists('g:loaded_man')
  finish
endif
exec 'source '.$VIMRUNTIME.'/plugin/man.vim'
let g:loaded_man = 1

"TODO indentline fires even when we have it disabled for man
" after following a tag we act is if we are no longer pager even if we were

function! <sid>open_page(count, count1, mods, ...) abort
  if a:0 == 0 && &filetype ==# 'man'
    let l:ref = expand('<cWORD>')
    if empty(ref)
      call s:error('no identifier under cursor')
      return
    endif
    let l:ref=substitute(l:ref, '\e\\[\d\d\=m', '', 'g')
    return call('man#open_page', [a:count, a:count1, a:mods, l:ref] + a:000)
  elseif a:0 == 1 && &filetype ==# 'man'
    " assume we were called a s keywordprg
    " TODO why do we need the double \\?
    let l:ref=substitute(a:1, '\e\\[\d\d\=m', '', 'g')
    return call('man#open_page', [a:count, a:count1, a:mods, l:ref] + a:000[1:])
  else
    return call('man#open_page', [a:count, a:count1, a:mods] + a:000)
  endif
endfunction

command! -bang -bar -range=0 -complete=customlist,man#complete -nargs=* Man
      \ if <bang>0 | set ft=man |
      \ else | call <sid>open_page(v:count, v:count1, <q-mods>, <f-args>) | endif
