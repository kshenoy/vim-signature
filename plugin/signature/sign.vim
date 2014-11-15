" vim: fdm=marker:et:ts=4:sw=2:sts=2
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! signature#sign#Toggle(sign, mode, lnum)                                                                 " {{{2
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
  "let l:present_signs = signature#sign#GetInfo(1)
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
    let l:SignatureMarkLineHL = eval( g:SignatureMarkLineHL )
    let l:SignatureMarkTextHL = eval( g:SignatureMarkTextHL )
    execute 'sign define Signature_' . l:str . ' text=' . l:str . ' texthl=' . l:SignatureMarkTextHL . ' linehl=' . l:SignatureMarkLineHL

  elseif has_key( b:sig_markers, l:lnum )
    let l:str = strpart( b:sig_markers[l:lnum], 0, 1 )

    " If g:SignatureMarkerTextHL points to a function, call it and use its output as the highlight group.
    " If it is a string, use it directly
    let l:SignatureMarkLineHL = eval( g:SignatureMarkLineHL )
    let l:SignatureMarkerTextHL = eval( g:SignatureMarkerTextHL )
    execute 'sign define Signature_' . l:str . ' text=' . l:str . ' texthl=' . l:SignatureMarkerTextHL . ' linehl=' . l:SignatureMarkLineHL

  else
    " FIXME: Clean-up. Undefine the sign
    execute 'sign unplace ' . l:id
    return
  endif
  execute 'sign place ' . l:id . ' line=' . l:lnum . ' name=Signature_' . l:str . ' buffer=' . bufnr('%')

  " If there is only 1 mark/marker in the file, also place a dummy sign to prevent flickering of the gutter
  if len(b:sig_marks) + len(b:sig_markers) == 1
    call signature#sign#ToggleDummy( 'place' )
  endif
endfunction


function! signature#sign#Refresh(...)                                                                             " {{{2
  " Description: Add signs for new marks/markers and remove signs for deleted marks/markers
  " Arguments: '1' to force a sign refresh

  call signature#utils#Init()
  " If Signature is not enabled, return
  if !b:sig_enabled | return | endif

  for i in signature#mark#GetList('free', 'buf_curr')
    " ... remove it
    call signature#sign#Toggle( i, "remove", 0 )
  endfor

  " Add signs for marks ...
  for j in signature#mark#GetList('used', 'buf_curr')
    " ... if mark is not present in our b:sig_marks list or if it is present but at the wrong line,
    " remove the old sign and add a new one
    if !has_key( b:sig_marks, j[1] ) || b:sig_marks[j[1]] !~# j[0] || a:0
      call signature#sign#Toggle( j[0], "remove", 0    )
      call signature#sign#Toggle( j[0], "place" , j[1] )
    endif
  endfor

  " We do not add signs for markers as SignRefresh is executed periodically and we don't have a way to determine if the
  " marker already has a sign or not
endfunction


function! signature#sign#ToggleDummy(mode)                                                                        " {{{2
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


function! signature#sign#GetInfo(...)                                                                             " {{{2
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
