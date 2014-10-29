" vim: fdm=marker:et:ts=4:sw=2:sts=2
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! signature#mark#Remove(...)
  " Description: Remove 'mark' and its associated sign. If called without an argument, obtain it from the user
  " Arguments:   a:1 = [a-z,A-Z]

  let l:mark = (a:0 ? a:1 : nr2char(getchar()))

  " Sanity check: Return if mark is not an alphabet
  if stridx(b:SignatureIncludeMarks, l:mark) >= 0
    return;
  endif

  " Remove the sign (Only from current buffer)
  let l:lnum = line("'" . l:mark)

  if (!(  (l:lnum > 0)
   \   && (l:lnum < line('$'))
   \   )
   \ )
    return
  endif
  call signature#ToggleSign(l:mark, "remove", l:lnum)

  " Delete the mark
  execute 'delmarks ' . l:mark
  call signature#ForceGlobalMarkRemoval(l:mark)
endfunction


function! signature#mark#Place(mark)
  " Description: Place new mark at current cursor position
  " Arguments:   mark = [a-z,A-Z]
  execute 'normal! m' . a:mark
  call signature#ToggleSign( a:mark, "place", line('.'))
endfunction
