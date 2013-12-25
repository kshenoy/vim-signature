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
command! -nargs=0 SignatureRefresh     call signature#SignRefresh(1)



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Create Maps                {{{1
"
" We create separate mappings for PlaceNextMark, PurgeMarks and PurgeMarkers instead of combining it with Leader/Input
" as if the user chooses to use some weird key like <BS> or <CR> for any of these 3, we need to be able to identify it.
" Eg. the nr2char(getchar()) will fail if the user presses a <BS>
if !exists ('g:SignatureMap'                     ) | let g:SignatureMap                      = {}        | endif
if !has_key( g:SignatureMap, 'Leader'            ) | let g:SignatureMap['Leader'           ] = "m"       | endif
if !has_key( g:SignatureMap, 'PlaceNextMark'     ) | let g:SignatureMap['PlaceNextMark'    ] = ","       | endif
if !has_key( g:SignatureMap, 'PurgeMarks'        ) | let g:SignatureMap['PurgeMarks'       ] = "<Space>" | endif
if !has_key( g:SignatureMap, 'PurgeMarkers'      ) | let g:SignatureMap['PurgeMarkers'     ] = "<BS>"    | endif
if !has_key( g:SignatureMap, 'GotoNextLineAlpha' ) | let g:SignatureMap['GotoNextLineAlpha'] = "']"      | endif
if !has_key( g:SignatureMap, 'GotoPrevLineAlpha' ) | let g:SignatureMap['GotoPrevLineAlpha'] = "'["      | endif
if !has_key( g:SignatureMap, 'GotoNextSpotAlpha' ) | let g:SignatureMap['GotoNextSpotAlpha'] = "`]"      | endif
if !has_key( g:SignatureMap, 'GotoPrevSpotAlpha' ) | let g:SignatureMap['GotoPrevSpotAlpha'] = "`["      | endif
if !has_key( g:SignatureMap, 'GotoNextLineByPos' ) | let g:SignatureMap['GotoNextLineByPos'] = "]'"      | endif
if !has_key( g:SignatureMap, 'GotoPrevLineByPos' ) | let g:SignatureMap['GotoPrevLineByPos'] = "['"      | endif
if !has_key( g:SignatureMap, 'GotoNextSpotByPos' ) | let g:SignatureMap['GotoNextSpotByPos'] = "]`"      | endif
if !has_key( g:SignatureMap, 'GotoPrevSpotByPos' ) | let g:SignatureMap['GotoPrevSpotByPos'] = "[`"      | endif
if !has_key( g:SignatureMap, 'GotoNextMarker'    ) | let g:SignatureMap['GotoNextMarker'   ] = "]-"      | endif
if !has_key( g:SignatureMap, 'GotoPrevMarker'    ) | let g:SignatureMap['GotoPrevMarker'   ] = "[-"      | endif
if !has_key( g:SignatureMap, 'GotoNextMarkerAny' ) | let g:SignatureMap['GotoNextMarkerAny'] = "]="      | endif
if !has_key( g:SignatureMap, 'GotoPrevMarkerAny' ) | let g:SignatureMap['GotoPrevMarkerAny'] = "[="      | endif

if g:SignatureMap['Leader'] != ""
  execute 'nmap <silent> <unique> ' . g:SignatureMap['Leader'] . ' :call signature#Input()<CR>'
endif

if g:SignatureMap['GotoNextLineAlpha'] != ""
  execute 'nmap <silent> <unique> ' . g:SignatureMap['GotoNextLineAlpha'] . ' :call signature#GotoMark( "next", "line", "alpha" )<CR>'
endif

if g:SignatureMap['GotoPrevLineAlpha'] != ""
  execute 'nmap <silent> <unique> ' . g:SignatureMap['GotoPrevLineAlpha'] . ' :call signature#GotoMark( "prev", "line", "alpha" )<CR>'
endif

if g:SignatureMap['GotoNextSpotAlpha'] != ""
  execute 'nmap <silent> <unique> ' . g:SignatureMap['GotoNextSpotAlpha'] . ' :call signature#GotoMark( "next", "spot", "alpha" )<CR>'
endif

if g:SignatureMap['GotoPrevSpotAlpha'] != ""
  execute 'nmap <silent> <unique> ' . g:SignatureMap['GotoPrevSpotAlpha'] . ' :call signature#GotoMark( "prev", "spot", "alpha" )<CR>'
endif

if g:SignatureMap['GotoNextLineByPos'] != ""
  execute 'nmap <silent> <unique> ' . g:SignatureMap['GotoNextLineByPos'] . ' :call signature#GotoMark( "next", "line", "pos" )<CR>'
endif

if g:SignatureMap['GotoPrevLineByPos'] != ""
  execute 'nmap <silent> <unique> ' . g:SignatureMap['GotoPrevLineByPos'] . ' :call signature#GotoMark( "prev", "line", "pos" )<CR>'
endif

if g:SignatureMap['GotoNextSpotByPos'] != ""
  execute 'nmap <silent> <unique> ' . g:SignatureMap['GotoNextSpotByPos'] . ' :call signature#GotoMark( "next", "spot", "pos" )<CR>'
endif

if g:SignatureMap['GotoPrevSpotByPos'] != ""
  execute 'nmap <silent> <unique> ' . g:SignatureMap['GotoPrevSpotByPos'] . ' :call signature#GotoMark( "prev", "spot", "pos" )<CR>'
endif

if g:SignatureMap['GotoNextMarker'] != ""
  execute 'nmap <silent> <unique> ' . g:SignatureMap['GotoNextMarker'] . ' :call signature#GotoMarker( "next", "same" )<CR>'
endif

if g:SignatureMap['GotoPrevMarker'] != ""
  execute 'nmap <silent> <unique> ' . g:SignatureMap['GotoPrevMarker'] . ' :call signature#GotoMarker( "prev", "same" )<CR>'
endif

if g:SignatureMap['GotoNextMarkerAny'] != ""
  execute 'nmap <silent> <unique> ' . g:SignatureMap['GotoNextMarkerAny'] . ' :call signature#GotoMarker( "next", "any" )<CR>'
endif

if g:SignatureMap['GotoPrevMarkerAny'] != ""
  execute 'nmap <silent> <unique> ' . g:SignatureMap['GotoPrevMarkerAny'] . ' :call signature#GotoMarker( "prev", "any" )<CR>'
endif



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Create Menu                {{{1
"
if ( g:SignatureMenu != 0 ) && has('gui_running')

  if g:SignatureMap['PlaceNextMark'] != ""
    execute 'menu  <silent> ' . g:SignatureMenu . '.Pl&ace\ next\ mark<Tab>' . g:SignatureMap['Leader'] . g:SignatureMap['PlaceNextMark'] . ' :call signature#ToggleMark(",")<CR>'
  else
    execute 'menu  <silent> ' . g:SignatureMenu . '.Pl&ace\ next\ mark :call signature#ToggleMark(",")<CR>'
  endif

  if g:SignatureMap['PurgeMarks'] != ""
    execute 'menu  <silent> ' . g:SignatureMenu . '.Re&move\ all\ marks\ \ \ \ <Tab>' . g:SignatureMap['Leader'] . g:SignatureMap['PurgeMarks'] ' :call signature#PurgeMarks()<CR>'
  else
    execute 'menu  <silent> ' . g:SignatureMenu . '.Re&move\ all\ marks :call signature#PurgeMarks()<CR>'
  endif

  execute 'amenu <silent> ' . g:SignatureMenu . '.-s1- :'

  if g:SignatureMap['GotoNextSpotByPos'] != ""
    execute 'menu  <silent> ' . g:SignatureMenu . '.Goto\ &next\ mark\ (pos)<Tab>' . g:SignatureMap['GotoNextSpotByPos'] . ' :call signature#GotoMark( "next", "spot", "pos" )'
  else
    execute 'menu  <silent> ' . g:SignatureMenu . '.Goto\ &next\ mark\ (pos) :call signature#GotoMark( "next", "spot", "pos" )'
  endif

  if g:SignatureMap['PrevSpotByPos'] != ""
    execute 'menu  <silent> ' . g:SignatureMenu . '.Goto\ p&rev\ mark\ (pos)<Tab>' . g:SignatureMap['GotoPrevSpotByPos'] . ' :call signature#GotoMark( "prev", "spot", "pos" )'
  else
    execute 'menu  <silent> ' . g:SignatureMenu . '.Goto\ p&rev\ mark\ (pos) :call signature#GotoMark( "prev", "spot", "pos" )'
  endif

  if g:SignatureMap['NextSpotByAlpha'] != ""
    execute 'menu  <silent> ' . g:SignatureMenu . '.Goto\ next\ mark\ (a&lpha)<Tab>' . g:SignatureMap['GotoNextSpotByAlpha'] . ' :call signature#GotoMark( "next", "spot", "alpha" )'
  else
    execute 'menu  <silent> ' . g:SignatureMenu . '.Goto\ next\ mark\ (a&lpha) :call signature#GotoMark( "next", "spot", "alpha" )'
  endif

  if g:SignatureMap['PrevSpotByAlpha'] != ""
    execute 'menu  <silent> ' . g:SignatureMenu . '.Goto\ prev\ mark\ (alp&ha)<Tab>' . g:SignatureMap['GotoPrevSpotByAlpha'] . ' :call signature#GotoMark( "prev", "spot", "alpha" )'
  else
    execute 'menu  <silent> ' . g:SignatureMenu . '.Goto\ prev\ mark\ (alp&ha)<Tab> :call signature#GotoMark( "prev", "spot", "alpha" )'
  endif

  execute 'amenu <silent> ' . g:SignatureMenu . '.-s2- :'

  if g:SignatureMap['GotoNextMarker'] != ""
    execute 'menu  <silent> ' . g:SignatureMenu . '.Goto\ nex&t\ marker<Tab>' . g:SignatureMap['GotoNextMarker'] . ' :call signature#GotoMarker( "next", "same" )'
  else
    execute 'menu  <silent> ' . g:SignatureMenu . '.Goto\ nex&t\ marker :call signature#GotoMarker( "next", "same" )'
  endif

  if g:SignatureMap['GotoPrevMarker'] != ""
    execute 'menu  <silent> ' . g:SignatureMenu . '.Goto\ pre&v\ marker<Tab>' . g:SignatureMap['GotoPrevMarker'] . ' :call signature#GotoMarker( "prev", "same" )'
  else
    execute 'menu  <silent> ' . g:SignatureMenu . '.Goto\ pre&v\ marker :call signature#GotoMarker( "prev", "same" )'
  endif

  if g:SignatureMap['GotoNextMarkerAny'] != ""
    execute 'menu  <silent> ' . g:SignatureMenu . '.Goto\ nex&t\ marker\ (any)<Tab>' . g:SignatureMap['GotoNextMarkerAny'] . ' :call signature#GotoMarker( "next", "any" )'
  else
    execute 'menu  <silent> ' . g:SignatureMenu . '.Goto\ nex&t\ marker\ (any) :call signature#GotoMarker( "next", "any" )'
  endif

  if g:SignatureMap['GotoPrevMarkerAny'] != ""
    execute 'menu  <silent> ' . g:SignatureMenu . '.Goto\ pre&v\ marker\ (any)<Tab>' . g:SignatureMap['GotoPrevMarkerAny'] . ' :call signature#GotoMarker( "prev", "any" )'
  else
    execute 'menu  <silent> ' . g:SignatureMenu . '.Goto\ pre&v\ marker\ (any) :call signature#GotoMarker( "prev", "any" )'
  endif

  execute 'menu  <silent> ' . g:SignatureMenu . '.Rem&ove\ all\ markers<Tab>' . g:SignatureMap['Leader'] . g:SignatureMap['PurgeMarkers'] . ' :call signature#PurgeMarkers()<CR>'
endif
" }}}1
