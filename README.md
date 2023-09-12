vim-markdown-outline
====================

This plugin adds super simple outline for Markdown files using
location-list.  After typing `gO`, current buffer is searched for Markdown
headings similar to these:

    # Heading 1
    ## Heading 2
    ### Heading 3 ...

    Heading 1
    =========
    Heading 2
    ---------

When all the headings are found, location-list is created, populated and
opened with the cursor being set at the current heading.

To disable the default mapping and define your own, you can do something like
this:

    let g:markdown_outline_no_mappings = 1
    augroup MarkdownOutline
      autocmd!
      autocmd FileType markdown nnoremap <buffer><silent> <Leader>o <Plug>MarkdownOutline
    augroup END
