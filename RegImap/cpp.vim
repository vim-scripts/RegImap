call SetParameters({'filetype' : 'cpp'})

call RegImap(whiteStart . '\zssw ', 'switch(' . PH() . ')\1{\1    ' . PH("case ") . '\1    ' . PH("default: ") . '\1}')
call RegImap(whiteStart . 'case \zs', PH("value") . ': ' . PH("code") . '; ' . PH('break;') . '\1' . PH("case "))

call RegImap('\<\l*F\zs', 'rame')
call RegImap(';' .cursor . '\s*$', ';', {'feedkeys' : "\<Esc>"})
call RegImap(';', '', {'feedkeys' : "\<Esc>"})

call RegImap('^\s*\zsp\s', 'printf("' . PH('Done') . '\\n");')
call RegImap('^\s*\zsP\s', 'Print(' . PH('') . ');')
call RegImap('^\s*\zspi\s', 'printf("%i\\n", ' . PH() . ');')
call RegImap('^\s*\zsps\s', 'printf("%s\\n", ' . PH() . ');')

let whiteStartCommands = [
      \['r ', 'return '],
      \['\(else\|}\|\)\s*if\zs ', '(' . PH() . ')\1    ' . PH()],
      \['e ', 'else\1    ' . PH()],
      \['c ',  'const '],
      \['d ',  'double '],
      \['b ',  'bool '],
      \['v ',  'void '],
      \['i ',  'int '],
      \['ci ', 'const int '],
      \['const\s*\(int\|double\)\s*\(\w*\)\zs\w', '\U&']
      \]                

for key in whiteStartCommands
  call RegImap(whiteStart . key[0], key[1])
endfor


" Single quote to braces after char
call RegImap('^' . closedQuotedText . notSQDQ . '\{-}\w\zs' . "'\\ze" . cursor . closedQuotedText . notSQDQ . '*$', '(' . PH() . ')', {'condition' : "'"})
" Single quote to two single quotes
call RegImap('^' . closedQuotedText . notSQDQ . '\{-}' . "'\\@!\\W" . '\zs' . "'\\ze" . cursor . closedQuotedText . notSQDQ . '*$', "'" . PH() . "'", {'condition' : "'"})

