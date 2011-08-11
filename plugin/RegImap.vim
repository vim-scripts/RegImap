" File:          RegImap.vim
" Author:        Artem Shcherbina
" Last Updated:  Aug 6, 2011
" Version:       0.5
" Description:   RegImap.vim  Plugin for using regular expression substitutes in insert mode
"
"                For more help see RegImap.txt; you can do this by using:
"                :helptags ~/.vim/doc
"                :h RegImap.txt

if exists("g:RegImap_inited") || &cp || version < 700
  finish
endif

let RegImap_inited = 1

if v:version > 703 || v:version == 703 && has("patch196")
  autocmd CursorMovedI * call TriggerRegImap()
  autocmd InsertCharPre * let s:useTrigger = 1
else
  autocmd CursorMovedI * let s:useTrigger = 1 | call TriggerRegImap()
endif

autocmd BufEnter * call ReadRegImaps()
autocmd FileType * call ReadRegImaps()

highlight PlaceHolder ctermbg=0 ctermfg=4 guifg=#4CFF4C guibg=#3A3A3A
call matchadd('PlaceHolder', '<' . '+.\{-}+>')

if !exists("g:RegImap_baseDir")
  let g:RegImap_baseDir = &runtimepath
endif

if !exists("g:RegImap_useNextPH")
  let g:RegImap_useNextPH = '<Tab>'
endif

if !exists("g:RegImap_selectNextPH")
  let g:RegImap_selectNextPH = '<S-Tab>'
endif

if !exists("g:RegImap_exitSelectMode")
  let g:RegImap_exitSelectMode = ';'
endif

if !exists("g:RegImap_clearSelectedText")
  let g:RegImap_clearSelectedText = '<C-j>'
endif

let g:whiteStart='^\(\s*\)\zs'
let g:cursor = '\' . '%#'
let g:isPH = '<' . '+.*+>'
let g:isCursorPH = '<' . '+@.*@+>'

let g:notDQ = '\%(\\\\\|\\[^\\]\|[^\"]\)'
let g:DQstr = '"' . notDQ . '*"'
let g:notSQ = "[^']"
let g:SQstr = "'" . notSQ . "*'"
let g:notSQDQ = "[^\"']"
let g:closedQuotedText = '\%(' . notSQDQ . '*\%(' . SQstr . '\|' . DQstr . '\)\)*' . notSQDQ . '*'


if g:RegImap_useNextPH != ''
  exec 'inoremap ' . g:RegImap_useNextPH . ' <C-r>=NextPH()'
  exec 'nnoremap ' . g:RegImap_useNextPH . ' a<C-r>=NextPH("", escape)'
  exec 'snoremap ' . g:RegImap_useNextPH . ' <Esc>a<C-r>=CheckSelected()'
endif

if g:RegImap_selectNextPH != ''
  exec 'nnoremap ' . g:RegImap_selectNextPH . ' :call SelectPH()'
  exec 'snoremap ' . g:RegImap_selectNextPH . ' <Esc>:call SelectPH()'
  exec 'inoremap ' . g:RegImap_selectNextPH . ' <Esc>:call SelectPH()'
endif

if g:RegImap_exitSelectMode != ''
  exec 'snoremap ' . g:RegImap_exitSelectMode . ' <Esc>'
endif

if g:RegImap_clearSelectedText != ''
  exec 'snoremap ' . g:RegImap_clearSelectedText . ' i<BS><C-r>=ClearSelection()'
endif


let escape = "\<Esc>" 
let s:useTrigger = 0
let s:defaults = {
      \'filetype' : 'common',
      \'condition' : '',
      \'feedkeys' : '',
      \}


let s:parameters = s:defaults
let s:sourcedFiles = {}
let s:regImaps = {}


fun! PH(...)
  return '<' . '+' . join(a:000) . '+>'
endfun

fun! CursorPH(...)
  return '<' . '+@' . join(a:000) . '@+>'
endfun

"fun! NotInString(...)
"  return '^' . g:closedQuotedText . '\zs' . join(a:000) . '\ze' . g:closedQuotedText . '$'
"endfun

function! SetParameters(...)
  if a:0 == 0
    let s:parameters = s:defaults
  else
    call extend(s:parameters, a:1)
  endif
endfunction

fun! RegImap(pattern, substitute, ...)
  if a:pattern == ''
    echohl WarningMsg
    echomsg 'RegImap: Empty pattern for ' . a:ft
    echohl None
  endif
  if a:pattern !~ '\\%#'
    let pattern = '\%(' . a:pattern . '\)\%#'
  else
    let pattern = a:pattern
  endif
  " Replace  by special string
  let substitute = substitute(a:substitute, '', '?c' . 'r?', 'g')
  if (substitute[0:1] == '\=') && substitute !~ g:isPH
    let substitute .= '."' . PH() . '"'
  endif
  
  if (substitute[0:1] != '\=') && substitute !~ g:isPH
    let substitute .= PH()
  endif
  
  if substitute !~ g:isCursorPH
    let substitute = substitute(substitute, '<' . '+\zs.\{-}\ze+>', '@&@', '')
  endif
  
  if a:0 > 0
    let parameters = GetParameters(a:1)
  else
    let parameters = s:parameters
  endif
  
  for ft in split(parameters.filetype, '\.')
    if !has_key(s:regImaps, ft)
      let s:regImaps[ft] = []
    endif
    let defined=0
    for RegImap in s:regImaps[ft]
      if RegImap.pattern == pattern
        echohl WarningMsg
        echomsg 'RegImap: Redefining ' . a:pattern . ' for ' . ft
        echohl None
        let defined=1
      endif
    endfor
    if !defined
      " singleline if not \n
      call add(s:regImaps[ft], extend({'pattern' : pattern, 'substitute' : substitute, 'singleLine' : (pattern !~ '\\n')}, parameters))
    endif
  endfor
