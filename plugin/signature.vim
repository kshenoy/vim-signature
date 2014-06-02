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
if !exists( 'g:SignatureDeleteConfirmation' )
  let g:SignatureDeleteConfirmation = 1
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

function! signature#CreateMaps()                                                                                  " {{{2
  " We create separate mappings for PlaceNextMark, PurgeMarks and PurgeMarkers instead of combining it with Leader/Input
  " as if the user chooses to use some weird key like <BS> or <CR> for any of these 3, we need to be able to identify it.
  " Eg. the nr2char(getchar()) will fail if the user presses a <BS>
  unlockvar g:SignatureMapInt
  let g:SignatureMapInt = ( exists('g:SignatureMap') ? copy(g:SignatureMap) : {} )
  if !has_key( g:SignatureMapInt, 'Leader'            ) | let g:SignatureMapInt.Leader             =  "m"       | endif
  if !has_key( g:SignatureMapInt, 'PlaceNextMark'     ) | let g:SignatureMapInt.PlaceNextMark      =  ","       | endif
  if !has_key( g:SignatureMapInt, 'ToggleMarkAtLine'  ) | let g:SignatureMapInt.ToggleMarkAtLine   =  "."       | endif
  if !has_key( g:SignatureMapInt, 'PurgeMarksAtLine'  ) | let g:SignatureMapInt.PurgeMarksAtLine   =  "-"       | endif
  if !has_key( g:SignatureMapInt, 'PurgeMarks'        ) | let g:SignatureMapInt.PurgeMarks         =  "<Space>" | endif
  if !has_key( g:SignatureMapInt, 'PurgeMarkers'      ) | let g:SignatureMapInt.PurgeMarkers       =  "<BS>"    | endif
  if !has_key( g:SignatureMapInt, 'GotoNextLineAlpha' ) | let g:SignatureMapInt.GotoNextLineAlpha  =  "']"      | endif
  if !has_key( g:SignatureMapInt, 'GotoPrevLineAlpha' ) | let g:SignatureMapInt.GotoPrevLineAlpha  =  "'["      | endif
  if !has_key( g:SignatureMapInt, 'GotoNextSpotAlpha' ) | let g:SignatureMapInt.GotoNextSpotAlpha  =  "`]"      | endif
  if !has_key( g:SignatureMapInt, 'GotoPrevSpotAlpha' ) | let g:SignatureMapInt.GotoPrevSpotAlpha  =  "`["      | endif
  if !has_key( g:SignatureMapInt, 'GotoNextLineByPos' ) | let g:SignatureMapInt.GotoNextLineByPos  =  "]'"      | endif
  if !has_key( g:SignatureMapInt, 'GotoPrevLineByPos' ) | let g:SignatureMapInt.GotoPrevLineByPos  =  "['"      | endif
  if !has_key( g:SignatureMapInt, 'GotoNextSpotByPos' ) | let g:SignatureMapInt.GotoNextSpotByPos  =  "]`"      | endif
  if !has_key( g:SignatureMapInt, 'GotoPrevSpotByPos' ) | let g:SignatureMapInt.GotoPrevSpotByPos  =  "[`"      | endif
  if !has_key( g:SignatureMapInt, 'GotoNextMarker'    ) | let g:SignatureMapInt.GotoNextMarker     =  "]-"      | endif
  if !has_key( g:SignatureMapInt, 'GotoPrevMarker'    ) | let g:SignatureMapInt.GotoPrevMarker     =  "[-"      | endif
  if !has_key( g:SignatureMapInt, 'GotoNextMarkerAny' ) | let g:SignatureMapInt.GotoNextMarkerAny  =  "]="      | endif
  if !has_key( g:SignatureMapInt, 'GotoPrevMarkerAny' ) | let g:SignatureMapInt.GotoPrevMarkerAny  =  "[="      | endif
  if !has_key( g:SignatureMapInt, 'ListLocalMarks   ' ) | let g:SignatureMapInt.ListLocalMarks     =  "'?"      | endif
  lockvar g:SignatureMapInt

  if g:SignatureMapInt.Leader != ""
    execute 'nnoremap <silent> <unique> ' . g:SignatureMapInt.Leader . ' :call signature#Input()<CR>'
  endif
  if g:SignatureMapInt.GotoNextLineAlpha != ""
    execute 'nnoremap <silent> <unique> ' . g:SignatureMapInt.GotoNextLineAlpha . ' :call signature#GotoMark( "next", "line", "alpha" )<CR>'
  endif
  if g:SignatureMapInt.GotoPrevLineAlpha != ""
    execute 'nnoremap <silent> <unique> ' . g:SignatureMapInt.GotoPrevLineAlpha . ' :call signature#GotoMark( "prev", "line", "alpha" )<CR>'
  endif
  if g:SignatureMapInt.GotoNextSpotAlpha != ""
    execute 'nnoremap <silent> <unique> ' . g:SignatureMapInt.GotoNextSpotAlpha . ' :call signature#GotoMark( "next", "spot", "alpha" )<CR>'
  endif
  if g:SignatureMapInt.GotoPrevSpotAlpha != ""
    execute 'nnoremap <silent> <unique> ' . g:SignatureMapInt.GotoPrevSpotAlpha . ' :call signature#GotoMark( "prev", "spot", "alpha" )<CR>'
  endif
  if g:SignatureMapInt.GotoNextLineByPos != ""
    execute 'nnoremap <silent> <unique> ' . g:SignatureMapInt.GotoNextLineByPos . ' :call signature#GotoMark( "next", "line", "pos" )<CR>'
  endif
  if g:SignatureMapInt.GotoPrevLineByPos != ""
    execute 'nnoremap <silent> <unique> ' . g:SignatureMapInt.GotoPrevLineByPos . ' :call signature#GotoMark( "prev", "line", "pos" )<CR>'
  endif
  if g:SignatureMapInt.GotoNextSpotByPos != ""
    execute 'nnoremap <silent> <unique> ' . g:SignatureMapInt.GotoNextSpotByPos . ' :call signature#GotoMark( "next", "spot", "pos" )<CR>'
  endif
  if g:SignatureMapInt.GotoPrevSpotByPos != ""
    execute 'nnoremap <silent> <unique> ' . g:SignatureMapInt.GotoPrevSpotByPos . ' :call signature#GotoMark( "prev", "spot", "pos" )<CR>'
  endif
  if g:SignatureMapInt.GotoNextMarker != ""
    execute 'nnoremap <silent> <unique> ' . g:SignatureMapInt.GotoNextMarker . ' :call signature#GotoMarker( "next", "same" )<CR>'
  endif
  if g:SignatureMapInt.GotoPrevMarker != ""
    execute 'nnoremap <silent> <unique> ' . g:SignatureMapInt.GotoPrevMarker . ' :call signature#GotoMarker( "prev", "same" )<CR>'
  endif
  if g:SignatureMapInt.GotoNextMarkerAny != ""
    execute 'nnoremap <silent> <unique> ' . g:SignatureMapInt.GotoNextMarkerAny . ' :call signature#GotoMarker( "next", "any" )<CR>'
  endif
  if g:SignatureMapInt.GotoPrevMarkerAny != ""
    execute 'nnoremap <silent> <unique> ' . g:SignatureMapInt.GotoPrevMarkerAny . ' :call signature#GotoMarker( "prev", "any" )<CR>'
  endif
  if g:SignatureMapInt.ListLocalMarks != ""
    execute 'nnoremap <silent> <unique> ' . g:SignatureMapInt.ListLocalMarks . ' :call signature#ListLocalMarks()<CR>'
  endif
