" vim: fdm=marker:et:ts=4:sw=4:sts=4
"===============================================================================

" Helper Functions {{{1
    function! s:MarksList() "{{{2
        let l:ref = split("abcdefghijklmnopqrstuvwxyz", '\zs')
        let l:marks = []
        for i in l:ref
            if stridx(g:SignatureIncludeMarks, i) >= 0
                let l:marks = add(l:marks, [i, line("'" . i)])
            endif
            if stridx(g:SignatureIncludeMarks, toupper(i)) >= 0
                let [ l:buf, l:line, l:col, l:off ] = getpos("'" . toupper(i))
                if l:buf == bufnr('%') || l:buf == 0
                    let l:marks = add(l:marks, [toupper(i), l:line])
                endif
            endif
            "if stridx(g:SignatureIncludeMarks, i) >= 0
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
            if stridx(g:SignatureIncludeMarks, i) >= 0 && line("'" . i) == 0
                let l:marks = add(l:marks, i)
            endif
        endfor
        return l:marks
    endfunction     "}}}2


" Toggle Marks/Signs    {{{1
    function! signature#ToggleMark(mark)    "{{{2
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
            call s:ToggleSign(a:mark, 0, 0)
            exec 'normal! m' . a:mark
            call s:ToggleSign(a:mark, 1, l:lnum)
        endif
    endfunction

    function! signature#ToggleMarker(marker)    "{{{2
        let l:lnum = line('.')
        if has_key(b:sig_markers, l:lnum) && b:sig_markers[l:lnum] == a:marker
            call s:ToggleSign(a:marker, 0, l:lnum)
        else
            call s:ToggleSign(a:marker, 1, l:lnum)
        endif
    endfunction

    function! s:ToggleSign(mark, mode, lnum)    "{{{2
        if !has('signs') | return | endif

        if stridx(g:SignatureMarkers, a:mark) >= 0
            " Visual marker has been set
            let l:lnum = a:lnum
            let l:id = ( winbufnr(0) + 1 ) * l:lnum
            if a:mode
                let b:sig_markers[l:lnum] = a:mark
                let l:str = stridx(g:SignatureMarkers, a:mark)
                exec 'sign place ' . l:id . ' line=' . l:lnum . ' name=sig_Marker_' . l:str . ' file=' . expand('%:p')
            else
                call remove(b:sig_markers, l:lnum)
                if has_key(b:sig_marks, l:lnum)
                    let l:str  = strpart(b:sig_marks[l:lnum], strlen(b:sig_marks[l:lnum])-2, 2)
                    exec 'sign define sig_Mark_' . l:id . ' text=' . l:str . ' texthl=Exception'
                    exec 'sign place ' . l:id . ' line=' . l:lnum . ' name=sig_Mark_' . l:id . ' file=' . expand('%:p')
                else
                    exec 'sign unplace ' . l:id
                endif
            endif

        else
            " Alphabetical mark has been set
            if a:mode
                let l:lnum = a:lnum
                let b:sig_marks[l:lnum] = get(b:sig_marks, l:lnum, "") . a:mark

            else
                let l:arr = keys(filter(copy(b:sig_marks), 'v:val =~# a:mark'))
                if empty(l:arr) | return | endif
                let l:lnum = l:arr[0]
                let l:save_ic = &ic | set noic
                let b:sig_marks[l:lnum] = substitute(b:sig_marks[l:lnum], a:mark, "", "")
                let &ic = l:save_ic
            endif

            let l:id = ( winbufnr(0) + 1 ) * l:lnum
            let l:str  = strpart(b:sig_marks[l:lnum], strlen(b:sig_marks[l:lnum])-2, 2)
            if empty(l:str) 
                call remove(b:sig_marks, l:lnum)
                if !has_key(b:sig_markers, l:lnum)
                    exec 'sign unplace ' . l:id
                endif
            elseif !has_key(b:sig_markers, l:lnum)
                exec 'sign define sig_Mark_' . l:id . ' text=' . l:str . ' texthl=Exception'
                exec 'sign place ' . l:id . ' line=' . l:lnum . ' name=sig_Mark_' . l:id . ' file=' . expand('%:p')
            endif
        endif

    endfunction

    function! signature#PurgeMarks()  "{{{2
        for i in map(filter(s:MarksList(), 'v:val[1]>0'), 'v:val[0]')
            silent exec 'delmarks ' . i
            silent call s:ToggleSign(i, 0, 0)
        endfor
    endfunction     "}}}2


