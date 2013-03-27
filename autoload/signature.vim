" vim: fdm=marker:et:ts=4:sw=2:sts=2
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"
" Helper Functions                                    {{{1
"
function! s:LowerMarksList() "                        {{{2
  " Description: Returns list of lowercase marks that are permitted to be used

  let l:SignatureIncludeMarks = ( exists('b:SignatureIncludeMarks') ? b:SignatureIncludeMarks : g:SignatureIncludeMarks )
  let l:ref = split("abcdefghijklmnopqrstuvwxyz", '\zs')
  let l:lmarks = []

  for i in l:ref
    if stridx(l:SignatureIncludeMarks, i) >= 0
      call add(l:lmarks, i)
    endif
  endfor

  return l:lmarks
endfunction


function! s:UpperMarksList() "                        {{{2
  " Description: Returns list of uppercase marks that are permitted to be used

  let l:SignatureIncludeMarks = ( exists('b:SignatureIncludeMarks') ? b:SignatureIncludeMarks : g:SignatureIncludeMarks )
  let l:ref = split("ABCDEFGHIJKLMNOPQRSTUVWXYZ", '\zs')
  let l:umarks = []

  for i in l:ref
    if stridx(l:SignatureIncludeMarks, i) >= 0
      call add(l:umarks, i)
    endif
  endfor

  return l:umarks
endfunction


function! s:MarksList() "                             {{{2
  " Description: Returns a list of [mark, line no.] pairs that are in use in
  "              the buffer or are free to be placed in which case, line no. is 0

  let l:SignatureIncludeMarks = ( exists('b:SignatureIncludeMarks') ? b:SignatureIncludeMarks : g:SignatureIncludeMarks )
  let l:marks = []

  for i in split("abcdefghijklmnopqrstuvwxyz", '\zs')
    if stridx(l:SignatureIncludeMarks, toupper(i)) >= 0
      let [ l:buf, l:line, l:col, l:off ] = getpos("'" . toupper(i))
      if l:buf == bufnr('%') || l:buf == 0
        " Add uppercase mark to list if it is in use in this buffer or hasn't been used at all.
        let l:marks = add(l:marks, [toupper(i), l:line])
      endif
    endif
    if stridx(l:SignatureIncludeMarks, i) >= 0
      let l:marks = add(l:marks, [i, line("'" . i)])
    endif
  endfor

  return l:marks
endfunction


function! s:MarksAt(line) "                           {{{2
  " Description: Return a list of marks that are in use on the specified line no.

  let l:return_var = map(filter(s:MarksList(), 'v:val[1]==' . a:line), 'v:val[0]')

  return l:return_var
endfunction


function! s:UsedMarks() "                             {{{2
  " Description: Returns a list of [mark, line no.] pairs that are in use in the current buffer

  let l:return_var = filter(s:MarksList(), 'v:val[1]>0')

  return l:return_var
endfunction


function! s:UnusedMarks() "                           {{{2
  " Description: Return a list of marks that are unused (globally unused for global marks)

  let l:marks = []

  for i in s:LowerMarksList()
    if line("'" . i) == 0
      let l:marks = add(l:marks, i)
    endif
  endfor

  for i in s:UpperMarksList()
    if !(buflisted(getpos("'" . i)[0]) == 1 && getpos("'" . i)[1] != 0)
      let l:marks = add(l:marks, i)
    endif
  endfor

  return l:marks
endfunction


function! signature#MapKey( rhs, mode ) "             {{{2
  " Description: Inverse of maparg()
  "              Pass in a key sequence and the first letter of a vim mode.
  "              Returns key mapping mapped to it in that mode, else '' if none.
  " Example:     :nnoremap <Tab> :bn<CR>
  "              :call Mapkey(':bn<CR>', 'n')
  "              returns <Tab>
  execute 'redir => l:mappings | silent! ' . a:mode . 'map | redir END'

  " Convert all text between angle-brackets to lowercase
  " Required to recognize all case-variants of <c-A> and <C-a> as the same thing
  let l:rhs = substitute(a:rhs, '<[^>]\+>', "\\L\\0", 'g')

  for l:map in split(l:mappings, '\n')
    " Get rhs for each mapping
    let l:lhs = split(l:map, '\s\+')[1]
    let l:lhs_map = maparg(l:lhs, a:mode)

    if substitute(l:lhs_map, '<[^>]\+>', "\\L\\0", 'g') ==# l:rhs
      return l:lhs
    endif
  endfor
  return ''
