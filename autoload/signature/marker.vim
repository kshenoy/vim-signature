" vim: fdm=marker:et:ts=4:sw=2:sts=1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! signature#marker#Toggle(marker)                                                                         " {{{1
  " Description: Toggle marker on current line
  " Arguments: marker [!@#$%^&*()]

  let l:lnum = line('.')
  " If marker is found on current line, remove it, else place it
  if (  (get(b:sig_markers, l:lnum, "") =~# escape(a:marker, '$^'))
   \ && !g:SignatureForceMarkerPlacement
   \ )
    call signature#sign#Remove(a:marker, l:lnum)
    call signature#sign#ToggleDummy()
  else
    call signature#sign#Place(a:marker, l:lnum)
  endif
endfunction


function! signature#marker#Remove(lnum, marker)                                                                   " {{{1
  " Description: Remove marker from specified line number
  " Arguments:   lnum - Line no. to delete marker from. If is 0, removes marker from current line
  "              a:2  - Marker to delete. If not specified, obtains input from user

  if (get(b:sig_markers, a:lnum, '') =~ a:marker)
    call signature#sign#Remove(a:marker, a:lnum)
  endif
endfunction


function! signature#marker#Purge(...)                                                                             " {{{1
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
  call signature#sign#ToggleDummy()
endfunction


function! signature#marker#Goto( dir, marker_num, count )                                                         " {{{1
  " Description: Jump to next/prev marker by location.
  " Arguments: dir    = next  : Jump forward
  "                     prev  : Jump backward
  "            marker = same  : Jump to a marker of the same type
  "                     any   : Jump to a marker of any type
  "                     [0-9] : Jump to the corresponding marker

  let l:lnum = line('.')

  let l:marker = ''
  if (a:marker_num =~ '\v<[0-9]>')
    let l:marker = split(b:SignatureIncludeMarkers, '\zs')[a:marker_num]
  elseif (  (a:marker_num ==? 'same')
       \ && has_key(b:sig_markers, l:lnum)
       \ )
    let l:marker = signature#utils#GetChar(b:sig_markers[l:lnum], 0)
  endif

  " Get list of line numbers of lines with markers.
  " If current line has a marker, filter out line numbers of other markers ...
  if (l:marker != '')
    let l:marker_lnums = sort(keys(filter(copy(b:sig_markers),
          \ 'signature#utils#GetChar(v:val, 0) == l:marker')), "signature#utils#NumericSort")
  else
    let l:marker_lnums = sort(keys(b:sig_markers), "signature#utils#NumericSort")
  endif

  if (a:dir ==? 'next')
    let l:marker_lnums = filter(copy(l:marker_lnums), ' v:val >  l:lnum')
                     \ + filter(copy(l:marker_lnums), '(v:val <= l:lnum) && b:SignatureWrapJumps')
  elseif (a:dir ==? 'prev')
    call reverse(l:marker_lnums)
    let l:marker_lnums = filter(copy(l:marker_lnums), ' v:val <  l:lnum')
                     \ + filter(copy(l:marker_lnums), '(v:val >= l:lnum) && b:SignatureWrapJumps')
  endif

  if (len(l:marker_lnums) == 0)
    return
  endif

  let l:count = (a:count == 0 ? 1 : a:count)
  if (b:SignatureWrapJumps)
    let l:count = l:count % len(l:marker_lnums)
  elseif (l:count > len(l:marker_lnums))
    let l:count = 0
  endif

  let l:targ = l:marker_lnums[l:count - 1]
  execute 'normal! ' . l:targ . 'G'
endfunction


function! signature#marker#List(...)                                                                              " {{{1
  " Description: Opens and populates location list with markers from current buffer
  "              Show all markers in location list if no argument is provided
  " Argument:    [markers] = 0-9 or any of the specified symbols : List only the specified markers
  "              [context] = 0 (default)                         : Adds context around marker
  "              To show all markers with 1 line of context call using arguments ("", 1)

  let l:markers = (a:0 && (a:1 != "") ? a:1 : b:SignatureIncludeMarkers)
  let l:context = (a:0 > 1 ? a:2 : 0)

  if (l:markers =~ '^\d$')
    if (  (  (l:markers == 0)
     \    && (len(b:SignatureIncludeMarkers) != 10)
     \    )
     \ || (l:markers > len(b:SignatureIncludeMarkers))
     \ )
      echoe "Signature: No corresponding marker exists for " . l:markers
      return
    endif
    let l:markers = split(b:SignatureIncludeMarkers, '\zs')[l:markers]
  endif

  let l:lines_tot = line('$')
  let l:buf_curr  = bufnr('%')
  let l:list_sep  = {'bufnr': '', 'lnum' : ''}
  let l:list      = []

  " Markers not specified in b:SignatureIncludeMarkers won't be present in b:sig_markers and hence get filtered out
  for l:lnum in sort(keys(filter(copy(b:sig_markers), 'v:val =~ "[" . l:markers . "]"')))

    for context_lnum in range(l:lnum - l:context, l:lnum + l:context)
      if (  (context_lnum < 1)
       \ || (context_lnum > lines_tot)
       \ )
        continue
      endif

      if     (context_lnum < l:lnum) | let l:text = '-' . ": " . getline(context_lnum)
      elseif (context_lnum > l:lnum) | let l:text = '+' . ": " . getline(context_lnum)
      else                           | let l:text = b:sig_markers[l:lnum] . ": " . getline(context_lnum)
      endif

      let l:list = add(l:list,
        \              { 'text' : l:text,
        \                'bufnr': l:buf_curr,
        \                'lnum' : context_lnum,
        \                'type' : 'M'
        \              }
        \             )
    endfor

    " Add separator when showing context
    "if (a:context > 0)
    "  let l:list = add(l:list, l:list_sep)
    "endif
  endfor

  " Remove the redundant separator at the end when showing context
  "if (  (a:context > 0)
  " \ && (len(l:list) > 0)
  " \ )
  "  call remove(l:list, -1)
  "endif

  call setloclist(0, l:list,) | lopen
endfunction
