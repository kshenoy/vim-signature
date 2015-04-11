" vim: fdm=marker:et:ts=4:sw=2:sts=2
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! signature#sign#Place(sign, lnum)                                                                        " {{{1
  " Description: Place signs for marks/markers on the specified line number
  " Arguments:
  "   sign : The mark/marker whose sign is to be placed
  "   lnum : Line number on/from which the sign is to be placed/removed

  "echom "DEBUG: sign = " . a:sign . ",  lnum = " . a:lnum

  " If Signature is not enabled, return
  if !b:sig_enabled | return | endif

  " FIXME: Highly inefficient. Needs work
  " Place sign only if there are no signs from other plugins (eg. syntastic)
  "let l:present_signs = signature#sign#GetInfo(1)
  "if (  b:SignatureDeferPlacement
  " \ && has_key(l:present_signs, a:lnum)
  " \ && (l:present_signs[a:lnum]['name'] !~# '^sig_Sign_')
  " \ )
  "  return
  "endif

  if stridx( b:SignatureIncludeMarkers, a:sign ) >= 0
    let b:sig_markers[a:lnum] = a:sign . get(b:sig_markers, a:lnum, "")
  else
    let b:sig_marks[a:lnum] = a:sign . get(b:sig_marks, a:lnum, "")
  endif
  "}}}3

  call signature#sign#RefreshLine(a:lnum)
endfunction


function! signature#sign#Remove(sign, lnum)                                                                       " {{{1
  " Description: Remove signs for marks/markers from the specified line number
  " Arguments:
  "   sign : The mark/marker whose sign is to be placed/removed/toggled
  "   lnum : Line number from which the sign is to be removed
  "          If line number is 0, the 'sign' will be removed from all lines

  "echom "DEBUG: sign = " . a:sign . ",  lnum = " . a:lnum

  " If Signature is not enabled, return
  if !b:sig_enabled | return | endif

  " Remove sign for markers
  if stridx( b:SignatureIncludeMarkers, a:sign ) >= 0
    let b:sig_markers[a:lnum] = substitute(b:sig_markers[a:lnum], "\\C" . escape( a:sign, '$^' ), "", "")

    " If there are no markers on the line, delete signs on that line
    if b:sig_markers[a:lnum] == ""
      call remove(b:sig_markers, a:lnum)
    endif
    call signature#sign#RefreshLine(a:lnum)

  " Remove sign for marks
  else
    " If a:lnum == 0, remove from all lines
    if a:lnum == 0
      let l:arr = keys(filter(copy(b:sig_marks), 'v:val =~# a:sign'))
      if empty(l:arr) | return | endif
    else
      let l:arr = [a:lnum]
    endif

    for l:lnum in l:arr
      " FIXME: Placed guard to avoid triggering issue #53
      if has_key(b:sig_marks, l:lnum)
        let b:sig_marks[l:lnum] = substitute(b:sig_marks[l:lnum], "\\C" . a:sign, "", "")
        " If there are no marks on the line, delete signs on that line
        if b:sig_marks[l:lnum] == ""
          call remove(b:sig_marks, l:lnum)
        endif
      endif
      call signature#sign#RefreshLine(l:lnum)
    endfor
  endif
endfunction


function! signature#sign#RefreshLine(lnum)                                                                        " {{{1
  " Description: Decides what the sign string should be based on if there are any marks or markers (using b:sig_marks
  "              and b:sig_markers) on the current line and the value of b:SignaturePrioritizeMarks.
  " Arguments:
  "   lnum : Line number for which the sign string is to be modified

  let l:id = a:lnum * 1000 + bufnr('%')

  " Place the sign
  if ( has_key(b:sig_marks, a:lnum)
   \ && (  b:SignaturePrioritizeMarks
   \    || !has_key(b:sig_markers, a:lnum)
   \    )
   \ )
    let l:str = substitute(b:SignatureMarkOrder, "\m", strpart( b:sig_marks[a:lnum], 0, 1 ), "")
    let l:str = substitute(l:str,                "\p", strpart( b:sig_marks[a:lnum], 1, 1 ), "")

    " If g:SignatureMarkTextHL points to a function, call it and use its output as the highlight group.
    " If it is a string, use it directly
    let l:SignatureMarkLineHL = eval( g:SignatureMarkLineHL )
    let l:SignatureMarkTextHL = eval( g:SignatureMarkTextHL )
    execute 'sign define Signature_' . l:str . ' text=' . l:str . ' texthl=' . l:SignatureMarkTextHL . ' linehl=' . l:SignatureMarkLineHL

  elseif has_key(b:sig_markers, a:lnum)
    let l:str = strpart(b:sig_markers[a:lnum], 0, 1)

    " If g:SignatureMarkerTextHL points to a function, call it and use its output as the highlight group.
    " If it is a string, use it directly
    let l:SignatureMarkerLineHL = eval( g:SignatureMarkerLineHL )
    let l:SignatureMarkerTextHL = eval( g:SignatureMarkerTextHL )
    execute 'sign define Signature_' . l:str . ' text=' . l:str . ' texthl=' . l:SignatureMarkerTextHL . ' linehl=' . l:SignatureMarkerLineHL

  else
    " FIXME: Clean-up. Undefine the sign
    call signature#sign#Unplace(a:lnum)
    return
  endif
  execute 'sign place ' . l:id . ' line=' . a:lnum . ' name=Signature_' . l:str . ' buffer=' . bufnr('%')

  " If there is only 1 mark/marker in the file, place a dummy to prevent flickering of the gutter when it is moved
  call signature#sign#ToggleDummy('place')
