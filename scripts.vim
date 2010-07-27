if did_filetype()	" filetype already set..
	  finish		" ..don't do these checks
endif

" WECAC package

if !exists("WECAC_loaded")

    function WECAC_CountCols(line)
        return len(split(a:line, "\t"))
    endfunction

    function WECAC_IsTabCsv()
        let ncols1 = WECAC_CountCols(getline(1))
        if ncols1 <= 2
            return 0
        endif
        let lnum = 2
        while lnum <= 5
            if WECAC_CountCols(getline(lnum)) != ncols1
                return 0
            endif
            let lnum += 1
        endwhile
        return 1
    endfunction

    let WECAC_loaded = 1

endif
    
if &ft == 'text' && WECAC_IsTabCsv()
    set filetype=csv
    Delimiter \t
endif
