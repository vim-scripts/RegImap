call SetParameters({'filetype' : 'cpp'})


call RegImap(whiteStart . '\zssw ', 'switch(' . PH() . ')\1{\1    ' . PH("case ") . '\1    ' . PH("default: ") . '\1}')
call RegImap(whiteStart . 'case \zs', PH("value") . ': ' . PH("code") . '; ' . PH('break;') . '\1' . PH("case "))

call RegImap('^\s*\zsp\s', 'printf("' . PH('Done') . '\\n");')
call RegImap('^\s*\zspi\s', 'printf("%i\\n", ' . PH() . ');')
call RegImap('^\s*\zspii\s', 'printf("%i, %i\\n", ' . PH() . ');')
call RegImap('^\s*\zsps\s', 'printf("%s\\n", ' . PH() . ');')

let whiteStartCommands = [
      \['r ', 'return '],
      \['\(else\|}\|\)\s*if\zs ', '(' . PH() . ')\1    ' . PH()],
      \['e ', 'else\1    ' . PH()],
      \['c ',  'const '],
      \['d ',  'double '],
      \['b ',  'bool '],
      \['v ',  'void '],
      \['ci ', 'const int '],
      \['for ', 'for(int ' . PH() . ' = 0; \2 < ' . PH() . '; \2++)\1    ' . PH()],
      \['const\s*\(int\|double\)\s*\(\w*\)\zs\w', '\U&'],
      \]                

for key in whiteStartCommands
  call RegImap(whiteStart . key[0], key[1])
endfor
  
call RegImap(whiteStart . 'for\s*(.\{-}\s\(\k\+' . cursor . '\k*\)\zs\(\s*=.\{-};\s\{-}\)\s\k*\(.*;\s*\)\k*\ze.*)', CursorPH() . '\3 \2\4\2')

let spaceCommands = [
      \['ma', '=\~'],
      \['nm', '!\~'],
      \['eq', '=='], 
      \['ne', '!='], 
      \['le', '<='], 
      \['ge', '>='], 
      \['an', '\&\&'], 
      \['or', '||'], 
      \]
      
for key in spaceCommands
  call RegImap('^' . closedQuotedText . '\zs\<' . key[0] . ' ', key[1] . ' ')
endfor

" Single quote to braces after char
call RegImap('^' . closedQuotedText . notSQDQ . '\{-}\w\zs' . "'\\ze" . cursor . closedQuotedText . notSQDQ . '*$', '(' . PH() . ')', {'condition' : "'"})
" Single quote to two single quotes
call RegImap('^' . closedQuotedText . notSQDQ . '\{-}' . "'\\@!\\W" . '\zs' . "'\\ze" . cursor . closedQuotedText . notSQDQ . '*$', "'" . PH() . "'", {'condition' : "'"})