endfunction

" }}}2


"
" Toggle Marks/Signs                                  {{{1
"
function! signature#ToggleMark( mark, ... ) "         {{{2
  " Arguments: mark, [mode], [line no.]
  " Description: If mode and line no. haven't been specified, toggle the specified mark on the current line
  "              If mode = 1, place new mark. If line no. is specified, do the above on the specified line no.

  let l:mode = ( a:0 >= 1 && a:1 >= 0 ? a:1 : -1 )
  let l:lnum = ( a:0 >= 2 && a:2 >  0 ? a:2 : line('.') )

  if a:mark == ","
    " Place new mark
    let l:mark = s:UnusedMarks()[0]
    if l:mark == ""
      echom "No free marks left."
      return
    endif
    execute 'normal! m' . l:mark
    call s:ToggleSign(l:mark, 1, l:lnum)

  else
    if l:mode == 0 || l:mode == -1
      " Toggle Mark
      for i in s:MarksAt(line('.'))
        if i ==# a:mark
          execute 'delmarks ' . a:mark
          call s:ToggleSign(a:mark, 0, l:lnum)
          return
        endif
      endfor
    endif

    if l:mode == 1 || l:mode == -1
      " Mark not present, hence place new mark
      call s:ToggleSign(a:mark, 0, 0)
      execute 'normal! m' . a:mark
      call s:ToggleSign(a:mark, 1, l:lnum)
    endif

  endif
endfunction


function! signature#PurgeMarks() "                    {{{2
  " Description: Remove all marks

  let l:marks = map(filter(s:MarksList(), 'v:val[1]>0'), 'v:val[0]')

  if g:SignaturePurgeConfirmation && !empty(l:marks)
    let choice = confirm("Are you sure you want to delete all marks? This cannot be undone.", "&Yes\n&No", 1)
    if choice == 2 | return | endif
  endif

  for i in l:marks
    silent execute 'delmarks ' . i
    silent call s:ToggleSign(i, 0, 0)
  endfor
endfunction
" }}}2

function! signature#ToggleMarker( marker, ... ) "     {{{2
  " Arguments: marker, [mode], [line no.]
  " Description: If mode and line no. haven't been specified, toggle the specified marker on the current line
  "              If mode = 1, place new marker. If line no. is specified, do the above on the specified line no.

  let l:lnum = ( a:0 >= 2 && a:2 >  0 ? a:2 : line('.') )
  let l:mode = ( a:0 >= 1 && a:1 >= 0 ? a:1 : !(has_key(b:sig_markers, l:lnum) && b:sig_markers[l:lnum] == a:marker))

  if !l:mode | call remove(b:sig_markers, l:lnum) | endif
  call s:ToggleSign(a:marker, l:mode, l:lnum)
endfunction


function! signature#RemoveMarker( marker ) "          {{{2
  " Description: Removes all markers of the specified type

  for i in keys(filter(copy(b:sig_markers), 'v:val=~#a:marker'))
    call s:ToggleSign(a:marker, 0, i)
  endfor
  call filter(b:sig_markers, 'v:val!~#a:marker')
endfunction


function! signature#PurgeMarkers() "                  {{{2
  " Description: Removes all markers

  for i in keys(b:sig_markers)
    call s:ToggleSign(b:sig_markers[i], 0, i)
  endfor
  let b:sig_markers = {}
endfunction
" }}}2

