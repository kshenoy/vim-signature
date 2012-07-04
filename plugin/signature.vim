" README:                               {{{1
" vim-signature, version 1.1
" 
" Description:                          {{{2
" vim-signature is a plugin to toggle, display and navigate marks.
" What are marks you say... Read [this](http://vim.wikia.com/wiki/Using_marks)  
" 
" Wait a minute...isn't this done not only well but excellently by vim-showmarks
" and mark-tools; why another plugin you say?
" Well, you are right. However, I got a little impatient with the delay between
" setting and display of marks in vim-showmarks and
" I liked the navigation options which mark-tools provided and I didn't want to
" use two plugins where one would do and
" I was bored and felt like writing my own...
" 
" Are you convinced yet or do you want me to go on? Anyway, that's how vim-signature was born.
" Oh, and I also added some touches of my own such as  
" * Display multiple marks (upto 2, limited by the signs feature)  
" * Place custom signs !@#$%^&*() as visual markers  
"    
" You can see it in action [here](http://imgur.com/a/bPp3m#0)
" 
" 
" Requirements:                         {{{2
" Requires Vim to be compiled with +signs to display marks.
" 
" 
" Installation:                         {{{2
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
" m,         : Place the next available mark
" ]`         : Jump to next mark
" [`         : Jump to prev mark
" ]'         : Jump to start of next line containing a mark
" ['         : Jump to start of prev line containing a mark
" `]         : Jump by alphabetical order to next mark
" `[         : Jump by alphabetical order to prev mark
" ']         : Jump by alphabetical order to start of next line containing a mark
" '[         : Jump by alphabetical order to start of prev line containing a mark
" 
" m[0-9]     : Toggle the corresponding marker !@#$%^&*()  
" m<S-[0-9]> : Remove all markers of the same type  
" ]=         : Jump to next line having same marker
" ]-         : Jump to prev line having same marker
" ````
" 
" This will allow the use of default behavior of m to set marks and, if the line
" already contains the mark, it'll be unset.
" The default behavior of `]'`, `['`, ]_`_ and [_`_ is supported and enhanced by
" wrapping around when beginning or end of file is reached.
"
" The command `SignatureToggle` can be used to enable/disable vim-signature
" 
"
" Customisation:                        {{{2
" The defaults not to your liking bub? Have no fear; use the following
" variables to set things just the way you want it
" 
" `g:SignatureDefaultMappings` ( Default : 1 )
" Will use the default mappings specified below.
" 
" `g:SignatureIncludeMarks` ( Default : 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ' )
" Specify the marks that can be controlled by this plugin.
" Only supports Alphabetical marks at the moment.
" 
" `g:SignatureWrapJumps` ( Default : 1 )
" Specify if jumping to marks should wrap-around.
" 
" `g:SignatureMarkLeader` ( Default : m )
" Set the key used to toggle marks.  If this key is set to `<leader>m`
" `<leader>ma` will toggle the mark 'a'
" `<leader>m,` will place the next available mark
" `<leader>m<Space>` will delete all marks
"
" ````
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
" `g:SignatureLcMarkStr` ( Default : "\p\m" )  
" Set the manner in which local (lowercase) marks are displayed.
" '\m' represents the latest mark added and '\p', the one previous to it.
"     g:SignatureLcMarkStr = "\m."  : Display last mark with '.' suffixed  
"     g:SignatureLcMarkStr = "_\m"  : Display last mark with '_' prefixed  
"     g:SignatureLcMarkStr = ">"    : Display ">" for a line containing a mark. The mark is not displayed  
"     g:SignatureLcMarkStr = "\m\p" : Display last two marks placed  
"
" `g:SignatureUcMarkStr` ( Default : "\p\m" )  
" Set the manner in which global (uppercase) marks are displayed. Similar to above.  
"
" You can display upto 2 characters. That's a limitation imposed by the signs
" feature; nothing I can do about it : / .  
" Setting the MarkStr to a single character will not suffix the mark.
" Don't be lazy people, if you want to see the mark, set it accordingly.  
" Oh, and see in all the above strings, I've used double-quotes and not
" single-quotes. That's not cause I love 'em but things go haywire if
" double-quotes aren't used. Also, `\m` and `\p` cannot be set to <Space>  
" 
" `g:SignatureMarkerLeader` ( Default: m )
" Set the key used to toggle markers.  If this key is set to `<leader>m`
" `<leader>m1` will toggle the marker '!'
" `<leader>m!` will remove all '!' markers  
" 
" <Plug>SIG_NextMarkerByType : Jump to next line having same marker
" <Plug>SIG_PrevMarkerByType : Jump to prev line having same marker
" 
" 
" Thanks To:                            {{{2
" Restecp (no, that's a reference and not a typo :P ) to
" * Sergey Khorev for [mark-tools](http://www.vim.org/scripts/script.php?script_id=2929)
" * Zak Johnson for [vim-showmarks](https://github.com/zakj/vim-showmarks)
" 
" I feel obligated to mention that as some portions were coded so well by
" them, I could think of no way to improve them and I've just used it as is.  
" Well, you know what they say... _"Good coders use; great coders reuse"_ ;)
" 
" 
" ToDo:                                 {{{2
" * Add custom color support for signs
" * Add support for non-Alphabetical marks
" 
" 
" Maintainer:                           {{{2
"   Kartik Shenoy
" 
" Changelist:
"   2012-06-30:
"     - Added support to change display style of marks
"     - Added support to remove all markers of a certain type
"     - Added support to display !@#$%^&*() as signs
"     - Added support to navigate markers
"     - Added support to display multiple marks
" 
"   2012-06-22:
"     - First release
" 
" vim: fdm=marker:et:ts=4:sw=4:sts=4    }}}1
"===========================================================================

