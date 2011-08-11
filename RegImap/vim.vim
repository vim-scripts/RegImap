call SetParameters({'filetype' : 'vim'})

call RegImap('^' . closedQuotedText . "('\\zs" . cursor . "\\ze)" . closedQuotedText . '$', PH() . "'", {'condition' : "'"})
call RegImap('^' . closedQuotedText . '\zs;' . cursor . '\ze' . closedQuotedText . '$', '', {'feedkeys' : "\<Esc>"})
call RegImap('^' . closedQuotedText . '[[]\zs' . cursor . '\ze\([]]\@!.\)*$', PH() . ']')
call RegImap('^' . closedQuotedText . '{\zs' . cursor . '\ze[^}]*$', PH() . '}')

let whiteStartCommands = [
      \['\s\zsr ', 'return '],
      \['if ', 'if ' . PH() . '\1  ' . PH() . '\1endif'],
      \['  e ', 'else\1  ' . PH()],
      \['for \zs', PH('key') . ' in ' . CursorPH('list') . '\1  ' . PH() . '\1endfor'],
      \['ex ', "exec '" . PH('normal! ') . "' . " . PH(), 'e'],
      \['.*[[]\s*\n\zs' . cursor . '\ze[]]', '\1      \\' . PH() . '\1      \\'],
      \]

for key in whiteStartCommands
  call RegImap(whiteStart . key[0], key[1])
endfor

call RegImap(whiteStart . '\\.*\n\zs\s*' . cursor, '\1\\', {'condition' : ' \|\n'})

let startCommands = [
      \['fu ', 'function! ' . PH() . '()  ' . PH() . 'endfunction'],
      \['fi ', 'finish'],
      \['[invsx]no', '&remap '],
      \['\(\w*\) def ', 'if !exists("g:\1")  let \1 = ' . PH('default') . 'endif'],
      \['r ', "call RegImap('". PH() . "', '". PH() . "')"],
      \['call RegImap(' . closedQuotedText . ',' . closedQuotedText . ',\zs\ze' . cursor . ')$', '', "{}\<Left>:"],
      \]

call RegImap('^' . closedQuotedText . '{\zs:' . cursor . '\ze}', PH() . " : " . PH())


for key in startCommands
  if exists("key[2]")
    call RegImap('^' . key[0], key[1], {'feedkeys' : key[2]})
  else
    call RegImap('^' . key[0], key[1])
  endif
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

call RegImap('\<ph ', 'PH(' . PH() . ')' . PH())

let functions = [
      \['getl', 'getline(' . PH() . ')'],
      \['getline(l\zs' . cursor . '\ze)', "ine('" . PH('.') . "')"],
      \]
     
for key in functions
  call RegImap('\<' . key[0], key[1])
endfor

" Other commands
call RegImap('\<line(\zs\.' . cursor . '\ze)', "'.'")

" Single quote to braces after char
call RegImap('^' . closedQuotedText . '\w\zs' . "'\\ze" . cursor . closedQuotedText . '$', '(' . PH() . ')', {'condition' : "'"})
" Single quote to two single quotes
call RegImap('^' . closedQuotedText . "\\%('\\@!\\W\\|^\\)" . '\zs' . "'\\ze" . cursor . closedQuotedText . '$', "'" . PH() . "'", {'condition' : "'"})

