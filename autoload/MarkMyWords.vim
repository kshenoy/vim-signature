" vim: fdm=marker:et:ts=4:sw=4:sts=4
"===============================================================================
" Public Interface: {{{1
" AppFunction: is a function you expect your users to call
" PickAMap: some sequence of characters that will run your AppFunction
" Repeat these three lines as needed for multiple functions which will
" be used to provide an interface for the user

" Global Maps:
"

"===============================================================================
" s:AppFunction: this function is available vi the <Plug>/<script> interface above  {{{1

    function! MarkMyWords#ToggleMark(mark)    "{{{
        let l:lnum = line('.')

        if a:mark == ','
            " Place new mark
            let l:mark = s:UnusedMarks()[0]
            exec "normal! m" . l:mark
            call s:ToggleSign(l:mark, 1, l:lnum)

        else
            " Toggle Mark
            for i in s:MarksAt(line('.'))
                if i ==# a:mark
                    exec "delmarks " . a:mark
                    call s:ToggleSign(a:mark, 0, l:lnum)
                    return
                endif
            endfor

            " Mark not present, hence place new mark
            call s:ToggleSign(a:mark, 0, l:lnum)
            exec "normal! m" . a:mark
            call s:ToggleSign(a:mark, 1, l:lnum)
        endif
    endfunction
    "}}}
    function! MarkMyWords#PurgeAll()  "{{{
        for i in map(filter(s:MarksList(), 'v:val[1]>0'), 'v:val[0]')
            silent exec 'delmarks ' . i
            silent call s:ToggleSign(i, 0, 0)
        endfor
    endfunction
    "}}}
    function! MarkMyWords#JumpToMark(mode, dir, loc)  "{{{
        "echom a:mode . ', ' . a:dir . ', ' . a:loc

        let l:mark = ''
        let l:dir  = a:dir

        if a:mode ==? 'pos'
            let l:mark = s:JumpByPos(a:dir)
        elseif a:mode ==? 'alpha'
            let l:mark = s:JumpByAlpha(a:dir)
        endif

        "echom ">>" . l:mark . "<<"

        if a:loc ==? 'line'
            exec "normal! '" . l:mark
        elseif a:loc ==? 'spot'
            exec "normal! `" . l:mark
        endif
    endfunction
    "}}}

  " Set up maps to internal functions

  " Call functions and not worry about name clashes by preceding those function names with <SID>
  " or you could call it with

"===============================================================================
" s:InternalAppFunction: this function cannot be called from outside the {{{1
" script, and its name won't clash with whatever else the user has loaded
let s:signs_ids = []

" Initial Setup {{{2
    function! MarkMyWords#MMW_Setup()   "{{{
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

        for i in split(g:MarkMyWords_IncludeMarks, '\zs')
            exec 'sign define MMW_Mark_'.i.' text='.i
        endfor
        for j in s:UsedMarks()
            call s:ToggleSign(j[0], 1, j[1])
        endfor

        call s:InitMappings()

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
    endfunction
    "}}}
    function! s:InitMappings()  "{{{
        for i in split(g:MarkMyWords_IncludeMarks, '\zs')
            "echom 'nnoremap <silent> ' . g:MarkMyWords_leader . i . ' :call MarkMyWords#ToggleMark("' . i . '")<CR>'
            silent exec 'nnoremap <silent> ' . g:MarkMyWords_leader . i . ' :call MarkMyWords#ToggleMark("' . i . '")<CR>'
        endfor

        silent exec 'nnoremap <silent> ' . g:MarkMyWords_leader . ', :call MarkMyWords#ToggleMark(",")<CR>'
        silent exec 'nnoremap <silent> ' . g:MarkMyWords_leader . '<Space> :call MarkMyWords#PurgeAll()<CR>'

        if !hasmapto('<Plug>MMW_NextSpotByAlpha')
            nnoremap <silent> <Plug>MMW_NextSpotByAlpha :call MarkMyWords#JumpToMark('alpha', 'next', 'spot')<CR>
        endif
        if !hasmapto('<Plug>MMW_PrevSpotByAlpha')
            nnoremap <silent> <Plug>MMW_PrevSpotByAlpha :call MarkMyWords#JumpToMark('alpha', 'prev', 'spot')<CR>
        endif
        if !hasmapto('<Plug>MMW_NextLineByAlpha')
            nnoremap <silent> <Plug>MMW_NextLineByAlpha :call MarkMyWords#JumpToMark('alpha', 'next', 'line')<CR>
        endif
        if !hasmapto('<Plug>MMW_PrevLineByAlpha')
            nnoremap <silent> <Plug>MMW_PrevLineByAlpha :call MarkMyWords#JumpToMark('alpha', 'prev', 'line')<CR>
        endif
        if !hasmapto('<Plug>MMW_NextSpotByPos')
            nnoremap <silent> <Plug>MMW_NextSpotByPos   :call MarkMyWords#JumpToMark('pos', 'next', 'spot')<CR>
        endif
        if !hasmapto('<Plug>MMW_PrevSpotByPos')
            nnoremap <silent> <Plug>MMW_PrevSpotByPos   :call MarkMyWords#JumpToMark('pos', 'prev', 'spot')<CR>
        endif
        if !hasmapto('<Plug>MMW_NextLineByPos')
            nnoremap <silent> <Plug>MMW_NextLineByPos   :call MarkMyWords#JumpToMark('pos', 'next', 'line')<CR>
        endif
        if !hasmapto('<Plug>MMW_PrevLineByPos')
            nnoremap <silent> <Plug>MMW_PrevLineByPos   :call MarkMyWords#JumpToMark('pos', 'prev', 'line')<CR>
        endif
    endfunction
    "}}}

