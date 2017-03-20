execute pathogen#infect()
syntax on
filetype plugin indent on
set nowrap
set tabstop=2
set shiftwidth=2
set expandtab
set smartindent
set autoindent

set nu

set background=dark
let term=$TERM

if term == 'putty-256color'
    colorscheme solarized
endif
