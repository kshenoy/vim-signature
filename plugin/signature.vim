" vim-signature is a plugin to toggle, display and navigate marks.
"
" Maintainer:
" Kartik Shenoy
"
" vim: fdm=marker:et:ts=4:sw=2:sts=2
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Exit when app has already been loaded (or "compatible" mode set)
if exists("g:loaded_Signature") || &cp
  finish
endif
let g:loaded_Signature = "1.5"  " Version Number
let s:save_cpo = &cpo
set cpo&vim


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Global variables     {{{1
"
if !exists('g:SignatureIncludeMarks')
  let g:SignatureIncludeMarks = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
endif
if !exists('g:SignatureIncludeMarkers')
  let g:SignatureIncludeMarkers = ")!@#$%^&*("
endif
if !exists('g:SignatureSignTextHL')
  let g:SignatureSignTextHL = "Exception"
endif
if !exists('g:SignatureWrapJumps')
  let g:SignatureWrapJumps = 1
endif
if !exists('g:SignatureMarkLeader')
  let g:SignatureMarkLeader = "m"
endif
if !exists('g:SignatureMarkerLeader')
  let g:SignatureMarkerLeader = g:SignatureMarkLeader
endif
if !exists('g:SignatureMarkOrder')
  let g:SignatureMarkOrder = "\p\m"
endif
if !exists('g:SignaturePurgeConfirmation')
  let g:SignaturePurgeConfirmation = 0
endif
if !exists('g:SignatureDisableMenu')
  let g:SignatureDisableMenu = 0
endif
if !exists('g:SignatureMenuStruct')
  let g:SignatureMenuStruct = 'P&lugin.&Signature'
endif
if !exists('g:SignaturePeriodicRefresh')
  let g:SignaturePeriodicRefresh = 1
endif
" }}}1

call signature#Init()


if has('autocmd')
  augroup sig_autocmds
    autocmd!
    " Disable mappings created by Signature in panes created by NERDTree
    autocmd FileType nerdtree call signature#BufferMaps(0)
    autocmd BufEnter * call signature#Toggle(0)
    autocmd CursorHold * if g:SignaturePeriodicRefresh | call signature#SignRefresh() | endif
  augroup END
endif

command! -nargs=0 SignatureToggle         call signature#Toggle(1)
command! -nargs=0 SignatureRefreshDisplay call signature#SignRefresh()


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Create Menu          {{{1
"
if !g:SignatureDisableMenu && has('gui_running')
  exec 'menu  <silent> ' . g:SignatureMenuStruct . '.Pl&ace\ next\ mark<Tab>' . g:SignatureMarkLeader . ', :call signature#ToggleMark(",")<CR>'
  exec 'menu  <silent> ' . g:SignatureMenuStruct . '.Re&move\ all\ marks\ \ \ \ <Tab>' . g:SignatureMarkLeader . '<Space> :call signature#PurgeMarks()<CR>'

  if hasmapto('<Plug>SIG_NextSpotByPos')
    exec 'menu  <silent> ' . g:SignatureMenuStruct . '.Goto\ &next\ mark\ (pos)<Tab>' . signature#MapKey('<Plug>SIG_NextSpotByPos', 'n') . ' :call signature#GotoMark("pos", "next", "spot")'
  else
    exec 'menu  <silent> ' . g:SignatureMenuStruct . '.Goto\ &next\ mark\ (pos) :call signature#GotoMark("pos", "next", "spot")'
  endif

  if hasmapto('<Plug>SIG_PrevSpotByPos')
    exec 'menu  <silent> ' . g:SignatureMenuStruct . '.Goto\ p&rev\ mark\ (pos)<Tab>' . signature#MapKey('<Plug>SIG_PrevSpotByPos', 'n') . ' :call signature#GotoMark("pos", "prev", "spot")'
  else
    exec 'menu  <silent> ' . g:SignatureMenuStruct . '.Goto\ p&rev\ mark\ (pos) :call signature#GotoMark("pos", "prev", "spot")'
  endif

  if hasmapto('<Plug>SIG_NextSpotByAlpha')
    exec 'menu  <silent> ' . g:SignatureMenuStruct . '.Goto\ next\ mark\ (a&lpha)<Tab>' . signature#MapKey('<Plug>SIG_NextSpotByAlpha', 'n') . ' :call signature#GotoMark("alpha", "next", "spot")'
  else
    exec 'menu  <silent> ' . g:SignatureMenuStruct . '.Goto\ next\ mark\ (a&lpha) :call signature#GotoMark("alpha", "next", "spot")'
  endif

  if hasmapto('<Plug>SIG_PrevSpotByAlpha')
    exec 'menu  <silent> ' . g:SignatureMenuStruct . '.Goto\ prev\ mark\ (alp&ha)<Tab>' . signature#MapKey('<Plug>SIG_PrevSpotByAlpha', 'n') . ' :call signature#GotoMark("alpha", "prev", "spot")'
  else
    exec 'menu  <silent> ' . g:SignatureMenuStruct . '.Goto\ prev\ mark\ (alp&ha)<Tab> :call signature#GotoMark("alpha", "prev", "spot")'
  endif

  exec 'amenu <silent> ' . g:SignatureMenuStruct . '.-s1- :'

  exec 'menu  <silent> ' . g:SignatureMenuStruct . '.Rem&ove\ all\ markers<Tab>' . g:SignatureMarkerLeader . '<BS> :call signature#PurgeMarkers()<CR>'

  if hasmapto('<Plug>SIG_NextMarkerByType')
    exec 'menu  <silent> ' . g:SignatureMenuStruct . '.Goto\ nex&t\ marker<Tab>' . signature#MapKey('<Plug>SIG_NextMarkerByType', 'n') . ' :call signature#GotoMarker("next")'
  else
    exec 'menu  <silent> ' . g:SignatureMenuStruct . '.Goto\ nex&t\ marker :call signature#GotoMarker("next")'
  endif

  if hasmapto('<Plug>SIG_PrevMarkerByType')
    exec 'menu  <silent> ' . g:SignatureMenuStruct . '.Goto\ pre&v\ marker<Tab>' . signature#MapKey('<Plug>SIG_PrevMarkerByType', 'n') . ' :call signature#GotoMarker("prev")'
  else
    exec 'menu  <silent> ' . g:SignatureMenuStruct . '.Goto\ pre&v\ marker :call signature#GotoMarker("prev")'
  endif
endif
" }}}1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let &cpo = s:save_cpo
unlet s:save_cpo
