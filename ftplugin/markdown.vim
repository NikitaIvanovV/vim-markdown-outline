" Name:         markdown_outline
" Description:  Simple Markdown outline in location-list
" Author:       Nikita Ivanov
" License:      MIT

if exists('g:loaded_markdown_outline') && g:loaded_markdown_outline
  finish
endif

let b:toc = []
let b:closest_heading = 0

echom expand('%')

function s:is_heading(text, lnum) abort
  " Match standard # heading
  let mark = matchstr(a:text, '^#[#[:space:]]\+')

  if !empty(mark)
    let mark = substitute(mark, '\s\+', '', 'g')
  else
    " If failed, try
    " heading
    " ======
    " or
    " heading
    " ------
    let next = getline(a:lnum + 1)
    if (match(next, '^==\+\s*$') != -1)
      let mark = '#'
    elseif (match(next, '^--\+\s*$') != -1)
      let mark = '##'
    endif
  endif

  return len(mark)
endfunction

" Make location list
function s:make_toc() abort
  let b:toc = []
  let toc_len = 0
  let bufnr = bufnr('%')
  let lnum = 1
  let last_line = line('$')
  let b:closest_heading = 0
  let current_line = line('.')

  " Iterate over all the lines
  while lnum && lnum <= last_line
    let text = getline(lnum)
    let level = s:is_heading(text, lnum)

    " If heading found, add to toc
    if level > 0
      let mark = repeat('#', level)
      let text = substitute(text, '^[#[:space:]]\+', '', '')

      call add(b:toc, {'bufnr': bufnr, 'lnum': lnum,
            \ 'text': mark .. " " .. text})
      let toc_len += 1
      if lnum <= current_line
        let b:closest_heading = toc_len
      endif
    endif

    " Pick next non-empty line
    let lnum = nextnonblank(lnum + 1)
  endwhile

  " Create location list
  call setloclist(0, b:toc, ' ')
  call setloclist(0, [], 'a', {'title': 'Markdown TOC'})
endfunction

" Open location list and jump to current heading
function s:open_toc() abort
  " We need to save this because :lopen changes current buffer
  let closest_heading = b:closest_heading
  lopen
  if closest_heading > 0
    call setpos('.', [0, closest_heading, 0, 0])
  endif
endfunction

function s:show_toc() abort
  call s:make_toc()
  call s:open_toc()
endfunction

nnoremap <Plug>MarkdownOutline <Cmd>call <SID>show_toc()<CR>

" Default mapping
if !exists('g:markdown_outline_no_mappings') || !g:markdown_outline_no_mappings
  nnoremap <buffer> gO <Plug>MarkdownOutline
endif
