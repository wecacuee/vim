" Python specific settings
let g:pydiction_location = '/u/dhimanv/.vim/spell/complete-dict'

" Jump to function definition
nnoremap <Leader>fs /^\s*def\s*\<<C-r><C-w>\>(.*)\s*:<CR>

" Set spell
setlocal spell spelllang=en_us
setlocal textwidth=78
