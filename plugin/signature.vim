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
let g:loaded_Signature = 1


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Global variables                                                                                                 {{{1
"
let g:SignaturePrioritizeMarks         = get(g:, 'SignaturePrioritizeMarks',         1                                                     )
let g:SignatureIncludeMarks            = get(g:, 'SignatureIncludeMarks',            'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ')
let g:SignatureIncludeMarkers          = get(g:, 'SignatureIncludeMarkers',          ')!@#$%^&*('                                          )
let g:SignatureMarkTextHL              = get(g:, 'SignatureMarkTextHL',              "SignatureMarkText"                                   )
let g:SignatureMarkTextHLDynamic       = get(g:, 'SignatureMarkTextHLDynamic',       0                                                     )
let g:SignatureMarkLineHL              = get(g:, 'SignatureMarkLineHL',              "SignatureMarkLine"                                   )
let g:SignatureMarkerTextHL            = get(g:, 'SignatureMarkerTextHL',            "SignatureMarkerText"                                 )
let g:SignatureMarkerTextHLDynamic     = get(g:, 'SignatureMarkerTextHLDynamic',     0                                                     )
let g:SignatureMarkerLineHL            = get(g:, 'SignatureMarkerLineHL',            "SignatureMarkerLine"                                 )
let g:SignatureWrapJumps               = get(g:, 'SignatureWrapJumps',               1                                                     )
let g:SignatureMarkOrder               = get(g:, 'SignatureMarkOrder',               "\p\m"                                                )
let g:SignatureDeleteConfirmation      = get(g:, 'SignatureDeleteConfirmation',      0                                                     )
let g:SignaturePurgeConfirmation       = get(g:, 'SignaturePurgeConfirmation',       0                                                     )
let g:SignaturePeriodicRefresh         = get(g:, 'SignaturePeriodicRefresh',         1                                                     )
let g:SignatureEnabledAtStartup        = get(g:, 'SignatureEnabledAtStartup',        1                                                     )
let g:SignatureDeferPlacement          = get(g:, 'SignatureDeferPlacement',          1                                                     )
let g:SignatureRecycleMarks            = get(g:, 'SignatureRecycleMarks',            0                                                     )
let g:SignatureErrorIfNoAvailableMarks = get(g:, 'SignatureErrorIfNoAvailableMarks', 1                                                     )
let g:SignatureForceRemoveGlobal       = get(g:, 'SignatureForceRemoveGlobal',       0                                                     )
let g:SignatureForceMarkPlacement      = get(g:, 'SignatureForceMarkPlacement',      0                                                     )
let g:SignatureForceMarkerPlacement    = get(g:, 'SignatureForceMarkerPlacement',    0                                                     )
let g:SignatureMap                     = get(g:, 'SignatureMap',                     {}                                                    )


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Commands, Autocmds and Maps                                                                                      {{{1
"
function! s:Map(key, map_lhs_default, map_rhs)                                                                    " {{{1
  let l:map_lhs = get(g:SignatureMap, a:key, a:map_lhs_default)
  if (l:map_lhs ==? '')
    return
  endif
  silent! execute 'nnoremap <silent> <unique> ' . l:map_lhs . ' ' . ':<C-U>call signature#' . a:map_rhs . '<CR>'
endfunction

let s:SignatureMapLeader = get(g:SignatureMap, 'Leader', 'm')
if (s:SignatureMapLeader == "")
  echoe "Signature: g:SignatureMap.Leader shouldn't be left blank"
endif

" We create separate mappings for PlaceNextMark, mark#Purge('all') and PurgeMarkers instead of combining it with
" Leader/Input as if the user chooses to use some weird key like <BS> or <CR> for any of these 3, we need to be able
" to identify it. Eg. the nr2char(getchar()) will fail if the user presses a <BS>
call s:Map('Leader',            s:SignatureMapLeader,             'utils#Input()'                       )
call s:Map('PlaceNextMark',     s:SignatureMapLeader . ",",       'mark#Toggle("next")'                 )
call s:Map('ToggleMarkAtLine',  s:SignatureMapLeader . ".",       'mark#ToggleAtLine()'                 )
call s:Map('PurgeMarksAtLine',  s:SignatureMapLeader . "-",       'mark#Purge("line")'                  )
call s:Map('PurgeMarks',        s:SignatureMapLeader . "<Space>", 'mark#Purge("all")'                   )
call s:Map('PurgeMarkers',      s:SignatureMapLeader . "<BS>",    'marker#Purge()'                      )
call s:Map('DeleteMark',        "dm",                             'utils#Remove(v:count)'               )
call s:Map('GotoNextLineAlpha', "']",                             'mark#Goto("next", "line", "alpha")'  )
call s:Map('GotoPrevLineAlpha', "'[",                             'mark#Goto("prev", "line", "alpha")'  )
call s:Map('GotoNextSpotAlpha', "`]",                             'mark#Goto("next", "spot", "alpha")'  )
call s:Map('GotoPrevSpotAlpha', "`[",                             'mark#Goto("prev", "spot", "alpha")'  )
call s:Map('GotoNextLineByPos', "]'",                             'mark#Goto("next", "line", "pos")'    )
call s:Map('GotoPrevLineByPos', "['",                             'mark#Goto("prev", "line", "pos")'    )
call s:Map('GotoNextSpotByPos', "]`",                             'mark#Goto("next", "spot", "pos")'    )
call s:Map('GotoPrevSpotByPos', "[`",                             'mark#Goto("prev", "spot", "pos")'    )
call s:Map('GotoNextMarker',    "]-",                             'marker#Goto("next", "same", v:count)')
call s:Map('GotoPrevMarker',    "[-",                             'marker#Goto("prev", "same", v:count)')
call s:Map('GotoNextMarkerAny', "]=",                             'marker#Goto("next", "any",  v:count)')
call s:Map('GotoPrevMarkerAny', "[=",                             'marker#Goto("prev", "any",  v:count)')
call s:Map('ListBufferMarks',   'm/',                             'mark#List(0, 0)'                     )
call s:Map('ListBufferMarkers', 'm?',                             'marker#List(v:count, 0)'             )


if has('autocmd')
  augroup sig_autocmds
    autocmd!

    " This needs to be called upon loading a colorscheme
    " VimEnter is kind of a backup if no colorscheme is explicitly loaded and the default is used
    autocmd VimEnter,ColorScheme * call signature#utils#SetupHighlightGroups()

    " This is required to remove signs for global marks that were removed when in another window
    autocmd BufEnter,CmdwinEnter * call signature#sign#Refresh()

    autocmd CursorHold * if (g:SignaturePeriodicRefresh) | call signature#sign#Refresh() | endif
  augroup END
endif

command! -nargs=0 SignatureToggleSigns     call signature#utils#Toggle()
command! -nargs=0 SignatureRefresh         call signature#sign#Refresh(1) " force refresh
command! -nargs=? SignatureListBufferMarks call signature#mark#List(0, <args>)
command! -nargs=? SignatureListGlobalMarks call signature#mark#List(1, <args>)
command! -nargs=* SignatureListMarkers     call signature#marker#List(<args>)
