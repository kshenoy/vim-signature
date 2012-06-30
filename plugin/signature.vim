" Description:
" signature.vim is a plugin to toggle, display and navigate marks.
" Combines the functionality of primarily vim-showmarks and mark-tools.
"
"   <SignatureLeader>[a-zA-Z]  : Place marks (normal behavior)
"   <SignatureLeader>[0-9]     : Place )!@#$%^&*( as signs
"   <Plug>SIG_PlaceNextMark    : Place next available mark
"   <Plug>SIG_PurgeMarks       : Delete all marks
"   <Plug>SIG_NextSpotByPos    : Jump to next mark
"   <Plug>SIG_PrevSpotByPos    : Jump to prev mark
"   <Plug>SIG_NextSpotByAlpha  : Jump to next mark by Alphabetical Order
"   <Plug>SIG_PrevSpotByAlpha  : Jump to prev mark by Alphabetical Order
"   <Plug>SIG_NextLineByPos    : Jump to beginning of next line containing a mark
"   <Plug>SIG_PrevLineByPos    : Jump to beginning of prev line containing a mark
"   <Plug>SIG_NextLineByAlpha  : Jump to next line by Alphabetical Order
"   <Plug>SIG_PrevLineByAlpha  : Jump to next prev by Alphabetical Order
"   <Plug>SIG_NextMarkerByType : Jump to next line having same marker
"   <Plug>SIG_PrevMarkerByType : Jump to prev line having same marker
"
" Maintainer: Kartik Shenoy
"
" Requirements:
" Requires Vim to be compiled with +signs to display marks
"
" Customisation:
"   g:SignatureDefaults : Will use the default mappings specified below.
"   Default: 1
"
"   g:SignatureIncludeMarks : Specify the marks that can be controlled by this plugin
"   Only supports Alphabetical marks at the moment
"   Default: 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
"
"   g:SignatureWrapJumps : Specify if jumping to marks should wrap-around
"   Default: 1
"
"   g:SignatureLeader : Set the key used to Toggle Marks.
"   Default: m
"   If this is set to <leader>m, 
"     <leader>ma will toggle the mark 'a' 
"     <leader>m, will place the next available mark
"     <leader>m<Space> will delete all marks
"
" Default Mappings:
"   nmap m,       <Plug>SIG_PlaceNextMark
"   nmap m<Space> <Plug>SIG_PurgeMarks
"   nmap ']       <Plug>SIG_NextLineByAlpha
"   nmap '[       <Plug>SIG_PrevLineByAlpha
"   nmap `]       <Plug>SIG_NextSpotByAlpha
"   nmap `[       <Plug>SIG_PrevSpotByAlpha
"   nmap ]'       <Plug>SIG_NextLineByPos
"   nmap ['       <Plug>SIG_PrevLineByPos
"   nmap ]`       <Plug>SIG_NextSpotByPos
"   nmap [`       <Plug>SIG_PrevSpotByPos
"   nmap ]=       <Plug>SIG_NextMarkerByType
"   nmap ]-       <Plug>SIG_PrevMarkerByType
" 
" - This will allow to use the default behavior of m to set marks and, if the
"   line already contains the mark, it will be unset.
"
" - Default behavior of ]', [', ]` and [` supported. Also now supports wrapped jumps
"
" - To disable the default mappings and use custom mappings, set
"      let g:SignatureDefaultMappings = 0
"
" Thanks To:
"   * Sergey Khorev for [mark-tools](http://www.vim.org/scripts/script.php?script_id=2929)
"   * Zak Johnson for [vim-showmarks](https://github.com/zakj/vim-showmarks)
"
" ToDo:
"   * Add custom color support for signs
"   * Add custom character display support for signs
"   * Add support for non-Alphabetical marks
"
" Changelist:
"   2012-06-29:
"     - Added support to display !@#$%^&*() as signs  
"     - Added support to navigate markers
"
"   2012-06-27:
"     - Added support to display multiple marks  
"
"   2012-06-22:
"     - First release  
"
" vim: fdm=marker:et:ts=4:sw=4:sts=4
"===========================================================================