" Exit when app has already been loaded (or "compatible" mode set)
if exists("g:loaded_Signature") || &cp
    finish
endif
let g:loaded_Signature = "1.1"  " Version Number
let s:save_cpo         = &cpo
set cpo&vim


function! s:SignatureToggle(...)
    let b:sig_status = ( a:0 > 0 ? a:1 : !( exists('b:sig_status') && b:sig_status ))

    if b:sig_status "   {{{
        if !exists('g:SignatureIncludeMarks')
            let g:SignatureIncludeMarks = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
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

        if g:SignatureDefaultMappings
            if !hasmapto( '<Plug>SIG_PlaceNextMark'    ) | nmap m,       <Plug>SIG_PlaceNextMark| endif
            if !hasmapto( '<Plug>SIG_PurgeMarks'       ) | nmap m<Space> <Plug>SIG_PurgeMarks| endif
            if !hasmapto( '<Plug>SIG_NextLineByAlpha'  ) | nmap ']       <Plug>SIG_NextLineByAlpha| endif
            if !hasmapto( '<Plug>SIG_PrevLineByAlpha'  ) | nmap '[       <Plug>SIG_PrevLineByAlpha| endif
            if !hasmapto( '<Plug>SIG_NextSpotByAlpha'  ) | nmap `]       <Plug>SIG_NextSpotByAlpha| endif
            if !hasmapto( '<Plug>SIG_PrevSpotByAlpha'  ) | nmap `[       <Plug>SIG_PrevSpotByAlpha| endif
            if !hasmapto( '<Plug>SIG_NextLineByPos'    ) | nmap ]'       <Plug>SIG_NextLineByPos| endif
            if !hasmapto( '<Plug>SIG_PrevLineByPos'    ) | nmap ['       <Plug>SIG_PrevLineByPos| endif
            if !hasmapto( '<Plug>SIG_NextSpotByPos'    ) | nmap ]`       <Plug>SIG_NextSpotByPos| endif
            if !hasmapto( '<Plug>SIG_PrevSpotByPos'    ) | nmap [`       <Plug>SIG_PrevSpotByPos| endif
            if !hasmapto( '<Plug>SIG_NextMarkerByType' ) | nmap ]=       <Plug>SIG_NextMarkerByType| endif
            if !hasmapto( '<Plug>SIG_PrevMarkerByType' ) | nmap ]-       <Plug>SIG_PrevMarkerByType| endif
        endif

        for i in split(g:SignatureIncludeMarks, '\zs')
            silent exec 'nnoremap <silent> ' . g:SignatureMarkLeader . i . ' :call signature#ToggleMark("' . i . '")<CR>'
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
            silent exec 'nnoremap <silent> ' . g:SignatureMarkerLeader . i . ' :call signature#ToggleMarker("' . s:signature_markers[i] . '")<CR>'
            silent exec 'nnoremap <silent> ' . g:SignatureMarkerLeader . s:signature_markers[i] . ' :call signature#RemoveMarker("' . s:signature_markers[i] . '")<CR>'
        endfor

        if has('autocmd')
            augroup sig_autocmds
                autocmd!
                autocmd BufEnter * call signature#RefreshAll(1) 
            augroup END
        endif
        call signature#RefreshAll(1)
    " }}}
    else            "   {{{

        call signature#RefreshAll(0)
        if has('autocmd')
            augroup sig_autocmds
                autocmd!
            augroup END
        endif

        for i in range(0, len(s:signature_markers)-1)
            silent exec 'nunmap <silent> ' . g:SignatureMarkerLeader . i
            silent exec 'nunmap <silent> ' . g:SignatureMarkerLeader . s:signature_markers[i]
        endfor
        unlet s:signature_markers
        unlet g:SignatureMarkers

        nunmap <silent> <Plug>SIG_PlaceNextMark
        nunmap <silent> <Plug>SIG_PurgeMarks
        nunmap <silent> <Plug>SIG_NextSpotByAlpha
        nunmap <silent> <Plug>SIG_PrevSpotByAlpha
        nunmap <silent> <Plug>SIG_NextLineByAlpha
        nunmap <silent> <Plug>SIG_PrevLineByAlpha
        nunmap <silent> <Plug>SIG_NextSpotByPos
        nunmap <silent> <Plug>SIG_PrevSpotByPos
        nunmap <silent> <Plug>SIG_NextLineByPos
        nunmap <silent> <Plug>SIG_PrevLineByPos
        nunmap <silent> <Plug>SIG_NextMarkerByType
        nunmap <silent> <Plug>SIG_PrevMarkerByType

        for i in split(g:SignatureIncludeMarks, '\zs')
            silent exec 'nunmap <silent> ' . g:SignatureMarkLeader . i
        endfor

        if exists('g:SignatureIncludeMarks')    | unlet g:SignatureIncludeMarks    | endif
        if exists('g:SignatureWrapJumps')       | unlet g:SignatureWrapJumps       | endif
        if exists('g:SignatureMarkLeader')      | unlet g:SignatureMarkLeader      | endif
        if exists('g:SignatureMarkerLeader')    | unlet g:SignatureMarkerLeader    | endif
        if exists('g:SignatureDefaultMappings') | unlet g:SignatureDefaultMappings | endif
        if exists('g:SignatureLcMarkStr')       | unlet g:SignatureLcMarkStr       | endif
        if exists('g:SignatureUcMarkStr')       | unlet g:SignatureUcMarkStr       | endif

    endif " }}}
endfunction
call s:SignatureToggle(1)

command! -nargs=0 SignatureToggle call s:SignatureToggle()


"===============================================================================
let &cpo = s:save_cpo
unlet s:save_cpo