" Misc Functions {{{2
    function! s:MarksList() "{{{
        let l:ref = split('abcdefghijklmnopqrstuvwxyz', '\zs')
        let l:marks = []
        for i in l:ref
            if stridx(g:MarkMyWords_IncludeMarks, toupper(i)) >= 0
                let [ l:buf, l:line, l:col, l:off ] = getpos("'" . toupper(i))
                if l:buf == bufnr('%') || l:buf == 0
                    let l:marks = add(l:marks, [toupper(i), l:line])
                endif
            endif
            if stridx(g:MarkMyWords_IncludeMarks, i) >= 0
                let l:marks = add(l:marks, [i, line("'" . i)])
            endif
            "if stridx(g:MarkMyWords_IncludeMarks, i) >= 0
                "let l:marks = add(l:marks, i)
            "endif
        endfor

        "echo l:marks
        return l:marks
    endfunction
    "}}}
    function! s:MarksAt(line)   "{{{
        let l:return_var = map(filter(s:MarksList(), 'v:val[1]==' . a:line), 'v:val[0]')
        "echom l:return_var
        return l:return_var
    endfunction
    "}}}
    function! s:UsedMarks()     "{{{
        let l:return_var = filter(s:MarksList(), 'v:val[1]>0')
        "echo l:return_var
        return l:return_var
    endfunction
    "}}}
    function! s:UnusedMarks()   "{{{
        let l:ref = split('abcdefghijklmnopqrstuvwxyz', '\zs')
        let l:marks = []
        for i in l:ref
            if stridx(g:MarkMyWords_IncludeMarks, i) >= 0 && line("'" . i) == 0
                let l:marks = add(l:marks, i)
            endif
        endfor
        return l:marks
    endfunction
    "}}}

" Toggle Signs  {{{2
    function! s:ToggleSign(mark, mode, lnum)    "{{{
        if !has('signs')
            return
        endif

        let l:id = str2nr(bufnr('%') . a:lnum . stridx(g:MarkMyWords_IncludeMarks, a:mark))
        if a:mode
            exec 'sign place ' . l:id . ' line=' . a:lnum . ' name=MMW_Mark_' . a:mark . ' file=' . expand("%:p")
            for i in s:signs_ids
                if i[0] ==# a:mark
                    let i[1] = l:id
                    return
                endif
            endfor
            let s:signs_ids = add(s:signs_ids, [a:mark, l:id])
        else
            if !empty(s:signs_ids)
                for i in range(0, len(s:signs_ids)-1)
                    if s:signs_ids[i][0] ==# a:mark
                        exec 'sign unplace ' . s:signs_ids[i][1]
                        call remove(s:signs_ids, i, i)
                        "echo s:signs_ids
                        return
                    endif
                endfor
            endif
        endif
    endfunction
    "}}}

" Jump to Marks {{{2
    function! s:JumpByPos(dir)  "{{{
        "echom "Jumping by POS"

        let l:pos  = line('.')
        let l:mark = ''
        let l:mark_first = ''
        let l:dist = 0
        let l:MarksList = s:UsedMarks()

        if !empty(l:MarksList)
            if a:dir ==? 'next'
                let l:pos_first = line('$') + 1
                for m in l:MarksList
                    if m[1] > l:pos && ( l:dist == 0 || m[1] - l:pos < l:dist )
                        let l:mark = m[0]
                        let l:dist = m[1] - l:pos
                    endif
                    if m[1] < l:pos_first
                        let l:mark_first = m[0]
                        let l:pos_first  = m[1]
                    endif
                endfor
            elseif a:dir ==? 'prev'
                let l:pos_first = 0
                for m in l:MarksList
                    if m[1] < l:pos && ( l:dist == 0 || l:pos - m[1] < l:dist )
                        let l:mark = m[0]
                        let l:dist = l:pos - m[1]
                    endif
                    if m[1] > l:pos_first
                        let l:mark_first = m[0]
                        let l:pos_first  = m[1]
                    endif
                endfor
            endif
            if l:mark == '' && g:MarkMyWords_WrapJumps
                let l:mark = l:mark_first
            endif
        endif
      return l:mark
    endfunction
    "}}}
    function! s:JumpByAlpha(dir)    "{{{
        "echom "Jumping by ALPHA"

        let l:UsedMarks = s:UsedMarks()
        let l:MarksAt = s:MarksAt(line('.'))
        let l:mark = ''
        let l:mark_first = ''

        if empty(l:MarksAt)
            if exists("g:MMW_JumpByAlpha")
                unlet g:MMW_JumpByAlpha
            endif
            return s:JumpByPos(a:dir)
        endif
        
        if len(l:MarksAt) == 1 || !exists('g:MMW_JumpByAlpha')
            let g:MMW_JumpByAlpha = l:MarksAt[0]
        endif

        for i in range(0, len(l:UsedMarks)-1)
            if l:UsedMarks[i][0] ==# g:MMW_JumpByAlpha
                if a:dir ==? 'next'
                    if i != len(l:UsedMarks)-1
                        let l:mark = l:UsedMarks[i+1][0]
                        let g:MMW_JumpByAlpha = l:mark
                    elseif g:MarkMyWords_WrapJumps 
                        let l:mark = l:UsedMarks[0][0]
                        let g:MMW_JumpByAlpha = l:mark
                    endif
                elseif a:dir ==? 'prev'
                    if i != 0
                        let l:mark = l:UsedMarks[i-1][0]
                        let g:MMW_JumpByAlpha = l:mark
                    elseif g:MarkMyWords_WrapJumps
                        let l:mark = l:UsedMarks[-1][0]
                        let g:MMW_JumpByAlpha = l:mark
                    endif
                endif
                return l:mark
            endif
        endfor
    endfunction
    "}}}

" }}}1
"===============================================================================
