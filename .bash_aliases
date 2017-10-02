# System Aliases
# ~/.bash_aliases
################################################################################
#shutdown
alias shut="sudo shutdown -h now"
alias reboot="sudo reboot"

#networking
alias myip="curl ipecho.net/plain ; echo"
alias localip="ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'"

#updating
alias upd="sudo apt update"
alias upg="sudo apt dist-upgrade"

#git
alias ggraph="git log --graph --oneline --decorate --color --all"

#custom aliases
alias q="exit"
alias c="clear"
alias h="history"
alias p="cat"
alias null="/dev/null"
alias vi='vim'
alias listen='netstat -tanl | grep LISTEN | sort'
alias power='upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -E "state|to\ full|percentage"'
alias syinfo='inxi -Fxz'
