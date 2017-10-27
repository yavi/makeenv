#Managed by yavi_env, will be erased

export BASH_IT="${HOME}/.bash_it" 
export BASH_IT_THEME='zork'
export GIT_HOSTING='git@gtlb.s-net.pl:yavi'
unset MAILCHECK
export TODO="t"
export SCM_CHECK=true
export BASH_IT_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE=1

source $BASH_IT/bash_it.sh

# disable the super-annoying scroll lock "feature" (ctrl+s)
stty -ixon

# Fix terminal for telnet, most network thingies have no idea of putty
alias telnet='TERM=xterm telnet'
alias sshh='ssh -p2221'
alias sftpp='sftp -oPort=2221'

if [[ -e ~/.bashrc_custom ]]; then
    source ~/.bashrc_custom
fi
