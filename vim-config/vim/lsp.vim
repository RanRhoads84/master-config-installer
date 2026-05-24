" Show diagnostics in the sign column
let g:lsp_diagnostics_enabled = 1
let g:lsp_diagnostics_signs_enabled = 1
let g:lsp_diagnostics_virtual_text_enabled = 1

" Highlight references to symbol under cursor
let g:lsp_document_highlight_enabled = 1

" Faster completion triggering
let g:asyncomplete_auto_popup = 1
let g:asyncomplete_auto_delay = 100

" Install LSP server for the current filetype on every file open.
" Skip if a server is already registered (prevents reinstalling on every open).
augroup lsp_auto_install
  autocmd!
  autocmd FileType * if empty(lsp#get_allowed_servers()) | silent! LspInstallServer! | endif
augroup END
