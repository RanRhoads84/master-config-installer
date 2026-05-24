filetype plugin indent on
set softtabstop=4
set smartindent
set showmatch
syntax on

" Line numbers
set number
set relativenumber

" Indentation and tabs
set tabstop=4
set shiftwidth=4
set autoindent
set expandtab

" Search
set ignorecase
set smartcase
set incsearch

" Appearance

" Backspace behavior
set backspace=indent,eol,start

" Split window behavior
set splitbelow
set splitright

" Keep cursor 8 lines from top/bottom
set scrolloff=8

" Cursor responsiveness
set updatetime=50

set laststatus=2

" Enable all Python highlighting features
let g:python_highlight_all = 1

" Autoformat on save for specific file types
autocmd BufWritePre *.c,*.cpp,*.cs,*.sh,*.py :Autoformat