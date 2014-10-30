" vim: fdm=marker:et:ts=4:sw=2:sts=2
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! signature#utils#Init()                                                                                  " {{{2
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


function! signature#utils#Set(var, default)
  if !exists(a:var)
    if type(a:default)
      execute 'let' a:var '=' string(a:default)
    else
      execute 'let' a:var '=' a:default
    endif
  endif
endfunction


function! signature#utils#NumericSort(x, y)                                                                       " {{{2
  return a:x - a:y
endfunction


function! s:CreateMap(key, map_lhs, map_rhs)                                                                      " {{{2
  let l:map_lhs = get(g:SignatureMap, a:key, a:map_lhs)
  if (l:map_lhs != "")
    silent! execute 'nnoremap <silent> <unique> ' . l:map_lhs . ' ' . ':<C-U>call signature#' . a:map_rhs . '<CR>'
  endif
endfunction

function! signature#utils#CreateMaps()                                                                            " {{{2
  " We create separate mappings for PlaceNextMark, mark#Purge('all') and PurgeMarkers instead of combining it with Leader/Input
  " as if the user chooses to use some weird key like <BS> or <CR> for any of these 3, we need to be able to identify it.
  " Eg. the nr2char(getchar()) will fail if the user presses a <BS>
  let s:SignatureMapLeader = get(g:SignatureMap, 'Leader', 'm')
  if (s:SignatureMapLeader == "")
    echoe "Signature: SignatureLeader shouldn't be left blank"
  endif
  call s:CreateMap('Leader'           , s:SignatureMapLeader              , 'Input()'                           )
  call s:CreateMap('PlaceNextMark'    , s:SignatureMapLeader . ","        , 'mark#Toggle("next")'               )
  call s:CreateMap('ToggleMarkAtLine' , s:SignatureMapLeader . "."        , 'mark#ToggleAtLine()'               )
  call s:CreateMap('PurgeMarksAtLine' , s:SignatureMapLeader . "-"        , 'mark#Purge("line")'                )
  call s:CreateMap('PurgeMarks'       , s:SignatureMapLeader . "<Space>"  , 'mark#Purge("all")'                 )
  call s:CreateMap('PurgeMarkers'     , s:SignatureMapLeader . "<BS>"     , 'marker#Purge()'                    )
  call s:CreateMap('DeleteMark'       , "dm"                              , 'mark#Remove()'                     )
  call s:CreateMap('GotoNextLineAlpha', "']"                              , 'mark#Goto("next", "line", "alpha")')
  call s:CreateMap('GotoPrevLineAlpha', "'["                              , 'mark#Goto("prev", "line", "alpha")')
  call s:CreateMap('GotoNextSpotAlpha', "`]"                              , 'mark#Goto("next", "spot", "alpha")')
  call s:CreateMap('GotoPrevSpotAlpha', "`["                              , 'mark#Goto("prev", "spot", "alpha")')
  call s:CreateMap('GotoNextLineByPos', "]'"                              , 'mark#Goto("next", "line", "pos")'  )
  call s:CreateMap('GotoPrevLineByPos', "['"                              , 'mark#Goto("prev", "line", "pos")'  )
  call s:CreateMap('GotoNextSpotByPos', "]`"                              , 'mark#Goto("next", "spot", "pos")'  )
  call s:CreateMap('GotoPrevSpotByPos', "[`"                              , 'mark#Goto("prev", "spot", "pos")'  )
  call s:CreateMap('GotoNextMarker'   , "]-"                              , 'marker#Goto("next", "same")'       )
  call s:CreateMap('GotoPrevMarker'   , "[-"                              , 'marker#Goto("prev", "same")'       )
  call s:CreateMap('GotoNextMarkerAny', "]="                              , 'marker#Goto("next", "any")'        )
  call s:CreateMap('GotoPrevMarkerAny', "[="                              , 'marker#Goto("prev", "any")'        )
  call s:CreateMap('ListLocalMarks'   , 'm/'                              , 'mark#List("buf_curr")'             )
  call s:CreateMap('ListLocalMarkers' , 'm?'                              , 'marker#List(v:count)'              )
  call s:CreateMap('', '0' . get(g:SignatureMap, 'ListLocalMarkers', 'm?'), 'marker#List(")")'                  )
endfunction
