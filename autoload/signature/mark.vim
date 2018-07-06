" vim: fdm=marker:et:ts=4:sw=2:sts=1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! signature#mark#Toggle(mark)                                                                             " {{{1
  " Description: mark = 'next' : Place new mark on current line else toggle specified mark on current line
  " Arguments:   mark [a-z,A-Z]

  if a:mark == "next"
    " Place new mark
    let l:marks_list = signature#mark#GetList('free', 'buf_all')
    if empty(l:marks_list)
      if (!g:SignatureRecycleMarks)
        " No marks available and mark re-use not in effect
        call s:ReportNoAvailableMarks()
        return
      endif
      " Remove a local mark
      let l:marks_list = signature#mark#GetList('used', 'buf_curr')[0]
      call signature#mark#Remove(l:marks_list[0])
    endif
    call s:Place(l:marks_list[0])

  else
    " Toggle Mark
    let l:used_marks = filter(signature#mark#GetList('used', 'buf_all'), 'v:val[0] ==# a:mark')
    if (len(l:used_marks) > 0)
      let l:mark_pos = l:used_marks[0][1]
      let l:mark_buf = l:used_marks[0][2]

      if (l:mark_buf == bufnr('%'))
        " If the mark is not in use in current buffer then it's a global ==> Don't worry about deleting it
        if (  (l:mark_pos == line('.'))
         \ && !g:SignatureForceMarkPlacement
         \ )
          " Mark is present on the current line. Remove it and return
          call signature#mark#Remove(a:mark)
          call signature#sign#ToggleDummy()
          return
        else
          " Mark is present elsewhere in the current buffer ==> Remove it and fall-through to place new mark.
          " If g:SignatureForceMarkPlacement is set, we remove and re-place it so that the sign string can be true
          " to the order in which the marks were placed.
          " For eg. if we place 'a, 'b and then 'a again, the sign string changes from "ab" to "ba"
          " Ask for confirmation before moving mark
          if (g:SignatureDeleteConfirmation)
            let choice = confirm("Mark '" . a:mark . "' has been used elsewhere. Reuse it?", "&Yes\n&No", 1)
            if choice == 2 | return | endif
          endif
          call signature#mark#Remove(a:mark)
        endif
      endif
    endif

    " Place new mark
    call s:Place(a:mark)
  endif
endfunction


function! signature#mark#Remove(mark)                                                                             " {{{1
  " Description: Remove 'mark' and its associated sign. If called without an argument, obtain it from the user
  " Arguments:   mark = [a-z,A-Z]

  if !signature#utils#IsValidMark(a:mark)
    return
  endif

  let l:lnum = line("'" . a:mark)
  call signature#sign#Remove(a:mark, l:lnum)
  execute 'delmarks ' . a:mark
  call s:ForceGlobalRemoval(a:mark)
endfunction


function! s:Place(mark)                                                                                           " {{{1
  " Description: Place new mark at current cursor position
  " Arguments:   mark = [a-z,A-Z]
  " If a line is deleted or mark is manipulated using any non-signature method then b:sig_marks can go out of sync
  " Thus, we forcibly remove signs for the mark present on any line before proceeding
  call signature#sign#Remove(a:mark, 0)
  execute 'normal! m' . a:mark
  call signature#sign#Place(a:mark, line('.'))
endfunction


function! signature#mark#ToggleAtLine()                                                                           " {{{1
  " Description: If no mark on current line, add one. If marks are on the current line, remove one.
  let l:marks_here = filter(signature#mark#GetList('used', 'buf_curr'), 'v:val[1] == ' . line('.'))
  if empty(l:marks_here)
    " Set up for adding a mark
    call signature#mark#Toggle('next')
  else
    " Delete first mark
    call signature#mark#Remove(l:marks_here[0][0])
  endif
endfunction


function! signature#mark#Purge(mode)                                                                              " {{{1
  " Description: Delete all marks from current line
  " Arguments:   mode = 'line' : Delete all marks from current line
  "                     'all'  : Delete all marks used in the buffer

  let l:used_marks = signature#mark#GetList('used', 'buf_curr')
  if (a:mode ==? 'line')
    call filter(l:used_marks, 'v:val[1] == ' . line('.'))
  endif

  if (  !empty(l:used_marks)
   \ && g:SignaturePurgeConfirmation
   \ )
    let l:msg = 'Are you sure you want to delete all marks' . (a:mode ==? 'line' ? ' from the current line' : '') . '?'
    let l:ans = confirm(l:msg . ' This cannot be undone.', "&Yes\n&No", 1)
    if (l:ans != 1) | return | endif
  endif

  for i in l:used_marks
    call signature#mark#Remove(i[0])
  endfor

  " If marks are modified using any non-signature method, b:sig_marks can go out of sync
  if (a:mode ==? 'all')
    for l:lnum in keys(b:sig_marks)
      call signature#sign#Unplace(l:lnum)
    endfor
  endif
  call signature#sign#ToggleDummy()
endfunction


function! signature#mark#Goto(dir, loc, mode)                                                                     " {{{1
  " Arguments:
  "   dir   = next   : Jump forward
  "           prev   : Jump backward
  "   loc   = line   : Jump to first column of line with mark
  "           spot   : Jump to exact column of the mark
  "   mode  = pos    : Jump to next mark by position
  "           alpha  : Jump to next mark by alphabetical order
  "           global : Jump only to global marks (applies to all buffers and alphabetical order)

  let l:mark = ""
  let l:dir  = a:dir

  if a:mode ==? "global"
    let l:mark = s:GotoByAlphaGlobal(a:dir)
  elseif a:mode ==? "alpha"
    let l:mark = s:GotoByAlpha(a:dir)
  elseif a:mode ==? "pos"
    let l:mark = s:GotoByPos(a:dir)
  endif

  " NOTE: If l:mark is an empty string then no movement will be made
  if l:mark == "" | return | endif

  if a:loc ==? "line"
    execute "normal! '" . l:mark
  elseif a:loc ==? "spot"
    execute 'normal! `' . l:mark
  endif
endfunction


function! s:GotoByPos(dir)                                                                                        " {{{1
  " Description: Jump to next/prev mark by location.
  " Arguments: dir  = next   : Jump forward
  "                   prev   : Jump backward

  " We need at least one mark to be present. If not, then return an empty string so that no movement will be made
  if empty(b:sig_marks) | return "" | endif

  let l:lnum = line('.')

  " Get list of line numbers of lines with marks.
  if a:dir ==? "next"
    let l:targ = min(sort(keys(b:sig_marks), "signature#utils#NumericSort"))
    let l:mark_lnums = sort(keys(filter(copy(b:sig_marks), 'v:key > l:lnum')), "signature#utils#NumericSort")
  elseif a:dir ==? "prev"
    let l:targ = max(sort(keys(b:sig_marks), "signature#utils#NumericSort"))
    let l:mark_lnums = reverse(sort(keys(filter(copy(b:sig_marks), 'v:key < l:lnum')), "signature#utils#NumericSort"))
  endif

  let l:targ = (empty(l:mark_lnums) ? (b:SignatureWrapJumps ? l:targ : "") : l:mark_lnums[0])
  if empty(l:targ) | return "" | endif

  let l:mark = signature#utils#GetChar(b:sig_marks[l:targ], 0)
  return l:mark
endfunction


function! s:GotoByAlpha(dir)                                                                                      " {{{1
  " Description: Jump to next/prev mark by alphabetical order. Direction specified as input argument

  let l:used_marks = signature#mark#GetList('used', 'buf_curr')
  let l:line_marks = filter(copy(l:used_marks), 'v:val[1] == ' . line('.'))

  " If there is only one mark in the current file, then return the same
  if (len(l:used_marks) == 1)
    return l:used_marks[0][0]
  endif

  " Since we can place multiple marks on a line, to jump by alphabetical order we need to know what the current mark is.
  " This information is kept in the b:sig_GotoByAlpha_CurrMark variable. For instance, if we have marks a, b and c
  " on the current line and b:sig_GotoByAlpha_CurrMark has the value 'a' then we jump to 'b' and set the value of
  " the variable to 'b'. Reinvoking this function will thus now jump to 'c'
  if empty(l:line_marks)
    if exists('b:sig_GotoByAlpha_CurrMark')
      unlet b:sig_GotoByAlpha_CurrMark
    endif
    " If there are no marks present on the current line then call GotoByPos to jump to the next line with a mark
    return s:GotoByPos(a:dir)
  endif

  if (( len(l:line_marks) == 1 ) || !exists('b:sig_GotoByAlpha_CurrMark') || (b:sig_GotoByAlpha_CurrMark ==? ""))
    let b:sig_GotoByAlpha_CurrMark = l:line_marks[0][0]
  endif

  for i in range( 0, len(l:used_marks) - 1 )
    if l:used_marks[i][0] ==# b:sig_GotoByAlpha_CurrMark
      if a:dir ==? "next"
        if (( i != len(l:used_marks)-1 ) || b:SignatureWrapJumps)
          let b:sig_GotoByAlpha_CurrMark = l:used_marks[(i+1)%len(l:used_marks)][0]
        endif
      elseif a:dir ==? "prev"
        if ((i != 0) || b:SignatureWrapJumps)
          let b:sig_GotoByAlpha_CurrMark = l:used_marks[i-1][0]
        endif
      endif
      return b:sig_GotoByAlpha_CurrMark
    endif
  endfor
endfunction


function! s:GotoByAlphaGlobal(dir)                                                                                " {{{1
  " Description: Jump to next/prev Global mark in any buffer by alphabetical order.
  "              Direction is specified as input argument

  let l:used_marks = signature#mark#GetList('used', 'buf_all', 'global')
  let l:line_marks = filter(copy(l:used_marks), 'v:val[1] == ' . line('.'))

  " If there is only one mark in the current file, return it
  if (len(l:used_marks) == 1)
    return l:used_marks[0][0]
  endif
  " If current line does not have a global mark on it then return the first used global mark
  if empty(l:line_marks)
    if exists('b:sig_GotoByAlphaGlobal_CurrMark')
      unlet b:sig_GotoByAlphaGlobal_CurrMark
    endif
    return l:used_marks[0][0]
  endif

  " Since we can place multiple marks on a line, to jump by alphabetical order we need to know what the current mark is.
  " This information is kept in the b:sig_GotoByAlphaGlobal_CurrMark variable. For instance, if we have marks A, B & C
  " on the current line and b:sig_GotoByAlphaGlobal_CurrMark has the value 'A' then we jump to 'B' and set the value of
  " the variable to 'B'. Reinvoking this function will thus now jump to 'C'
  if (  (len(l:line_marks) == 1)
   \ || !exists('b:sig_GotoByAlpha_CurrMark')
   \ || (b:sig_GotoByAlphaGlobal_CurrMark ==? "")
   \ )
    let b:sig_GotoByAlphaGlobal_CurrMark = l:line_marks[0][0]
  endif

  for i in range( 0, len(l:used_marks) - 1 )
    if l:used_marks[i][0] ==# b:sig_GotoByAlphaGlobal_CurrMark
      if a:dir ==? "next"
        if (( i != len(l:used_marks)-1 ) || b:SignatureWrapJumps)
          let b:sig_GotoByAlphaGlobal_CurrMark = l:used_marks[(i+1)%len(l:used_marks)][0]
        endif
      elseif a:dir ==? "prev"
        if ((i != 0) || b:SignatureWrapJumps)
          let b:sig_GotoByAlphaGlobal_CurrMark = l:used_marks[i-1][0]
        endif
      endif
      return b:sig_GotoByAlphaGlobal_CurrMark
    endif
  endfor
endfunction


function! signature#mark#GetList(mode, scope, ...)                                                                " {{{1
  " Arguments: mode    = 'used'     : Returns list of [ [used marks, line no., buf no.] ]
  "                      'free'     : Returns list of [ free marks ]
  "            scope   = 'buf_curr' : Limits scope to current buffer i.e used/free marks in current buffer
  "                      'buf_all'  : Set scope to all buffers i.e used/free marks from all buffers
  "            [type]  = 'global'   : Return only global marks

  let l:marks_list = []
  let l:line_tot = line('$')
  let l:buf_curr = bufnr('%')
  let l:type     = (a:0 ? a:1 : "")

  " Respect order specified in g:SignatureIncludeMarks
  for i in split(b:SignatureIncludeMarks, '\zs')
    if (i =~# "[A-Z]")
      let [ l:buf, l:line, l:col, l:off ] = getpos( "'" . i )
      let l:marks_list = add(l:marks_list, [i, l:line, l:buf])
    elseif (l:type !=? "global")
      let l:marks_list = add(l:marks_list, [i, line("'" .i), l:buf_curr])
    endif
  endfor

  if (a:mode ==? 'used')
    if (a:scope ==? 'buf_curr')
      call filter( l:marks_list, '(v:val[2] == l:buf_curr) && (v:val[1] > 0)' )
    else
      call filter( l:marks_list, 'v:val[1] > 0' )
    endif
  else
    if (a:scope ==? 'buf_all')
      call filter( l:marks_list, 'v:val[1] == 0' )
    else
      call filter( l:marks_list, '(v:val[1] == 0) || (v:val[2] != l:buf_curr)' )
    endif
    call map( l:marks_list, 'v:val[0]' )
  endif

  return l:marks_list
endfunction


function! s:ForceGlobalRemoval(mark)                                                                              " {{{1
  " Description: Edit viminfo/shada file to forcibly delete Global mark since vim's handling is iffy
  " Arguments:   mark - The mark to delete

  if (  (a:mark !~# '[A-Z]')
   \ || !g:SignatureForceRemoveGlobal
   \ )
    return
  endif

  if has('nvim')
    wshada!
  else
    wviminfo!
  endif
endfunction


function! s:ReportNoAvailableMarks()                                                                              " {{{1
  if g:SignatureErrorIfNoAvailableMarks
    echoe "Signature: No free marks left."
  else
    echohl WarningMsg
    echomsg "Signature: No free marks left."
    echohl None
  endif
endfunction


function! signature#mark#List(scope, ...)                                                                         " {{{1
  " Description: Opens and populates location list with marks
  " Arguments:   scope     = 0 : List local and global marks from current buffer
  "                          1 : List only global marks from all buffers
  "              [context] = 0 : Adds context around the mark

  let l:list = []
  let l:buf_curr = bufnr('%')
  let l:list_sep = {'bufnr': '', 'lnum' : ''}

  let l:SignatureIncludeMarks = (a:scope == 0 ? b:SignatureIncludeMarks : g:SignatureIncludeMarks)
  for i in split(l:SignatureIncludeMarks, '\zs')
    let [l:bufnr, l:lnum, l:col, l:off] = getpos( "'" . i )

    " Local marks set the buffer no. to 0, replace it with the actual buffer number
    let l:bufnr = (l:bufnr == 0 ? l:buf_curr : l:bufnr)

    " Check that
    "   1. Mark is set (lnum > 0)
    "   2. If buf_all = 0, filter out global marks from other buffers
    "   3. If buf_all = 1, filter out local marks from current buffer
    if (  (l:lnum == 0)
     \ || (  (a:scope == 0)
     \    && (l:bufnr != l:buf_curr)
     \    )
     \ || (  (a:scope == 1)
     \    && (i       =~# "[a-z]")
     \    )
     \ )
      "echom 'DEBUG: Skipping mark ' . i
      continue
    endif

    " If the buffer is not loaded, what's the point of showing empty context?
    let l:context = (bufloaded(l:bufnr) && a:0 ? a:1 : 0)

    for context_lnum in range(l:lnum - l:context, l:lnum + l:context)
      let l:text = get(getbufline(l:bufnr, context_lnum), 0, "")
      if (!bufloaded(l:bufnr))
        " Buffer is not loaded, hence we won't be able to get the line. Opening the file should fix it
        let l:text = "~~~ File is not loaded into memory. Open file and rerun to see the line ~~~"
      elseif (l:text == "")
        " Line does not exist. Possibly because context_lnum > total no. of lines
        "echom 'DEBUG: Skipping line=' . context_lnum . ' for mark=' . i . " because line doesn't exist in buffer=" . l:bufnr
        continue
      endif

      if     (context_lnum < l:lnum) | let l:text = '-: ' . l:text
      elseif (context_lnum > l:lnum) | let l:text = '+: ' . l:text
      else                           | let l:text = i . ': ' . l:text
      endif

      let l:list = add(l:list,
        \              { 'text' : l:text,
        \                'bufnr': l:bufnr,
        \                'lnum' : context_lnum,
        \                'col'  : l:col,
        \                'type' : 'm'
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

  call setloclist(0, l:list) | lopen
endfunction
