" Toggle and display marks
" Signs support required to display marks
"
" Last Change:	Jun 21, 2012
" URL: 
" Maintainer:
" vim: fdm=marker:et:ts=4:sw=4:sts=4
"
" MAPPINGS:
"   g:MarkMyWords_leader      : Set the key used to Toggle Marks. If this key is set to <leader>m, 
"                                 <leader>ma will toggle the mark 'a' 
"                                 <leader>m, will place the next available mark
"                                 <leader>m<Space> will delete all marks
"
"   <Plug>MMW_NextSpotByPos   : Jump to next mark
"   <Plug>MMW_PrevSpotByPos   : Jump to prev mark
"   <Plug>MMW_NextSpotByAlpha : Jump to next mark by Alphabetical Order
"   <Plug>MMW_PrevSpotByAlpha : Jump to prev mark by Alphabetical Order
"   <Plug>MMW_NextLineByPos   : Jump to beginning of next line containing a mark
"   <Plug>MMW_PrevLineByPos   : Jump to beginning of prev line containing a mark
"   <Plug>MMW_NextLineByAlpha : Jump to next line by Alphabetical Order
"   <Plug>MMW_PrevLineByAlpha : Jump to next prev by Alphabetical Order
"
" Recommended:
"   let g:MarkMyWords_leader = 'm'
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
"   line already contains the mark, it'll be unset.
" - Default behavior of ]', [', ]` and [` supported. Also now supports wrapped jumps
"
" CUSTOMISATION:
"   g:MarkMyWords_IncludeMarks : Specify the marks that can be controlled by this plugin
"   Default:
"   let g:MarkMyWords_IncludeMarks = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
"
"   g:MarkMyWords_WrapJumps : Specify if jumping to marks should wrap-around
"   Default:
"   let g:MarkMyWords_WrapJumps = 1
"
" Thanks to 
"   - Sergey Khorev for mark-tools
"   - zakj for vim-showmarks
"
" ToDo:
"   - Add color support for signs
"   - Add custom character display support for signs
"   - Multiple characters display support for signs
"
"===========================================================================

if exists("g:loaded_MarkMyWords")
    finish
endif
let g:loaded_MarkMyWords = 1


if has('autocmd')
    augroup MMW_autocmds
        autocmd!
        autocmd VimEnter * call MarkMyWords#MMW_Setup() 
    augroup END
endif
