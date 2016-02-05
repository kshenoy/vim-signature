" vim: fdm=marker:et:ts=4:sw=2:sts=2
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Place/Remove/Toggle                                                                                              {{{1
"
function! signature#marker#Toggle(marker)                                                                         " {{{2
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


function! signature#marker#Remove(lnum, marker)                                                                   " {{{2
  " Description: Remove marker from specified line number
  " Arguments:   lnum - Line no. to delete marker from. If is 0, removes marker from current line
  "              a:2  - Marker to delete. If not specified, obtains input from user

  if (get(b:sig_markers, a:lnum, '') =~ a:marker)
    call signature#sign#Remove(a:marker, a:lnum)
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
  call signature#sign#ToggleDummy()
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Navigation                                                                                                       {{{1
"
function! signature#marker#Goto( dir, marker_num, count )                                                         " {{{2
  " Description: Jump to next/prev marker by location.
  " Arguments: dir    = next  : Jump forward
  "                     prev  : Jump backward
  "            marker = same  : Jump to a marker of the same type
  "                     any   : Jump to a marker of any type
  "                     [1-9] : Jump to the corresponding marker

  let l:lnum = line('.')

  let l:marker = ''
  if (a:marker_num =~ '\v<[1-9]>')
    let l:marker = split(b:SignatureIncludeMarkers, '\zs')[a:marker_num]
  elseif (  (a:marker_num ==? 'same')
       \ && has_key(b:sig_markers, l:lnum)
       \ )
    let l:marker = strpart(b:sig_markers[l:lnum], 0, 1)
  endif

  " Get list of line numbers of lines with markers.
  " If current line has a marker, filter out line numbers of other markers ...
  if (l:marker != '')
    let l:marker_lnums = sort(keys(filter(copy(b:sig_markers),
          \ 'strpart(v:val, 0, 1) == l:marker')), "signature#utils#NumericSort")
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


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Misc                                                                                                             {{{1
"
function! signature#marker#List(...)                                                                              " {{{2
  " Description: Opens and populates location list with markers from current buffer
  "              Show all markers in location list if no argument is provided
  " Argument:    [marker]  = 0-9 or any of !@#$%^&*() : List only the specified markers
  "              [context] = 0 (default)              : Adds context around marker

  let l:marker = (a:0 && (a:1 != "") ? a:1 : ')!@#$%^&*(')
  let l:count  = (a:0 > 1 ? a:2 : 0)

  if (l:marker =~ '^\d$')
    if (l:marker >= len(')!@#$%^&*('))
      echoe "Signature: Marker specified is out-of-bounds"
      return
    endif
    let l:marker = split(')!@#$%^&*(', '\zs')[l:marker]
  endif

  let l:list_map = map(
                   \   sort(
                   \     keys(filter(copy(b:sig_markers), 'v:val =~ "[" . l:marker . "]"')),
                   \     'signature#utils#NumericSort'
                   \   ),
                   \   '{
                   \     "bufnr": ' . bufnr('%') . ',
                   \     "lnum" : v:val,
                   \     "col"  : "",
                   \     "type" : "M",
                   \     "text" : b:sig_markers[v:val] . ": " . getline(v:val)
                   \   }'
                   \  )

  if l:count
    let l:temp_list = []
    for i in range(0, len(l:list_map)-1)
      for l:context in range(-l:count, l:count)
        let l:item_context = copy(l:list_map[i])
        if (l:context != 0)
          let l:item_context.lnum = l:list_map[i].lnum + l:context
          let l:item_context.text = (l:context < 0 ? "-" : "+") . ": " . getline(l:item_context.lnum)
        endif
        let l:item_context.text = substitute(l:item_context.text, '\s\+$', '', '')
        let l:temp_list = add(l:temp_list, l:item_context)
      endfor
      if (i != len(l:list_map)-1)
        let l:temp_list = add(l:temp_list, { 'bufnr': '',
                                           \ 'lnum' : '',
                                           \ 'col'  : '',
                                           \ 'type' : '',
                                           \ 'text' : ''
                                           \ })
      endif
    endfor
    let l:list_map = l:temp_list
  endif

  call setloclist(0, l:list_map,)|lopen
endfunction
" }}}2
