
#clock in corner of shell top right
# while sleep 1;do tput sc;tput cup 0 $(($(tput cols)-25));date;tput rc;done &

#to open alias listing
alias changealias="vim ~/.bash_aliases"

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
alias vealcommit="git -c user.name='Vealor' -c user.email='jakob.m.roberts@gmail.com' commit --verbose"
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

#twitch
function gettwitch {
  TWITCHERS="monstercat summit1g ZodiacOnFire alsatiak shroud "
  for TWITCHER in $TWITCHERS; do
    echo "======== $TWITCHER >>>"
    youtube-dl -F https://twitch.tv/$TWITCHER | egrep -v --color=never "twitch:stream|info"
  done
}
function starttwitch {
  mpv --no-config --ytdl-format=$2 https://www.twitch.tv/$1 &
}

#weather
function getweather {
  curl -s wttr.in/$1 |egrep -v "Follow"|egrep -v "feature"
}
function getweatherloop {
  while true ; do
    clear
    curl -s wttr.in/$1 |egrep -v "Follow"|egrep -v "feature"
    sleep 300
  done
}

#youtube
# TO DO:  add support for just end link for TY, add soundcloud? other?
function ytm { #music
  mpv $1 --loop-playlist=inf --autofit-larger=30%x30% &
}
function ytv { #video
  mpv $1 --autofit-larger=50%x50% &
}

#sensors
function sensorloop {
  while true ; do
    clear
    sensors
    sleep 2
  done
}
