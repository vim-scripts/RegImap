" File:          RegImap.vim
" Author:        Artem Shcherbina
" Last Updated:  Aug 6, 2011
" Version:       0.5
" Description:   RegImap.vim  Plugin for using regular expression substitutes in insert mode
"
"                For more help see RegImap.txt; you can do this by using:
"                :helptags ~/.vim/doc
"                :h RegImap.txt

"plugin/RegImap.vim
"doc/RegImap.txt
"RegImap/common.vim
"RegImap/vim.vim
"RegImap/cpp.vim
"RegImap/tex.vim


if exists("g:RegImap_inited") || &cp || version < 700
  finish
endif

let RegImap_inited=1

autocmd CursorMovedI * call TriggerRegImap()
autocmd BufEnter * call ReadRegImaps()

if !exists("g:baseDir")
  let baseDir = &runtimepath
endif

if !exists("g:useNextPH")
  let useNextPH = '<Tab>'
endif

if !exists("g:selectNextPH")
  let selectNextPH = '<S-Tab>'
endif

if !exists("g:exitSelectMode")
  let exitSelectMode = ';'
endif

if !exists("g:clearSelectedText")
  let clearSelectedText = '<C-j>'
endif

exec 'inoremap ' . useNextPH . ' <C-r>=NextPH()'
exec 'nnoremap ' . useNextPH . ' a<C-r>=NextPH("") . Escape()'
exec 'snoremap ' . useNextPH . ' <Esc>a<C-r>=CheckSelected()'
exec 'nnoremap ' . selectNextPH . ' :call SelectPH()'
exec 'snoremap ' . selectNextPH . ' <Esc>:call SelectPH()'
exec 'inoremap ' . selectNextPH . ' <Esc>:call SelectPH()'
exec 'snoremap ' . exitSelectMode . ' <Esc>'
exec 'snoremap ' . clearSelectedText . ' i<BS><C-r>=ClearSelection()'

function! Escape()
  return "\<Esc>"
endfunction

function! ClearSelection()
  let save_cursor = getpos(".")
  if search('^\s*\n', 'bc', line('.'))
    call cursor(line('.'), save_cursor[2])
    return "\<Esc>dd"
  endif
  return ''
endfunction

function! CheckSelected()
  if search(g:isPH . g:cursor, 'bce')
    let save_cursor = getpos(".")
    s/<[+]\(.\{-}\)+\%#>/\1/
    call cursor(line('.'), save_cursor[2]-3)
    return TriggerRegImap(1)
  endif
  return "\<Esc>a"
endfunction


let s:RegImaps = {}
let whiteStart='^\(\s*\)\zs'
let cursor = '\' . '%#'
let isPH = '<' . '+.*+>'
let isAutoPH = '<' . '+|.*|+>'

let notDQ = '\%(\\\\\|\\[^\\]\|[^\"]\)'
let DQstr = '"' . notDQ . '*"'
let notSQ = "[^']"
let SQstr = "'" . notSQ . "*'"
let notSQDQ = "[^\"']"
let closedQuotedText = '\%(' . notSQDQ . '*\%(' . SQstr . '\|' . DQstr . '\)\)*' . notSQDQ . '*'

fun! PH(...)
  return '<' . '+' . join(a:000) . '+>'
endfun

let defaults = {
      \'filetype' : 'common',
      \'condition' : '',
      \'feedkeys' : '',
      \}

let parameters = defaults

function! SetParameters(...)
  if a:0 == 0
    let g:parameters = g:defaults
  else
    call extend(g:parameters, a:1)
  endif
endfunction

function! GetParameters(input)
  let parameters = extend(copy(g:parameters), a:input)
  if parameters.condition !~ g:cursor
    let parameters.condition .= '\%#'
  endif
  if parameters.filetype == ''
    let parameters.filetype = 'common'
  endif
  return parameters
endfunction

