" vim: fdm=marker:et:ts=4:sw=2:sts=2
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"
" Helper Functions                                  {{{1
"
function! s:NumericSort(x, y) "                     {{{2
  return a:x - a:y
endfunction


function! s:MarksList(...) "                        {{{2
  " Description: Takes two optional arguments - mode and line no.
  "              If no arguments are specified, returns a list of [mark, line no.] pairs that are in use in the buffer
  "              or are free to be placed in which case, line no. is 0
  "
  " Arguments: a:1 (mode) = 'used' : Returns list of [ [used marks, line no.] ]
  "                         'free' : Returns list of [ free marks ]
  "            a:2 (line no.)      : Returns list of used marks on current line. Note that mode = 'free' is meaningless
  "                                  here and thus, is ignored

  let l:SignatureIncludeMarks = ( exists('b:SignatureIncludeMarks') ? b:SignatureIncludeMarks : g:SignatureIncludeMarks )
  let l:marks_list = []

  " Add local marks first
  for i in filter( split( l:SignatureIncludeMarks, '\zs' ), 'v:val =~# "[a-z]"' )
    let l:marks_list = add(l:marks_list, [i, line("'" . i)])
  endfor

  " Add global (uppercase) marks to list only if it is in use in this buffer or hasn't been used at all.
  for i in filter( split( l:SignatureIncludeMarks, '\zs' ), 'v:val =~# "[A-Z]"' )
    let [ l:buf, l:line, l:col, l:off ] = getpos( "'" . i )
    if l:buf == bufnr('%') || l:buf == 0
      let l:marks_list = add(l:marks_list, [i, l:line])
    endif
  endfor

  if ( a:0 == 0 )
    return l:marks_list
  elseif (( a:0 == 1 ) && ( a:1 ==? "used" ))
    return filter( l:marks_list, 'v:val[1] > 0' )
  elseif (( a:0 == 1 ) && ( a:1 ==? "free" ))
    return map( filter( l:marks_list, 'v:val[1] == 0' ), 'v:val[0]' )
  elseif (( a:0 == 2 ) && ( a:2 > 0 ))
    return map( filter( l:marks_list, 'v:val[1] == ' . a:2 ), 'v:val[0]' )
  endif
endfunction
" }}}2


