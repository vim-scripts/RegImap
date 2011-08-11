call SetParameters({'filetype' : 'r'})

let whiteStartCommands = [
      \['[^(]*\zs\s*=', ' <- '],
      \['\zs[[]', '\\[' . PH() . '\1\\]', ""],
      \]

for key in whiteStartCommands
  if exists("key[2]")
    call RegImap(whiteStart . key[0], key[1], {'feedkeys' : key[2]})
  else
    call RegImap(whiteStart . key[0], key[1])
  endif
endfor

call RegImap('\<for\zs ', '(' . PH() . ' in ' . PH() . ')')
call RegImap(';', '', {'feedkeys' : "\<Esc>"})

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

let spaceCommands = [
      \['eq', '=='], 
      \['ne', '!='], 
      \['le', '<='], 
      \['ge', '>='], 
      \['an', '\&\&'], 
      \['or', '||'], 
      \['c', "cat('" . PH() . "')"], 
      \['f', 'function(' . PH() . ')'], 
      \['p', 'print(' . PH() . ')'], 
      \['pl', 'plot(' . PH() . ')'], 
      \]
      
for key in spaceCommands
  call RegImap('\<' . key[0] . ' ', key[1] . ' ')
endfor


" Single quote to braces
call RegImap("'\\ze" . cursor, '(' . PH() . ')' . PH() )

call RegImap('[[]\zs' . cursor . '\ze\([]]\@!.\)*$', PH() . ']')
call RegImap('\s*\/\/' . cursor, ' %% ')

