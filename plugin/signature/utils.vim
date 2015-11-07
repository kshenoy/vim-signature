" vim: fdm=marker:et:ts=4:sw=2:sts=2
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! signature#utils#Set(var, default)                                                                       " {{{1
  if !exists(a:var)
    if type(a:default)
      execute 'let' a:var '=' string(a:default)
    else
      execute 'let' a:var '=' a:default
    endif
  endif
  return a:var
endfunction


function! signature#utils#NumericSort(x, y)                                                                       " {{{1
  return a:x - a:y
endfunction


function! s:Map(mode, key, map_lhs_default, map_rhs)                                                              " {{{1
  let l:map_lhs = get(g:SignatureMap, a:key, a:map_lhs_default)
  if (l:map_lhs ==? '')
    return
  endif
  if (a:mode ==? 'create')
    silent! execute 'nnoremap <silent> <unique> ' . l:map_lhs . ' ' . ':<C-U>call signature#' . a:map_rhs . '<CR>'
  elseif (a:mode ==? 'remove')
    silent! execute 'nunmap ' . l:map_lhs
  endif
endfunction

function! signature#utils#Maps(mode)                                                                              " {{{1
  " We create separate mappings for PlaceNextMark, mark#Purge('all') and PurgeMarkers instead of combining it with
  " Leader/Input as if the user chooses to use some weird key like <BS> or <CR> for any of these 3, we need to be able
  " to identify it. Eg. the nr2char(getchar()) will fail if the user presses a <BS>
  let s:SignatureMapLeader = get(g:SignatureMap, 'Leader', 'm')
  if (s:SignatureMapLeader == "")
    echoe "Signature: g:SignatureMap.Leader shouldn't be left blank"
  endif
  call s:Map(a:mode, 'Leader'           , s:SignatureMapLeader            , 'utils#Input()'                       )
  call s:Map(a:mode, 'PlaceNextMark'    , s:SignatureMapLeader . ","      , 'mark#Toggle("next")'                 )
  call s:Map(a:mode, 'ToggleMarkAtLine' , s:SignatureMapLeader . "."      , 'mark#ToggleAtLine()'                 )
  call s:Map(a:mode, 'PurgeMarksAtLine' , s:SignatureMapLeader . "-"      , 'mark#Purge("line")'                  )
  call s:Map(a:mode, 'PurgeMarks'       , s:SignatureMapLeader . "<Space>", 'mark#Purge("all")'                   )
  call s:Map(a:mode, 'PurgeMarkers'     , s:SignatureMapLeader . "<BS>"   , 'marker#Purge()'                      )
  call s:Map(a:mode, 'DeleteMark'       , "dm"                            , 'utils#Remove(v:count)'               )
  call s:Map(a:mode, 'GotoNextLineAlpha', "']"                            , 'mark#Goto("next", "line", "alpha")'  )
  call s:Map(a:mode, 'GotoPrevLineAlpha', "'["                            , 'mark#Goto("prev", "line", "alpha")'  )
  call s:Map(a:mode, 'GotoNextSpotAlpha', "`]"                            , 'mark#Goto("next", "spot", "alpha")'  )
  call s:Map(a:mode, 'GotoPrevSpotAlpha', "`["                            , 'mark#Goto("prev", "spot", "alpha")'  )
  call s:Map(a:mode, 'GotoNextLineByPos', "]'"                            , 'mark#Goto("next", "line", "pos")'    )
  call s:Map(a:mode, 'GotoPrevLineByPos', "['"                            , 'mark#Goto("prev", "line", "pos")'    )
  call s:Map(a:mode, 'GotoNextSpotByPos', "]`"                            , 'mark#Goto("next", "spot", "pos")'    )
  call s:Map(a:mode, 'GotoPrevSpotByPos', "[`"                            , 'mark#Goto("prev", "spot", "pos")'    )
  call s:Map(a:mode, 'GotoNextMarker'   , "]-"                            , 'marker#Goto("next", "same", v:count)')
  call s:Map(a:mode, 'GotoPrevMarker'   , "[-"                            , 'marker#Goto("prev", "same", v:count)')
  call s:Map(a:mode, 'GotoNextMarkerAny', "]="                            , 'marker#Goto("next", "any",  v:count)')
  call s:Map(a:mode, 'GotoPrevMarkerAny', "[="                            , 'marker#Goto("prev", "any",  v:count)')
  call s:Map(a:mode, 'ListLocalMarks'   , 'm/'                            , 'mark#List("buf_curr")'               )
  call s:Map(a:mode, 'ListLocalMarkers' , 'm?'                            , 'marker#List()'                       )
endfunction


function! signature#utils#Input()                                                                                 " {{{2
  " Description: Grab input char

  " Obtain input from user ...
  let l:char = nr2char(getchar())

  " ... if the input is not a number eg. '!' ==> Delete all '!' markers
  if stridx(b:SignatureIncludeMarkers, l:char) >= 0
    return signature#marker#Purge(l:char)
  endif

  " ... but if input is a number, convert it to corresponding marker before proceeding
  if match( l:char, '\d' ) >= 0
    let l:char = split(')!@#$%^&*(', '\zs')[l:char]
  endif

  if stridx(b:SignatureIncludeMarkers, l:char) >= 0
    return signature#marker#Toggle(l:char)
  elseif stridx(b:SignatureIncludeMarks, l:char) >= 0
    return signature#mark#Toggle(l:char)
  else
    " l:char is probably one of `'[]<>
    execute 'normal! m' . l:char
  endif
endfunction


function! signature#utils#Remove(lnum)                                                                            " {{{2
  " Description: Obtain mark or marker from the user and remove it from the specified line number.
  "              If lnum is not specified for marker, or is 0, removes the marker from current line
  "              NOTE: lnum is meaningless for a mark
  " Arguments:   lnum - Line no. to delete the marker from

  let l:char = nr2char(getchar())

  if (l:char =~ '^\d$')
    let l:lnum = (a:lnum == 0 ? line('.') : a:lnum)
    let l:char = split(')!@#$%^&*(', '\zs')[l:char]
    call signature#marker#Remove(lnum, l:char)
  elseif (l:char =~? '^[a-z]$')
    call signature#mark#Remove(l:char)
  endif
endfunction


function! signature#utils#Toggle()                                                                                " {{{2
  " Description: Toggles and refreshes sign display in the buffer.

  let b:sig_enabled = !b:sig_enabled

  if b:sig_enabled
    " Signature enabled ==> Refresh signs
    call signature#sign#Refresh()

    " Add signs for markers ...
    for i in keys(b:sig_markers)
      call signature#sign#Place(b:sig_markers[i], i)
    endfor
  else
    " Signature disabled ==> Remove signs
    for l:lnum in keys(b:sig_markers)
      call signature#sign#Unplace(l:lnum)
    endfor
    for l:lnum in keys(b:sig_marks)
      call signature#sign#Unplace(l:lnum)
    endfor
    call signature#sign#ToggleDummy('remove')
    unlet b:sig_marks
  endif
endfunction