endfun

fun! ReloadRegImaps()
  let s:regImaps = {}
  for RegImapsFile in keys(s:sourcedFiles)
    if (filereadable(RegImapsFile))
      exec 'source ' . RegImapsFile
    endif
  endfor
endf

function! ClearSelection()
  return (search('^\s*\n', 'nbc', line('.')) ? "\<Esc>dd" : '') . "a\<C-R>=NextPH()\<CR>"
endfunction

function! CheckSelected()
  if search('<' . g:cursor . '+.*+>', 'bce')
    let save_cursor = getpos(".")
    s/<[+]\(.\{-}\)+\%#>/\1/
    call cursor(line('.'), save_cursor[2]-3)
    return TriggerRegImap(1)
  endif
  let s:useTrigger = 1
  return "\<Esc>a"
endfunction


function! GetParameters(input)
  let parameters = extend(copy(s:parameters), a:input)
  if parameters.condition !~ g:cursor
    let parameters.condition = '\%(' . parameters.condition . '\)\%#'
  endif
  if parameters.filetype == ''
    let parameters.filetype = 'common'
  endif
  return parameters
endfunction

fun! ReadRegImaps()
  if &ft != ''
    call ReadFile(&ft)
  endif
  call ReadFile('common')
endf

fun! ReadFile(filetype)
  for RegImapsFile in split(globpath(g:RegImap_baseDir, 'RegImap/' . a:filetype . '.vim')) + split(globpath(g:RegImap_baseDir, 'MyRegImap/' . a:filetype . '.vim'))
    if !has_key(s:sourcedFiles, RegImapsFile) && filereadable(RegImapsFile) " If file was not sourced yet
      let s:sourcedFiles[RegImapsFile] = 1
      exec 'source ' . RegImapsFile
    endif
  endfor
endf


function! SelectPH()
  if search(g:isPH, 'w') " PlaceHolder found
    let save_cursor = getpos(".")
    let width = searchpos('+>', 'en')[1] - save_cursor[2]
    call feedkeys("\<Esc>v" . (width) . "lo\<C-g>", 'n')
  endif
endfunction


function! NextPH(...)
  " Use tab for autocomplete?
  if pumvisible()
    return "\<C-y>"
  endif
  
  if search(g:isCursorPH, 'cw') || search(g:isPH, 'cw') " PlaceHolder found
    let save_cursor = getpos(".")
    
    if search('\%#' . g:isCursorPH, 'cw')
      let width = searchpos('+>', 'en')[1] - save_cursor[2] - 2
      s/\%#<[+]@\(.\{-}\)@+>/\1/
    else
      let width = searchpos('+>', 'en')[1] - save_cursor[2]
      s/\%#<[+]\(.\{-}\)+>/\1/
    endif
    
    call setpos('.', save_cursor)
    
    if width > 4
      " PlaceHolder with text
      call feedkeys("\<Esc>lv" . (width-4) . "l\<C-g>", 'n')
    elseif width == 4
      " PlaceHolder with one char
      call feedkeys("\<Esc>lv\<C-g>", 'n')
    endif
    if a:0 > 0
      call feedkeys(a:1)
    endif
  else
    if a:0 > 1
      call feedkeys(a:2)
    endif
  endif
  return ''
endfunction

fun! TriggerRegImap(...)
  if !s:useTrigger
    return ''
  endif
  let s:useTrigger = 0
  let lineNum = line('.')
  for ft in split(&ft, '\.') + ['common']
    if exists('s:regImaps["'.ft.'"]')
      for mapping in s:regImaps[ft]
        if mapping.singleLine
          if (mapping.condition == '' || search(mapping.condition, 'cnb', lineNum)) && search(mapping.pattern, 'cnb', lineNum)
"            call feedkeys("<C-g>u")
            exec 'normal! :s/' . mapping.pattern . '/' . mapping.substitute . "\<CR>"
            s/?[c]r?//ge " Put  defined in RegImap back
            return NextPH(mapping.feedkeys)
          endif
        else
          if (mapping.condition == '' || search(mapping.condition, 'cnb')) && search(mapping.pattern, 'cnb')
            exec 'normal! :%s/' . mapping.pattern . '/' . mapping.substitute . "\<CR>"
            %s/?[c]r?//ge " Put  defined in RegImap back
            return NextPH(mapping.feedkeys)
          endif
        endif
      endfor
    endif
  endfor
  return ''
endfun

" For debug
fun! PrintRegImaps()
  for ft in split(&ft, '\.') + ['common']
    if exists('s:regImaps["'.ft.'"]')
      exec 'normal! o' . ft
      for mapping in s:regImaps[ft]
        exec 'normal! o' . mapping.pattern . ' -> ' 
              \. mapping.substitute . ' / ' 
              \. mapping.condition . ' / ' . mapping.feedkeys
      endfor
    endif
  endfor
endfun
