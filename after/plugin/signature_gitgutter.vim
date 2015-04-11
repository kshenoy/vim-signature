" vim: fdm=marker:et:ts=4:sw=2:sts=2

" Maintainer:  Kartik Shenoy
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Exit if the signs feature is not available or if the app has already been loaded (or "compatible" mode set)
if (  !has('signs')
 \ || &cp
 \ )
  finish
endif

"" Exit if vim-signature is not loaded
if !exists('g:loaded_Signature')
  finish
endif

if exists('g:loaded_gitgutter')
  if g:SignatureMarkTextHLDynamic
    let g:SignatureMarkTextHL = 'signature#sign#GetGitGutterHLGroup(a:lnum)'
  endif
  if g:SignatureMarkerTextHLDynamic
    let g:SignatureMarkerTextHL = 'signature#sign#GetGitGutterHLGroup(a:lnum)'
  endif
endif

if exists('g:loaded_signify')
  if g:SignatureMarkTextHLDynamic
    let g:SignatureMarkTextHL = 'signature#sign#GetSignifyHLGroup(a:lnum)'
  endif
  if g:SignatureMarkerTextHLDynamic
    let g:SignatureMarkerTextHL = 'signature#sign#GetSignifyHLGroup(a:lnum)'
  endif
endif
