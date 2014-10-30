" vim: fdm=marker:et:ts=4:sw=2:sts=2
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Place/Remove/Toggle                                                                                              {{{1
"
function! signature#marker#Toggle(marker)                                                                         " {{{2
  " Description: Toggle marker on current line
  " Arguments: marker [!@#$%^&*()]

  let l:lnum = line('.')
  " If marker is found in on current line, remove it, else place it
  let l:mode = ( (  !g:SignatureForceMarkerPlacement
        \   && (get( b:sig_markers, l:lnum, "" ) =~# escape( a:marker, '$^' ))
        \   )
        \ ? "remove" : "place"
        \ )
  call signature#ToggleSign( a:marker, l:mode, l:lnum )
endfunction


function! signature#marker#Purge(...)                                                                             " {{{2
  " Description: If argument is given, removes marker only of the specified type else all markers are removed

  if empty(b:sig_markers) | return | endif
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
  if (len(b:sig_marks) + len(b:sig_markers) == 0)
    call signature#ToggleSignDummy('remove')
  endif
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Navigation                                                                                                       {{{1
"
function! signature#marker#Goto( dir, type )                                                                     " {{{2
  " Description: Jump to next/prev marker by location.
  " Arguments: dir  = next : Jump forward
  "                   prev : Jump backward
  "            type = same : Jump to a marker of the same type
  "                   any  : Jump to a marker of any type

  let l:lnum = line('.')

  " Get list of line numbers of lines with markers.
  " If current line has a marker, filter out line numbers of other markers ...
  if (  has_key(b:sig_markers, l:lnum)
   \ && (a:type ==? 'same')
   \ )
    let l:marker_lnums = sort( keys( filter( copy(b:sig_markers),
          \ 'strpart(v:val, 0, 1) == strpart(b:sig_markers[l:lnum], 0, 1)' )), "signature#NumericSort" )
  else
    let l:marker_lnums = sort( keys( b:sig_markers ), "signature#NumericSort" )
  endif

  if (a:dir ==? 'next')
    let l:targ = ( b:SignatureWrapJumps ? min( l:marker_lnums ) : l:lnum )
    for i in l:marker_lnums
      if i > l:lnum
        let l:targ = i
        break
      endif
    endfor
  elseif (a:dir ==? 'prev')
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
