" vim: fdm=marker:et:ts=4:sw=2:sts=2
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Navigation                                                                                                       {{{1
"
function! signature#GotoMark( dir, loc, mode )                                                                    " {{{2
  " Arguments:
  "   dir  = next  : Jump forward
  "          prev  : Jump backward
  "   loc  = line  : Jump to first column of line with mark
  "          spot  : Jump to exact column of the mark
  "   mode = pos   : Jump to next mark by position
  "          alpha : Jump to next mark by alphabetical order

  call signature#Init()
  let l:mark = ""
  let l:dir  = a:dir

  if a:mode ==? "alpha"
    let l:mark = s:GotoMarkByAlpha(a:dir)
  elseif a:mode ==? "pos"
    let l:mark = s:GotoMarkByPos(a:dir)
  endif

  " NOTE: If l:mark is an empty string then no movement will be made
  if l:mark == "" | return | endif

  if a:loc ==? "line"
    execute "normal! '" . l:mark
  elseif a:loc ==? "spot"
    execute 'normal! `' . l:mark
  endif
endfunction


function! s:GotoMarkByPos( dir )                                                                                  " {{{2
  " Description: Jump to next/prev mark by location.
  " Arguments: dir = next : Jump forward
  "                  prev : Jump backward

  " We need at least one mark to be present. If not, then return an empty string so that no movement will be made
  if empty( b:sig_marks ) | return "" | endif

  let l:lnum = line('.')

  " Get list of line numbers of lines with marks.
  if a:dir ==? "next"
    let l:targ = min( sort( keys( b:sig_marks ), "s:NumericSort" ))
    let l:mark_lnums = sort( keys( filter( copy( b:sig_marks ), 'v:key > l:lnum')), "s:NumericSort" )
  elseif a:dir ==? "prev"
    let l:targ = max( sort( keys( b:sig_marks ), "s:NumericSort" ))
    let l:mark_lnums = reverse( sort( keys( filter( copy( b:sig_marks ), 'v:key < l:lnum')), "s:NumericSort" ))
  endif
  let l:targ = ( empty( l:mark_lnums ) && b:SignatureWrapJumps ? l:targ : l:mark_lnums[0] )
  let l:mark = strpart( b:sig_marks[l:targ], 0, 1 )

  return l:mark
endfunction


function! s:GotoMarkByAlpha( dir )                                                                                " {{{2
  " Description: Jump to next/prev mark by alphabetical order. Direction specified as input argument

  let l:used_marks = signature#MarksList( "used", "b" )
  let l:line_marks = signature#MarksList( line('.') )

  " If there is only one mark in the current file, then return the same
  if ( len(l:used_marks) == 1 )
    return l:used_marks[0][0]
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

  if (( len(l:line_marks) == 1 ) || !exists('b:sig_GotoMarkByAlpha_CurrMark') || (b:sig_GotoMarkByAlpha_CurrMark ==? ""))
    let b:sig_GotoMarkByAlpha_CurrMark = l:line_marks[0]
  endif

  for i in range( 0, len(l:used_marks) - 1 )
    if l:used_marks[i][0] ==# b:sig_GotoMarkByAlpha_CurrMark
      if a:dir ==? "next"
        if (( i != len(l:used_marks)-1 ) || b:SignatureWrapJumps)
          let b:sig_GotoMarkByAlpha_CurrMark = l:used_marks[(i+1)%len(l:used_marks)][0]
        endif
      elseif a:dir ==? "prev"
        if ((i != 0) || b:SignatureWrapJumps)
          let b:sig_GotoMarkByAlpha_CurrMark = l:used_marks[i-1][0]
        endif
      endif
      return b:sig_GotoMarkByAlpha_CurrMark
    endif
  endfor
endfunction


function! signature#GotoMarker( dir, type )                                                                       " {{{2
  " Description: Jump to next/prev marker by location.
  " Arguments: dir  = next : Jump forward
  "                   prev : Jump backward
  "            type = same : Jump to a marker of the same type
  "                   any  : Jump to a marker of any type

  call signature#Init()
  let l:lnum = line('.')

  " Get list of line numbers of lines with markers.
  " If current line has a marker, filter out line numbers of other markers ...
  if has_key( b:sig_markers, l:lnum ) && a:type ==? "same"
    let l:marker_lnums = sort( keys( filter( copy(b:sig_markers),
      \ 'strpart(v:val, 0, 1) == strpart(b:sig_markers[l:lnum], 0, 1)' )), "s:NumericSort" )
  else
    let l:marker_lnums = sort( keys( b:sig_markers ), "s:NumericSort" )
  endif

  if a:dir ==? "next"
    let l:targ = ( b:SignatureWrapJumps ? min( l:marker_lnums ) : l:lnum )
    for i in l:marker_lnums
      if i > l:lnum
        let l:targ = i
        break
      endif
    endfor

  elseif a:dir ==? "prev"
    let l:targ = ( b:SignatureWrapJumps ? max( l:marker_lnums ) : l:lnum )
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


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Toggle Marks/Signs                                                                                               {{{1
"
function! signature#Input()                                                                                       " {{{2
  " Description: Grab input char

  call signature#Init()

  " ... if not, obtain input from user ...
  let l:ascii = getchar()
  let l:char  = nr2char( l:ascii )

  " ... if the input is not a number eg. '!' ==> Delete all '!' markers
  if stridx( b:SignatureIncludeMarkers, l:char ) >= 0
    return signature#PurgeMarkers( l:char )
  endif

  " ... but if input is a number, convert it to corresponding marker before proceeding
  if match( l:char, '\d' ) >= 0
    let l:char = split( ")!@#$%^&*(", '\zs' )[l:char]
  endif

  if stridx( b:SignatureIncludeMarkers, l:char ) >= 0
    return s:ToggleMarker( l:char )
  elseif stridx( b:SignatureIncludeMarks, l:char ) >= 0
    return signature#ToggleMark( l:char )
  else
    " l:char is probably one of `'[]<>
    execute 'normal! m' . l:char
  endif
endfunction


function! signature#ToggleMarkAtLine()                                                                            " {{{2
  " Description: If no mark on current line, add one. If marks are on the
  " current line, remove one.
  let l:lnum = line('.')
  " get list of marks wt this line (from s:MarksAt())
  let l:marks_here = join(map(filter(signature#LocalMarkList(), 'v:val[1]==' . l:lnum), 'v:val[0]'), '')
  if empty(l:marks_here)
    " set up for adding a mark
    call signature#ToggleMark('next')
    return
  else
    " delete one mark
    call signature#ToggleMark(l:marks_here[0])
    return
  endif
endfunction


function! signature#PurgeMarksAtLine()                                                                            " {{{2
  " Description: If no mark on current line, add one. If marks are on the
  " current line, remove one.
  let l:lnum = line('.')
  " get list of marks wt this line (from s:MarksAt())
  let l:marks_here = map(filter(signature#LocalMarkList(), 'v:val[1]==' . l:lnum), 'v:val[0]')
  if !empty(l:marks_here)
    " delete one mark
    for l:mark in l:marks_here
      call signature#ToggleMark(l:mark)
    endfor
    return
  endif
endfunction


function! signature#ToggleMark( mark )                                                                            " {{{2
  " Description: mark = 'next' : Place new mark on current line else toggle specified mark on current line
  " Arguments:   mark [a-z,A-Z]

  let l:lnum = line('.')

  if a:mark == "next"
    " Place new mark
    let l:marks_list = signature#MarksList( 'free', 'g' )
    if empty(l:marks_list)
      if g:SignatureUnconditionallyRecycleMarks
        " Reuse existing mark
        let l:used_marks = s:UsedMarks()
        if empty(l:used_marks)
          " no existing mark available
          call s:ReportNoAvailableMarks()
          return
        else
          " reuse first used mark
          call signature#ToggleMark(l:used_marks[0])
          return
        endif
      else
        " no marks available and mark re-use not in effect
        call s:ReportNoAvailableMarks()
        return
      endif
    endif
    let l:mark = l:marks_list[0]

    execute 'normal! m' . l:mark
    call signature#ToggleSign( l:mark, "place", l:lnum )

  else
    " Toggle Mark
    let l:mark = a:mark
    let l:mark_pos = 0
    let l:mark_buf = bufnr('%')
    let l:used_marks = filter( signature#MarksList( 'used', 'g' ), 'v:val[0] ==# l:mark' )
    if ( len(l:used_marks) > 0 )
      let l:mark_pos = l:used_marks[0][1]
      let l:mark_buf = l:used_marks[0][2]
    endif

    if ( l:mark_buf == bufnr('%') ) && ( l:mark_pos == l:lnum )
      " Mark is present on the current line. Remove it and return
      execute 'delmarks ' . l:mark
      call signature#ToggleSign( l:mark, "remove", l:lnum )
      call signature#ForceGlobalMarkRemoval( l:mark )
      return

    else
      " Mark is not present on current line but it may be present somewhere else. We first place the new sign and only
      " then remove the old sign to avoid shifting of Foldcolumn if there is only 1 mark placed.

      " Ask for confirmation before moving mark. l:mark_pos != 0 indicates that the mark was used.
      if (  g:SignatureDeleteConfirmation && ( l:mark_pos != 0 ))
        let choice = confirm("Mark '" . l:mark . "' has been used elsewhere. Reuse it?", "&Yes\n&No", 1)
        if choice == 2 | return | endif
      endif

      " Place new sign
      execute 'normal! m' . l:mark
      call signature#ToggleSign( l:mark, "place", l:lnum )

      " If not, we have to remove the sign for the original mark
      if ( l:mark_buf == bufnr('%') ) && ( l:mark_pos != 0 )
        call signature#ToggleSign( l:mark, "remove", l:mark_pos )
      endif
    endif
  endif
endfunction


function! signature#ForceGlobalMarkRemoval( mark )
  " Description: Edit .viminfo file to forcibly delete Global mark since vim's handling is iffy
  " Arguments:   mark - The mark to delete

  if a:mark !~# '[A-Z]'
    return
  endif
  if !g:SignatureForceRemoveGlobal
    return
  endif

  if has('unix')
    let l:filename = expand($HOME . '/.viminfo')
  else
    let l:filename = expand($HOME . '/_viminfo')
  endif
  if filewritable(l:filename) == 1
    let l:lines = readfile(l:filename, 'b')
    call filter(l:lines, 'v:val !~ "^''' . a:mark. '"')
    if has('win32')
      " for some reason writefile(_viminfo) only works after editing directly
      exe "noautocmd split " . l:filename
      noautocmd write
      noautocmd bdelete
    endif
    call writefile(l:lines, l:filename, 'b')
  else
      echohl WarningMsg
      echomsg "Signature: Unable to read/write .viminfo ('" . l:filename . "')"
      echohl None
  endif
endfunction


function! signature#PurgeMarks()                                                                                  " {{{2
  " Description: Remove all marks

  let l:used_marks = signature#MarksList( "used", "b" )
  if empty( l:used_marks ) | return | endif

  if g:SignaturePurgeConfirmation
    let choice = confirm("Are you sure you want to delete all marks? This cannot be undone.", "&Yes\n&No", 1)
    if choice == 2 | return | endif
  endif

  for i in l:used_marks
    silent execute 'delmarks ' . i[0]
    silent call signature#ToggleSign( i[0], "remove", i[1] )
    call signature#ForceGlobalMarkRemoval(i[0])
  endfor

  " If there are no marks and markers left, also remove the dummy sign
  if len(b:sig_marks) + len(b:sig_markers) == 0
    call signature#ToggleSignDummy( 'remove' )
  endif
endfunction


function! s:ToggleMarker( marker )                                                                                " {{{2
  " Description: Toggle marker on current line
  " Arguments: marker [!@#$%^&*()]

  let l:lnum = line('.')
  " If marker is found in on current line, remove it, else place it
  let l:mode = ( get( b:sig_markers, l:lnum, "" ) =~# escape( a:marker, '$^' ) ? "remove" : "place" )
  call signature#ToggleSign( a:marker, l:mode, l:lnum )
endfunction


function! signature#PurgeMarkers(...)                                                                             " {{{2
  " Description: If argument is given, removes marker only of the specified type else all markers are removed

  if empty( b:sig_markers ) | return | endif

  if g:SignaturePurgeConfirmation
    let choice = confirm("Are you sure you want to delete all markers? This cannot be undone.", "&Yes\n&No", 1)
    if choice == 2 | return | endif
  endif

  if a:0 > 0
    let l:markers = [ a:1 ]
  else
    let l:markers = split( b:SignatureIncludeMarkers, '\zs' )
  endif

  for l:marker in l:markers
    for l:lnum in keys( filter( copy(b:sig_markers), 'v:val =~# l:marker' ))
      call signature#ToggleSign( l:marker, "remove", l:lnum )
    endfor
  endfor

  " If there are no marks and markers left, also remove the dummy sign
  if len(b:sig_marks) + len(b:sig_markers) == 0
    call signature#ToggleSignDummy( 'remove' )
  endif
endfunction


function! signature#Toggle()                                                                                      " {{{2
  " Description: Toggles and refreshes sign display in the buffer.

  call signature#Init()

  if b:sig_enabled
    " Signature enabled ==> Refresh signs
    call signature#SignRefresh()

    " Add signs for markers ...
    for i in keys( b:sig_markers )
      call signature#ToggleSign( b:sig_markers[i], "place", i )
    endfor
  else
    " Signature disabled ==> Remove signs
    for i in keys( b:sig_markers )
      let l:id = i * 1000 + bufnr('%')
      silent! execute 'sign unplace ' . l:id
    endfor
    for i in keys( b:sig_marks )
      let l:id = i * 1000 + bufnr('%')
      silent! execute 'sign unplace ' . l:id
    endfor
    unlet b:sig_marks
  endif
endfunction
" }}}2


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Misc Functions                                                                                                   {{{1
"
function! s:NumericSort(x, y)                                                                                     " {{{2
  return a:x - a:y
endfunction


function! signature#SignInfo(...)                                                                                 " {{{2
  " Description: Returns a dictionary of filenames, each of which is dictionary of line numbers on which signs are placed
  " Arguments: filename (optional).
  "            If filename is provided, the return value will contain signs only present in the given file
  " Eg. {
  "       'vimrc': {
  "         '711': {
  "           'id': '1422',
  "           'name': 'sig_Sign_1422'
  "         },
  "         '676': {
  "           'id': '1352',
  "           'name': 'sig_Sign_1352'
  "         }
  "       }
  "     }

  " Redirect the input to a variable
  redir => l:sign_str
  silent! sign place
  redir END

  " Create a Hash of files to store the info.
  let l:signs_dic = {}
  " The file that is currently being processed is stored into l:file
  let l:match_file = ""
  let l:file_found = 0

  " Split the string into an array of sentences and filter out empty lines
  for i in filter( split( l:sign_str, '\n' ), 'v:val =~ "^[S ]"' )
    let l:temp_file = matchstr( i, '\v(Signs for )@<=\S+:@=' )

    if l:temp_file != ""
      let l:match_file = l:temp_file
      let l:signs_dic[l:match_file] = {}
    elseif l:match_file != ""
      " Get sign info
      let l:info_match = matchlist( i, '\vline\=(\d+)\s*id\=(\S+)\s*name\=(\S+)' )
      if !empty( l:info_match )
        let l:signs_dic[l:match_file][l:info_match[1]] = {
          \ 'id'   : l:info_match[2],
          \ 'name' : l:info_match[3],
          \ }
      endif
    endif
  endfor

  if a:0
    "" Search for the full path first in the hash ...
    "let l:curr_filepath = expand('%:p')
    "if has_key( l:signs_dic, l:curr_filepath )
    "  return filter( l:signs_dic, 'v:key ==# l:curr_filepath' )[l:curr_filepath]
    "else
    " ... if no entry is found for the full path, search for the filename in the hash ...
    " Since we're searching for the current file, if present in the hash, it'll be as a filename and not the full path
    let l:curr_filename = expand('%:t')
    if has_key( l:signs_dic, l:curr_filename )
      return filter( l:signs_dic, 'v:key ==# l:curr_filename' )[l:curr_filename]
    endif

    " ... if nothing is found, then return an empty hash to indicate that no signs are present in the current file
    return {}
  endif

  return l:signs_dic
endfunction


function! s:ReportNoAvailableMarks()                                                                              " {{{2
    if g:SignatureErrorIfNoAvailableMarks
      echoe "Signature: No free marks left."
    else
      echohl WarningMsg
      echomsg "Signature: No free marks left."
      echohl None
    endif
endfunction


" Patched-in support fron Nark-Tools                                                                              " {{{2
let s:local_marks_nlist = split("abcdefghijklmnopqrstuvwxyz", '\zs')


function! signature#LocalMarkList()                                                                               " {{{2
  return map(copy(s:local_marks_nlist), '[v:val, line("''" . v:val)]')
endfunction


function! s:MarksAt(pos)                                                                                          " {{{2
  return join(map(filter(signature#LocalMarkList(), 'v:val[1]==' . a:pos), 'v:val[0]'), '')
endfunction


function! s:UsedMarks()                                                                                           " {{{2
  return join(map(signature#LocalMarkList(), '(v:val[1]>0 ? v:val[0] : " ")'),'')
endfunction


function! signature#ListLocalMarks()                                                                              " {{{2
  " Description: Opens and populates location list with local marks
    call setloclist(0,
                \filter(
                \map(
                \copy(s:local_marks_nlist),
                \'{"bufnr": bufnr("%"), "lnum": line("''" . v:val), "col": col("''" . v:val),
                \"type": "m", "text": v:val . ": " . getline(line("''" . v:val))}'),
                \'v:val.lnum > 0'))
    lopen
    if !exists("g:signature_set_location_list_convenience_maps") || g:signature_set_location_list_convenience_maps
        nnoremap <buffer> <silent> q        :q<CR>
        noremap  <buffer> <silent> <ESC>    :q<CR>
        noremap  <buffer> <silent> <ENTER>  <CR>:lcl<CR>
    endif
endfunction
