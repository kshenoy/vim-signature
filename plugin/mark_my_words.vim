" MarkMyWords.vim is a plugin to toggle, display and navigate marks.
" Combines the functionality of primarily vim-showmarks and mark-tools.
"
" Maintainer: Kartik Shenoy
" vim: fdm=marker:et:ts=4:sw=4:sts=4
"
" Requirements:
" Requires Vim to be compiled with +signs to display marks
"
" Customisation:
"   g:MarkMyWords_Defaults : Will use the default mappings specified below.
"   Default: 1
"
"   g:MarkMyWords_IncludeMarks : Specify the marks that can be controlled by this plugin
"   Only supports Alphabetical marks at the moment
"   Default: 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
"
"   g:MarkMyWords_WrapJumps : Specify if jumping to marks should wrap-around
"   Default: 1
"
"   g:MarkMyWords_leader : Set the key used to Toggle Marks.
"   Default: m
"   If this is set to <leader>m, 
"     <leader>ma will toggle the mark 'a' 
"     <leader>m, will place the next available mark
"     <leader>m<Space> will delete all marks
"
" Mappings:
"   <Plug>MMW_NextSpotByPos   : Jump to next mark
"   <Plug>MMW_PrevSpotByPos   : Jump to prev mark
"   <Plug>MMW_NextSpotByAlpha : Jump to next mark by Alphabetical Order
"   <Plug>MMW_PrevSpotByAlpha : Jump to prev mark by Alphabetical Order
"   <Plug>MMW_NextLineByPos   : Jump to beginning of next line containing a mark
"   <Plug>MMW_PrevLineByPos   : Jump to beginning of prev line containing a mark
"   <Plug>MMW_NextLineByAlpha : Jump to next line by Alphabetical Order
"   <Plug>MMW_PrevLineByAlpha : Jump to next prev by Alphabetical Order
"
" Default Mappings:
"   nmap '] <Plug>MMW_NextLineByAlpha
"   nmap '[ <Plug>MMW_PrevLineByAlpha
"   nmap `] <Plug>MMW_NextSpotByAlpha
"   nmap `[ <Plug>MMW_PrevSpotByAlpha
"   nmap ]' <Plug>MMW_NextLineByPos
"   nmap [' <Plug>MMW_PrevLineByPos
"   nmap ]` <Plug>MMW_NextSpotByPos
"   nmap [` <Plug>MMW_PrevSpotByPos
" 
" - This will allow to use the default behavior of m to set marks and, if the
"   line already contains the mark, it will be unset.
"
" - Default behavior of ]', [', ]` and [` supported. Also now supports wrapped jumps
"
" - To disable the default mappings and use custom mappings, set
"      let g:MarkMyWords_DefaultMappings = 0
"
" Thanks To:
"   * Sergey Khorev for [mark-tools](http://www.vim.org/scripts/script.php?script_id=2929)
"   * Zak Johnson for [vim-showmarks](https://github.com/zakj/vim-showmarks)
"
" ToDo:
"   * Add color support for signs
"   * Add custom character display support for signs
"   * Add support for non-Alphabetical marks
"
" Changelist:
"   2012-06-27 : Added support to display multiple marks
"
"   2012-06-22 : First release
"
"===========================================================================

" Exit when your app has already been loaded (or "compatible" mode set)
if exists("g:loaded_MarkMyWords") || &cp
    finish
endif
let g:loaded_MarkMyWords = 1    " Version Number
let s:keepcpo            = &cpo
set cpo&vim


if !exists('g:MarkMyWords_IncludeMarks')
    let g:MarkMyWords_IncludeMarks = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
endif
if !exists('g:MarkMyWords_WrapJumps')
    let g:MarkMyWords_WrapJumps = 1
endif
if !exists('g:MarkMyWords_leader')
    let g:MarkMyWords_leader = "m"
endif
if !exists('g:MarkMyWords_DefaultMappings')
    let g:MarkMyWords_DefaultMappings = 1
endif

if g:MarkMyWords_DefaultMappings
    nmap '] <Plug>MMW_NextLineByAlpha
    nmap '[ <Plug>MMW_PrevLineByAlpha
    nmap `] <Plug>MMW_NextSpotByAlpha
    nmap `[ <Plug>MMW_PrevSpotByAlpha
    nmap ]' <Plug>MMW_NextLineByPos
    nmap [' <Plug>MMW_PrevLineByPos
    nmap ]` <Plug>MMW_NextSpotByPos
    nmap [` <Plug>MMW_PrevSpotByPos
endif

for i in split(g:MarkMyWords_IncludeMarks, '\zs')
    "echom 'nnoremap <silent> ' . g:MarkMyWords_leader . i . ' :call mark_my_words#ToggleMark("' . i . '")<CR>'
    silent exec 'nnoremap <silent> ' . g:MarkMyWords_leader . i . ' :call mark_my_words#ToggleMark("' . i . '")<CR>'
endfor

silent exec 'nnoremap <silent> ' . g:MarkMyWords_leader . ', :call mark_my_words#ToggleMark(",")<CR>'
silent exec 'nnoremap <silent> ' . g:MarkMyWords_leader . '<Space> :call mark_my_words#PurgeAll()<CR>'
nnoremap <silent> <Plug>MMW_NextSpotByAlpha :call mark_my_words#JumpToMark('alpha', 'next', 'spot')<CR>
nnoremap <silent> <Plug>MMW_PrevSpotByAlpha :call mark_my_words#JumpToMark('alpha', 'prev', 'spot')<CR>
nnoremap <silent> <Plug>MMW_NextLineByAlpha :call mark_my_words#JumpToMark('alpha', 'next', 'line')<CR>
nnoremap <silent> <Plug>MMW_PrevLineByAlpha :call mark_my_words#JumpToMark('alpha', 'prev', 'line')<CR>
nnoremap <silent> <Plug>MMW_NextSpotByPos   :call mark_my_words#JumpToMark('pos', 'next', 'spot')<CR>
nnoremap <silent> <Plug>MMW_PrevSpotByPos   :call mark_my_words#JumpToMark('pos', 'prev', 'spot')<CR>
nnoremap <silent> <Plug>MMW_NextLineByPos   :call mark_my_words#JumpToMark('pos', 'next', 'line')<CR>
nnoremap <silent> <Plug>MMW_PrevLineByPos   :call mark_my_words#JumpToMark('pos', 'prev', 'line')<CR>


if has('autocmd')
    augroup MMW_autocmds
        autocmd!
        autocmd BufEnter * call mark_my_words#RefreshMarks() 
    augroup END
endif

"===============================================================================
let &cpo= s:keepcpo
unlet s:keepcpo
