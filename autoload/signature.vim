" vim: fdm=marker:et:ts=4:sw=2:sts=2
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! signature#Input()                                                                                       " {{{2
  " Description: Grab input char

  " Obtain input from user ...
  let l:char = nr2char(getchar())

  " ... if the input is not a number eg. '!' ==> Delete all '!' markers
  if stridx( b:SignatureIncludeMarkers, l:char ) >= 0
    return signature#marker#Purge( l:char )
  endif

  " ... but if input is a number, convert it to corresponding marker before proceeding
  if match( l:char, '\d' ) >= 0
    let l:char = split( ")!@#$%^&*(", '\zs' )[l:char]
  endif

  if stridx( b:SignatureIncludeMarkers, l:char ) >= 0
    return signature#marker#Toggle( l:char )
  elseif stridx( b:SignatureIncludeMarks, l:char ) >= 0
    return signature#mark#Toggle( l:char )
  else
    " l:char is probably one of `'[]<>
    execute 'normal! m' . l:char
  endif
endfunction


function! signature#Toggle()                                                                                      " {{{2
  " Description: Toggles and refreshes sign display in the buffer.

  call signature#Init()
  let b:sig_enabled = !b:sig_enabled

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
    " Also remove the dummy sign
    call signature#ToggleSignDummy('remove')
  endif
endfunction
" }}}2


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Misc Functions                                                                                                   {{{1
"
function! signature#NumericSort(x, y)                                                                                     " {{{2
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
