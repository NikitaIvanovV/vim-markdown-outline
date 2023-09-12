" Name:         markdown_outline
" Description:  Simple Markdown outline in location-list
" Author:       Nikita Ivanov
" License:      MIT

if exists('g:loaded_markdown_outline')
  finish
endif
let g:loaded_markdown_outline = 1

function s:show_toc() abort
  let toc = []
  let toc_len = 0
  let bufnr = bufnr('%')
  let lnum = 1
  let last_line = line('$')
  let closest_heading = 0
  let current_line = line('.')

  " Iterate over all the lines
  while lnum && lnum <= last_line
    let text = getline(lnum)

    " Match standard # heading
    let mark = matchstr(text, "^#[#[:space:]]\\+")

    " If failed, try
    " heading
    " ======
    " or
    " heading
    " ------
    if empty(mark)
      let next = getline(lnum + 1)
      if (match(next, "^==\\+\\s*$") != -1)
        let mark = "#"
      elseif (match(next, "^--\\+\\s*$") != -1)
        let mark = "##"
      endif
    endif

    " If heading found, add to toc
    if !empty(mark)
      let mark = substitute(mark, "\\s\\+", "", "g")
      let text = substitute(text, "^[#[:space:]]\\+", "", "")

      call add(toc, {'bufnr': bufnr, 'lnum': lnum,
            \ 'text': mark . " " . text})
      let toc_len += 1
      if lnum <= current_line
        let closest_heading = toc_len
      endif
    endif

    " Pick next non-empty line
    let lnum = nextnonblank(lnum + 1)
  endwhile

  " Create location list
  call setloclist(0, toc, ' ')
  call setloclist(0, [], 'a', {'title': 'Markdown TOC'})

  " Open location list and jump to current heading
  lopen
  if closest_heading > 0
    call setpos('.', [0, closest_heading, 0, 0])
  endif
endfunction

nnoremap <Plug>MarkdownOutline :call <SID>show_toc()<CR>

" Default mapping
if !exists('g:markdown_outline_no_mappings') || !g:markdown_outline_no_mappings
  nnoremap <buffer><silent> gO <Plug>MarkdownOutline
endif