function! s:ToggleSign( mark, mode, lnum ) "          {{{2

  if !has('signs') | return | endif

  let l:SignatureIncludeMarkers = ( exists('b:SignatureIncludeMarkers') ? b:SignatureIncludeMarkers : g:SignatureIncludeMarkers )
  let l:SignatureMarkOrder  = ( exists('b:SignatureMarkOrder') ? b:SignatureMarkOrder : g:SignatureMarkOrder )
  let l:SignatureSignTextHL  = ( exists('b:SignatureSignTextHL') ? b:SignatureSignTextHL : g:SignatureSignTextHL )

  if stridx(l:SignatureIncludeMarkers, a:mark) >= 0
    " Visual marker has been set
    let l:lnum = a:lnum
    let l:id = ( winbufnr(0) + 1 ) * l:lnum
    if a:mode
      let b:sig_markers[l:lnum] = a:mark
      let l:str = stridx(l:SignatureIncludeMarkers, a:mark)
      execute 'sign place ' . l:id . ' line=' . l:lnum . ' name=sig_Marker_' . l:str . ' buffer=' . winbufnr(0)
    else
      if has_key(b:sig_marks, l:lnum)
        let l:mark = strpart(b:sig_marks[l:lnum], 0, 1)
        let l:str = substitute(l:SignatureMarkOrder, "\m", l:mark, "")
        let l:str = substitute(l:str, "\p", strpart(b:sig_marks[l:lnum], 1, 1), "")
        execute 'sign define sig_Mark_' . l:id . ' text=' . l:str . ' texthl=' . l:SignatureSignTextHL
        execute 'sign place ' . l:id . ' line=' . l:lnum . ' name=sig_Mark_' . l:id . ' buffer=' . winbufnr(0)
      else
        execute 'sign unplace ' . l:id
      endif
    endif

  else
    " Alphabetical mark has been set
    if a:mode
      let l:lnum = a:lnum
      let l:id  = ( winbufnr(0) + 1 ) * l:lnum
      let b:sig_marks[l:lnum] = a:mark . get(b:sig_marks, l:lnum, "")
    else
      let l:arr = keys(filter(copy(b:sig_marks), 'v:val =~# a:mark'))
      if empty(l:arr) | return | endif
      let l:lnum = l:arr[0]
      let l:id  = ( winbufnr(0) + 1 ) * l:lnum
      let l:save_ic = &ic | set noic
      let b:sig_marks[l:lnum] = substitute(b:sig_marks[l:lnum], a:mark, "", "")
      let &ic = l:save_ic
      if empty(b:sig_marks[l:lnum])
        call remove(b:sig_marks, l:lnum)
        if !has_key(b:sig_markers, l:lnum)
          execute 'sign unplace ' . l:id
        endif
        return
      endif
    endif

    if !has_key(b:sig_markers, l:lnum)
      let l:mark = strpart(b:sig_marks[l:lnum], 0, 1)
      let l:str  = substitute(l:SignatureMarkOrder, "\m", l:mark, "")
      let l:str  = substitute(l:str, "\p", strpart(b:sig_marks[l:lnum], 1, 1), "")
      execute 'sign define sig_Mark_' . l:id . ' text=' . l:str . ' texthl=' . l:SignatureSignTextHL
      execute 'sign place ' . l:id . ' line=' . l:lnum . ' name=sig_Mark_' . l:id . ' buffer=' . winbufnr(0)
    endif
  endif
endfunction
"}}}2


"
" Navigation                                          {{{1
"
function! signature#GotoMark( mode, dir, loc ) "      {{{2
  let l:mark = ""
  let l:dir  = a:dir

  if a:mode ==? "pos"
    let l:mark = s:GotoMarkByPos(a:dir)
  elseif a:mode ==? "alpha"
    let l:mark = s:GotoMarkByAlpha(a:dir)
  endif
  " Note: If l:mark is an empty string then no movement will be made

  if a:loc ==? "line"
    execute "normal! '" . l:mark
  elseif a:loc ==? "spot"
    execute 'normal! `' . l:mark
  endif
endfunction