" Exit when your app has already been loaded (or "compatible" mode set)
if exists("g:loaded_Signature") || &cp
    finish
endif
let g:loaded_Signature = 1    " Version Number
let s:keepcpo          = &cpo
set cpo&vim


if !exists('g:SignatureIncludeMarks')
    let g:SignatureIncludeMarks = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
endif
if !exists('g:SignatureWrapJumps')
    let g:SignatureWrapJumps = 1
endif
if !exists('g:SignatureLeader')
    let g:SignatureLeader = "m"
endif
if !exists('g:SignatureDefaultMappings')
    let g:SignatureDefaultMappings = 1
endif

if g:SignatureDefaultMappings
    nmap m,       <Plug>SIG_PlaceNextMark
    nmap m<Space> <Plug>SIG_PurgeMarks
    nmap ']       <Plug>SIG_NextLineByAlpha
    nmap '[       <Plug>SIG_PrevLineByAlpha
    nmap `]       <Plug>SIG_NextSpotByAlpha
    nmap `[       <Plug>SIG_PrevSpotByAlpha
    nmap ]'       <Plug>SIG_NextLineByPos
    nmap ['       <Plug>SIG_PrevLineByPos
    nmap ]`       <Plug>SIG_NextSpotByPos
    nmap [`       <Plug>SIG_PrevSpotByPos
    nmap ]=       <Plug>SIG_NextMarkerByType
    nmap ]-       <Plug>SIG_PrevMarkerByType
endif

for i in split(g:SignatureIncludeMarks, '\zs')
    silent exec 'nnoremap <silent> ' . g:SignatureLeader . i . ' :call signature#ToggleMark("' . i . '")<CR>'
endfor

nnoremap <silent> <Plug>SIG_PlaceNextMark    :call signature#ToggleMark(",")<CR>
nnoremap <silent> <Plug>SIG_PurgeMarks       :call signature#PurgeMarks()<CR>
nnoremap <silent> <Plug>SIG_NextSpotByAlpha  :call signature#GotoMark("alpha", "next", "spot")<CR>
nnoremap <silent> <Plug>SIG_PrevSpotByAlpha  :call signature#GotoMark("alpha", "prev", "spot")<CR>
nnoremap <silent> <Plug>SIG_NextLineByAlpha  :call signature#GotoMark("alpha", "next", "line")<CR>
nnoremap <silent> <Plug>SIG_PrevLineByAlpha  :call signature#GotoMark("alpha", "prev", "line")<CR>
nnoremap <silent> <Plug>SIG_NextSpotByPos    :call signature#GotoMark("pos", "next", "spot")<CR>
nnoremap <silent> <Plug>SIG_PrevSpotByPos    :call signature#GotoMark("pos", "prev", "spot")<CR>
nnoremap <silent> <Plug>SIG_NextLineByPos    :call signature#GotoMark("pos", "next", "line")<CR>
nnoremap <silent> <Plug>SIG_PrevLineByPos    :call signature#GotoMark("pos", "prev", "line")<CR>
nnoremap <silent> <Plug>SIG_NextMarkerByType :call signature#GotoMarker("next")<CR>
nnoremap <silent> <Plug>SIG_PrevMarkerByType :call signature#GotoMarker("prev")<CR>


let g:SignatureMarkers = ")!@#$%^&*("
let s:signature_markers = split(g:SignatureMarkers, '\zs')
for i in range(0, len(s:signature_markers)-1)
    exec 'sign define sig_Marker_' . i . ' text=' . s:signature_markers[i] . ' texthl=WarningMsg'
    silent exec 'nnoremap <silent> ' . g:SignatureLeader . i . ' :call signature#ToggleMarker("' . s:signature_markers[i] . '")<CR>'
endfor

if has('autocmd')
    augroup sig_autocmds
        autocmd!
        autocmd BufEnter * call signature#RefreshMarks() 
    augroup END
endif

"===============================================================================
let &cpo= s:keepcpo
unlet s:keepcpo
