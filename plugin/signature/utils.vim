" vim: fdm=marker:et:ts=4:sw=2:sts=2
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! signature#utils#Init()                                                                                  " {{{1
  " Description: Initialize variables

  if !exists('b:sig_marks')
    " b:sig_marks = { lnum => signs_str }
    let b:sig_marks = {}
  else
    " Lines can be removed using an external tool. Hence, we need to filter out marks placed on line numbers that are
    " now greater than the total number of lines in the file.
    let l:line_tot = line('$')
    call filter( b:sig_marks, 'v:key <= l:line_tot' )
  endif

  if !exists('b:sig_markers')
    " b:sig_markers = { lnum => marker }
    let b:sig_markers = {}
  else
    " Lines can be removed using an external tool. Hence, we need to filter out marks placed on line numbers that are
    " now greater than the total number of lines in the file.
    let l:line_tot = line('$')
    call filter( b:sig_markers, 'v:key <= l:line_tot' )
  endif

  call signature#utils#Set('b:sig_enabled'             , g:SignatureEnabledAtStartup)
  call signature#utils#Set('b:SignatureIncludeMarks'   , g:SignatureIncludeMarks    )
  call signature#utils#Set('b:SignatureIncludeMarkers' , g:SignatureIncludeMarkers  )
  call signature#utils#Set('b:SignatureMarkOrder'      , g:SignatureMarkOrder       )
  call signature#utils#Set('b:SignaturePrioritizeMarks', g:SignaturePrioritizeMarks )
  call signature#utils#Set('b:SignatureDeferPlacement' , g:SignatureDeferPlacement  )
  call signature#utils#Set('b:SignatureWrapJumps'      , g:SignatureWrapJumps       )
endfunction


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
  call s:Map(a:mode, 'Leader'           , s:SignatureMapLeader            , 'Input()'                             )
  call s:Map(a:mode, 'PlaceNextMark'    , s:SignatureMapLeader . ","      , 'mark#Toggle("next")'                 )
  call s:Map(a:mode, 'ToggleMarkAtLine' , s:SignatureMapLeader . "."      , 'mark#ToggleAtLine()'                 )
  call s:Map(a:mode, 'PurgeMarksAtLine' , s:SignatureMapLeader . "-"      , 'mark#Purge("line")'                  )
  call s:Map(a:mode, 'PurgeMarks'       , s:SignatureMapLeader . "<Space>", 'mark#Purge("all")'                   )
  call s:Map(a:mode, 'PurgeMarkers'     , s:SignatureMapLeader . "<BS>"   , 'marker#Purge()'                      )
  call s:Map(a:mode, 'DeleteMark'       , "dm"                            , 'Remove(v:count)'                     )
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
