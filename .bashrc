#
# ~/.bashrc
#

export GTK_THEME=Adwaita-dark
export GDK_SCALE=1
export GDK_DPI_SCALE=1


# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
