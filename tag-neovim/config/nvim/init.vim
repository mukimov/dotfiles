let mapleader=","                    
" let g:opamshare = substitute(system('opam config var share'),'\n$','','''')
" execute "set rtp+=" . g:opamshare . "/merlin/vim"

call plug#begin('~/.local/share/nvim/plugged')
Plug 'reasonml-editor/vim-reason-plus'
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'roxma/nvim-completion-manager'
Plug 'leafgarland/typescript-vim'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'airblade/vim-gitgutter'
Plug 'joshdick/onedark.vim'
Plug 'itchyny/lightline.vim'
Plug 'maximbaz/lightline-ale'
Plug 'Shougo/neosnippet'
Plug 'Shougo/neosnippet-snippets'
Plug 'prettier/vim-prettier', { 'do': 'yarn install' }
Plug 'justinmk/vim-sneak'
Plug 'kana/vim-textobj-entire'
Plug 'kana/vim-textobj-user'
Plug 'tpope/vim-repeat'
Plug 'pangloss/vim-javascript'
Plug 'othree/javascript-libraries-syntax.vim'
Plug 'mxw/vim-jsx'
Plug 'moll/vim-bbye'
Plug 'google/vim-searchindex'
Plug 'tommcdo/vim-exchange'
Plug 'chilicuil/vim-sprunge'
Plug 'lifepillar/vim-cheat40'
Plug 'styled-components/vim-styled-components'
Plug 'hail2u/vim-css3-syntax'
Plug 'flowtype/vim-flow'
Plug 'jparise/vim-graphql'
Plug 'w0rp/ale'

call plug#end()

imap <expr> <CR>  (pumvisible() ?  "\<c-y>\<Plug>(neosnippet_expand_or_jump)" : "\<CR>")
imap <expr> <Plug>(expand_or_nl) (cm#completed_is_snippet() ? "\<C-U>":"\<CR>")

imap <expr><TAB>
     \ pumvisible() ? "\<C-n>" :
     \ neosnippet#expandable_or_jumpable() ?
     \    "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
      \ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

if has('conceal')
    set conceallevel=2 concealcursor=niv
endif

let g:LanguageClient_serverCommands = {
            \ 'javascript': ['javascript-typescript-stdio'],
            \ 'typescript': ['javascript-typescript-stdio'],
            \ 'reason': ['ocaml-language-server', '--stdio'],
            \ 'ocaml': ['ocaml-language-server', '--stdio'],
            \ 'go': ['go-langserver'],
            \ }

let g:LanguageClient_autoStart = 1

let g:lightline = {
  \ 'colorscheme': 'onedark',
  \ }

let g:lightline.component_expand = {
      \  'linter_checking': 'lightline#ale#checking',
      \  'linter_warnings': 'lightline#ale#warnings',
      \  'linter_errors': 'lightline#ale#errors',
      \  'linter_ok': 'lightline#ale#ok',
      \ }

let g:lightline.component_type = {
      \     'linter_checking': 'left',
      \     'linter_warnings': 'warning',
      \     'linter_errors': 'error',
      \     'linter_ok': 'left',
      \ }

let g:lightline.active = { 'right': [[ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_ok' ]] }

nnoremap <silent> <F2> :call LanguageClient_textDocument_rename()<CR>
nnoremap <silent> gd :call LanguageClient_textDocument_definition()<CR>
nnoremap <silent> gf :call LanguageClient_textDocument_formatting()<CR>
nmap <leader>t :Files<CR>
nmap <leader>b :Buffers<CR>
map <leader>q :Bdelete<cr>
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)

let g:javascript_plugin_flow = 1 
let g:sneak#label = 1
let local_flow = finddir('node_modules', '.;') . '/.bin/flow'
let g:flow#autoclose = 1
if matchstr(local_flow, "^\/\\w") == ''
    let local_flow= getcwd() . "/" . local_flow
endif
if executable(local_flow)
    let g:flow#flowpath = local_flow
endif

colorscheme onedark
set noshowmode

set expandtab
set smarttab
set shiftwidth=2
set tabstop=4
set lbr
set tw=500
set number

set ai si wrap
set backupcopy=yes
