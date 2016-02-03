#######=== CUSTOM ALIASES ===#######
#to open alias listing
alias changealias="vim ~/.bash_aliases"
alias shut="sudo shutdown -h now"

#networking
alias myip="curl ipecho.net/plain ; echo"

#custome aliases
alias c="clear"
alias upg="sudo apt-get dist-upgrade"
alias upd="sudo apt-get update"
alias audit="echo adtdepchk - Dependency checker && echo adttmpcln -  Auditor temp file cleaner && echo dskadtchk -  Disk Auditor && echo fsadtchk - File System Auditor && echo genadtchk - General System Auditor && echo netadtchk - Network Auditor && echo usradtchk - User Auditor && echo pwgen - A fairly complex password generator"

#git commit on external machine
alias vealcommit="git -c user.name='Vealor' -c user.email='jakob.m.roberts@gmail.com' commit --verbose"
#git log graph
alias ggraph="-git log --graph --oneline --decorate --color --all"
