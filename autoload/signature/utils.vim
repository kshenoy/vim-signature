" vim: fdm=marker:et:ts=4:sw=2:sts=2
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! signature#utils#NumericSort(x, y)                                                                       " {{{1
  return a:x - a:y
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
    let l:char = strpart(b:SignatureIncludeMarkers, l:in, 1)
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
    call signature#sign#ToggleDummy()
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
