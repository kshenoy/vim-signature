" README:               {{{1
" vim-signature, version 1.3
" 
" Description:          {{{2
" vim-signature is a plugin to toggle, display and navigate marks.  
" What are marks you say... Read [this](http://vim.wikia.com/wiki/Using_marks)
" 
" Wait a minute...isn't this done not only well but excellently so by vim-showmarks
" and mark-tools; why another plugin you say?  
" Well, you are right. However, I got a little impatient with the delay between
" setting and display of marks in vim-showmarks and  
" I liked the navigation options which mark-tools provided and I didn't want to
" use two plugins where one would do and  
" I was bored and felt like writing my own...  
" 
" Are you convinced yet or do you want me to go on? Anyway, that's how vim-signature was born.
" Oh, and I also added some touches of my own such as
" * Displaying multiple marks (upto 2, limited by the signs feature)  
" * Placing custom signs !@#$%^&*() as visual markers  
" 
" ### Screenshots
" [Click](http://imgur.com/a/bPp3m#0)
" 
" ### Vim.org mirror
" http://www.vim.org/scripts/script.php?script_id=4118  
" 
" Requirements:         {{{2
" Requires Vim to be compiled with +signs to display marks.
" 
" 
" Installation:         {{{2
" I highly recommend using Pathogen or Vundler to do the dirty work for you. If
" for some reason, you do not want to use any of these excellent plugins, then
" unzip it to your ~/.vim directory. You know how it goes...  
" 
" So, once that's done, out of the box, the followings mappings are defined by
" default
" 
" ````
" m[a-zA-Z]  : Toggle mark  
" m<Space>   : Delete all marks
" m,       : Place the next available mark
" ]`       : Jump to next mark
" [`       : Jump to prev mark
" ]'       : Jump to start of next line containing a mark  
" ['       : Jump to start of prev line containing a mark  
" `]       : Jump by alphabetical order to next mark  
" `[       : Jump by alphabetical order to prev mark  
" ']       : Jump by alphabetical order to start of next line containing a mark  
" '[       : Jump by alphabetical order to start of prev line containing a mark 
" 
" m[0-9]     : Toggle the corresponding marker !@#$%^&*()
" m<S-[0-9]>   : Remove all markers of the same type  
" ]=       : Jump to next line having same marker  
" ]-       : Jump to prev line having same marker  
" m<BackSpace> : Remove all markers  
" ````
" 
" This will allow the use of default behavior of m to set marks and, if the line
" already contains the mark, it'll be unset.  
" The default behavior of `]'`, `['`, ``]` `` and ``[` `` is supported and enhanced by
" wrapping around when beginning or end of file is reached.  
" 
" The command `SignatureToggleDisplay` can be used to show/hide the signs. Note that this does not delete any of the marks but only hides them.  
" 
" 
" Customisation:        {{{2
" The defaults not to your liking bub? Have no fear; use the following
" variables to set things just the way you want it  
" 
" * `g:SignatureDefaultMappings` ( Default : 1 )  
" Will use the default mappings specified below.  
" 
" * `g:SignatureIncludeMarks` ( Default : 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ' )  
" Specify the marks that can be controlled by this plugin.
" Only supports Alphabetical marks at the moment.  
" `b:SignatureIncludeMarks` can be set separately to specify buffer-specific settings.  
" 
" * `g:SignatureWrapJumps` ( Default : 1 )  
" Specify if jumping to marks should wrap-around.
" `b:SignatureWrapJumps` can be set to specify buffer-specific settings.  
" 
" * `g:SignatureMarkLeader` ( Default: m )  
" Set the key used to toggle marks.  If this key is set to `<leader>m`,  
"   `<leader>ma` will toggle the mark 'a'  
"   `<leader>m,` will place the next available mark  
"   `<leader>m<Space>` will delete all marks  
" 
" ````
" <Plug>SIG_PlaceNextMark    : Place next available mark
" <Plug>SIG_PurgeMarks     : Remove all marks
" <Plug>SIG_NextSpotByPos    : Jump to next mark  
" <Plug>SIG_PrevSpotByPos    : Jump to prev mark  
" <Plug>SIG_NextLineByPos    : Jump to start of next line containing a mark  
" <Plug>SIG_PrevLineByPos    : Jump to start of prev line containing a mark  
" <Plug>SIG_NextSpotByAlpha  : Jump by alphabetical order to next mark  
" <Plug>SIG_PrevSpotByAlpha  : Jump by alphabetical order to prev mark  
" <Plug>SIG_NextLineByAlpha  : Jump by alphabetical order to start of next line containing a mark  
" <Plug>SIG_PrevLineByAlpha  : Jump by alphabetical order to start of prev line containing a mark  
" ````
" 
" * `g:SignatureLcMarkStr` ( Default : "\p\m" )  
" Set the manner in which local (lowercase) marks are displayed.  
" `g:SignatureUcMarkStr` ( Default : "\p\m" )  
" Set the manner in which global (uppercase) marks are displayed. Similar to above.  
" `b:SignatureLcMarkStr` and `b:SignatureUcMarkStr`can be set separately to specify buffer-specific settings.  
" 
" `\m` represents the latest mark added and `\p`, the one previous to it.
" ````
" g:SignatureLcMarkStr = "\m."  : Display last mark with '.' suffixed  
" g:SignatureLcMarkStr = "_\m"  : Display last mark with '_' prefixed  
" g:SignatureLcMarkStr = ">"    : Display ">" for a line containing a mark. The mark is not displayed  
" g:SignatureLcMarkStr = "\m\p" : Display last two marks placed  
" ````
" 
" You can display upto 2 characters. That's a limitation imposed by the signs
" feature; nothing I can do about it : / .  
" Setting the MarkStr to a single character will not suffix the mark.
" Don't be lazy people, if you want to see the mark, set it accordingly.  
" Oh, and see in all the above strings, I've used double-quotes and not
" single-quotes. That's not cause I love 'em but things go haywire if
" double-quotes aren't used. Also, `\m` and `\p` cannot be set to _Space_  
" 
" * `g:SignatureMarkerLeader` ( Default: m )  
" Set the key used to toggle markers.  If this key is set to `<leader>m`  
"   `<leader>m1` will toggle the marker '!'  
"   `<leader>m!` will remove all the '!' markers  
" 
" * `g:SignatureIncludeMarkers` ( Default : '!@#$%^&*()' )
" Specify the markers that can be used by the plugin.
" `b:SignatureIncludeMarkers` can be specified separately for buffer-specific settings  
" 
" ````
" <Plug>SIG_NextMarkerByType : Jump to next line having same marker  
" <Plug>SIG_PrevMarkerByType : Jump to prev line having same marker  
" <Plug>SIG_PurgeMarkers     : Remove all markers  
" ````
"
" * `g:SignaturePurgeConfirmation` ( Default: 0 )
" An option for the more clumsy-fingered. Asks for confirmation before deleting all marks

