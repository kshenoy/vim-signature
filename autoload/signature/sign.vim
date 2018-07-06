" vim: fdm=marker:et:ts=4:sw=2:sts=2
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! signature#sign#Place(sign, lnum)                                                                         "{{{1
  " Description: Place signs for marks/markers on the specified line number
  " Arguments:
  "   sign : The mark/marker whose sign is to be placed
  "   lnum : Line number on/from which the sign is to be placed/removed

  "echom "DEBUG: sign = " . a:sign . ",  lnum = " . a:lnum

  " If Signature is not enabled, return
  if !b:sig_enabled | return | endif

  " FIXME: Highly inefficient. Needs work
  " Place sign only if there are no signs from other plugins (eg. syntastic)
  "let l:present_signs = s:GetInfo(1)
  "if (  b:SignatureDeferPlacement
  " \ && has_key(l:present_signs, a:lnum)
  " \ && (l:present_signs[a:lnum]['name'] !~# '^sig_Sign_')
  " \ )
  "  return
  "endif

  if signature#utils#IsValidMarker(a:sign)
    let b:sig_markers[a:lnum] = a:sign . get(b:sig_markers, a:lnum, "")
  elseif signature#utils#IsValidMark(a:sign)
    let b:sig_marks[a:lnum] = a:sign . get(b:sig_marks, a:lnum, "")
  else
    echoerr "Unexpected sign found: " . a:sign
  endif
  "}}}3

  call s:RefreshLine(a:lnum)
endfunction


function! signature#sign#Remove(sign, lnum)                                                                        "{{{1
  " Description: Remove signs for marks/markers from the specified line number
  " Arguments:
  "   sign : The mark/marker whose sign is to be placed/removed/toggled
  "   lnum : Line number from which the sign is to be removed
  "          If sign is a marker and lnum is 0, the sign will be removed from all lines
  "          If sign is a mark   and lnum is 0, the lnum will be found and the sign will be removed from that line

  "echom "DEBUG: sign = " . a:sign . ",  lnum = " . a:lnum

  " If Signature is not enabled, return
  if !b:sig_enabled | return | endif

  " Remove sign for markers
  if signature#utils#IsValidMarker(a:sign)
    let b:sig_markers[a:lnum] = substitute(b:sig_markers[a:lnum], "\\C" . escape( a:sign, '$^' ), "", "")

    " If there are no markers on the line, delete signs on that line
    if b:sig_markers[a:lnum] == ""
      call remove(b:sig_markers, a:lnum)
    endif
    call s:RefreshLine(a:lnum)

  " Remove sign for marks
  else
    " For marks, if a:lnum == 0, find out the line where the mark was placed
    if a:lnum == 0
      let l:arr = keys(filter(copy(b:sig_marks), 'v:val =~# a:sign'))
      if empty(l:arr) | return | endif
    else
      let l:arr = [a:lnum]
    endif
    if (v:version >= 800)
      call assert_true(len(l:arr) == 1, "Multiple marks found where one was expected")
    elseif (len(l:arr) != 1)
      echoerr "Multiple marks found where one was expected"
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
      call s:RefreshLine(l:lnum)
    endfor
  endif
endfunction


function! s:EvaluateHL(expr, lnum, ...)                                                                            "{{{1
  " Description: If expr points to a function, call it and use its output as the highlight group.
  "              If it is a string, use it directly.
  "              If the optional argument is specified, use it as a fallback. If not, return an empty string

  if type(a:expr) == type("")
    return a:expr
  elseif type(a:expr) == type(function("tr"))
    let l:retval = a:expr(a:lnum)
    if (l:retval != "")
      return l:retval
    endif
  endif

  return (a:0 > 0 ? a:1 : "")
endfunction