endfunction


function! signature#sign#Refresh(...)                                                                             " {{{1
  " Description: Add signs for new marks/markers and remove signs for deleted marks/markers
  " Arguments: '1' to force a sign refresh

  call signature#utils#Init()
  " If Signature is not enabled, return
  if !b:sig_enabled | return | endif

  for i in signature#mark#GetList('free', 'buf_curr')
    " ... remove it
    call signature#sign#Remove(i, 0)
  endfor

  " Add signs for marks ...
  for j in signature#mark#GetList('used', 'buf_curr')
    " ... if mark is not present in our b:sig_marks list or if it is present but at the wrong line,
    " remove the old sign and add a new one
    if !has_key(b:sig_marks, j[1]) || b:sig_marks[j[1]] !~# j[0] || a:0
      call signature#sign#Remove(j[0], 0   )
      call signature#sign#Place (j[0], j[1])
    endif
  endfor

  " We do not add signs for markers as SignRefresh is executed periodically and we don't have a way to determine if the
  " marker already has a sign or not
endfunction


function! signature#sign#Unplace(lnum)                                                                            " {{{1
  " Description: Remove the sign from the specified line number
  let l:id = a:lnum * 1000 + bufnr('%')
  silent! execute 'sign unplace ' . l:id
endfunction


function! signature#sign#ToggleDummy(...)                                                                         " {{{1
  " Description: Places a dummy sign to prevent flickering of the gutter when the mark is moved or the line containing
  "              a mark/marker is deleted and then the delete is undone
  " Arguments:   a:1 (place/remove) - Force mode

  if (a:0)
    let l:place  = (a:1 =~# 'place' )
    let l:remove = (a:1 =~# 'remove')
  else
    let l:place  = (len(b:sig_marks) + len(b:sig_markers) == 1)
    let l:remove = (len(b:sig_marks) + len(b:sig_markers) == 0)
  endif

  if (l:place)
    sign define Signature_Dummy
    execute 'sign place 666 line=1 name=Signature_Dummy buffer=' . bufnr('%')
  elseif (l:remove)
    silent! execute 'sign unplace 666 buffer=' . bufnr('%')
  endif
endfunction


function! signature#sign#GetInfo(...)                                                                             " {{{1
  " Description: Returns a dic of filenames, each of which is a dic of line numbers on which signs are placed
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


function! signature#sign#GetGitGutterHLGroup(lnum)
  " Description: This returns the highlight group used by vim-gitgutter depending on how the line was edited

  let l:line_state = filter(copy(gitgutter#diff#process_hunks(gitgutter#hunk#hunks())), 'v:val[0] == a:lnum')

  if len(l:line_state) == 0
    return 'Exception'
  endif

  if l:line_state[0][1] =~ 'added'
    return 'GitGutterAdd'
  elseif l:line_state[0][1] =~ 'modified'
    return 'GitGutterChange'
  elseif l:line_state[0][1] =~ 'removed'
    return 'GitGutterDelete'
  endif
endfunction


function! signature#sign#GetSignifyHLGroup(lnum)
  " Description: This returns the highlight group used by vim-signify depending on how the line was edited
  "              Thanks to @michaelmior

  call sy#sign#get_current_signs()

  if has_key(b:sy.internal, a:lnum)
    let type = b:sy.internal[a:lnum]['type']
    if type =~ 'SignifyAdd'
      return 'DiffAdd'
    elseif type =~ 'SignifyChange'
      return 'DiffChange'
    elseif type =~ 'SignifyDelete'
      return 'DiffDelete'
    end
  else
    return 'Exception'
  endif
endfunction
