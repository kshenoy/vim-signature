" vim: fdm=marker:et:ts=4:sw=2:sts=2

" Description: vim-signature is a plugin to toggle, display and navigate marks.
"
" Maintainer: Kartik Shenoy
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Exit if the signs feature is not available or if the app has already been loaded (or "compatible" mode set)
if !has('signs') || &cp
  finish
endif
if exists('g:loaded_Signature')
  finish
endif
let g:loaded_Signature = 3


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Global variables                                                                                                 {{{1
"
call signature#utils#Set('g:SignaturePrioritizeMarks',             1                                                     )
call signature#utils#Set('g:SignatureIncludeMarks',                'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ')
call signature#utils#Set('g:SignatureIncludeMarkers',              ')!@#$%^&*('                                          )
call signature#utils#Set('g:SignatureMarkTextHL',                  '"Exception"'                                         )
call signature#utils#Set('g:SignatureMarkTextHLDynamic',           0                                                     )
call signature#utils#Set('g:SignatureMarkLineHL',                  '""'                                                  )
call signature#utils#Set('g:SignatureMarkerTextHL',                '"WarningMsg"'                                        )
call signature#utils#Set('g:SignatureMarkerTextHLDynamic',         0                                                     )
call signature#utils#Set('g:SignatureMarkerLineHL',                '""'                                                  )
call signature#utils#Set('g:SignatureWrapJumps',                   1                                                     )
call signature#utils#Set('g:SignatureMarkOrder',                   "\p\m"                                                )
call signature#utils#Set('g:SignatureDeleteConfirmation',          0                                                     )
call signature#utils#Set('g:SignaturePurgeConfirmation',           0                                                     )
call signature#utils#Set('g:SignaturePeriodicRefresh',             1                                                     )
call signature#utils#Set('g:SignatureEnabledAtStartup',            1                                                     )
call signature#utils#Set('g:SignatureDeferPlacement',              1                                                     )
call signature#utils#Set('g:SignatureUnconditionallyRecycleMarks', 0                                                     )
call signature#utils#Set('g:SignatureErrorIfNoAvailableMarks',     1                                                     )
call signature#utils#Set('g:SignatureForceRemoveGlobal',           1                                                     )
call signature#utils#Set('g:SignatureForceMarkPlacement',          0                                                     )
call signature#utils#Set('g:SignatureForceMarkerPlacement',        0                                                     )
call signature#utils#Set('g:SignatureMap',                         {}                                                    )


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Commands, Autocmds and Maps                                                                                      {{{1
"
call signature#utils#Maps('create')

if has('autocmd')
  augroup sig_autocmds
    autocmd!
    autocmd BufEnter,CmdwinEnter * call signature#sign#Refresh()
    autocmd CursorHold * if g:SignaturePeriodicRefresh | call signature#sign#Refresh() | endif
    autocmd BufEnter,FileType * if (&filetype ==? 'nerdtree') | call signature#utils#Maps('remove') | endif
    autocmd BufLeave * if (&filetype ==? 'nerdtree') | call signature#utils#Maps('create') | endif
  augroup END
endif

command! -nargs=0 SignatureToggleSigns call signature#Toggle()
command! -nargs=0 SignatureRefresh     call signature#sign#Refresh('force')
command! -nargs=0 SignatureListMarks   call signature#mark#List('buf_curr')
command! -nargs=? SignatureListMarkers call signature#marker#List(<args>)


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Misc                                                                                                             {{{1
"
function! signature#Input()                                                                                       " {{{2
  " Description: Grab input char

  " Obtain input from user ...
  let l:char = nr2char(getchar())

  " ... if the input is not a number eg. '!' ==> Delete all '!' markers
  if stridx(b:SignatureIncludeMarkers, l:char) >= 0
    return signature#marker#Purge(l:char)
  endif

  " ... but if input is a number, convert it to corresponding marker before proceeding
  if match( l:char, '\d' ) >= 0
    let l:char = split(')!@#$%^&*(', '\zs')[l:char]
  endif

  if stridx(b:SignatureIncludeMarkers, l:char) >= 0
    return signature#marker#Toggle(l:char)
  elseif stridx(b:SignatureIncludeMarks, l:char) >= 0
    return signature#mark#Toggle(l:char)
  else
    " l:char is probably one of `'[]<>
    execute 'normal! m' . l:char
  endif
endfunction


function! signature#Toggle()                                                                                      " {{{2
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
    call signature#sign#ToggleDummy('remove')
    unlet b:sig_marks
  endif
endfunction


function! signature#Remove(lnum)                                                                                  " {{{2
  " Description: Obtain mark or marker from the user and remove it from the specified line number.
  "              If lnum is not specified for marker, or is 0, removes the marker from current line
  "              NOTE: lnum is meaningless for a mark
  " Arguments:   lnum - Line no. to delete the marker from

  let l:char = nr2char(getchar())

  if (l:char =~ '^\d$')
    let l:lnum = (a:lnum == 0 ? line('.') : a:lnum)
    let l:char = split(')!@#$%^&*(', '\zs')[l:char]
    call signature#marker#Remove(lnum, l:char)
  elseif (l:char =~? '^[a-z]$')
    call signature#mark#Remove(l:char)
  endif
endfunction