function! s:RefreshLine(lnum)                                                                                      "{{{1
  " Description: Decides what the sign string should be based on if there are any marks or markers (using b:sig_marks
  "              and b:sig_markers) on the current line and the value of b:SignaturePrioritizeMarks.
  " Arguments:
  "   lnum : Line number for which the sign string is to be modified

  let l:id  = abs(a:lnum * 1000 + bufnr('%'))
  let l:str = ""

  " Place the sign
  if ( has_key(b:sig_marks, a:lnum)
   \ && (  b:SignaturePrioritizeMarks
   \    || !has_key(b:sig_markers, a:lnum)
   \    )
   \ )
    let l:SignatureMarkTextHL = s:EvaluateHL(g:SignatureMarkTextHL, a:lnum, "SignatureMarkText")
    let l:SignatureMarkLineHL = s:EvaluateHL(g:SignatureMarkLineHL, a:lnum, "SignatureMarkLine")
    let l:str = substitute(b:SignatureMarkOrder, "\m", signature#utils#GetChar(b:sig_marks[a:lnum], 0), '')
    let l:str = substitute(l:str,                "\p", signature#utils#GetChar(b:sig_marks[a:lnum], 1), '')

    execute 'sign define Signature_' . l:str . ' text=' . l:str . ' texthl=' . l:SignatureMarkTextHL . ' linehl=' . l:SignatureMarkLineHL

  elseif has_key(b:sig_markers, a:lnum)
    let l:SignatureMarkerTextHL = s:EvaluateHL(g:SignatureMarkerTextHL, a:lnum, "SignatureMarkerText")
    let l:SignatureMarkerLineHL = s:EvaluateHL(g:SignatureMarkerLineHL, a:lnum, "SignatureMarkerLine")

    " Since the same marker can be placed on multiple lines, we can't use the same sign for all of them.
    " This is because if dynamic highlighting of markers is enabled then the sign placed on eg. a modified line should
    " be highlighted differently than the one placed on an unchanged line.
    " In order to support this, I append the name of the TextHL and LineHL group to the name of the sign.
    let l:txt = signature#utils#GetChar(b:sig_markers[a:lnum], 0)
    let l:str = l:txt . '_' . l:SignatureMarkerTextHL . '_' . l:SignatureMarkerLineHL

    execute 'sign define Signature_' . l:str . ' text=' . l:txt . ' texthl=' . l:SignatureMarkerTextHL . ' linehl=' . l:SignatureMarkerLineHL
  else
    call signature#sign#Unplace(a:lnum)
  endif

  if (l:str != "")
    execute 'sign place ' . l:id . ' line=' . a:lnum . ' name=Signature_' . l:str . ' buffer=' . bufnr('%')
  endif

  " If there is only 1 mark/marker in the file, place a dummy to prevent flickering of the gutter when it is moved
  " If there are no signs left, remove the dummy
  call signature#sign#ToggleDummy()
endfunction


function! signature#sign#Refresh(...)                                                                              "{{{1
  " Description: Add signs for new marks/markers and remove signs for deleted marks/markers
  " Arguments:   Specify an argument to force a sign refresh

  call s:InitializeVars(a:0 && a:1)
  " If Signature is not enabled, return
  if !b:sig_enabled | return | endif

  for i in signature#mark#GetList('free', 'buf_curr')
    " ... remove it
    call signature#sign#Remove(i, 0)
  endfor

  " Add signs for marks ...
  for [l:mark, l:lnum, _] in signature#mark#GetList('used', 'buf_curr')
    " ... if mark is not present in our b:sig_marks list or if it is present but at the wrong line,
    " remove the old sign and add a new one
    if (  !has_key(b:sig_marks, l:lnum)
     \ || (b:sig_marks[l:lnum] !~# l:mark)
     \ || a:0
     \ )
      call signature#sign#Remove(l:mark, 0)
      call signature#sign#Place (l:mark, l:lnum)
    endif
  endfor

  call signature#sign#ToggleDummy()

  " We do not add signs for markers as SignRefresh is executed periodically and we don't have a way to determine if the
  " marker already has a sign or not
endfunction


function! signature#sign#Unplace(lnum)                                                                             "{{{1
  " Description: Remove the sign from the specified line number
  " FIXME: Clean-up. Undefine the sign
  let l:id = abs(a:lnum * 1000 + bufnr('%'))
  silent! execute 'sign unplace ' . l:id
endfunction


function! signature#sign#ToggleDummy(...)                                                                          "{{{1
  " Description: Places a dummy sign to prevent flickering of the gutter when the mark is moved or the line containing
  "              a mark/marker is deleted and then the delete is undone
  " Arguments: (optional) 0 : force remove
  "                       1 : force place

  let l:place  = a:0 ?  a:1 : (len(b:sig_marks) + len(b:sig_markers) == 1) && !b:sig_DummyExists
  let l:remove = a:0 ? !a:1 : (len(b:sig_marks) + len(b:sig_markers) == 0) &&  b:sig_DummyExists

  if (l:place)
    sign define Signature_Dummy
    execute 'sign place 666 line=1 name=Signature_Dummy buffer=' . bufnr('%')
    let b:sig_DummyExists = 1
  elseif (l:remove)
    silent! execute 'sign unplace 666 buffer=' . bufnr('%')
    let b:sig_DummyExists = 0
  endif
endfunction


function! s:GetInfo(...)                                                                                           "{{{1
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


function! signature#sign#GetGitGutterHLGroup(lnum)                                                                 "{{{1
  " Description: This returns the highlight group used by vim-gitgutter depending on how the line was edited

  let l:current_bufnr = bufnr('%')
  let l:line_state = filter(copy(gitgutter#diff#process_hunks(l:current_bufnr, gitgutter#hunk#hunks(l:current_bufnr))), 'v:val[0] == a:lnum')

  if len(l:line_state) == 0
    return ""
  endif

  if     (l:line_state[0][1]) =~ 'added'            | return 'GitGutterAdd'
  elseif (l:line_state[0][1]) =~ 'modified_removed' | return 'GitGutterChangeDelete'
  elseif (l:line_state[0][1]) =~ 'modified'         | return 'GitGutterChange'
  elseif (l:line_state[0][1]) =~ 'removed'          | return 'GitGutterDelete'
  endif
endfunction


function! signature#sign#GetSignifyHLGroup(lnum)                                                                   "{{{1
  " Description: This returns the highlight group used by vim-signify depending on how the line was edited
  "              Thanks to @michaelmior

  if !exists('b:sy')
    return ""
  endif
  call sy#sign#get_current_signs(b:sy)

  if has_key(b:sy.internal, a:lnum)
    let l:line_state = b:sy.internal[a:lnum]['type']
    if     l:line_state =~ 'SignifyAdd'    | return 'SignifySignAdd'
    elseif l:line_state =~ 'SignifyChange' | return 'SignifySignChange'
    elseif l:line_state =~ 'SignifyDelete' | return 'SignifySignDelete'
    end
  endif

  return ""
endfunction


" function! signature#sign#GetMarkSignLine(mark)                                                                   "{{{1
"   if !signature#utils#IsValidMark(a:mark)
"     echoe "Signature: Invalid mark " . a:mark
"     return
"   endif

"   let l:sign_info=filter(split(execute('sign place'), '\n'),
"                        \ 'v:val =~ "\\vSignature_(.?' . a:mark . '|' . a:mark . '.?)$"')

"   if (len(l:sign_info) != 1)
"     echoe "Signature: Expected single match, found " . len(l:sign_info)
"     return
"   endif

"   return matchstr(l:sign_info[0], '\v(line\=)@<=\d+')
" endfunction


function! s:InitializeVars(...)                                                                                    "{{{1
  " Description: Initialize variables
  " Arguments:   Specify an argument to re-init

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

  call signature#utils#Set('b:sig_DummyExists'         , 0                          , a:0 && a:1)
  call signature#utils#Set('b:sig_enabled'             , g:SignatureEnabledAtStartup, a:0 && a:1)
  call signature#utils#Set('b:SignatureIncludeMarks'   , g:SignatureIncludeMarks    , a:0 && a:1)
  call signature#utils#Set('b:SignatureIncludeMarkers' , g:SignatureIncludeMarkers  , a:0 && a:1)
  call signature#utils#Set('b:SignatureMarkOrder'      , g:SignatureMarkOrder       , a:0 && a:1)
  call signature#utils#Set('b:SignaturePrioritizeMarks', g:SignaturePrioritizeMarks , a:0 && a:1)
  call signature#utils#Set('b:SignatureDeferPlacement' , g:SignatureDeferPlacement  , a:0 && a:1)
  call signature#utils#Set('b:SignatureWrapJumps'      , g:SignatureWrapJumps       , a:0 && a:1)
endfunction
