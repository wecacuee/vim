function! FixCuddledBraces()
    :argdo %s/\(\s*\)} \(else\( if (.\{-})\)\?\|catch (.\{-})\|finally\) {/\1}\r\1\2 {/gec | update
    :argdo %s/^\(\s*\)\(\(public\|private\|protected\).*\)\s*{/\1\2\r\1{/gec | update
endfunction

function! LineBeforeIf()
    :argdo %s/\(\n\s*[^\/ ]\S\+.*[^ {]\s*\)\(\n\s*if (\)/\1\r\2/gec | update
endfunction

function! Find80Character()
    :vimgrep /^.\{81,}$/g ./**/*.java
endfunction

function! FindMissingExtraLineAtEndOfBlock()
    :vimgrep /}\s*\n\s*[^ }ecf*]/gj ./**/*.java
    :vimgrep /^\s*[^ */].*[^}{;]\s*\n.*;\s*\n\s*\S.*[^}]$/g **/*.java
endfunction

function! PushExtraLineAtTheEndOfFile()
    :argdo $s/^\s*\S\+\s*\zs\ze$/\r/gec | update
endfunction

function! ReplaceParamsNextFunction(slnum, scnum)
  let c_lnum = a:slnum
  call cursor(c_lnum, a:scnum)
  let end_func_def = search('{')
  let lines = getline(c_lnum, end_func_def)
  let funcDef = join(lines)
  let paramList = ParseParameters(funcDef)

  let s_skip ='synIDattr(synID(line("."), col("."), 0), "name") ' .
        \ '=~?	"string\\|comment"'
  execute 'if' s_skip '| let s_skip = 0 | endif'

  let m_lnum = searchpair('{', '', '}', 'nW', s_skip)

  let cmd = c_lnum . ',' . m_lnum . 's/\<-oldname-\>/-newname-/gc'
  for param in paramList
    let newParam = NewParamName(param)
    if strlen(newParam)
        let thiscmd = substitute(cmd, '-oldname-', param, '')
        let thiscmd = substitute(thiscmd, '-newname-', newParam, '')
        exe thiscmd
    endif
   endfor
   call cursor(m_lnum, $)
endfunction
    

function! ReplaceParmatersAllFunctions()
  call cursor(1, 1)
  let pattern = '\(public\|private\|protected\)[^=]*(\_.\{-})\_.\{-}{'
  let flags = 'W'
  let [c_lnum, c_cnum] = searchpos(pattern, flags)
  while c_lnum > 0
    call ReplaceParamsNextFunction(c_lnum, c_cnum)
    let c_lnum = search(pattern, flags)
  endwhile
endfunction

function! ParseParameters(funcDef)
    let withoutGenerics = substitute(a:funcDef, '<[^>]*>', '', 'g')
    let paramDef = matchlist(withoutGenerics, '(\(\_.\{-}\))')[1]
    let paramsDef = split(paramDef, ',')
    let paramList = []
    for param in paramsDef
        let paramName = matchlist(param, '\S\+[ \n]\+\(\w\+\)')[1]
        call add(paramList, paramName)
    endfor
    return paramList
endfunction

function! NewParamName(oldParamName)
    if a:oldParamName =~ 'a\u'
        return ""
    endif
    let fc = 'a' . toupper(a:oldParamName[0])
    return substitute(a:oldParamName, '^.', fc, '')
endfunction


"autocmd CursorMoved,CursorMovedI * call s:Highlight_Matching_Paren()
"autocmd InsertEnter * match none

