# System Functions
# ~/.bash_functions
################################################################################
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
################################################################################
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
################################################################################
#youtube
# TO DO:  add support for just end link for TY, add soundcloud? other?
function ytm { #music
  mpv $1 --loop-playlist=inf --autofit-larger=30%x30% &
}
function ytv { #video
  mpv $1 --autofit-larger=50%x50% &
}
################################################################################
#sensors
function sensorloop {
  while true ; do
    clear
    sensors
    sleep 2
  done
}
################################################################################
################################################################################

#clock in corner of shell top right
# while sleep 1;do tput sc;tput cup 0 $(($(tput cols)-25));date;tput rc;done &
