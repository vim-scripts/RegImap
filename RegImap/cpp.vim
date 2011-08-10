call SetParameters({'filetype' : 'cpp'})

call RegImap(whiteStart . '\zssw ', 'switch(' . PH() . ')
call RegImap(whiteStart . 'case \zs', PH("value") . ': ' . PH("code") . '; ' . PH('break;') . '

call RegImap('^\s*\zsp\s', 'printf("' . PH('Done') . '\\n");')
call RegImap('^\s*\zspi\s', 'printf("%i\\n", ' . PH() . ');')
call RegImap('^\s*\zspii\s', 'printf("%i, %i\\n", ' . PH() . ');')
call RegImap('^\s*\zsps\s', 'printf("%s\\n", ' . PH() . ');')

let whiteStartCommands = [
      \['r ', 'return '],
      \['\(else\|}\|\)\s*if\zs ', '(' . PH() . ')
      \['e ', 'else
      \['c ',  'const '],
      \['d ',  'double '],
      \['b ',  'bool '],
      \['v ',  'void '],
      \['ci ', 'const int '],
      \['const\s*\(int\|double\)\s*\(\w*\)\zs\w', '\U&'],
      \['\zs\(\w*\)\s*for ', 'for(int \2 = 0; \2 < ' . PH() . '; \2++)
      \]                

for key in whiteStartCommands
  call RegImap(whiteStart . key[0], key[1])
endfor

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
