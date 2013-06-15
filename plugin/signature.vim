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
let g:loaded_Signature = "2"


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Global variables           {{{1
"
if !exists('g:SignatureEnableDefaultMappings')
  let g:SignatureEnableDefaultMappings = 1
endif
if !exists('g:SignatureIncludeMarks')
  let g:SignatureIncludeMarks = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
endif
if !exists('g:SignatureIncludeMarkers')
  let g:SignatureIncludeMarkers = ")!@#$%^&*("
endif
if !exists('g:SignatureMarkTextHL')
  let g:SignatureMarkTextHL = "Exception"
endif
if !exists('g:SignatureMarkerTextHL')
  let g:SignatureMarkerTextHL = "WarningMsg"
endif
if !exists('g:SignaturePrioritizeMarks')
  let g:SignaturePrioritizeMarks = 1
endif
if !exists('g:SignatureWrapJumps')
  let g:SignatureWrapJumps = 1
endif
if !exists('g:SignatureLeader')
  let g:SignatureLeader = "m"
endif
if !exists('g:SignatureMarkOrder')
  let g:SignatureMarkOrder = "\p\m"
endif
if !exists('g:SignaturePurgeConfirmation')
  let g:SignaturePurgeConfirmation = 0
endif
if !exists('g:SignatureMenu')
  let g:SignatureMenu = 'P&lugin.&Signature'
endif
if !exists('g:SignaturePeriodicRefresh')
  let g:SignaturePeriodicRefresh = 1
endif
" }}}1


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Commands and autocmds      {{{1
"
if has('autocmd')
  augroup sig_autocmds
    autocmd!
    autocmd BufEnter   * call signature#SignRefresh()
    autocmd CursorHold * if g:SignaturePeriodicRefresh | call signature#SignRefresh() | endif
    " Create maps only if we aren't entering a NERDTree pane
    " We can't use &ft for condition checking as filetype still hasn't been set
    autocmd FileType *
      \ if expand('<amatch>') !=? "nerdtree" |
      \   call signature#BufferMaps( g:SignatureEnableDefaultMappings ) |
      \ endif
  augroup END
endif

command! -nargs=0 SignatureToggle  call signature#Toggle()
command! -nargs=0 SignatureRefresh call signature#SignRefresh(1)
" }}}1


  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Create Menu                {{{1
"
if ( g:SignatureMenu != 0 ) && has('gui_running')
  exec 'menu  <silent> ' . g:SignatureMenu . '.Pl&ace\ next\ mark<Tab>' . g:SignatureLeader . ', :call signature#ToggleMark(",")<CR>'
  exec 'menu  <silent> ' . g:SignatureMenu . '.Re&move\ all\ marks\ \ \ \ <Tab>' . g:SignatureLeader . '<Space> :call signature#PurgeMarks()<CR>'

  if hasmapto('<Plug>SIG_NextSpotByPos')
    exec 'menu  <silent> ' . g:SignatureMenu . '.Goto\ &next\ mark\ (pos)<Tab>' . signature#MapKey('<Plug>SIG_NextSpotByPos', 'n') . ' :call signature#GotoMark("pos", "next", "spot")'
  else
    exec 'menu  <silent> ' . g:SignatureMenu . '.Goto\ &next\ mark\ (pos) :call signature#GotoMark("pos", "next", "spot")'
  endif

  if hasmapto('<Plug>SIG_PrevSpotByPos')
    exec 'menu  <silent> ' . g:SignatureMenu . '.Goto\ p&rev\ mark\ (pos)<Tab>' . signature#MapKey('<Plug>SIG_PrevSpotByPos', 'n') . ' :call signature#GotoMark("pos", "prev", "spot")'
  else
    exec 'menu  <silent> ' . g:SignatureMenu . '.Goto\ p&rev\ mark\ (pos) :call signature#GotoMark("pos", "prev", "spot")'
  endif

  if hasmapto('<Plug>SIG_NextSpotByAlpha')
    exec 'menu  <silent> ' . g:SignatureMenu . '.Goto\ next\ mark\ (a&lpha)<Tab>' . signature#MapKey('<Plug>SIG_NextSpotByAlpha', 'n') . ' :call signature#GotoMark("alpha", "next", "spot")'
  else
    exec 'menu  <silent> ' . g:SignatureMenu . '.Goto\ next\ mark\ (a&lpha) :call signature#GotoMark("alpha", "next", "spot")'
  endif

  if hasmapto('<Plug>SIG_PrevSpotByAlpha')
    exec 'menu  <silent> ' . g:SignatureMenu . '.Goto\ prev\ mark\ (alp&ha)<Tab>' . signature#MapKey('<Plug>SIG_PrevSpotByAlpha', 'n') . ' :call signature#GotoMark("alpha", "prev", "spot")'
  else
    exec 'menu  <silent> ' . g:SignatureMenu . '.Goto\ prev\ mark\ (alp&ha)<Tab> :call signature#GotoMark("alpha", "prev", "spot")'
  endif

  exec 'amenu <silent> ' . g:SignatureMenu . '.-s1- :'

  exec 'menu  <silent> ' . g:SignatureMenu . '.Rem&ove\ all\ markers<Tab>' . g:SignatureLeader . '<BS> :call signature#PurgeMarkers()<CR>'

  if hasmapto('<Plug>SIG_NextMarkerByType')
    exec 'menu  <silent> ' . g:SignatureMenu . '.Goto\ nex&t\ marker<Tab>' . signature#MapKey('<Plug>SIG_NextMarkerByType', 'n') . ' :call signature#GotoMarker("next")'
  else
    exec 'menu  <silent> ' . g:SignatureMenu . '.Goto\ nex&t\ marker :call signature#GotoMarker("next")'
  endif

  if hasmapto('<Plug>SIG_PrevMarkerByType')
    exec 'menu  <silent> ' . g:SignatureMenu . '.Goto\ pre&v\ marker<Tab>' . signature#MapKey('<Plug>SIG_PrevMarkerByType', 'n') . ' :call signature#GotoMarker("prev")'
  else
    exec 'menu  <silent> ' . g:SignatureMenu . '.Goto\ pre&v\ marker :call signature#GotoMarker("prev")'
  endif
endif
" }}}1


call signature#Init()