function! s:GotoMarkByPos( dir ) "                    {{{2
  let l:SignatureWrapJumps = ( exists('b:SignatureWrapJumps') ? b:SignatureWrapJumps : g:SignatureWrapJumps )

  let l:MarksList = s:UsedMarks()
  " We need at least one mark to be present. If not, then return an empty string so that no movement will be made
  if ( len(l:MarksList) < 1 ) | return "" | endif

  let l:pos        = line('.')
  let l:dist       = 0
  " Initialize l:mark and l:mark_first so that if there is only 1 mark present in the whole file,
  " then a jump will be made directly to that mark itself
  let l:mark       = l:MarksList[0][0]
  let l:mark_first = l:MarksList[0][0]

  if a:dir ==? "next"
    let l:pos_first = line('$') + 1
    for m in l:MarksList
      " Find the mark that comes just after the current line
      if (( m[1] > l:pos ) && ( l:dist == 0 || m[1] - l:pos < l:dist ))
        let l:mark = m[0]
        let l:dist = m[1] - l:pos
      endif
      " Find the mark that is present first, in case the current line doesn't
      " have any mark after it and we have to wrap around to the start.
      if ( m[1] < l:pos_first )
        let l:mark_first = m[0]
        let l:pos_first  = m[1]
      endif
    endfor
    " If l:mark is an empty string then it means that there is no mark after the current line till EOF
    " Hence, if WrapJumps is enabled, wrap around to the first mark present in the file
    if ( empty(l:mark) && l:SignatureWrapJumps )
      let l:mark = l:mark_first
    endif

  elseif a:dir ==? "prev"
    let l:pos_last = 0
    for m in l:MarksList
      " Find the mark that comes just before the current line
      if (( m[1] < l:pos ) && ( l:dist == 0 || l:pos - m[1] < l:dist ))
        let l:mark = m[0]
        let l:dist = l:pos - m[1]
      endif
      " Find the mark that is present last, in case the current line doesn't
      " have any mark after it and we have to wrap around to the end.
      if ( m[1] > l:pos_last )
        let l:mark_last = m[0]
        let l:pos_last  = m[1]
      endif
    endfor
    " If l:mark is an empty string then it means that there is no mark before the current line till start of file
    " Hence, if WrapJumps is enabled, wrap around to the last mark present in the file
    if ( empty(l:mark) && l:SignatureWrapJumps )
      let l:mark = l:mark_last
    endif
  endif

  return l:mark
endfunction


function! s:GotoMarkByAlpha( dir ) "                  {{{2
  let l:SignatureWrapJumps = ( exists('b:SignatureWrapJumps') ? b:SignatureWrapJumps : g:SignatureWrapJumps )

  let l:UsedMarks  = s:UsedMarks()
  let l:MarksAt    = s:MarksAt(line('.'))
  let l:mark       = ""
  let l:mark_first = ""

  " Since we can place multiple marks on a line, to jump by alphabetical order we need to know what the current mark is.
  " This information is kept in the b:sig_GotoMarkByAlpha_CurrMark variable. For instance, if we have marks a, b, and c
  " on the current line and b:sig_GotoMarkByAlpha_CurrMark has the value 'a' then we jump to 'b' and set the value of
  " the variable to 'b'. Reinvoking this function will thus now jump to 'c'

  if empty(l:MarksAt)
    if exists('b:sig_GotoMarkByAlpha_CurrMark')
      unlet b:sig_GotoMarkByAlpha_CurrMark
    endif
    " If there are no marks present on the current line then call GotoMarkByPos to jump to the next line with a mark
    return s:GotoMarkByPos(a:dir)
  endif

  " If there is only one mark in the current file, then return the same
  if ( len(l:UsedMarks) == 1 )
    return l:MarksAt[0]
  endif

  if (( len(l:MarksAt) == 1 ) || !exists('b:sig_GotoMarkByAlpha_CurrMark'))
    let b:sig_GotoMarkByAlpha_CurrMark = l:MarksAt[0]
  endif

  for i in range(0, len(l:UsedMarks)-1)
    if l:UsedMarks[i][0] ==# b:sig_GotoMarkByAlpha_CurrMark
      if a:dir ==? "next"
        if i != len(l:UsedMarks)-1
          let l:mark = l:UsedMarks[i+1][0]
          let b:sig_GotoMarkByAlpha_CurrMark = l:mark
        elseif l:SignatureWrapJumps
          let l:mark = l:UsedMarks[0][0]
          let b:sig_GotoMarkByAlpha_CurrMark = l:mark
        endif
      elseif a:dir ==? "prev"
        if i != 0
          let l:mark = l:UsedMarks[i-1][0]
          let b:sig_GotoMarkByAlpha_CurrMark = l:mark
        elseif l:SignatureWrapJumps
          let l:mark = l:UsedMarks[-1][0]
          let b:sig_GotoMarkByAlpha_CurrMark = l:mark
        endif
      endif
      return l:mark
    endif
  endfor
