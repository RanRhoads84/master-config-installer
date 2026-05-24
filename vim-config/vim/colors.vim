" Jellybeans colorscheme options
" https://github.com/nanotech/jellybeans.vim
"
" let g:jellybeans_overrides = {
"\    'Todo': { 'guifg': '303030', 'guibg': 'f0f000',
"\              'ctermfg': 'Black', 'ctermbg': 'Yellow',
"\              'attr': 'bold' },
"\    'Comment': { 'guifg': 'cccccc' },
"\}
"

" let g:jellybeans_use_term_italics = 1

" colorscheme jellybeans

" colorscheme github 

set termguicolors       " enable true colors support

set background=light    " for light version of theme
set background=dark     " for either mirage or dark version.
" NOTE: `background` controls `g:ayucolor`, but `g:ayucolor` doesn't control `background`

let g:ayucolor="mirage" " for mirage version of theme
let g:ayucolor="dark"   " for dark version of theme
" NOTE: g:ayucolor will default to 'dark' when not set. 

colorscheme ayu

" defaults to 0.
let g:ayu_italic_comment = 1 

" defaults to 0. If set to 1, 
" SignColumn and FoldColumn will have a higher contrast instead of using the Normal background
let g:ayu_sign_contrast = 1 

" defaults to 0. If set to 1, enables extended palette. 
" Adds more colors to some highlights (function keyword, loops, conditionals, imports)
let g:ayu_extended_palette = 1 