fun! RegImap(pattern, substitute, ...)
  if a:pattern == ''
    echohl WarningMsg
    echomsg 'RegImap: Empty pattern for ' . a:ft
    echohl None
  endif
  let pattern = a:pattern . (a:pattern =~ '\\%#' ? '' : '\%#')
  
  " Replace  by special string
  let substitute = substitute(a:substitute, '', '?c' . 'r?', 'g')
  if (substitute[0:1] != '\=') && substitute !~ g:isPH
    let substitute .= PH()
  endif

  if a:0 > 0
    let parameters = GetParameters(a:1)
  else
    let parameters = g:parameters
  endif
  
  for ft in split(parameters.filetype, '\.')
    if !has_key(s:RegImaps, ft)
      let s:RegImaps[ft] = []
    endif
    let defined=0
    for RegImap in s:RegImaps[ft]
      if RegImap.pattern == pattern
        echohl WarningMsg
        echomsg 'RegImap: Redefining ' . a:pattern . ' for ' . ft
        echohl None
        let defined=1
      endif
    endfor
    if !defined
      " Singleline if not \n
      call add(s:RegImaps[ft], extend({'pattern' : pattern, 'substitute' : substitute, 'singleLine' : (pattern !~ '\\n')}, parameters))
    endif
  endfor
endfun

fun! ReadRegImaps()
  let s:RegImaps = {}
  
  for RegImapsFile in split(globpath(g:baseDir, 'RegImap/common.vim')) + split(globpath(&rtp, 'RegImap/' . &ft . '.vim'))
    exec 'normal! :so ' . RegImapsFile . ''
  endfor
endf

function! SelectPH()
  if search(g:isPH, 'w') " PlaseHolder found
    let save_cursor = getpos(".")
    let width = searchpos('+>', 'en')[1] - save_cursor[2]
    call feedkeys("\<Esc>v" . (width) . "lo\<C-g>", 'n')
  endif
endfunction


function! NextPH(...)
"      return ''
  if pumvisible()
    return "\<C-y>"
  endif
  if search(g:isPH, 'cw') " PlaseHolder found
    let save_cursor = getpos(".")
    let width = searchpos('+>', 'en')[1] - save_cursor[2]
  
    s/\%#<[+]\(.\{-}\)+>/\1/
    call setpos('.', save_cursor)
    
    if width > 4
      " PlaseHolder with text
      call feedkeys("\<Esc>lv" . (width-4) . "l\<C-g>", 'n')
    elseif width == 4
      " PlaseHolder with one char
      call feedkeys("\<Esc>lv\<C-g>", 'n')
    endif
    if a:0 > 0
      call feedkeys(a:1)
    endif
  endif
  return ''
endfunction

fun! TriggerRegImap(...)
  for ft in split(&ft, '\.') + ['common']
    if exists('s:RegImaps["'.ft.'"]')
      for RegImap in s:RegImaps[ft]
        if RegImap.singleLine
          let lineNum = line('.')
          if (RegImap.condition == '' || search(RegImap.condition, 'cnb', lineNum)) && search(RegImap.pattern, 'cnb', lineNum)
            exec 'normal! :s/' . RegImap.pattern . '/' . RegImap.substitute . "\<CR>"
            " Put  defined in RegImap back
            s/?[c]r?//ge
            call setpos('.', [bufnr("%"), lineNum, 0, 0])
            call NextPH(RegImap.feedkeys)
            return ''
          endif
        else
          let lineNum = line('.')
          if (RegImap.condition == '' || search(RegImap.condition, 'cnb')) && search(RegImap.pattern, 'cnb')
            exec 'normal! :%s/' . RegImap.pattern . '/' . RegImap.substitute . "\<CR>"
            " Put  defined in RegImap back
            %s/?[c]r?//ge
            call setpos('.', [bufnr("%"), lineNum, 0, 0])
            call NextPH(RegImap.feedkeys)
            return ''
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
    if exists('s:RegImaps["'.ft.'"]')
      exec 'normal! o' . ft
      for RegImap in s:RegImaps[ft]
        exec 'normal! o' . RegImap.pattern . ' -> ' . RegImap.substitute . ' / ' . RegImap.condition . ' / ' . RegImap.feedkeys
      endfor
    endif
  endfor
endfun

