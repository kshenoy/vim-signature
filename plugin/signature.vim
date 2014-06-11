" vim-signature is a plugin to toggle, display and navigate marks.
"
" Maintainer:
" Kartik Shenoy
"
" vim: fdm=marker:et:ts=4:sw=2:sts=2
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Exit if the signs feature is not available or if the app has already been loaded (or "compatible" mode set)
if !has('signs') || &cp
  finish
endif
if exists("g:loaded_Signature")
  finish
endif
let g:loaded_Signature = "3"


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Global variables                                                                                                 {{{1
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
  let g:SignatureDeleteConfirmation = 0
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


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Commands and autocmds                                                                                            {{{1
"
if has('autocmd')
  augroup sig_autocmds
    autocmd!
    autocmd BufEnter,CmdwinEnter * call signature#SignRefresh()
    autocmd CursorHold * if g:SignaturePeriodicRefresh | call signature#SignRefresh() | endif
  augroup END
endif

command! -nargs=0 SignatureToggleSigns call signature#Toggle()
command! -nargs=0 SignatureRefresh     call signature#SignRefresh( "force" )
command! -nargs=0 SignatureList        call signature#ListLocalMarks()


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Misc                                              {{{1
"
function! signature#Init()                                                                                        " {{{2
  " Description: Initialize variables

  if !exists('b:sig_marks')
    " b:sig_marks   = { lnum => signs_str }
    let b:sig_marks = {}
  endif
  if !exists('b:sig_markers')
    " b:sig_markers = { lnum => marker }
    let b:sig_markers = {}
  endif
  if !exists('b:sig_enabled')
    let b:sig_enabled = g:SignatureEnabledAtStartup
  endif

  if !exists('b:SignatureIncludeMarks'   ) | let b:SignatureIncludeMarks    = g:SignatureIncludeMarks    | endif
  if !exists('b:SignatureIncludeMarkers' ) | let b:SignatureIncludeMarkers  = g:SignatureIncludeMarkers  | endif
  if !exists('b:SignatureMarkOrder'      ) | let b:SignatureMarkOrder       = g:SignatureMarkOrder       | endif
  if !exists('b:SignaturePrioritizeMarks') | let b:SignaturePrioritizeMarks = g:SignaturePrioritizeMarks | endif
  if !exists('b:SignatureDeferPlacement' ) | let b:SignatureDeferPlacement  = g:SignatureDeferPlacement  | endif
  if !exists('b:SignatureWrapJumps'      ) | let b:SignatureWrapJumps       = g:SignatureWrapJumps       | endif
endfunction


function! signature#MarksList(...)                                                                                        " {{{2
  " Description: Takes two optional arguments - mode/line no. and scope
  "              If no arguments are specified, returns a list of [mark, line no.] pairs that are in use in the buffer
  "              or are free to be placed in which case, line no. is 0
  "
  " Arguments: a:1 (mode)  = 'used' : Returns list of [ [used marks, line no., buf no.] ]
  "                          'free' : Returns list of [ free marks ]
  "                          <lnum> : Returns list of used marks on current line.
  "            a:2 (scope) = 'b'    : Limits scope to current buffer i.e used/free marks in current buffer
  "                          'g'    : Set scope to global i.e used/free marks from all buffers

  let l:marks_list = []

  " Add local marks first
  for i in filter( split( b:SignatureIncludeMarks, '\zs' ), 'v:val =~# "[a-z]"' )
    let l:marks_list = add(l:marks_list, [i, line("'" . i), bufnr('%')])
  endfor

  " Add global (uppercase) marks to list
  for i in filter( split( b:SignatureIncludeMarks, '\zs' ), 'v:val =~# "[A-Z]"' )
    let [ l:buf, l:line, l:col, l:off ] = getpos( "'" . i )
    if ( a:0 > 1) && ( a:2 ==? "b" )
      " If it is not in use in the current buffer treat it as free
      if l:buf != bufnr('%')
        let l:line = 0
      endif
    endif
    let l:marks_list = add(l:marks_list, [i, l:line, l:buf])
  endfor

  if ( a:0 == 0 )
    return l:marks_list
  elseif ( a:1 ==? "used" )
    return filter( l:marks_list, 'v:val[1] > 0' )
  elseif ( a:1 ==? "free" )
    return map( filter( l:marks_list, 'v:val[1] == 0' ), 'v:val[0]' )
  elseif ( a:1 > 0 ) && ( a:1 < line('$'))
    return map( filter( l:marks_list, 'v:val[1] == ' . a:1 ), 'v:val[0]' )
  endif
endfunction


function! signature#ToggleSign( sign, mode, lnum )        " {{{2
  " Description: Enable/Disable/Toggle signs for marks/markers on the specified line number, depending on value of mode
  " Arguments:
  "   sign : The mark/marker whose sign is to be placed/removed/toggled
  "   mode : 'remove'
  "        : 'place'
  "   lnum : Line number on/from which the sign is to be placed/removed
  "          If mode = "remove" and line number is 0, the 'sign' is removed from all lines

  "echom "DEBUG: sign = " . a:sign . ",  mode = " . a:mode . ",  lnum = " . a:lnum

  " If Signature is not enabled, return
  if !b:sig_enabled | return | endif

  " FIXME: Highly inefficient. Needs work
  " Place sign only if there are no signs from other plugins (eg. syntastic)
  "let l:present_signs = signature#SignInfo(1)
  "if b:SignatureDeferPlacement && has_key( l:present_signs, a:lnum ) && l:present_signs[a:lnum]['name'] !~# '^sig_Sign_'
    "return
  "endif

  let l:lnum = a:lnum
  let l:id   = ( winbufnr(0) + 1 ) * l:lnum

  " Toggle sign for markers                         {{{3
  if stridx( b:SignatureIncludeMarkers, a:sign ) >= 0

    if a:mode ==? "place"
      let b:sig_markers[l:lnum] = a:sign . get( b:sig_markers, l:lnum, "" )
    else
      let b:sig_markers[l:lnum] = substitute( b:sig_markers[l:lnum], "\\C" . escape( a:sign, '$^' ), "", "" )

      " If there are no markers on the line, delete signs on that line
      if b:sig_markers[l:lnum] == ""
        call remove( b:sig_markers, l:lnum )
      endif
    endif

  " Toggle sign for marks                           {{{3
  else
    if a:mode ==? "place"
      let b:sig_marks[l:lnum] = a:sign . get( b:sig_marks, l:lnum, "" )
    else
      " If l:lnum == 0, remove from all lines
      if l:lnum == 0
        let l:arr = keys( filter( copy(b:sig_marks), 'v:val =~# a:sign' ))
        if empty(l:arr) | return | endif
      else
        let l:arr = [l:lnum]
      endif

      for l:lnum in l:arr
        let l:id   = ( winbufnr(0) + 1 ) * l:lnum
        let b:sig_marks[l:lnum] = substitute( b:sig_marks[l:lnum], "\\C" . a:sign, "", "" )

        " If there are no marks on the line, delete signs on that line
        if b:sig_marks[l:lnum] == ""
          call remove( b:sig_marks, l:lnum )
        endif
      endfor
    endif
  endif
  "}}}3

  " Place the sign
  if ( has_key( b:sig_marks, l:lnum ) && ( b:SignaturePrioritizeMarks || !has_key( b:sig_markers, l:lnum )))
    let l:str = substitute( b:SignatureMarkOrder, "\m", strpart( b:sig_marks[l:lnum], 0, 1 ), "" )
    let l:str = substitute( l:str,                "\p", strpart( b:sig_marks[l:lnum], 1, 1 ), "" )
    execute 'sign define sig_Sign_' . l:id . ' text=' . l:str . ' texthl=' . g:SignatureMarkTextHL
  elseif has_key( b:sig_markers, l:lnum )
      let l:str = strpart( b:sig_markers[l:lnum], 0, 1 )
      execute 'sign define sig_Sign_' . l:id . ' text=' . l:str . ' texthl=' . g:SignatureMarkerTextHL
  else
    execute 'sign unplace ' . l:id
    return
  endif
  execute 'sign place ' . l:id . ' line=' . l:lnum . ' name=sig_Sign_' . l:id . ' buffer=' . winbufnr(0)
endfunction


function! signature#SignRefresh(...)              " {{{2
  " Description: Add signs for new marks/markers and remove signs for deleted marks/markers
  " Arguments: '1' to force a sign refresh

  call signature#Init()
  " If Signature is not enabled, return
  if !b:sig_enabled | return | endif

  for i in signature#MarksList( 'free', 'b' )
    " ... remove it
    call signature#ToggleSign( i, "remove", 0 )
  endfor

  " Add signs for marks ...
  for j in signature#MarksList( 'used', 'b' )
    " ... if mark is not present in our b:sig_marks list or if it is present but at the wrong line,
    " remove the old sign and add a new one
    if !has_key( b:sig_marks, j[1] ) || b:sig_marks[j[1]] !~# j[0] || a:0
      call signature#ToggleSign( j[0], "remove", 0    )
      call signature#ToggleSign( j[0], "place" , j[1] )
    endif
  endfor

  " We do not add signs for markers as SignRefresh is executed periodically and we don't have a way to determine if the
  " marker already has a sign or not
endfunction


function! s:CreateMenu()                                                                                  " {{{2
  if ( g:SignatureMenu != 0 ) && has('gui_running')
    if s:SignatureMap.PlaceNextMark != ""
      execute 'menu <silent> ' . g:SignatureMenu . '.Pl&ace\ next\ mark<Tab>' . s:SignatureMap.Leader . s:SignatureMap.PlaceNextMark . ' :call signature#ToggleMark("next")<CR>'
    else
      execute 'menu <silent> ' . g:SignatureMenu . '.Pl&ace\ next\ mark :call signature#ToggleMark("next")<CR>'
    endif
    if s:SignatureMap.PurgeMarks != ""
      execute 'menu <silent> ' . g:SignatureMenu . '.Re&move\ all\ marks\ \ \ \ <Tab>' . s:SignatureMap.Leader . s:SignatureMap.PurgeMarks ' :call signature#PurgeMarks()<CR>'
    else
      execute 'menu <silent> ' . g:SignatureMenu . '.Re&move\ all\ marks :call signature#PurgeMarks()<CR>'
    endif
    execute  'amenu <silent> ' . g:SignatureMenu . '.-s1- :'
    if s:SignatureMap.GotoNextSpotByPos != ""
      execute 'menu <silent> ' . g:SignatureMenu . '.Goto\ &next\ mark\ (pos)<Tab>' . s:SignatureMap.GotoNextSpotByPos . ' :call signature#GotoMark( "next", "spot", "pos" )'
    else
      execute 'menu <silent> ' . g:SignatureMenu . '.Goto\ &next\ mark\ (pos) :call signature#GotoMark( "next", "spot", "pos" )'
    endif
    if s:SignatureMap.PrevSpotByPos != ""
      execute 'menu <silent> ' . g:SignatureMenu . '.Goto\ p&rev\ mark\ (pos)<Tab>' . s:SignatureMap.GotoPrevSpotByPos . ' :call signature#GotoMark( "prev", "spot", "pos" )'
    else
      execute 'menu <silent> ' . g:SignatureMenu . '.Goto\ p&rev\ mark\ (pos) :call signature#GotoMark( "prev", "spot", "pos" )'
    endif
    if s:SignatureMap.NextSpotByAlpha != ""
      execute 'menu <silent> ' . g:SignatureMenu . '.Goto\ next\ mark\ (a&lpha)<Tab>' . s:SignatureMap.GotoNextSpotByAlpha . ' :call signature#GotoMark( "next", "spot", "alpha" )'
    else
      execute 'menu <silent> ' . g:SignatureMenu . '.Goto\ next\ mark\ (a&lpha) :call signature#GotoMark( "next", "spot", "alpha" )'
    endif
    if s:SignatureMap.PrevSpotByAlpha != ""
      execute 'menu <silent> ' . g:SignatureMenu . '.Goto\ prev\ mark\ (alp&ha)<Tab>' . s:SignatureMap.GotoPrevSpotByAlpha . ' :call signature#GotoMark( "prev", "spot", "alpha" )'
    else
      execute 'menu <silent> ' . g:SignatureMenu . '.Goto\ prev\ mark\ (alp&ha)<Tab> :call signature#GotoMark( "prev", "spot", "alpha" )'
    endif
    execute  'amenu <silent> ' . g:SignatureMenu . '.-s2- :'
    if s:SignatureMap.GotoNextMarker != ""
      execute 'menu <silent> ' . g:SignatureMenu . '.Goto\ nex&t\ marker<Tab>' . s:SignatureMap.GotoNextMarker . ' :call signature#GotoMarker( "next", "same" )'
    else
      execute 'menu <silent> ' . g:SignatureMenu . '.Goto\ nex&t\ marker :call signature#GotoMarker( "next", "same" )'
    endif
    if s:SignatureMap.GotoPrevMarker != ""
      execute 'menu <silent> ' . g:SignatureMenu . '.Goto\ pre&v\ marker<Tab>' . s:SignatureMap.GotoPrevMarker . ' :call signature#GotoMarker( "prev", "same" )'
    else
      execute 'menu <silent> ' . g:SignatureMenu . '.Goto\ pre&v\ marker :call signature#GotoMarker( "prev", "same" )'
    endif
    if s:SignatureMap.GotoNextMarkerAny != ""
      execute 'menu <silent> ' . g:SignatureMenu . '.Goto\ nex&t\ marker\ (any)<Tab>' . s:SignatureMap.GotoNextMarkerAny . ' :call signature#GotoMarker( "next", "any" )'
    else
      execute 'menu <silent> ' . g:SignatureMenu . '.Goto\ nex&t\ marker\ (any) :call signature#GotoMarker( "next", "any" )'
    endif
    if s:SignatureMap.GotoPrevMarkerAny != ""
      execute 'menu <silent> ' . g:SignatureMenu . '.Goto\ pre&v\ marker\ (any)<Tab>' . s:SignatureMap.GotoPrevMarkerAny . ' :call signature#GotoMarker( "prev", "any" )'
    else
      execute 'menu <silent> ' . g:SignatureMenu . '.Goto\ pre&v\ marker\ (any) :call signature#GotoMarker( "prev", "any" )'
    endif
    execute   'menu <silent> ' . g:SignatureMenu . '.Rem&ove\ all\ markers<Tab>' . s:SignatureMap.Leader . s:SignatureMap.PurgeMarkers . ' :call signature#PurgeMarkers()<CR>'
  endif
endfunction


function! signature#CreateMaps()                                                                                  " {{{2
  " We create separate mappings for PlaceNextMark, PurgeMarks and PurgeMarkers instead of combining it with Leader/Input
  " as if the user chooses to use some weird key like <BS> or <CR> for any of these 3, we need to be able to identify it.
  " Eg. the nr2char(getchar()) will fail if the user presses a <BS>
  let s:SignatureMap = ( exists('g:SignatureMap') ? copy(g:SignatureMap) : {} )
  if !has_key( s:SignatureMap, 'Leader'            ) | let s:SignatureMap.Leader             =  "m"                               | endif
  if !has_key( s:SignatureMap, 'PlaceNextMark'     ) | let s:SignatureMap.PlaceNextMark      =  s:SignatureMap.Leader . ","       | endif
  if !has_key( s:SignatureMap, 'ToggleMarkAtLine'  ) | let s:SignatureMap.ToggleMarkAtLine   =  s:SignatureMap.Leader . "."       | endif
  if !has_key( s:SignatureMap, 'PurgeMarksAtLine'  ) | let s:SignatureMap.PurgeMarksAtLine   =  s:SignatureMap.Leader . "-"       | endif
  if !has_key( s:SignatureMap, 'PurgeMarks'        ) | let s:SignatureMap.PurgeMarks         =  s:SignatureMap.Leader . "<Space>" | endif
  if !has_key( s:SignatureMap, 'PurgeMarkers'      ) | let s:SignatureMap.PurgeMarkers       =  s:SignatureMap.Leader . "<BS>"    | endif
  if !has_key( s:SignatureMap, 'GotoNextLineAlpha' ) | let s:SignatureMap.GotoNextLineAlpha  =  "']"                              | endif
  if !has_key( s:SignatureMap, 'GotoPrevLineAlpha' ) | let s:SignatureMap.GotoPrevLineAlpha  =  "'["                              | endif
  if !has_key( s:SignatureMap, 'GotoNextSpotAlpha' ) | let s:SignatureMap.GotoNextSpotAlpha  =  "`]"                              | endif
  if !has_key( s:SignatureMap, 'GotoPrevSpotAlpha' ) | let s:SignatureMap.GotoPrevSpotAlpha  =  "`["                              | endif
  if !has_key( s:SignatureMap, 'GotoNextLineByPos' ) | let s:SignatureMap.GotoNextLineByPos  =  "]'"                              | endif
  if !has_key( s:SignatureMap, 'GotoPrevLineByPos' ) | let s:SignatureMap.GotoPrevLineByPos  =  "['"                              | endif
  if !has_key( s:SignatureMap, 'GotoNextSpotByPos' ) | let s:SignatureMap.GotoNextSpotByPos  =  "]`"                              | endif
  if !has_key( s:SignatureMap, 'GotoPrevSpotByPos' ) | let s:SignatureMap.GotoPrevSpotByPos  =  "[`"                              | endif
  if !has_key( s:SignatureMap, 'GotoNextMarker'    ) | let s:SignatureMap.GotoNextMarker     =  "]-"                              | endif
  if !has_key( s:SignatureMap, 'GotoPrevMarker'    ) | let s:SignatureMap.GotoPrevMarker     =  "[-"                              | endif
  if !has_key( s:SignatureMap, 'GotoNextMarkerAny' ) | let s:SignatureMap.GotoNextMarkerAny  =  "]="                              | endif
  if !has_key( s:SignatureMap, 'GotoPrevMarkerAny' ) | let s:SignatureMap.GotoPrevMarkerAny  =  "[="                              | endif
  if !has_key( s:SignatureMap, 'ListLocalMarks   ' ) | let s:SignatureMap.ListLocalMarks     =  "'?"                              | endif

  if s:SignatureMap.Leader            != ""
    execute 'nnoremap <silent> <unique> ' . s:SignatureMap.Leader            . ' :call signature#Input()<CR>'
  endif
  if s:SignatureMap.PlaceNextMark     != ""
    execute 'nnoremap <silent> <unique> ' . s:SignatureMap.PlaceNextMark     . ' :call signature#ToggleMark("next")<CR>'
  endif
  if s:SignatureMap.ToggleMarkAtLine  != ""
    execute 'nnoremap <silent> <unique> ' . s:SignatureMap.ToggleMarkAtLine  . ' :call signature#ToggleMarkAtLine()<CR>'
  endif
  if s:SignatureMap.PurgeMarksAtLine  != ""
    execute 'nnoremap <silent> <unique> ' . s:SignatureMap.PurgeMarksAtLine  . ' :call signature#PurgeMarksAtLine()<CR>'
  endif
  if s:SignatureMap.PurgeMarks        != ""
    execute 'nnoremap <silent> <unique> ' . s:SignatureMap.PurgeMarks        . ' :call signature#PurgeMarks()<CR>'
  endif
  if s:SignatureMap.PurgeMarkers      != ""
    execute 'nnoremap <silent> <unique> ' . s:SignatureMap.PurgeMarkers      . ' :call signature#PurgeMarkers()<CR>'
  endif
  if s:SignatureMap.GotoNextLineAlpha != ""
    execute 'nnoremap <silent> <unique> ' . s:SignatureMap.GotoNextLineAlpha . ' :call signature#GotoMark( "next", "line", "alpha" )<CR>'
  endif
  if s:SignatureMap.GotoPrevLineAlpha != ""
    execute 'nnoremap <silent> <unique> ' . s:SignatureMap.GotoPrevLineAlpha . ' :call signature#GotoMark( "prev", "line", "alpha" )<CR>'
  endif
  if s:SignatureMap.GotoNextSpotAlpha != ""
    execute 'nnoremap <silent> <unique> ' . s:SignatureMap.GotoNextSpotAlpha . ' :call signature#GotoMark( "next", "spot", "alpha" )<CR>'
  endif
  if s:SignatureMap.GotoPrevSpotAlpha != ""
    execute 'nnoremap <silent> <unique> ' . s:SignatureMap.GotoPrevSpotAlpha . ' :call signature#GotoMark( "prev", "spot", "alpha" )<CR>'
  endif
  if s:SignatureMap.GotoNextLineByPos != ""
    execute 'nnoremap <silent> <unique> ' . s:SignatureMap.GotoNextLineByPos . ' :call signature#GotoMark( "next", "line", "pos" )<CR>'
  endif
  if s:SignatureMap.GotoPrevLineByPos != ""
    execute 'nnoremap <silent> <unique> ' . s:SignatureMap.GotoPrevLineByPos . ' :call signature#GotoMark( "prev", "line", "pos" )<CR>'
  endif
  if s:SignatureMap.GotoNextSpotByPos != ""
    execute 'nnoremap <silent> <unique> ' . s:SignatureMap.GotoNextSpotByPos . ' :call signature#GotoMark( "next", "spot", "pos" )<CR>'
  endif
  if s:SignatureMap.GotoPrevSpotByPos != ""
    execute 'nnoremap <silent> <unique> ' . s:SignatureMap.GotoPrevSpotByPos . ' :call signature#GotoMark( "prev", "spot", "pos" )<CR>'
  endif
  if s:SignatureMap.GotoNextMarker    != ""
    execute 'nnoremap <silent> <unique> ' . s:SignatureMap.GotoNextMarker    . ' :call signature#GotoMarker( "next", "same" )<CR>'
  endif
  if s:SignatureMap.GotoPrevMarker    != ""
    execute 'nnoremap <silent> <unique> ' . s:SignatureMap.GotoPrevMarker    . ' :call signature#GotoMarker( "prev", "same" )<CR>'
  endif
  if s:SignatureMap.GotoNextMarkerAny != ""
    execute 'nnoremap <silent> <unique> ' . s:SignatureMap.GotoNextMarkerAny . ' :call signature#GotoMarker( "next", "any" )<CR>'
  endif
  if s:SignatureMap.GotoPrevMarkerAny != ""
    execute 'nnoremap <silent> <unique> ' . s:SignatureMap.GotoPrevMarkerAny . ' :call signature#GotoMarker( "prev", "any" )<CR>'
  endif
  if s:SignatureMap.ListLocalMarks    != ""
    execute 'nnoremap <silent> <unique> ' . s:SignatureMap.ListLocalMarks    . ' :call signature#ListLocalMarks()<CR>'
  endif

  " Update the menu
  call s:CreateMenu()
endfunction
call signature#CreateMaps()
" }}}1