endfunction
" }}}2

function! signature#GotoMarker( dir ) "               {{{2
  let l:lnum = line('.')
  let l:lmin = line('$') + 1
  let l:lmax = 0

  if     a:dir ==? "next" | let l:targ = l:lmin
  elseif a:dir ==? "prev" | let l:targ = l:lmax
  endif

  if has_key(b:sig_markers, l:lnum)
    let l:markers = keys(filter(copy(b:sig_markers), 'v:val==b:sig_markers[l:lnum]'))
  else
    let l:markers = keys(b:sig_markers)
  endif

  for i in l:markers
    if a:dir == "next" && i > l:lnum && i < l:targ ||
          \ a:dir == "prev" && i < l:lnum && i > l:targ
      let l:targ = i
    endif
    if i < l:lmin | let l:lmin = i | endif
    if i > l:lmax | let l:lmax = i | endif
  endfor

  if     a:dir == "next" && l:lnum >= l:lmax | let l:targ = l:lmin
  elseif a:dir == "prev" && l:lnum <= l:lmin | let l:targ = l:lmax
  endif

  if l:targ != 0 && l:targ != line('$') + 1
    execute 'normal! ' . l:targ . 'G'
  endif
endfunction
" }}}2


"
" Misc                                                {{{1
"
function! signature#Init() "                          {{{2
  " Description: Set up mapping-plugs

  " Plugs...
  nnoremap <silent> <Plug>SIG_PlaceNextMark    :call signature#ToggleMark(",")<CR>
  nnoremap <silent> <Plug>SIG_PurgeMarks       :call signature#PurgeMarks()<CR>
  nnoremap <silent> <Plug>SIG_NextSpotByAlpha  :call signature#GotoMark("alpha", "next", "spot")<CR>
  nnoremap <silent> <Plug>SIG_PrevSpotByAlpha  :call signature#GotoMark("alpha", "prev", "spot")<CR>
  nnoremap <silent> <Plug>SIG_NextLineByAlpha  :call signature#GotoMark("alpha", "next", "line")<CR>
  nnoremap <silent> <Plug>SIG_PrevLineByAlpha  :call signature#GotoMark("alpha", "prev", "line")<CR>
  nnoremap <silent> <Plug>SIG_NextSpotByPos    :call signature#GotoMark("pos", "next", "spot")<CR>
  nnoremap <silent> <Plug>SIG_PrevSpotByPos    :call signature#GotoMark("pos", "prev", "spot")<CR>
  nnoremap <silent> <Plug>SIG_NextLineByPos    :call signature#GotoMark("pos", "next", "line")<CR>
  nnoremap <silent> <Plug>SIG_PrevLineByPos    :call signature#GotoMark("pos", "prev", "line")<CR>
  nnoremap <silent> <Plug>SIG_NextMarkerByType :call signature#GotoMarker("next")<CR>
  nnoremap <silent> <Plug>SIG_PrevMarkerByType :call signature#GotoMarker("prev")<CR>
  nnoremap <silent> <Plug>SIG_PurgeMarkers     :call signature#PurgeMarkers()<CR>

  " Enable/disable mappings
  call signature#BufferMaps( 1 )

