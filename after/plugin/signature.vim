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
    unlet g:SignatureMarkTextHL
    let   g:SignatureMarkTextHL = function("signature#sign#GetGitGutterHLGroup")
  endif
  if g:SignatureMarkerTextHLDynamic
    unlet g:SignatureMarkerTextHL
    let   g:SignatureMarkerTextHL = function("signature#sign#GetGitGutterHLGroup")
  endif
endif

if exists('g:loaded_signify')
  if g:SignatureMarkTextHLDynamic
    unlet g:SignatureMarkTextHL
    let   g:SignatureMarkTextHL = function("signature#sign#GetSignifyHLGroup")
  endif
  if g:SignatureMarkerTextHLDynamic
    unlet g:SignatureMarkerTextHL
    let   g:SignatureMarkerTextHL = function("signature#sign#GetSignifyHLGroup")
  endif
endif
