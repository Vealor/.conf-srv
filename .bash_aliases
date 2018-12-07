# System Aliases
# ~/.bash_aliases
################################################################################
#shutdown
alias shut="sudo shutdown -h now"
alias reboot="sudo shutdown -r now"

#git
alias gitveal='pushd ~/.dotfiles && git config user.name Vealor && git config user.email jakob.m.roberts@gmail.com && popd'

#networking
alias myip="curl ipecho.net/plain ; echo"
alias localip="ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'"
alias openports='netstat -nape --inet'
alias listen='netstat -tanl | grep LISTEN | sort'

#sys
alias topcpu="/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"
alias cpusage="grep 'cpu ' /proc/stat | awk '{usage=(\$2+\$4)*100/(\$2+\$4+\$5)} END {print usage}' | awk '{printf(\"%.1f\n\", \$1)}'"
alias power='upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -E "state|to\ full|percentage"'
alias syinfo='inxi -Fxz'
alias tree='tree -CAuhF --dirsfirst'
alias paths='sed "s/:/\n/g" <<< "$PATH"'
alias treed='tree -CAFd'
alias mkdir='mkdir -p'

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
alias f="find ./ | grep "
alias g="grep -rni ./ -e "
alias null="/dev/null"
alias vi='vim'
alias df='df -kTh'
