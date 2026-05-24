" Vim Keybinds, Spacebar is the leaderkey!
let mapleader=" "

" Change to open panes
nnoremap <leader><Left>  <C-w>h
nnoremap <leader><Right> <C-w>l
nnoremap <leader><Down>  <C-w>j
nnoremap <leader><Up>    <C-w>k

" Resize panes
nnoremap <leader>= <C-w>=        " equalize all panes
nnoremap <leader>> <C-w>10+      " wider
nnoremap <leader>< <C-w>10-      " narrower
nnoremap <leader>+ <C-w>10>      " taller
nnoremap <leader>- <C-w>10<      " shorter

" Open netrw (File explorer) with <leader>cd
nnoremap <leader>cd :Ex<CR>

" Make current file executable
nnoremap <leader>x :!chmod +x %<CR>

" Reload vimrc (adjust path as needed)
nnoremap <leader>rl :source ~/.vimrc<CR>

" Source current file
nnoremap <leader><leader> :so<CR>

" Close
nnoremap <leader>q :q<CR>

" Hard Close
nnoremap <leader>qq :q!<CR>

" Save
nnoremap <leader>w :w<CR>

" Save and Close
nnoremap <leader>wq :wq<CR>

" Open NerdTree
nnoremap <leader>t :NERDTreeToggle<CR>

" Format code with vim-autoformat
nnoremap <leader>fm :Autoformat<CR>