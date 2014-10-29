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
call s:Set( 'g:SignatureForceMarkPlacement',          0                                                      )
call s:Set( 'g:SignatureForceMarkerPlacement',        0                                                      )


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
command! -nargs=0 SignatureRefresh     call signature#SignRefresh('force')
command! -nargs=0 SignatureList        call signature#mark#ListLocal('buf_curr')


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Misc                                              {{{1
"
function! signature#Init()                                                                                        " {{{2
  " Description: Initialize variables

  if !exists('b:sig_marks')
    " b:sig_marks = { lnum => signs_str }
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

  call s:Set('b:sig_enabled'             , g:SignatureEnabledAtStartup)
  call s:Set('b:SignatureIncludeMarks'   , g:SignatureIncludeMarks    )
  call s:Set('b:SignatureIncludeMarkers' , g:SignatureIncludeMarkers  )
  call s:Set('b:SignatureMarkOrder'      , g:SignatureMarkOrder       )
  call s:Set('b:SignaturePrioritizeMarks', g:SignaturePrioritizeMarks )
  call s:Set('b:SignatureDeferPlacement' , g:SignatureDeferPlacement  )
  call s:Set('b:SignatureWrapJumps'      , g:SignatureWrapJumps       )
endfunction


function! signature#GetMarks(mode, scope)                                                                         " {{{2
  " Description: Takes two optional arguments - mode/line no. and scope
  "              If no arguments are specified, returns a list of [mark, line no.] pairs that are in use in the buffer
  "              or are free to be placed in which case, line no. is 0
  "
  " Arguments: mode  = 'used'     : Returns list of [ [used marks, line no., buf no.] ]
  "                    'free'     : Returns list of [ free marks ]
  "            scope = 'buf_curr' : Limits scope to current buffer i.e used/free marks in current buffer
  "                    'buf_all'  : Set scope to all buffers i.e used/free marks from all buffers

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
    if (a:scope ==? 'buf_curr')
      " If it is not in use in the current buffer treat it as free
      if l:buf != l:buf_curr
        let l:line = 0
      endif
    endif
    let l:marks_list = add(l:marks_list, [i, l:line, l:buf])
  endfor

  if (a:mode ==? 'used')
    if (a:scope ==? 'buf_curr')
      call filter( l:marks_list, '(v:val[2] == l:buf_curr) && (v:val[1] > 0)' )
    else
      call filter( l:marks_list, 'v:val[1] > 0' )
    endif
  else
    if (a:scope ==? 'buf_all')
      call filter( l:marks_list, 'v:val[1] == 0' )
    else
      call filter( l:marks_list, '(v:val[1] == 0) || (v:val[2] != l:buf_curr)' )
    endif
    call map( filter( l:marks_list, 'v:val[1] == 0' ), 'v:val[0]' )
  endif

  return l:marks_list
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

  for i in signature#GetMarks('free', 'buf_curr')
    " ... remove it
    call signature#ToggleSign( i, "remove", 0 )
  endfor

  " Add signs for marks ...
  for j in signature#GetMarks('used', 'buf_curr')
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


function! s:CreateMap(key, value, map)                                                                            " {{{2
  if (!has_key(s:SignatureMap, a:key))
    let s:SignatureMap[a:key] = a:value
  endif
  if (s:SignatureMap[a:key] != "")
    execute 'nnoremap <silent> <unique> ' . s:SignatureMap[a:key] . ' ' . ':<C-U>call signature#' . a:map . '<CR>'
  endif
endfunction

function! signature#CreateMaps()                                                                                  " {{{2
  " We create separate mappings for PlaceNextMark, mark#Purge('all') and PurgeMarkers instead of combining it with Leader/Input
  " as if the user chooses to use some weird key like <BS> or <CR> for any of these 3, we need to be able to identify it.
  " Eg. the nr2char(getchar()) will fail if the user presses a <BS>
  let s:SignatureMap = (exists('g:SignatureMap') ? copy(g:SignatureMap) : {})
  call s:CreateMap('Leader'           , "m"                              , 'Input()'                              )
  call s:CreateMap('PlaceNextMark'    , s:SignatureMap.Leader . ","      , 'mark#Toggle("next")'                  )
  call s:CreateMap('ToggleMarkAtLine' , s:SignatureMap.Leader . "."      , 'mark#ToggleAtLine()'                  )
  call s:CreateMap('PurgeMarksAtLine' , s:SignatureMap.Leader . "-"      , 'mark#Purge("line")'                   )
  call s:CreateMap('PurgeMarks'       , s:SignatureMap.Leader . "<Space>", 'mark#Purge("all")'                    )
  call s:CreateMap('PurgeMarkers'     , s:SignatureMap.Leader . "<BS>"   , 'marker#Purge()'                       )
  call s:CreateMap('DeleteMark'       , "dm"                             , 'mark#Remove()'                        )
  call s:CreateMap('GotoNextLineAlpha', "']"                             , 'mark#Goto( "next", "line", "alpha" )' )
  call s:CreateMap('GotoPrevLineAlpha', "'["                             , 'mark#Goto( "prev", "line", "alpha" )' )
  call s:CreateMap('GotoNextSpotAlpha', "`]"                             , 'mark#Goto( "next", "spot", "alpha" )' )
  call s:CreateMap('GotoPrevSpotAlpha', "`["                             , 'mark#Goto( "prev", "spot", "alpha" )' )
  call s:CreateMap('GotoNextLineByPos', "]'"                             , 'mark#Goto( "next", "line", "pos" )'   )
  call s:CreateMap('GotoPrevLineByPos', "['"                             , 'mark#Goto( "prev", "line", "pos" )'   )
  call s:CreateMap('GotoNextSpotByPos', "]`"                             , 'mark#Goto( "next", "spot", "pos" )'   )
  call s:CreateMap('GotoPrevSpotByPos', "[`"                             , 'mark#Goto( "prev", "spot", "pos" )'   )
  call s:CreateMap('GotoNextMarker'   , "]-"                             , 'marker#Goto( "next", "same" )'        )
  call s:CreateMap('GotoPrevMarker'   , "[-"                             , 'marker#Goto( "prev", "same" )'        )
  call s:CreateMap('GotoNextMarkerAny', "]="                             , 'marker#Goto( "next", "any" )'         )
  call s:CreateMap('GotoPrevMarkerAny', "[="                             , 'marker#Goto( "prev", "any" )'         )
  call s:CreateMap('ListLocalMarks'   , "'?"                             , 'mark#List("buf_curr")'                )
endfunction
call signature#CreateMaps()
" }}}1
