" Bash Language Server Plugin config
" Manual registration — only active when vim-lsp-settings is not installed,
" since that plugin auto-registers bash-language-server on its own.

if executable('bash-language-server') && !isdirectory(expand('~/.vim/plugged/vim-lsp-settings'))
  au User lsp_setup call lsp#register_server({
        \ 'name': 'bash-language-server',
        \ 'cmd': {server_info->['bash-language-server', 'start']},
        \ 'allowlist': ['sh', 'bash'],
        \ })
endif