endfunction


function! signature#BufferMaps( mode ) "              {{{2
  " Description: Set up mappings
  " Arguments:   When mode = 0, disable mappings.
  "                   mode = 1, enable  mappings.

  " To prevent maps from being called again when re-entering a buffer
  if !exists('b:sig_map_set') | let b:sig_map_set = 0  | endif

  if ( a:mode && !b:sig_map_set ) "                   {{{

    " Create maps for marks a-z, A-Z
    for i in split( g:SignatureIncludeMarks, '\zs' )
      if maparg( g:SignatureMarkLeader . i, 'n' ) == ""
        silent exec 'nnoremap <buffer> <unique> <silent> ' . g:SignatureMarkLeader . i . ' :call signature#ToggleMark("' . i . '")<CR>'
      endif
    endfor

    " Create maps for markers !@#$%^&*()
    let s:signature_markers = split(g:SignatureIncludeMarkers, '\zs')
    for i in range(0, len(s:signature_markers)-1)
      if maparg( g:SignatureMarkerLeader . i, 'n' ) == ""
        exec 'sign define sig_Marker_' . i . ' text=' . s:signature_markers[i] . ' texthl=WarningMsg'
        silent exec 'nnoremap <buffer> <unique> <silent>' . g:SignatureMarkerLeader . i . ' :call signature#ToggleMarker("' . s:signature_markers[i] . '")<CR>'
        silent exec 'nnoremap <buffer> <unique> <silent>' . g:SignatureMarkerLeader . s:signature_markers[i] . ' :call signature#RemoveMarker("' . s:signature_markers[i] . '")<CR>'
      endif
    endfor

    " Using hasmapto() allows a flexibility to use custom mappings along with the default mappings.
    " Similarly, maparg() is used to ensure that mapping is created only if it is free
    " Thus, using both, we ensure that mapping is done only if RHS (<Plug>) is unmapped and LHS is unassigned

    if !hasmapto( '<Plug>SIG_PlaceNextMark' ) && maparg( g:SignatureMarkerLeader . ',', 'n' ) == ""
      exec 'nmap <buffer> ' . g:SignatureMarkLeader . ', <Plug>SIG_PlaceNextMark'
    endif
    if !hasmapto( '<Plug>SIG_PurgeMarks' ) && maparg( g:SignatureMarkerLeader . '<Space>', 'n' ) == ""
      exec 'nmap <buffer> ' . g:SignatureMarkLeader . '<Space> <Plug>SIG_PurgeMarks'
    endif
    if !hasmapto( '<Plug>SIG_PurgeMarkers' ) && maparg( g:SignatureMarkerLeader . '<BS>', 'n' ) == ""
      exec 'nmap <buffer> ' . g:SignatureMarkerLeader . '<BS> <Plug>SIG_PurgeMarkers'
    endif

    if !hasmapto( '<Plug>SIG_NextLineByAlpha' ) && maparg( "']", 'n' ) == ""
      nmap <buffer> '] <Plug>SIG_NextLineByAlpha
    endif
    if !hasmapto( '<Plug>SIG_PrevLineByAlpha' ) && maparg( "'[", 'n' ) == ""
      nmap <buffer> '[ <Plug>SIG_PrevLineByAlpha
    endif
    if !hasmapto( '<Plug>SIG_NextSpotByAlpha' ) && maparg( "`]", 'n' ) == ""
      nmap <buffer> `] <Plug>SIG_NextSpotByAlpha
    endif
    if !hasmapto( '<Plug>SIG_PrevSpotByAlpha' ) && maparg( "`[", 'n' ) == ""
      nmap <buffer> `[ <Plug>SIG_PrevSpotByAlpha
    endif
    if !hasmapto( '<Plug>SIG_NextLineByPos' ) && maparg( "]'", 'n' ) == ""
      nmap <buffer> ]' <Plug>SIG_NextLineByPos
    endif
    if !hasmapto( '<Plug>SIG_PrevLineByPos' ) && maparg( "['", 'n' ) == ""
      nmap <buffer> [' <Plug>SIG_PrevLineByPos
    endif
    if !hasmapto( '<Plug>SIG_NextSpotByPos') && maparg( "]`", 'n' ) == ""
      nmap <buffer> ]` <Plug>SIG_NextSpotByPos
    endif
    if !hasmapto( '<Plug>SIG_PrevSpotByPos' ) && maparg( "[`", 'n' ) == ""
      nmap <buffer> [` <Plug>SIG_PrevSpotByPos
    endif
    if !hasmapto( '<Plug>SIG_NextMarkerByType' ) && maparg( "]-", 'n' ) == ""
      nmap <buffer> ]- <Plug>SIG_NextMarkerByType
    endif
    if !hasmapto( '<Plug>SIG_PrevMarkerByType' ) && maparg( "[-", 'n' ) == ""
      nmap <buffer> [- <Plug>SIG_PrevMarkerByType
    endif

    "TODO Call SignRefresh after performing any action that affects marks to adjust the corresponding signs
    "nnoremap dd dd:call signature#SignRefresh()<CR>
    "vnoremap d   d:call signature#SignRefresh()<CR>
    "nnoremap u   u:call signature#SignRefresh()<CR>
    "nnoremap U   U:call signature#SignRefresh()<CR>
    "nnoremap J   J:call signature#SignRefresh()<CR>

    let b:sig_map_set = 1

  " }}}
  elseif ( a:mode == 0 && b:sig_map_set ) "           {{{
    " Remove mappings

    for i in split(g:SignatureIncludeMarks, '\zs')
      silent exec 'nunmap <buffer> <silent> ' . g:SignatureMarkLeader . i
    endfor

    let s:signature_markers = split(g:SignatureIncludeMarkers, '\zs')
    for i in range(0, len(s:signature_markers)-1)
      silent exec 'nunmap <buffer> ' . g:SignatureMarkerLeader . i
      silent exec 'nunmap <buffer> ' . g:SignatureMarkerLeader . s:signature_markers[i]
    endfor

    if hasmapto( '<Plug>SIG_PlaceNextMark' )
      exec 'nunmap <buffer> ' . signature#MapKey( '<Plug>SIG_PlaceNextMark', 'n' )
    endif
    if hasmapto( '<Plug>SIG_PurgeMarks' )
      exec 'nunmap <buffer> ' . signature#MapKey( '<Plug>SIG_PurgeMarks', 'n' )
    endif
    if hasmapto( '<Plug>SIG_PurgeMarkers' )
      exec 'nunmap <buffer> ' . signature#MapKey( '<Plug>SIG_PurgeMarkers', 'n' )
    endif
    if hasmapto( '<Plug>SIG_NextLineByAlpha'  )
      exec 'nunmap <buffer> ' . signature#MapKey( '<Plug>SIG_NextLineByAlpha' , 'n' )
    endif
    if hasmapto( '<Plug>SIG_PrevLineByAlpha'  )
      exec 'nunmap <buffer> ' . signature#MapKey( '<Plug>SIG_PrevLineByAlpha' , 'n' )
    endif
    if hasmapto( '<Plug>SIG_NextSpotByAlpha'  )
      exec 'nunmap <buffer> ' . signature#MapKey( '<Plug>SIG_NextSpotByAlpha' , 'n' )
    endif
    if hasmapto( '<Plug>SIG_PrevSpotByAlpha'  )
      exec 'nunmap <buffer> ' . signature#MapKey( '<Plug>SIG_PrevSpotByAlpha' , 'n' )
    endif
    if hasmapto( '<Plug>SIG_NextLineByPos'  )
      exec 'nunmap <buffer> ' . signature#MapKey( '<Plug>SIG_NextLineByPos'   , 'n' )
    endif
    if hasmapto( '<Plug>SIG_PrevLineByPos'  )
      exec 'nunmap <buffer> ' . signature#MapKey( '<Plug>SIG_PrevLineByPos'   , 'n' )
    endif
    if hasmapto( '<Plug>SIG_NextSpotByPos'  )
      exec 'nunmap <buffer> ' . signature#MapKey( '<Plug>SIG_NextSpotByPos'   , 'n' )
    endif
    if hasmapto( '<Plug>SIG_PrevSpotByPos'  )
      exec 'nunmap <buffer> ' . signature#MapKey( '<Plug>SIG_PrevSpotByPos'   , 'n' )
    endif
    if hasmapto( '<Plug>SIG_NextMarkerByType' )
      exec 'nunmap <buffer> ' . signature#MapKey( '<Plug>SIG_NextMarkerByType', 'n' )
    endif
    if hasmapto( '<Plug>SIG_PrevMarkerByType' )
      exec 'nunmap <buffer> ' . signature#MapKey( '<Plug>SIG_PrevMarkerByType', 'n' )
    endif

    let b:sig_map_set = 0

  endif " }}}
endfunction


function! signature#SignRefresh() "                   {{{2
  " Description: Add signs for new marks/marksers and remove signs for deleted marks/markers

  if !exists('b:sig_status')  | let b:sig_status  = 1  | endif

  " If Signature has been disabled, return
  if ( !b:sig_status ) | return | endif

  if !exists('b:sig_marks')   | let b:sig_marks   = {} | endif
  if !exists('b:sig_markers') | let b:sig_markers = {} | endif

  let l:SignatureIncludeMarks = ( exists('b:SignatureIncludeMarks') ? b:SignatureIncludeMarks : g:SignatureIncludeMarks )
  let l:used_marks = s:UsedMarks()

  " Remove signs for absent marks
  for i in split(l:SignatureIncludeMarks, '\zs')
    let l:pair = items(filter(copy(b:sig_marks), 'v:val =~# i'))
    if !empty(l:pair)
      let l:found = 0
      for j in l:used_marks
        if j[0] ==# i && j[1] == l:pair[0][0]
          let l:found = 1
          break
        endif
      endfor
      if !(l:found)
        call s:ToggleSign(i, 0, 0)
      endif
    endif
  endfor

  " Add signs for present marks
  for k in l:used_marks
    if !has_key(b:sig_marks, k[1])
      call s:ToggleSign(k[0], 1, k[1])
    elseif b:sig_marks[k[1]] !~# k[0]
      call s:ToggleSign(k[0], 0, 0)
      call s:ToggleSign(k[0], 1, k[1])
    endif
  endfor

  " Add signs for markers
  for i in keys(b:sig_markers)
    call s:ToggleSign(b:sig_markers[i], 1, i)
  endfor
endfunction


function! signature#Toggle( mode ) "                  {{{2
  " Description: Toggles and refreshes sign display in the buffer.
  " Arguments:   When mode = 1, toggle sign display.
  "                        = 0, don't toggle, preserve existing state. Useful for recreating maps when returning from
  "                             buffers in which Signature and its maps have been disabled

  if !exists('b:sig_marks')   | let b:sig_marks   = {} | endif
  " b:sig_marks   = { lnum:marks_str }
  if !exists('b:sig_markers') | let b:sig_markers = {} | endif
  " b:sig_markers = { lnum:marker }

  if !exists( 'b:sig_status' )
    let b:sig_status  = 1
  elseif ( a:mode )
    let b:sig_status = !b:sig_status
  endif

  " Enable/disable mappings
  call signature#BufferMaps( b:sig_status )

  if b:sig_status
    " Signature enabled ==> Refresh signs
    call signature#SignRefresh()
  else
    " Signature has been disabled
    for i in range(1, line('$'))
      let l:id = ( winbufnr(0) + 1 ) * i
      execute 'sign unplace ' . l:id
    endfor
    unlet b:sig_marks
  endif

endfunction