" * `g:SignatureDisableMenu` ( Default: 0 )  
" Hides the menu if set to 1  
" 
" * `g:SignatureMenuStruct` ( Default: "P&lugins.&Signature" )  
" Set where the menu options are to be displayed. For more details type,
" ````
" :h usr_42.txt
" ````
" 
" 
" Thanks To:            {{{2
" Restecp to (no, that's a reference and not a typo :P )  
" * Sergey Khorev for [mark-tools](http://www.vim.org/scripts/script.php?script_id=2929)
" * Zak Johnson for [vim-showmarks](https://github.com/zakj/vim-showmarks)  
" 
" I feel obligated to mention that as some portions were coded so well by
" them, I could think of no way to improve them and I've just used it as is.  
" Well, you know what they say... _"Good coders use; great coders reuse"_ ;)
" 
" 
" ToDo:                 {{{2
" * Add custom color support for signs
" * Add support for non-Alphabetical marks
" 
" 
" Maintainer:           {{{2
" Kartik Shenoy
" 
" Changelist:
" 2012-09-22:
"   - vim-signature is now initialised ( mappings, sign display etc. ) upon entering the buffer
"   - Checks buffer type before setting up vim-signature
"     ( in response to: https://github.com/kshenoy/vim-signature/issues/3 )
"   - SignatureToggle command now also removes all mappings
"
" 2012-08-15:
"   - Added option to ask for confirmation before deleting all marks
"
" 2012-07-23:
"   - Enabled non-default mappings for m, m<Space> and m<BS> which had been left out
"   - Display mark options in menu
"   - Modified marker navigation mappings to be consistent with others
"   in the use of [ and ] to go to the prev and next respectively
"
" 2012-07-05:
"   - Added support to toggle sign display
"   - Added support for buffer-specific settings
"
" 2012-06-30:
"   - Added support to change display style of marks
"   - Added support to remove all markers of a certain type
"   - Added support to display !@#$%^&*() as signs
"   - Added support to navigate markers
"   - Added support to display multiple marks
" 
" 2012-06-22:
"   - First release
" 
" vim: fdm=marker:et:ts=4:sw=2:sts=2  }}}1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Exit when app has already been loaded (or "compatible" mode set)
if exists("g:loaded_Signature") || &cp
  finish
