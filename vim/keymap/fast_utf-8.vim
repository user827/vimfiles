" Vim Keymap file for the normalized Canadian multilingual keyboard
" CAN/CSA Z243.200-92 using the latin1 encoding.
" This mapping is limited in scope, as it assumes that the AltGr
" key works as it typically does in a Windows system with a multilingual
" English keyboard.  It probably won't work with the US keyboard on US
" English versions of Windows, because those don't provide the AltGr keys.
" The mapping was tested with Win2k and WinXP.

" Maintainer: TODO: maintainer ( 15-Feb-2013, John Doe )
" Last Change: 2013 Feb 15

" 2013 Feb 15
" Initial Revision

" All characters are given literally, conversion to another encoding (e.g.,
" UTF-8) should work.
scriptencoding utf-8

" Use this short name in the status line.
let b:keymap_name = "fast_us"

loadkeymap
" map each number to its shift-key character
 1 !
 2 @
 3 #
 4 $
 5 %
 6 ^
 7 &
 8 *
 9 (
 0 )
 - _
" and then the opposite
 ! 1
 @ 2
 # 3
 $ 4
 % 5
 ^ 6
 & 7
 * 8
 ( 9
 ) 0
 _ -