" Navigate Marks    {{{1
    function! signature#GotoMark(mode, dir, loc)  "{{{2
        "echom a:mode . ", " . a:dir . ", " . a:loc

        let l:mark = ""
        let l:dir  = a:dir

        if a:mode ==? "pos"
            let l:mark = s:GotoMarkByPos(a:dir)
        elseif a:mode ==? "alpha"
            let l:mark = s:GotoMarkByAlpha(a:dir)
        endif

        "echom ">>" . l:mark . "<<"

        if a:loc ==? "line"
            exec "normal! '" . l:mark
        elseif a:loc ==? "spot"
            exec 'normal! `' . l:mark
        endif
    endfunction

    function! s:GotoMarkByPos(dir)  "{{{2
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

        if empty(l:mark) && g:Signature_WrapJumps
            let l:mark = l:mark_first
        endif

      return l:mark
    endfunction

    function! s:GotoMarkByAlpha(dir)    "{{{2
        "echom "Jumping by ALPHA"

        let l:UsedMarks = s:UsedMarks()
        let l:MarksAt = s:MarksAt(line('.'))
        let l:mark = ""
        let l:mark_first = ""

        if empty(l:MarksAt)
            if exists('g:sig_GotoMarkByAlpha')
                unlet g:sig_GotoMarkByAlpha
            endif
            return s:GotoMarkByPos(a:dir)
        endif
        
        if len(l:MarksAt) == 1 || !exists('g:sig_GotoMarkByAlpha')
            let g:sig_GotoMarkByAlpha = l:MarksAt[0]
        endif

        for i in range(0, len(l:UsedMarks)-1)
            if l:UsedMarks[i][0] ==# g:sig_GotoMarkByAlpha
                if a:dir ==? "next"
                    if i != len(l:UsedMarks)-1
                        let l:mark = l:UsedMarks[i+1][0]
                        let g:sig_GotoMarkByAlpha = l:mark
                    elseif g:Signature_WrapJumps 
                        let l:mark = l:UsedMarks[0][0]
                        let g:sig_GotoMarkByAlpha = l:mark
                    endif
                elseif a:dir ==? "prev"
                    if i != 0
                        let l:mark = l:UsedMarks[i-1][0]
                        let g:sig_GotoMarkByAlpha = l:mark
                    elseif g:Signature_WrapJumps
                        let l:mark = l:UsedMarks[-1][0]
                        let g:sig_GotoMarkByAlpha = l:mark
                    endif
                endif
                return l:mark
            endif
        endfor
    endfunction     "}}}2


" Navigate Signs    {{{1
    function! signature#GotoMarker(dir)   "{{{2
        let l:lnum = line('.')
        let l:lmax = 0
        let l:lmin = line('$') + 1

        if     a:dir ==? "next" | let l:targ = l:lmin
        elseif a:dir ==? "prev" | let l:targ = l:lmax
        endif

        for i in keys(filter(copy(b:sig_markers), 'v:val==b:sig_markers[l:lnum]'))
            if a:dir == "next" && i > l:lnum && i < l:targ ||
             \ a:dir == "prev" && i < l:lnum && i > l:targ
                let l:targ = i
            endif
            if i < l:lmin | let l:lmin = i | endif
            if i > l:lmax | let l:lmax = i | endif
        endfor

        if     a:dir == "next" && l:lnum == l:lmax | let l:targ = l:lmin
        elseif a:dir == "prev" && l:lnum == l:lmin | let l:targ = l:lmax
        endif

        if l:targ != 0 && l:targ != line('$') + 1
            exec 'normal! ' . l:targ . 'G'
        endif
    endfunction     "}}}2


" Misc {{{1
    function! signature#RefreshMarks()   "{{{2
        if !exists('b:sig_marks')   | let b:sig_marks   = {} | endif
        if !exists('b:sig_markers') | let b:sig_markers = {} | endif

        let l:used_marks = s:UsedMarks()

        " Remove marks
        for i in split(g:SignatureIncludeMarks, '\zs')
            let l:pair = items(filter(copy(b:sig_marks), 'v:val =~# i'))
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
                    echom "Whoa!!!"
                endif
            endif
        endfor

        " Add marks
        for k in l:used_marks
            if !has_key(b:sig_marks, k[1])
                call s:ToggleSign(k[0], 1, k[1])
            elseif b:sig_marks[k[1]] !~# k[0]
                call s:ToggleSign(k[0], 0, 0)
                call s:ToggleSign(k[0], 1, k[1])
            endif
        endfor

    endfunction
