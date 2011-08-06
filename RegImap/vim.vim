call SetParameters({'filetype' : 'vim'})

call RegImap('^' . closedQuotedText . '\zs;', '', {'feedkeys' : "\<Esc>"})
call RegImap('^' . closedQuotedText . '[[]\zs' . cursor . '\ze\([]]\@!.\)*$', PH() . ']')
call RegImap('^' . closedQuotedText . '{\zs' . cursor . '\ze[^}]*$', PH() . '}')
call RegImap('^call RegImap' . closedQuotedText . '{\zs:' . cursor . '\ze}', "'" . PH() . "' : '" . PH() . "'")

let whiteStartCommands = [
      \['r ', 'return '],
      \['if', 'if ' . PH() . '\1  ' . PH() . '\1endif'],
      \['  el', 'else\1  ' . PH()],
      \['for', 'for ' . PH('key') . ' in ' . PH() . '\1  ' . PH() . '\1endfor'],
      \['exe', "exec '" . PH('normal! ') . "' . " . PH(), 'e'],
      \['.*[[]\s*\n\zs' . cursor . '\ze[]]', '\1      \\' . PH() . '\1      \\'],
      \]
"      \['\\.*[[]\s*\n' . cursor, "exec '" . PH('normal! ') . "' . " . PH(), 'e'],

if !exists("g:baseDir")
  let baseDir = &rtp
endif

" Auto let 

for key in whiteStartCommands
  call RegImap(whiteStart . key[0], key[1])
endfor

call RegImap(whiteStart . '\\.*\n\zs', '\1\\', {'condition' : '\n'})

"let speedCalls = [
"      \]
"for key in speedCalls
"  call RegImap(whiteStart . 'call \zs' . key[0] . ' ', key[1])
"endfor

let startCommands = [
      \['fu', 'function! ' . PH() . '()  ' . PH() . 'endfunction'],
      \['fi', 'finish'],
      \['[invsx]no', '&remap '],
      \['\(\w*\) def ', 'if !exists("g:\1")  let \1 = ' . PH('default') . 'endif'],
      \['r ', "call RegImap('". PH() . "', '". PH() . "'" . PH(', ') . ")"],
      \]
      
for key in startCommands
  call RegImap('^' . key[0], key[1])
endfor

let vimKeyCodes =[
      \['b', '<BS>'],
      \['c', '<CR>'],
      \['c\(.\)', '<C-\1>'],
      \['d', '<Down>'],
      \['e', '<Esc>'],
      \['f\(\d\)', '<F\1>'],
      \['f\(1\d\)', '<F\1>'],
      \['l', '<Left>'],
      \['r', '<Right>'],
      \['s', '<Space>'],
      \['t', '<Tab>'],
      \['u', '<Up>']]


for key in vimKeyCodes
  call RegImap('\\\zs' . key[0] . ' ', key[1], {'condition' : ' '})
  call RegImap('^\%(' . notDQ . '*' . DQstr . '\)*' . notDQ . '*"' . notDQ . '*\zs\<' . key[0] . ' ', '\\' . key[1], {'condition' : ' '})
  call RegImap('^\%(' . notDQ . '*' . DQstr . '\)*' . notDQ . '*\zs\<' . key[0] . ' ', key[1], {'condition' : ' '})
"  call RegImap('\zs\<' . key[0] . ' ', key[1], {'condition' : ' '})
endfor


let spaceCommands = [
      \['ma', '=\~'],
      \['nm', '!\~'],
      \['eq', '=='], 
      \['ne', '!='], 
      \['le', '<='], 
      \['ge', '>='], 
      \]
      
for key in spaceCommands
  call RegImap('\<' . key[0] . ' ', key[1] . ' ')
endfor

let functions = [
      \['getl', 'getline(' . PH() . ')'],
      \['getline(l\zs' . cursor . '\ze)', "ine('" . PH('.') . "')"],
      \['fee', 'feedkeys' . PH()],
      \]
     
for key in functions
  call RegImap('\<' . key[0], key[1])
endfor

" Other commands
call RegImap('\<line(\zs\.' . cursor . '\ze)', "'.'")

" Single quote to braces after char
call RegImap('^' . closedQuotedText . '\w\zs' . "'\\ze" . cursor . closedQuotedText . '$', '(' . PH() . ')', {'condition' : "'"})
" Single quote to two single quotes
call RegImap('^' . closedQuotedText . "'\\@!\\W" . '\zs' . "'\\ze" . cursor . closedQuotedText . '$', "'" . PH() . "'", {'condition' : "'"})


let doubleOperators = [
      \['\s*\([!-=+><]\)\s*=', ' \1= ', '='],
      \['\s*\([=!]\)\s*\~', ' \1\~ ', '\~'],
      \]
      
for key in doubleOperators
  call RegImap('^' . closedQuotedText . '\zs' . key[0], key[1], {'condition' : key[2]})
endfor

" Insert spaces
"let operators = [
"      \['=', '='],
"      \['-', '-'],
"      \['+', '+'],
"      \['>', '>'],
"      \['<', '<'],
"      \]

"for key in operators
"  call RegImap('^' . closedQuotedText . '\S\zs' . key[0], ' ' . key[1] . ' ', key[0])
"  call RegImap(notSQDQ . '*\zs' . key[0] . '\s*=', key[1] . '= ', '')
"  call RegImap(closedQuotedText . '\S\zs' . key[0] . '\s*=', ' ' . key[1] . '= ', '')
"endfor

