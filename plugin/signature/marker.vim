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
        \        && (get(b:sig_markers, l:lnum, "") =~# escape( a:marker, '$^' ))
        \        )
        \      ? "remove" : "place"
        \      )
  call signature#sign#Toggle( a:marker, l:mode, l:lnum )
endfunction


function! signature#marker#Remove(lnum, marker)                                                                   " {{{2
  " Description: Remove marker from specified line number
  " Arguments:   lnum - Line no. to delete marker from. If is 0, removes marker from current line
  "              a:2  - Marker to delete. If not specified, obtains input from user

  if (get(b:sig_markers, a:lnum, '') =~ a:marker)
    call signature#sign#Toggle(a:marker, 'remove', a:lnum)
  endif
endfunction


function! signature#marker#Purge(...)                                                                             " {{{2
  " Description: If argument is given, removes marker only of the specified type else all markers are removed

  if empty(b:sig_markers) | return | endif
  if g:SignaturePurgeConfirmation
    let choice = confirm('Are you sure you want to delete all markers? This cannot be undone.', '&Yes\n&No', 1)
    if choice == 2 | return | endif
  endif

  if a:0 > 0
    let l:markers = [ a:1 ]
  else
    let l:markers = split(b:SignatureIncludeMarkers, '\zs')
  endif

  for l:marker in l:markers
    for l:lnum in keys(filter(copy(b:sig_markers), 'v:val =~# l:marker'))
      call signature#marker#Remove(l:lnum, l:marker)
    endfor
  endfor

  " If there are no marks and markers left, also remove the dummy sign
  if (len(b:sig_marks) + len(b:sig_markers) == 0)
    call signature#sign#ToggleDummy('remove')
  endif
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Navigation                                                                                                       {{{1
"
function! signature#marker#Goto( dir, type )                                                                      " {{{2
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
    let l:marker_lnums = sort(keys(filter(copy(b:sig_markers),
          \ 'strpart(v:val, 0, 1) == strpart(b:sig_markers[l:lnum], 0, 1)')), "signature#utils#NumericSort")
  else
    let l:marker_lnums = sort(keys(b:sig_markers), "signature#utils#NumericSort")
  endif

  if (a:dir ==? 'next')
    let l:targ = (b:SignatureWrapJumps ? min(l:marker_lnums) : l:lnum)
    for i in l:marker_lnums
      if i > l:lnum
        let l:targ = i
        break
      endif
    endfor
  elseif (a:dir ==? 'prev')
    let l:targ = (b:SignatureWrapJumps ? max(l:marker_lnums) : l:lnum)
    for i in l:marker_lnums
      if i < l:lnum
        let l:targ = i
        break
      endif
    endfor
  endif

  execute 'normal! ' . l:targ . 'G'
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Misc                                                                                                             {{{1
"
function! signature#marker#List(...)                                                                              " {{{2
  " Description: Opens and populates location list with markers from current buffer
  " Argument:    Show all markers in location list. If any particular marker is specified, list only that

  " If a:1 == 0                    ==> No count was specified, list all markers
  " If a:1 == ')'                  ==> List only the ')' marker
  " If a:1 == [1-9] or '!@#$%^&*(' ==> List the corresponding marker
  let l:marker = ''
  if (a:0 != '')
    let l:marker = a:1
    if (l:marker =~ '^\d$')
      let l:marker = (l:marker == 0 ? '' : split(')!@#$%^&*(', '\zs')[l:marker])
    endif
  endif
  if (  (l:marker != '')
   \ && (stridx(b:SignatureIncludeMarkers, l:marker) == -1)
   \ )
    return
  endif

  let l:list_map = map(
                   \   sort(
                   \     keys(l:marker != "" ? filter(copy(b:sig_markers), 'v:val == l:marker') : b:sig_markers),
                   \     'signature#utils#NumericSort'
                   \   ),
                   \   '{
                   \     "bufnr": ' . bufnr('%') . ',
                   \     "lnum" : v:val,
                   \     "col"  : 1,
                   \     "type" : "M",
                   \     "text" : b:sig_markers[v:val] . ": " . getline(v:val)
                   \   }'
                   \  )
  call setloclist(0, l:list_map,)|lopen
endfunction
" }}}2
