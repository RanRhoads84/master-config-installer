" Plugin loader

let s:plugin_dir = expand('~/.config/vim/plugged')

function! s:ensure(repo)
  let name = split(a:repo, '/')[-1]
  let path = s:plugin_dir . '/' . name

  if !isdirectory(path)
    if !isdirectory(s:plugin_dir)
      call mkdir(s:plugin_dir, 'p')
    endif
    execute '!git clone --depth=1 https://github.com/' . a:repo . ' ' . shellescape(path)
  endif

  execute 'set runtimepath+=' . fnameescape(path)
endfunction

" to load plugins 
" call s:ensure(repo) 

" color schemes
" https://vimcolorschemes.com
" call s:ensure ('/nanotech/jellybeans.vim')
call s:ensure('Luxed/ayu-vim')


" fuzzy finder plugin
call s:ensure('junegunn/fzf')
call s:ensure('junegunn/fzf.vim')

" lightline & git-branch
call s:ensure('itchyny/lightline.vim')
call s:ensure('itchyny/vim-gitbranch')


" Coding Plugins

" Indent Guides
call s:ensure('nathanaelkane/vim-indent-guides')

"" vim-lsp / Autocomplete / LSP Settings
"call s:ensure('prabirshrestha/vim-lsp')
"call s:ensure('prabirshrestha/asyncomplete.vim')
"call s:ensure('mattn/vim-lsp-settings')
"
" Vim Syntax Highlighting
call s:ensure('octol/vim-cpp-enhanced-highlight')
call s:ensure('sheerun/vim-polyglot')

" Nerdtree
call s:ensure('preservim/nerdtree')

" Inline git signs 
call s:ensure('airblade/vim-gitgutter')

" Comment toggling
call s:ensure('tpope/vim-commentary')

" Snippet engine
call s:ensure('hrsh7th/vim-vsnip')

" Quick wrapping
call s:ensure('tpope/vim-surround')

" Auto-close brackets, quotes, etc.
call s:ensure('jiangmiao/auto-pairs')

" Python syntax highlighting
call s:ensure('vim-python/python-syntax')

" Code formatting
call s:ensure('Chiel92/vim-autoformat')