endif
let g:loaded_Signature = "1.3"  " Version Number
let s:save_cpo = &cpo
set cpo&vim


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Global variables     {{{1
"
if !exists('g:SignatureIncludeMarks')
  let g:SignatureIncludeMarks = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
endif
if !exists('g:SignatureIncludeMarkers')
  let g:SignatureIncludeMarkers = ")!@#$%^&*("
endif
if !exists('g:SignatureWrapJumps')
  let g:SignatureWrapJumps = 1
endif
if !exists('g:SignatureMarkLeader')
  let g:SignatureMarkLeader = "m"
endif
if !exists('g:SignatureMarkerLeader')
  let g:SignatureMarkerLeader = g:SignatureMarkLeader
endif
if !exists('g:SignatureDefaultMappings')
  let g:SignatureDefaultMappings = 1
endif
if !exists('g:SignatureLcMarkStr')
  let g:SignatureLcMarkStr = "\p\m"
endif
if !exists('g:SignatureUcMarkStr')
  let g:SignatureUcMarkStr = g:SignatureLcMarkStr
endif
if !exists('g:SignaturePurgeConfirmation')
  let g:SignaturePurgeConfirmation = 0
endif
if !exists('g:SignatureDisableMenu')
  let g:SignatureDisableMenu = 0
endif
if !exists('g:SignatureMenuStruct')
  let g:SignatureMenuStruct = 'P&lugin.&Signature'
endif
if !exists('g:SignaturePeriodicRefresh')
  let g:SignaturePeriodicRefresh = 1
endif
" }}}1

call signature#Init() 


if has('autocmd')
  augroup sig_autocmds
    autocmd!
    autocmd FileType nerdtree call signature#BufferRefresh(1)
    autocmd BufEnter * call signature#BufferRefresh(1) 
    autocmd CursorHold * if g:SignaturePeriodicRefresh | call signature#BufferRefresh(1) | endif
  augroup END
endif

command! -nargs=0 SignatureToggle         call signature#BufferRefresh(0)
command! -nargs=0 SignatureRefreshDisplay call signature#BufferRefresh(1)


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Create Menu          {{{1
"
if !g:SignatureDisableMenu && has('gui_running')
  exec 'menu  <silent> ' . g:SignatureMenuStruct . '.Pl&ace\ next\ mark<Tab>' . g:SignatureMarkLeader . ', :call signature#ToggleMark(",")<CR>'
  exec 'menu  <silent> ' . g:SignatureMenuStruct . '.Re&move\ all\ marks\ \ \ \ <Tab>' . g:SignatureMarkLeader . '<Space> :call signature#PurgeMarks()<CR>'

  if hasmapto('<Plug>SIG_NextSpotByPos')
    exec 'menu  <silent> ' . g:SignatureMenuStruct . '.Goto\ &next\ mark\ (pos)<Tab>' . signature#MapKey('<Plug>SIG_NextSpotByPos', 'n') . ' :call signature#GotoMark("pos", "next", "spot")'
  else
    exec 'menu  <silent> ' . g:SignatureMenuStruct . '.Goto\ &next\ mark\ (pos) :call signature#GotoMark("pos", "next", "spot")'
  endif

  if hasmapto('<Plug>SIG_PrevSpotByPos')
    exec 'menu  <silent> ' . g:SignatureMenuStruct . '.Goto\ p&rev\ mark\ (pos)<Tab>' . signature#MapKey('<Plug>SIG_PrevSpotByPos', 'n') . ' :call signature#GotoMark("pos", "prev", "spot")'
  else
    exec 'menu  <silent> ' . g:SignatureMenuStruct . '.Goto\ p&rev\ mark\ (pos) :call signature#GotoMark("pos", "prev", "spot")'
  endif

  if hasmapto('<Plug>SIG_NextSpotByAlpha')
    exec 'menu  <silent> ' . g:SignatureMenuStruct . '.Goto\ next\ mark\ (a&lpha)<Tab>' . signature#MapKey('<Plug>SIG_NextSpotByAlpha', 'n') . ' :call signature#GotoMark("alpha", "next", "spot")'
  else
    exec 'menu  <silent> ' . g:SignatureMenuStruct . '.Goto\ next\ mark\ (a&lpha) :call signature#GotoMark("alpha", "next", "spot")'
  endif

  if hasmapto('<Plug>SIG_PrevSpotByAlpha')
    exec 'menu  <silent> ' . g:SignatureMenuStruct . '.Goto\ prev\ mark\ (alp&ha)<Tab>' . signature#MapKey('<Plug>SIG_PrevSpotByAlpha', 'n') . ' :call signature#GotoMark("alpha", "prev", "spot")'
  else
    exec 'menu  <silent> ' . g:SignatureMenuStruct . '.Goto\ prev\ mark\ (alp&ha)<Tab> :call signature#GotoMark("alpha", "prev", "spot")'
  endif

  exec 'amenu <silent> ' . g:SignatureMenuStruct . '.-s1- :'

  exec 'menu  <silent> ' . g:SignatureMenuStruct . '.Rem&ove\ all\ markers<Tab>' . g:SignatureMarkerLeader . '<BS> :call signature#PurgeMarkers()<CR>'

  if hasmapto('<Plug>SIG_NextMarkerByType')
    exec 'menu  <silent> ' . g:SignatureMenuStruct . '.Goto\ nex&t\ marker<Tab>' . signature#MapKey('<Plug>SIG_NextMarkerByType', 'n') . ' :call signature#GotoMarker("next")'
  else
    exec 'menu  <silent> ' . g:SignatureMenuStruct . '.Goto\ nex&t\ marker :call signature#GotoMarker("next")'
  endif

  if hasmapto('<Plug>SIG_PrevMarkerByType')
    exec 'menu  <silent> ' . g:SignatureMenuStruct . '.Goto\ pre&v\ marker<Tab>' . signature#MapKey('<Plug>SIG_PrevMarkerByType', 'n') . ' :call signature#GotoMarker("prev")'
  else
    exec 'menu  <silent> ' . g:SignatureMenuStruct . '.Goto\ pre&v\ marker :call signature#GotoMarker("prev")'
  endif
endif
" }}}1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let &cpo = s:save_cpo
unlet s:save_cpo
