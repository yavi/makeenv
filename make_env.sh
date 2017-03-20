#!/bin/bash

# Skrypt jest w bashu, nie ryzykujemy innego shella
if [ ! -n "$BASH" ] ;then echo Please run this script $0 with bash; exit 1; fi

VERSION=5
BATCH=false #Tryb wsadowy
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#Kolorki i inne takie (http://misc.flogisoft.com/bash/tip_colors_and_formatting)
f_yellow='\e[00;33m'
f_red='\e[00;31m'
f_green='\e[00;32m'
f_reset='\e[00;0m'

# Ladne wyswietlanie komunikatow

function p_warn {
    echo -e "${f_yellow}[WRN]${f_reset} ${1}"
}

function p_err {
    echo -e "${f_red}[ERR]${f_reset} ${1}"   
}

function p_ok {
    echo -e "${f_green}[OK ]${f_reset} ${1}"
}

# Sprawdzamy, czy przypadkiem nie odpalalismy juz skryptu w obecnej lub wyzszej wersji

if [[ -e ~/.yavi_env ]]; then
    ver="$(cat ~/.yavi_env)"
    if [[ ${ver} -ge ${VERSION} ]]; then
        p_warn "You have already run the script in version ${ver}"
        exit 1
    else
      echo "${VERSION}" > ~/.yavi_env
    fi
else
#    echo ""
    echo "${VERSION}" > ~/.yavi_env
fi

# Sprawdzamy, czy aktualnym shellem usera jest bash
cur_shell="$(getent passwd $LOGNAME | cut -d: -f7)"
if ! [[ ${cur_shell} =~ .*bash.* ]]; then
    p_warn "User shell is not bash - ask root to change."
fi

# Sprawdzamy, czy mamy gita
if ! [ -x "$(command -v git)" ]; then
    p_err "How did we git checkout without git? Git is needed. Cannot git so exit."
    exit 2
fi

# Sprawdzamy, czy mamy curla
if ! [ -x "$(command -v curl)" ]; then
    p_err "Curl is needed to download stuff."
    exit 3
fi


# Sprawdzamy, czy mamy vima
have_vim=true
if ! [ -x "$(command -v vim)" ]; then
    p_err " No vim found. We hate emacs. And nano. And mcedit. Vim4life."
    have_vim=false
    # nie wychodzimy - vima mozna doinstalowac pozniej, nic nie powinno wybuchnac
fi

# Sugerujemy pare innych pakietow
have_tmux=true
if ! [ -x "$(command -v tmux)" ]; then 
    have_tmux=true
    p_warn "Tmux not found. Tmux nice. Get tmux!"
fi

# Ustawiamy sobie gita
git config --global user.name "Jakub 'yavi' Neumann"
git config --global user.email jn@s-net.pl
git config --global core.editor vim
git config --global diff.tool vimdiff
git config --global push.default simple

#### Bash setup

# Pobieramy bash-it jezeli go nie ma
if ! [[ -d ~/.bash_it ]]; then
    git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it > /dev/null 2>&1 \
        && p_ok "Bash-it cloned" \
        || p_err "Bash-it clone failed!"

    # Uzywamy trybu interaktywnego albo nie
    if ${BATCH}; then
        targs="--silent"
    else 
        echo -e "--> Bash-it installation follows.\n\n"
        targs=
    fi    
    ~/.bash_it/install.sh ${targs} && p_ok "Bash-it installed" || p_err "Bash-it installation failed"
else
    p_ok "Bash-it already installed"
fi

if ! [[ -d ~/.config/base16-shell ]]; then
  git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell > /dev/null 2>&1 \
    && p_ok "base16-shell" || p_err "base16-shell"
fi

if [[ -e ~/.bashrc ]]; then mv ~/.bashrc ~/.bashrc_old; fi
#pobieranie jest mniej fajne, a skoro i tak na poczatku trzeba git clone, to lepiej cp
#curl -LSso ~/.bashrc 'http://yavi.biz/bashrc'&& p_ok "Downloaded .bashrc" || p_err "Bashrc download failed"
cp ${DIR}/bashrc ~/.bashrc
if [[ -e ~/.bash_profile ]]; then rm -f ~/.bash_profile; fi
ln -s ~/.bashrc ~/.bash_profile # Nie robimy roznicy miedzy login a non-login shell

# Dodajemy crona do updejtu srodowiska o 1 w nocy codziennie
croncmd="/bin/bash -ic 'bash-it update'"
cronjob="@daily"
( crontab -l | grep -v -F "$croncmd" ; echo -e "${cronjob}\t${croncmd}" ) | crontab -


#### VIM Setup

# install a plugin
# $1 - name
# $2 - cloneurl

function vim_install_plugin {
  if ! [[ -d ~/.vim/bundle/${1} ]]; then
    cd ~/.vim/bundle && git clone ${2} \
      && p_ok "\t ${1}" || p_err "\t${1}"
  else
    p_ok "${1} already present"
  fi
}

if ${have_vim}; then
    if ! [[ -e ~/.vim/autoload ]]; then
	# Get pathogen
	mkdir -p ~/.vim/autoload ~/.vim/bundle \
		&& curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim \
		&& p_ok "Vim-pathogen installed" || p_err "Pathogen install failed!"
    fi


    # Get vim plugins
#    echo "Installing vim plugins..."
#    if ! [[ -d ~/.vim/bundle/vim-sensible ]]; then
#	    cd ~/.vim/bundle && git clone https://github.com/tpope/vim-sensible.git \
#        	&& p_ok "\t vim-sensible" || p_err "vim-sensible"
#    else 
#	    p_ok "vim-sensible already present" 
#    fi

    vim_install_plugin vim-sensible git://github.com/tpope/vim-sensible.git
#    vim_install_plugin base16-vim https://github.com/chriskempson/base16-vim.git
    vim_install_plugin vim-colors-solarized git://github.com/altercation/vim-colors-solarized.git

    # Make .vimrc
    if [[ -e ~/.vimrc ]]; then mv ~/.vimrc ~/.vimrc.old; fi
    cp ${DIR}/vimrc ~/.vimrc
fi
