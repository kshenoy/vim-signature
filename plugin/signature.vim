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
function! s:Set(var, default)
  if !exists(a:var)
    if type(a:default)
      execute 'let' a:var '=' string(a:default)
    else
      execute 'let' a:var '=' a:default
    endif
  endif
endfunction
call s:Set( 'g:SignaturePrioritizeMarks',             1                                                      )
call s:Set( 'g:SignatureIncludeMarks',                'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ' )
call s:Set( 'g:SignatureIncludeMarkers',              ')!@#$%^&*('                                           )
call s:Set( 'g:SignatureMarkTextHL',                  '"Exception"'                                          )
call s:Set( 'g:SignatureMarkerTextHL',                '"WarningMsg"'                                         )
call s:Set( 'g:SignatureWrapJumps',                   1                                                      )
call s:Set( 'g:SignatureMarkOrder',                   "\p\m"                                                 )
call s:Set( 'g:SignatureDeleteConfirmation',          0                                                      )
call s:Set( 'g:SignaturePurgeConfirmation',           0                                                      )
call s:Set( 'g:SignaturePeriodicRefresh',             1                                                      )
call s:Set( 'g:SignatureEnabledAtStartup',            1                                                      )
call s:Set( 'g:SignatureDeferPlacement',              1                                                      )
call s:Set( 'g:SignatureUnconditionallyRecycleMarks', 0                                                      )
call s:Set( 'g:SignatureErrorIfNoAvailableMarks',     1                                                      )
call s:Set( 'g:SignatureForceRemoveGlobal',           1                                                      )


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
  else
    " Lines can be removed using an external tool. Hence, we need to filter out marks placed on line numbers that are now
    " greater than the total number of lines in the file.
    let l:line_tot = line('$')
    call filter( b:sig_marks, 'v:key <= l:line_tot' )
  endif

  if !exists('b:sig_markers')
    " b:sig_markers = { lnum => marker }
    let b:sig_markers = {}
  else
    " Lines can be removed using an external tool. Hence, we need to filter out marks placed on line numbers that are now
    " greater than the total number of lines in the file.
    let l:line_tot = line('$')
    call filter( b:sig_markers, 'v:key <= l:line_tot' )
  endif

  if !exists('b:sig_enabled')
    let b:sig_enabled = g:SignatureEnabledAtStartup
  endif

  call s:Set( 'b:SignatureIncludeMarks',    g:SignatureIncludeMarks    )
  call s:Set( 'b:SignatureIncludeMarkers',  g:SignatureIncludeMarkers  )
  call s:Set( 'b:SignatureMarkOrder',       g:SignatureMarkOrder       )
  call s:Set( 'b:SignaturePrioritizeMarks', g:SignaturePrioritizeMarks )
  call s:Set( 'b:SignatureDeferPlacement',  g:SignatureDeferPlacement  )
  call s:Set( 'b:SignatureWrapJumps',       g:SignatureWrapJumps       )
endfunction


function! signature#MarksList(...)                                                                                " {{{2
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
  let l:line_tot = line('$')
  let l:buf_curr = bufnr('%')

  " Add local marks first
  for i in filter( split( b:SignatureIncludeMarks, '\zs' ), 'v:val =~# "[a-z]"' )
    let l:marks_list = add(l:marks_list, [i, line("'" .i), l:buf_curr])
  endfor

  " Add global (uppercase) marks to list
  for i in filter( split( b:SignatureIncludeMarks, '\zs' ), 'v:val =~# "[A-Z]"' )
    let [ l:buf, l:line, l:col, l:off ] = getpos( "'" . i )
    if ( a:0 > 1 ) && ( a:2 ==? "b" )
      " If it is not in use in the current buffer treat it as free
      if l:buf != l:buf_curr
        let l:line = 0
      endif
    endif
    let l:marks_list = add(l:marks_list, [i, l:line, l:buf])
  endfor

  call filter( l:marks_list, '( v:val[2] == l:buf_curr ) && ( v:val[1] <= l:line_tot )' )
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


function! signature#ToggleSignDummy( mode )                                                                       " {{{2
  " Arguments:
  "   mode : 'remove'
  "        : 'place'

  if a:mode ==? 'place'
    sign define Signature_Dummy
    " When only 1 sign is present and we delete the line that the sign is on and undo the delete,
    " ToggleSignDummy('place') is called again. To avoid placing multiple dummy signs we unplace and place it.
    execute 'sign unplace 666 buffer=' . bufnr('%')
    execute 'sign place 666 line=1 name=Signature_Dummy buffer=' . bufnr('%')
  else
    silent! execute 'sign unplace 666 buffer=' . bufnr('%')
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
  let l:id   = l:lnum * 1000 + bufnr('%')

  " Toggle sign for markers                         {{{3
  if stridx( b:SignatureIncludeMarkers, a:sign ) >= 0

    if a:mode ==? 'place'
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
        let l:id = l:lnum * 1000 + bufnr('%')
        " FIXME: Placed guard to avoid triggering issue #53
        if has_key( b:sig_marks, l:lnum )
          let b:sig_marks[l:lnum] = substitute( b:sig_marks[l:lnum], "\\C" . a:sign, "", "" )
          " If there are no marks on the line, delete signs on that line
          if b:sig_marks[l:lnum] == ""
            call remove( b:sig_marks, l:lnum )
          endif
        endif
      endfor
    endif
  endif
  "}}}3

  " Place the sign
  if ( has_key( b:sig_marks, l:lnum ) && ( b:SignaturePrioritizeMarks || !has_key( b:sig_markers, l:lnum )))
    let l:str = substitute( b:SignatureMarkOrder, "\m", strpart( b:sig_marks[l:lnum], 0, 1 ), "" )
    let l:str = substitute( l:str,                "\p", strpart( b:sig_marks[l:lnum], 1, 1 ), "" )

    " If g:SignatureMarkTextHL points to a function, call it and use its output as the highlight group.
    " If it is a string, use it directly
    let l:SignatureMarkTextHL = eval( g:SignatureMarkTextHL )
    execute 'sign define Signature_' . l:str . ' text=' . l:str . ' texthl=' . l:SignatureMarkTextHL

  elseif has_key( b:sig_markers, l:lnum )
    let l:str = strpart( b:sig_markers[l:lnum], 0, 1 )

    " If g:SignatureMarkerTextHL points to a function, call it and use its output as the highlight group.
    " If it is a string, use it directly
    let l:SignatureMarkerTextHL = eval( g:SignatureMarkerTextHL )
    execute 'sign define Signature_' . l:str . ' text=' . l:str . ' texthl=' . l:SignatureMarkerTextHL

  else
    " FIXME: Clean-up. Undefine the sign
    execute 'sign unplace ' . l:id
    return
  endif
  execute 'sign place ' . l:id . ' line=' . l:lnum . ' name=Signature_' . l:str . ' buffer=' . bufnr('%')

  " If there is only 1 mark/marker in the file, also place a dummy sign to prevent flickering of the gutter
  if len(b:sig_marks) + len(b:sig_markers) == 1
    call signature#ToggleSignDummy( 'place' )
  endif
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
endfunction
call signature#CreateMaps()
" }}}1
