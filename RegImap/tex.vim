call SetParameters({'filetype' : 'tex'})

let whiteStartCommands = [
      \['b ', '\1\\begin{' . PH() . '}\1  ' . PH() . '\1\\end{}'],
      \['s ', '\1\\section{' . PH() . '}'],
      \['ss ', '\1\\subsection{' . PH() . '}'],
      \['\zs[[]', '\\[' . PH() . '\1\\]'],
      \['\zs{', '{' . PH() . '\1}'],
      \['\zsi ', '\\item '],
      \]

for key in whiteStartCommands
  call RegImap(whiteStart . key[0], key[1])
endfor


" Math patterns
"call RegImap('\<h ', '\hat')
"call RegImap('\<b ', '\bar')
"call RegImap('\<s ', '\sub')

" Text patterns
call RegImap('\<ith ', '$i$-th')
call RegImap('\<jth ', '$i$-th')
"call RegImap('\<x ', '$X$')
"call RegImap('\<k ', '$K$')
call RegImap('\<\([dD]\)ont ', "\1on't ")
"call RegImap('\<sub', "subpopulation")


" Sinchronize \begin{} and \end{} based on indent
call RegImap(whiteStart . '\\begin{\zs\([^}]*\)\%#\([^}]*\)\(}.*\n' . '\(\1\(\s.*\)\?\n\)\{-}' . '\1\\end{\)[^}]*\ze}', '\2\3' . PH() . '\4\2\3')
call RegImap(whiteStart . '\\begin{\zs[^}]*\(}.*\n' . '\(\1\(\s.*\)\?\n\)\{-}' . '\1\\end{\)\([^}]*\)\%#\([^}]*\)\ze}', '\5\6\2\5\6' . PH())

" Other
"call RegImap('[[]', '[\%#]')
"call RegImap('{', '{\%#}')
"call RegImap("'", '(\%#)')
"call RegImap('\S\zs\s*\([,.]\)', '\1 ')