endfunction
call signature#CreateMaps()

function! signature#CreateMenu()                                                                                  " {{{2
  if ( g:SignatureMenu != 0 ) && has('gui_running')
    if g:SignatureMapInt.PlaceNextMark != ""
      execute 'menu <silent> ' . g:SignatureMenu . '.Pl&ace\ next\ mark<Tab>' . g:SignatureMapInt.Leader . g:SignatureMapInt.PlaceNextMark . ' :call signature#ToggleMark(",")<CR>'
    else
      execute 'menu <silent> ' . g:SignatureMenu . '.Pl&ace\ next\ mark :call signature#ToggleMark(",")<CR>'
    endif
    if g:SignatureMapInt.PurgeMarks != ""
      execute 'menu <silent> ' . g:SignatureMenu . '.Re&move\ all\ marks\ \ \ \ <Tab>' . g:SignatureMapInt.Leader . g:SignatureMapInt.PurgeMarks ' :call signature#PurgeMarks()<CR>'
    else
      execute 'menu <silent> ' . g:SignatureMenu . '.Re&move\ all\ marks :call signature#PurgeMarks()<CR>'
    endif
    execute  'amenu <silent> ' . g:SignatureMenu . '.-s1- :'
    if g:SignatureMapInt.GotoNextSpotByPos != ""
      execute 'menu <silent> ' . g:SignatureMenu . '.Goto\ &next\ mark\ (pos)<Tab>' . g:SignatureMapInt.GotoNextSpotByPos . ' :call signature#GotoMark( "next", "spot", "pos" )'
    else
      execute 'menu <silent> ' . g:SignatureMenu . '.Goto\ &next\ mark\ (pos) :call signature#GotoMark( "next", "spot", "pos" )'
    endif
    if g:SignatureMapInt.PrevSpotByPos != ""
      execute 'menu <silent> ' . g:SignatureMenu . '.Goto\ p&rev\ mark\ (pos)<Tab>' . g:SignatureMapInt.GotoPrevSpotByPos . ' :call signature#GotoMark( "prev", "spot", "pos" )'
    else
      execute 'menu <silent> ' . g:SignatureMenu . '.Goto\ p&rev\ mark\ (pos) :call signature#GotoMark( "prev", "spot", "pos" )'
    endif
    if g:SignatureMapInt.NextSpotByAlpha != ""
      execute 'menu <silent> ' . g:SignatureMenu . '.Goto\ next\ mark\ (a&lpha)<Tab>' . g:SignatureMapInt.GotoNextSpotByAlpha . ' :call signature#GotoMark( "next", "spot", "alpha" )'
    else
      execute 'menu <silent> ' . g:SignatureMenu . '.Goto\ next\ mark\ (a&lpha) :call signature#GotoMark( "next", "spot", "alpha" )'
    endif
    if g:SignatureMapInt.PrevSpotByAlpha != ""
      execute 'menu <silent> ' . g:SignatureMenu . '.Goto\ prev\ mark\ (alp&ha)<Tab>' . g:SignatureMapInt.GotoPrevSpotByAlpha . ' :call signature#GotoMark( "prev", "spot", "alpha" )'
    else
      execute 'menu <silent> ' . g:SignatureMenu . '.Goto\ prev\ mark\ (alp&ha)<Tab> :call signature#GotoMark( "prev", "spot", "alpha" )'
    endif
    execute  'amenu <silent> ' . g:SignatureMenu . '.-s2- :'
    if g:SignatureMapInt.GotoNextMarker != ""
      execute 'menu <silent> ' . g:SignatureMenu . '.Goto\ nex&t\ marker<Tab>' . g:SignatureMapInt.GotoNextMarker . ' :call signature#GotoMarker( "next", "same" )'
    else
      execute 'menu <silent> ' . g:SignatureMenu . '.Goto\ nex&t\ marker :call signature#GotoMarker( "next", "same" )'
    endif
    if g:SignatureMapInt.GotoPrevMarker != ""
      execute 'menu <silent> ' . g:SignatureMenu . '.Goto\ pre&v\ marker<Tab>' . g:SignatureMapInt.GotoPrevMarker . ' :call signature#GotoMarker( "prev", "same" )'
    else
      execute 'menu <silent> ' . g:SignatureMenu . '.Goto\ pre&v\ marker :call signature#GotoMarker( "prev", "same" )'
    endif
    if g:SignatureMapInt.GotoNextMarkerAny != ""
      execute 'menu <silent> ' . g:SignatureMenu . '.Goto\ nex&t\ marker\ (any)<Tab>' . g:SignatureMapInt.GotoNextMarkerAny . ' :call signature#GotoMarker( "next", "any" )'
    else
      execute 'menu <silent> ' . g:SignatureMenu . '.Goto\ nex&t\ marker\ (any) :call signature#GotoMarker( "next", "any" )'
    endif
    if g:SignatureMapInt.GotoPrevMarkerAny != ""
      execute 'menu <silent> ' . g:SignatureMenu . '.Goto\ pre&v\ marker\ (any)<Tab>' . g:SignatureMapInt.GotoPrevMarkerAny . ' :call signature#GotoMarker( "prev", "any" )'
    else
      execute 'menu <silent> ' . g:SignatureMenu . '.Goto\ pre&v\ marker\ (any) :call signature#GotoMarker( "prev", "any" )'
    endif
    execute   'menu <silent> ' . g:SignatureMenu . '.Rem&ove\ all\ markers<Tab>' . g:SignatureMapInt.Leader . g:SignatureMapInt.PurgeMarkers . ' :call signature#PurgeMarkers()<CR>'
  endif
endfunction
call signature#CreateMenu()
" }}}1
