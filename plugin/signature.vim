" vim-signature is a plugin to toggle, display and navigate marks.
"
" Maintainer:
" Kartik Shenoy
"
" vim: fdm=marker:et:ts=4:sw=2:sts=2
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Exit if the signs feature is not available or if the app has already been loaded (or "compatible" mode set)
if !has('signs') || &cp
  finish
endif
if exists("g:loaded_Signature")
  finish
endif
let g:loaded_Signature = "3"


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Global variables           {{{1
"
if !exists( 'g:SignaturePrioritizeMarks' )
  let g:SignaturePrioritizeMarks = 1
endif
if !exists( 'g:SignatureIncludeMarks' )
  let g:SignatureIncludeMarks = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
endif
if !exists( 'g:SignatureIncludeMarkers' )
  let g:SignatureIncludeMarkers = ")!@#$%^&*("
endif
if !exists( 'g:SignatureMarkTextHL' )
  let g:SignatureMarkTextHL = "Exception"
endif
if !exists( 'g:SignatureMarkerTextHL' )
  let g:SignatureMarkerTextHL = "WarningMsg"
endif
if !exists( 'g:SignatureWrapJumps' )
  let g:SignatureWrapJumps = 1
endif
if !exists( 'g:SignatureMarkOrder' )
  let g:SignatureMarkOrder = "\p\m"
endif
if !exists( 'g:SignaturePurgeConfirmation' )
  let g:SignaturePurgeConfirmation = 0
endif
if !exists( 'g:SignatureMenu' )
  let g:SignatureMenu = 'P&lugin.&Signature'
endif
if !exists( 'g:SignaturePeriodicRefresh' )
  let g:SignaturePeriodicRefresh = 1
endif
if !exists( 'g:SignatureEnabledAtStartup' )
  let g:SignatureEnabledAtStartup = 1
endif
if !exists( 'g:SignatureDeferPlacement' )
  let g:SignatureDeferPlacement = 1
endif
if !exists( 'g:SignatureUnconditionallyRecycleMarks' )
  let g:SignatureUnconditionallyRecycleMarks = 0
endif
if !exists( 'g:SignatureErrorIfNoAvailableMarks' )
  let g:SignatureErrorIfNoAvailableMarks = 1
endif



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Commands and autocmds      {{{1
"
if has('autocmd')
  augroup sig_autocmds
    autocmd!
    autocmd BufEnter   * call signature#SignRefresh()
    autocmd CursorHold * if g:SignaturePeriodicRefresh | call signature#SignRefresh() | endif
  augroup END
endif

command! -nargs=0 SignatureToggleSigns call signature#Toggle()
command! -nargs=0 SignatureRefresh     call signature#SignRefresh( "force" )
command! -nargs=0 SignatureList        call signature#ListLocalMarks()

call signature#CreateMaps()
call signature#CreateMenu()
" }}}1
