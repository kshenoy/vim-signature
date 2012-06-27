" vim: fdm=marker:et:ts=4:sw=4:sts=4
"===============================================================================

" Helper Functions {{{1
    function! s:MarksList() "{{{2
        let l:ref = split("abcdefghijklmnopqrstuvwxyz", '\zs')
        let l:marks = []
        for i in l:ref
            if stridx(g:MarkMyWords_IncludeMarks, i) >= 0
                let l:marks = add(l:marks, [i, line("'" . i)])
            endif
            if stridx(g:MarkMyWords_IncludeMarks, toupper(i)) >= 0
                let [ l:buf, l:line, l:col, l:off ] = getpos("'" . toupper(i))
                if l:buf == bufnr('%') || l:buf == 0
                    let l:marks = add(l:marks, [toupper(i), l:line])
                endif
            endif
            "if stridx(g:MarkMyWords_IncludeMarks, i) >= 0
                "let l:marks = add(l:marks, i)
            "endif
        endfor

        "echo l:marks
        return l:marks
    endfunction

    function! s:MarksAt(line)   "{{{2
        let l:return_var = map(filter(s:MarksList(), 'v:val[1]==' . a:line), 'v:val[0]')
        "echom l:return_var
        return l:return_var
    endfunction

    function! s:UsedMarks()     "{{{2
        let l:return_var = filter(s:MarksList(), 'v:val[1]>0')
        "echo l:return_var
        return l:return_var
    endfunction

    function! s:UnusedMarks()   "{{{2
        let l:ref = split("abcdefghijklmnopqrstuvwxyz", '\zs')
        let l:marks = []
        for i in l:ref
            if stridx(g:MarkMyWords_IncludeMarks, i) >= 0 && line("'" . i) == 0
                let l:marks = add(l:marks, i)
            endif
        endfor
        return l:marks
    endfunction     "}}}2


" Toggle Marks/Signs    {{{1
    function! mark_my_words#ToggleMark(mark)    "{{{2
        let l:lnum = line('.')

        if a:mark == ","
            " Place new mark
            let l:mark = s:UnusedMarks()[0]
            exec 'normal! m' . l:mark
            call s:ToggleSign(l:mark, 1, l:lnum)

        else
            " Toggle Mark
            for i in s:MarksAt(line('.'))
                if i ==# a:mark
                    exec 'delmarks ' . a:mark
                    call s:ToggleSign(a:mark, 0, l:lnum)
                    return
                endif
            endfor

            " Mark not present, hence place new mark
            call s:ToggleSign(a:mark, 0, l:lnum)
            exec 'normal! m' . a:mark
            call s:ToggleSign(a:mark, 1, l:lnum)
        endif
    endfunction

    function! s:ToggleSign(mark, mode, lnum)    "{{{2
        if !has('signs') | return | endif

        if a:mode
            let l:lnum = a:lnum
            let l:str  = get(b:mmw_signs_str, l:lnum, "") . a:mark
        else
            let l:arr = keys(filter(copy(b:mmw_signs_str), 'v:val =~# a:mark'))
            if empty(l:arr) | return | endif
            let l:lnum = l:arr[0]
            let l:str  = substitute(b:mmw_signs_str[l:lnum], a:mark, "", "")
        endif

        let l:id   = ( winbufnr(0) + 1 ) * l:lnum

        if empty(l:str)
            exec 'sign unplace ' . l:id
            call remove(b:mmw_signs_str, l:lnum)
            return
        else
            exec 'sign define MMW_Mark_' . l:id . ' text=' . strpart(l:str, strlen(l:str)-2, 2)
            exec 'sign place ' . l:id . ' line=' . l:lnum . ' name=MMW_Mark_' . l:id . ' file=' . expand('%:p')
            let b:mmw_signs_str[l:lnum] = l:str
        endif

    endfunction

    function! mark_my_words#PurgeAll()  "{{{2
        for i in map(filter(s:MarksList(), 'v:val[1]>0'), 'v:val[0]')
            silent exec 'delmarks ' . i
            silent call s:ToggleSign(i, 0, 0)
        endfor
    endfunction     "}}}2


" Navigate Marks    {{{1
    function! mark_my_words#JumpToMark(mode, dir, loc)  "{{{2
        "echom a:mode . ", " . a:dir . ", " . a:loc

        let l:mark = ""
        let l:dir  = a:dir

        if a:mode ==? "pos"
            let l:mark = s:JumpByPos(a:dir)
        elseif a:mode ==? "alpha"
            let l:mark = s:JumpByAlpha(a:dir)
        endif

        "echom ">>" . l:mark . "<<"

        if a:loc ==? "line"
            exec "normal! '" . l:mark
        elseif a:loc ==? "spot"
            exec 'normal! `' . l:mark
        endif
    endfunction

    function! s:JumpByPos(dir)  "{{{2
        "echom "Jumping by POS"

        let l:MarksList = s:UsedMarks()
        if len(l:MarksList) < 2 | return "" | endif

        let l:pos  = line('.')
        let l:mark = ""
        let l:mark_first = ""
        let l:dist = 0

        if a:dir ==? "next"
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
        elseif a:dir ==? "prev"
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

        if empty(l:mark) && g:MarkMyWords_WrapJumps
            let l:mark = l:mark_first
        endif

      return l:mark
    endfunction

    function! s:JumpByAlpha(dir)    "{{{2
        "echom "Jumping by ALPHA"

        let l:UsedMarks = s:UsedMarks()
        let l:MarksAt = s:MarksAt(line('.'))
        let l:mark = ""
        let l:mark_first = ""

        if empty(l:MarksAt)
            if exists('g:MMW_JumpByAlpha')
                unlet g:MMW_JumpByAlpha
            endif
            return s:JumpByPos(a:dir)
        endif
        
        if len(l:MarksAt) == 1 || !exists('g:MMW_JumpByAlpha')
            let g:MMW_JumpByAlpha = l:MarksAt[0]
        endif

        for i in range(0, len(l:UsedMarks)-1)
            if l:UsedMarks[i][0] ==# g:MMW_JumpByAlpha
                if a:dir ==? "next"
                    if i != len(l:UsedMarks)-1
                        let l:mark = l:UsedMarks[i+1][0]
                        let g:MMW_JumpByAlpha = l:mark
                    elseif g:MarkMyWords_WrapJumps 
                        let l:mark = l:UsedMarks[0][0]
                        let g:MMW_JumpByAlpha = l:mark
                    endif
                elseif a:dir ==? "prev"
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
    endfunction     "}}}2


" Misc {{{1
    function! mark_my_words#RefreshMarks()   "{{{2
        if !exists('b:mmw_signs_str')
            let b:mmw_signs_str = {}
        endif

        let l:used_marks = s:UsedMarks()

        " Remove marks
        for i in split(g:MarkMyWords_IncludeMarks, '\zs')
            let l:pair = items(filter(copy(b:mmw_signs_str), 'v:val =~# i'))
            if !empty(l:pair)
                let l:found = 0
                for j in l:used_marks
                    if j[0] ==# i && j[1] == l:pair[0][0]
                        let l:found = 1
                        break
                    endif
                endfor
                if !(l:found)
                    call s:ToggleSign(i, 0, 0)
                endif
            endif
        endfor

        " Add marks
        for k in l:used_marks
            if !has_key(b:mmw_signs_str, k[1])
                call s:ToggleSign(k[0], 1, k[1])
            elseif b:mmw_signs_str[k[1]] !~# k[0]
                call s:ToggleSign(k[0], 0, 0)
                call s:ToggleSign(k[0], 1, k[1])
            endif
        endfor

    endfunction
