" vim: fdm=marker:et:ts=4:sw=2:sts=2
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! signature#utils#Set(var, value, ...)                                                                    " {{{1
  " Description: Assign value to var if var is unset or if an optional 3rd arg is provided to force

  if (!exists(a:var) || a:0 && a:1)
    if type(a:value)
      execute 'let' a:var '=' string(a:value)
    else
      execute 'let' a:var '=' a:value
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
  let l:SignatureMapLeader = get(g:SignatureMap, 'Leader', 'm')
  if (l:SignatureMapLeader == "")
    echoe "Signature: g:SignatureMap.Leader shouldn't be left blank"
  endif
  call s:Map(a:mode, 'Leader'           , l:SignatureMapLeader            , 'utils#Input()'                       )
  call s:Map(a:mode, 'PlaceNextMark'    , l:SignatureMapLeader . ","      , 'mark#Toggle("next")'                 )
  call s:Map(a:mode, 'ToggleMarkAtLine' , l:SignatureMapLeader . "."      , 'mark#ToggleAtLine()'                 )
  call s:Map(a:mode, 'PurgeMarksAtLine' , l:SignatureMapLeader . "-"      , 'mark#Purge("line")'                  )
  call s:Map(a:mode, 'PurgeMarks'       , l:SignatureMapLeader . "<Space>", 'mark#Purge("all")'                   )
  call s:Map(a:mode, 'PurgeMarkers'     , l:SignatureMapLeader . "<BS>"   , 'marker#Purge()'                      )
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
  call s:Map(a:mode, 'ListBufferMarks'  , 'm/'                            , 'mark#List(0, 0)'                     )
  call s:Map(a:mode, 'ListBufferMarkers', 'm?'                            , 'marker#List(v:count, 0)'             )
endfunction


function! signature#utils#Input()                                                                                 " {{{1
  " Description: Grab input char

  if &ft ==# "netrw"
    " Workaround for #104
    return
  endif

  " Obtain input from user ...
  let l:in = nr2char(getchar())

  " ... if the input is not a number eg. '!' ==> Delete all '!' markers
  if signature#utils#IsValidMarker(l:in)
    return signature#marker#Purge(l:in)
  endif

  " ... but if input is a number, convert it to corresponding marker before proceeding
  if match(l:in, '\d') >= 0
    let l:char = signature#utils#GetChar(b:SignatureIncludeMarkers, l:in)
  else
    let l:char = l:in
  endif

  if signature#utils#IsValidMarker(l:char)
    return signature#marker#Toggle(l:char)
  elseif signature#utils#IsValidMark(l:char)
    return signature#mark#Toggle(l:char)
  else
    " l:char is probably one of `'[]<> or a space from the gap in b:SignatureIncludeMarkers
    execute 'normal! m' . l:in
  endif
endfunction


function! signature#utils#Remove(lnum)                                                                            " {{{1
  " Description: Obtain mark or marker from the user and remove it.
  "              There can be multiple markers of the same type on different lines. If a line no. is provided
  "              (non-zero), delete the marker from the specified line else delete it from the current line
  "              NOTE: lnum is meaningless for a mark and will be ignored
  " Arguments:   lnum - Line no. to delete the marker from

  let l:char = nr2char(getchar())

  if (l:char =~ '^\d$')
    let l:lnum = (a:lnum == 0 ? line('.') : a:lnum)
    let l:char = split(b:SignatureIncludeMarkers, '\zs')[l:char]
    call signature#marker#Remove(lnum, l:char)
  elseif (l:char =~? '^[a-z]$')
    call signature#mark#Remove(l:char)
  endif
endfunction


function! signature#utils#Toggle()                                                                                " {{{1
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
    " Force removal. Simply toggling doesn't work as we check whether b:sig_markers and b:sig_marks are empty before
    " removing the dummy and b:sig_markers won't be empty
    call signature#sign#ToggleDummy(0)
    unlet b:sig_marks
  endif
endfunction


function! signature#utils#SetupHighlightGroups()                                                                  " {{{1
  " Description: Sets up the highlight groups

  function! CheckAndSetHL(curr_hl, prefix, attr, targ_color)
    let l:curr_color = synIDattr(synIDtrans(hlID(a:curr_hl)), a:attr, a:prefix)

    if (  (  (l:curr_color == "")
     \    || (l:curr_color  < 0)
     \    )
     \ && (a:targ_color != "")
     \ && (a:targ_color >= 0)
     \ )
      " echom "DEBUG: HL=" . a:curr_hl . " (" . a:prefix . a:attr . ") Curr=" . l:curr_color . ", To=" . a:targ_color
      execute 'highlight ' . a:curr_hl . ' ' . a:prefix . a:attr . '=' . a:targ_color
    endif
  endfunction

  let l:prefix = (has('gui_running') || (has('termguicolors') && &termguicolors) ? 'gui' : 'cterm')
  let l:sign_col_color = synIDattr(synIDtrans(hlID('SignColumn')), 'bg', l:prefix)

  call CheckAndSetHL('SignatureMarkText',   l:prefix, 'fg', 'Red')
  call CheckAndSetHL('SignatureMarkText',   l:prefix, 'bg', l:sign_col_color)
  call CheckAndSetHL('SignatureMarkerText', l:prefix, 'fg', 'Green')
  call CheckAndSetHL('SignatureMarkerText', l:prefix, 'bg', l:sign_col_color)

  delfunction CheckAndSetHL
endfunction


function! signature#utils#IsValidMark(mark)                                                                       " {{{1
  return (b:SignatureIncludeMarks =~# a:mark)
endfunction


function! signature#utils#IsValidMarker(marker)                                                                   " {{{1
  return (  (b:SignatureIncludeMarkers =~# a:marker)
         \ && (a:marker != ' ')
         \ )
endfunction


function! signature#utils#GetChar(string, pos)                                                                    " {{{1
  if a:pos > strchars(a:string) - 1 | return "" | endif
  let pattern = '.\{-' . a:pos . '}\(.\).*'
  return substitute(a:string, pattern, '\1', '')
endfunction