"
" Toggle Marks/Signs                                {{{1
"
function! signature#Input() "                    {{{2
  " Description: Grab input char

  let l:SignatureIncludeMarkers = ( exists('b:SignatureIncludeMarkers') ? b:SignatureIncludeMarkers : g:SignatureIncludeMarkers )
  let l:SignatureIncludeMarks   = ( exists('b:SignatureIncludeMarks')   ? b:SignatureIncludeMarks   : g:SignatureIncludeMarks )

  " ... if not, obtain input from user ...
  let l:ascii = getchar()
  let l:char  = nr2char( l:ascii )

  " Check if 'PlaceNextMark', 'PurgeMarks' or 'PurgeMarkers' was called
  if g:SignatureMap['PlaceNextMark'] == "<CR>"    && l:ascii == 13   | return s:ToggleMark('next')     | endif
  if g:SignatureMap['PlaceNextMark'] == "<Space>" && l:ascii == 32   | return s:ToggleMark('next')     | endif
  if l:ascii == eval( '"\' . g:SignatureMap['PlaceNextMark'] . '"' ) | return s:ToggleMark('next')     | endif

  if g:SignatureMap['PurgeMarks']    == "<CR>"    && l:ascii == 13   | return signature#PurgeMarks()   | endif
  if g:SignatureMap['PurgeMarks']    == "<Space>" && l:ascii == 32   | return signature#PurgeMarks()   | endif
  if l:ascii == eval( '"\' . g:SignatureMap['PurgeMarks'] . '"' )    | return signature#PurgeMarks()   | endif

  if g:SignatureMap['PurgeMarkers']  == "<CR>"    && l:ascii == 13   | return signature#PurgeMarkers() | endif
  if g:SignatureMap['PurgeMarkers']  == "<Space>" && l:ascii == 32   | return signature#PurgeMarkers() | endif
  if l:ascii == eval( '"\' . g:SignatureMap['PurgeMarkers'] . '"' )  | return signature#PurgeMarkers() | endif

  " ... if the input is not a number eg. '!' ==> Delete all '!' markers
  if stridx( l:SignatureIncludeMarkers, l:char ) >= 0
    return signature#PurgeMarkers( l:char )
  endif

  " ... but if input is a number, convert it to corresponding marker before proceeding
  if match( l:char, '\d' ) >= 0
    let l:char = split( ")!@#$%^&*(", '\zs' )[l:char]
  endif

  if stridx( l:SignatureIncludeMarkers, l:char ) >= 0
    return s:ToggleMarker( l:char )
  elseif stridx( l:SignatureIncludeMarks, l:char ) >= 0
    return s:ToggleMark( l:char )
  endif

endfunction


function! s:ToggleMark( mark ) "                    {{{2
  " Description: mark = 'next' : Place new mark on current line else toggle specified mark on current line
  " Arguments:   mark [,a-z,A-Z]

  let l:lnum = line('.')

  if a:mark == "next"
    " Place new mark
    let l:mark = s:MarksList( "free" )[0]
    if l:mark == ""
      echoe "Signature: No free marks left."
      return
    endif

    execute 'normal! m' . l:mark
    call s:ToggleSign( l:mark, "place", l:lnum )

  else
    " Toggle Mark
    let l:mark = a:mark
    let l:mark_pos = filter( s:MarksList(), 'v:val[0] ==# l:mark' )[0][1]

    if l:mark_pos == l:lnum
      " Mark is present on the current line. Remove it and return
      execute 'delmarks ' . l:mark
      call s:ToggleSign( l:mark, "remove", l:lnum )
      return

    else
      " Mark is not present on current line but it may be present somewhere else. We will first place and remove the
      " sign to avoid the shifting of the Foldcolumn when there is only 1 mark placed and we re-place it somewhere else
      " Place new sign
      execute 'normal! m' . l:mark
      call s:ToggleSign( l:mark, "place", l:lnum )

      " l:mark_pos == 0 indicates that the mark was free. If not, we have to remove the sign for the original mark
      if l:mark_pos != 0
        call s:ToggleSign( l:mark, "remove", l:mark_pos )
      endif
    endif
  endif
endfunction


function! signature#PurgeMarks() "                  {{{2
  " Description: Remove all marks

  let l:used_marks = s:MarksList( "used" )
  if empty( l:used_marks ) | return | endif

  if g:SignaturePurgeConfirmation
    let choice = confirm("Are you sure you want to delete all marks? This cannot be undone.", "&Yes\n&No", 1)
    if choice == 2 | return | endif
  endif

  for i in l:used_marks
    silent execute 'delmarks ' . i[0]
    silent call s:ToggleSign( i[0], "remove", i[1] )
  endfor
endfunction


function! s:ToggleMarker( marker ) "                {{{2
  " Description: Toggle marker on current line
  " Arguments: marker [!@#$%^&*()]

  let l:lnum = line('.')
  " If marker is found in on current line, remove it, else place it
  let l:mode = ( get( b:sig_markers, l:lnum, "" ) =~# escape( a:marker, '$^' ) ? "remove" : "place" )
  call s:ToggleSign( a:marker, l:mode, l:lnum )
endfunction


function! signature#PurgeMarkers(...) "             {{{2
  " Description: If argument is given, removes marker only of the specified type else all markers are removed

  if empty( b:sig_markers ) | return | endif

  if g:SignaturePurgeConfirmation
    let choice = confirm("Are you sure you want to delete all markers? This cannot be undone.", "&Yes\n&No", 1)
    if choice == 2 | return | endif
  endif

  if a:0 > 0
    let l:markers = [ a:1 ]
  else
    let l:SignatureIncludeMarkers = ( exists('b:SignatureIncludeMarkers') ? b:SignatureIncludeMarkers : g:SignatureIncludeMarkers )
    let l:markers = split( l:SignatureIncludeMarkers, '\zs' )
  endif

  for l:marker in l:markers
    for l:lnum in keys( filter( copy(b:sig_markers), 'v:val =~# l:marker' ))
      call s:ToggleSign( l:marker, "remove", l:lnum )
    endfor
  endfor
endfunction


function! s:ToggleSign( sign, mode, lnum ) "        {{{2
  " Description: Enable/Disable/Toggle signs for marks/markers on the specified line number, depending on value of mode
  " Arguments:
  "   sign : The mark/marker whose sign is to be placed/removed/toggled
  "   mode : 'remove'
  "        : 'place'
  "   lnum : Line number on/from which the sign is to be placed/removed
  "          If mode = "remove" and line number is 0, the 'sign' is removed from all lines

  "echom "DEBUG: sign = " . a:sign . ",  mode = " . a:mode . ",  lnum = " . a:lnum

  let l:SignatureIncludeMarkers  = ( exists('b:SignatureIncludeMarkers')  ? b:SignatureIncludeMarkers  : g:SignatureIncludeMarkers )
  let l:SignatureMarkOrder       = ( exists('b:SignatureMarkOrder')       ? b:SignatureMarkOrder       : g:SignatureMarkOrder )
  let l:SignaturePrioritizeMarks = ( exists('b:SignaturePrioritizeMarks') ? b:SignaturePrioritizeMarks : g:SignaturePrioritizeMarks )

  " If Signature is not enabled, return
  if !b:sig_enabled | return | endif

  let l:lnum = a:lnum
  let l:id   = ( winbufnr(0) + 1 ) * l:lnum

  " Toggle sign for markers                         {{{3
  if stridx( l:SignatureIncludeMarkers, a:sign ) >= 0

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

  " TODO: Place sign only if there are no signs from other plugins (eg. syntastic)
  if ( has_key( b:sig_marks, l:lnum ) && ( l:SignaturePrioritizeMarks || !has_key( b:sig_markers, l:lnum )))
    let l:str = substitute( l:SignatureMarkOrder, "\m", strpart( b:sig_marks[l:lnum], 0, 1 ), "" )
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
"}}}2


"
" Navigation                                        {{{1
"
function! signature#GotoMark( dir, loc, mode ) "    {{{2
  " Arguments:
  "   dir  = next  : Jump forward
  "          prev  : Jump backward
  "   loc  = line  : Jump to first column of line with mark
  "          spot  : Jump to exact column of the mark
  "   mode = pos   : Jump to next mark by position
  "          alpha : Jump to next mark by alphabetical order

  let l:mark = ""
  let l:dir  = a:dir

  if a:mode ==? "alpha"
    let l:mark = s:GotoMarkByAlpha(a:dir)
  elseif a:mode ==? "pos"
    let l:mark = s:GotoMarkByPos(a:dir)
  endif

  " Note: If l:mark is an empty string then no movement will be made
  if l:mark == "" | return | endif

  if a:loc ==? "line"
    execute "normal! '" . l:mark
  elseif a:loc ==? "spot"
    execute 'normal! `' . l:mark
  endif
endfunction


function! s:GotoMarkByPos( dir ) "                  {{{2
  " Description: Jump to next/prev mark by location.
  " Arguments: dir = next : Jump forward
  "                  prev : Jump backward

  " We need at least one mark to be present. If not, then return an empty string so that no movement will be made
  if empty( b:sig_marks ) | return "" | endif

  let l:SignatureWrapJumps = ( exists('b:SignatureWrapJumps') ? b:SignatureWrapJumps : g:SignatureWrapJumps )
  let l:lnum = line('.')

  " Get list of line numbers of lines with marks.
  if a:dir ==? "next"
    let l:targ = min( sort( keys( b:sig_marks ), "s:NumericSort" ))
    let l:mark_lnums = sort( keys( filter( copy( b:sig_marks ), 'v:key > l:lnum')), "s:NumericSort" )
  elseif a:dir ==? "prev"
    let l:targ = max( sort( keys( b:sig_marks ), "s:NumericSort" ))
    let l:mark_lnums = reverse( sort( keys( filter( copy( b:sig_marks ), 'v:key < l:lnum')), "s:NumericSort" ))
  endif
  let l:targ = ( empty( l:mark_lnums ) && l:SignatureWrapJumps ? l:targ : l:mark_lnums[0] )
  let l:mark = strpart( b:sig_marks[l:targ], 0, 1 )

  return l:mark
endfunction


function! s:GotoMarkByAlpha( dir ) "                {{{2
  " Description: Jump to next/prev mark by alphabetical order. Direction specified as input argument

  let l:SignatureWrapJumps = ( exists('b:SignatureWrapJumps') ? b:SignatureWrapJumps : g:SignatureWrapJumps )

  let l:used_marks = s:MarksList( "used" )
  let l:line_marks = s:MarksList( "used", line('.') )
  let l:mark       = ""
  let l:mark_first = ""

  " If there is only one mark in the current file, then return the same
  if ( len(l:used_marks) == 1 )
    return l:used_marks[0]
  endif

  " Since we can place multiple marks on a line, to jump by alphabetical order we need to know what the current mark is.
  " This information is kept in the b:sig_GotoMarkByAlpha_CurrMark variable. For instance, if we have marks a, b, and c
  " on the current line and b:sig_GotoMarkByAlpha_CurrMark has the value 'a' then we jump to 'b' and set the value of
  " the variable to 'b'. Reinvoking this function will thus now jump to 'c'

  if empty(l:line_marks)
    if exists('b:sig_GotoMarkByAlpha_CurrMark')
      unlet b:sig_GotoMarkByAlpha_CurrMark
    endif
    " If there are no marks present on the current line then call GotoMarkByPos to jump to the next line with a mark
    return s:GotoMarkByPos(a:dir)
  endif

  if (( len(l:line_marks) == 1 ) || !exists('b:sig_GotoMarkByAlpha_CurrMark'))
    let b:sig_GotoMarkByAlpha_CurrMark = l:line_marks[0]
  endif

  for i in range( 0, len(l:used_marks) - 1 )
    if l:used_marks[i][0] ==# b:sig_GotoMarkByAlpha_CurrMark
      if a:dir ==? "next"
        if i != len(l:used_marks)-1
          let l:mark = l:used_marks[i+1][0]
          let b:sig_GotoMarkByAlpha_CurrMark = l:mark
        elseif l:SignatureWrapJumps
          let l:mark = l:used_marks[0][0]
          let b:sig_GotoMarkByAlpha_CurrMark = l:mark
        endif
      elseif a:dir ==? "prev"
        if i != 0
          let l:mark = l:used_marks[i-1][0]
          let b:sig_GotoMarkByAlpha_CurrMark = l:mark
        elseif l:SignatureWrapJumps
          let l:mark = l:used_marks[-1][0]
          let b:sig_GotoMarkByAlpha_CurrMark = l:mark
        endif
      endif
      return l:mark
    endif
  endfor
endfunction


function! signature#GotoMarker( dir, type ) "       {{{2
  " Description: Jump to next/prev marker by location.
  " Arguments: dir  = next : Jump forward
  "                   prev : Jump backward
  "            type = same : Jump to a marker of the same type
  "                   any  : Jump to a marker of any type

  "" We need at least one mark to be present
  if empty( b:sig_markers ) | return | endif

  let l:SignatureWrapJumps = ( exists('b:SignatureWrapJumps') ? b:SignatureWrapJumps : g:SignatureWrapJumps )
  let l:lnum = line('.')

  " Get list of line numbers of lines with markers.
  " If current line has a marker, filter out line numbers of other markers ...
  if has_key( b:sig_markers, l:lnum ) && a:type ==? "same"
    let l:marker_lnums = sort( keys( filter( copy(b:sig_markers),
      \ 'strpart(v:val, 0, 1) == strpart(b:sig_markers[l:lnum], 0, 1)' )), "s:NumericSort" )
  else
    let l:marker_lnums = sort( keys( b:sig_markers ), "s:NumericSort" )
  endif

  if a:dir ==? "prev"
    call reverse( l:marker_lnums )
  endif

  if a:dir ==? "next"
    let l:targ = ( l:SignatureWrapJumps ? min( l:marker_lnums ) : l:lnum )
    for i in l:marker_lnums
      if i > l:lnum
        let l:targ = i
        break
      endif
    endfor

  elseif a:dir ==? "prev"
    let l:targ = ( l:SignatureWrapJumps ? max( l:marker_lnums ) : l:lnum )
    for i in l:marker_lnums
      if i < l:lnum
        let l:targ = i
        break
      endif
    endfor

  endif

  execute 'normal! ' . l:targ . 'G'
endfunction
" }}}2


"
" Misc                                              {{{1
"
function! signature#SignRefresh(...) "              {{{2
  " Description: Add signs for new marks/markers and remove signs for deleted marks/markers
  " Arguments: '1' to force a sign refresh

  if !exists('b:sig_marks')   | let b:sig_marks   = {} | endif
    " b:sig_marks   = { lnum => signs_str }
  if !exists('b:sig_markers') | let b:sig_markers = {} | endif
    " b:sig_markers = { lnum => marker }

  " If Signature is not enabled, return
  if !exists('b:sig_enabled') | let b:sig_enabled = g:SignatureEnabledAtStartup | endif
  if !b:sig_enabled | return | endif

  let l:SignatureIncludeMarks = ( exists('b:SignatureIncludeMarks') ? b:SignatureIncludeMarks : g:SignatureIncludeMarks )
  let l:used_marks = map( copy(s:MarksList( "used" )), 'v:val[0]')

  for i in s:MarksList( "free" )
    " ... remove it
    call s:ToggleSign( i, "remove", 0 )
  endfor

  " Add signs for marks ...
  for j in s:MarksList( "used" )
    " ... if mark is not present in our b:sig_marks list or if it is present but at the wrong line,
    " remove the old sign and add a new one
    if !has_key( b:sig_marks, j[1] ) || b:sig_marks[j[1]] !~# j[0] || ( a:0 > 0 && a:1 )
      call s:ToggleSign( j[0], "remove", 0 )
      call s:ToggleSign( j[0], "place", j[1] )
    endif
  endfor

  " We do not add signs for markers as SignRefresh is executed periodically and we don't have a way to determine if the
  " marker already has a sign or not
endfunction


function! signature#Toggle() "                      {{{2
  " Description: Toggles and refreshes sign display in the buffer.

  if !exists('b:sig_marks')   | let b:sig_marks   = {} | endif
    " b:sig_marks   = { lnum => signs_str }
  if !exists('b:sig_markers') | let b:sig_markers = {} | endif
    " b:sig_markers = { lnum => marker }

  " If Signature is not enabled, return
  let b:sig_enabled = ( exists('b:sig_enabled') ? !b:sig_enabled : g:SignatureEnabledAtStartup )

  if b:sig_enabled
    " Signature enabled ==> Refresh signs
    call signature#SignRefresh()

    " Add signs for markers ...
    for i in keys( b:sig_markers )
      call s:ToggleSign( b:sig_markers[i], "place", i )
    endfor
  else
    " Signature disabled ==> Remove signs
    for i in keys( b:sig_markers )
      let l:id = ( winbufnr(0) + 1 ) * i
      silent! execute 'sign unplace ' . l:id
    endfor
    for i in keys( b:sig_marks )
      let l:id = ( winbufnr(0) + 1 ) * i
      silent! execute 'sign unplace ' . l:id
    endfor
    unlet b:sig_marks
  endif

endfunction
