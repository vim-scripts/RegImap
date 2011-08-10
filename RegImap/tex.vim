call SetParameters({'filetype' : 'tex'})

let whiteStartCommands = [
      \['b ', '\1\\begin{' . PH() . '}\1  ' . PH() . '\1\\end{}'],
      \['s ', '\1\\section{' . PH() . '}'],
      \['ss ', '\1\\subsection{' . PH() . '}'],
      \['\zs[[]', '\\[  ' . PH() . '\1\\]'],
      \['\zs{', '{' . PH() . '\1}'],
      \['\zsi ', '\\item '],
      \]

for key in whiteStartCommands
  if exists("key[2]")
    call RegImap(whiteStart . key[0], key[1], {'feedkeys' : key[2]})
  else
    call RegImap(whiteStart . key[0], key[1])
  endif
endfor


let commands = [
      \['{\zs', PH() . '\1}' . PH() ],
      \]

for key in commands
  if exists("key[2]")
    call RegImap(key[0], key[1], {'feedkeys' : key[2]})
  else
    call RegImap(key[0], key[1])
  endif
endfor

" Text patterns
call RegImap('\<ith ', '$i$-th')
call RegImap('\<jth ', '$i$-th')
call RegImap('\<\([dD]\)ont ', "\1on't ")

" Sinchronize \begin{} and \end{} based on indent
call RegImap(whiteStart . '\\begin{\zs\([^}]*\)\%#\([^}]*\)\(}.*\n' . '\(\1\(\s.*\)\?\n\)\{-}' . '\1\\end{\)[^}]*\ze}', '\2\3' . PH() . '\4\2\3')
call RegImap(whiteStart . '\\begin{\zs[^}]*\(}.*\n' . '\(\1\(\s.*\)\?\n\)\{-}' . '\1\\end{\)\([^}]*\)\%#\([^}]*\)\ze}', '\5\6\2\5\6' . PH())

" Single quote to braces after char
"call RegImap("'\\ze" . cursor, '(' . PH() . ')' . PH() )
