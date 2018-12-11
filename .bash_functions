# System Functions
# ~/.bash_functions
################################################################################
#twitch

TWITCHSOURCES="monstercat summit1g ZodiacOnFire maddamesalsa shroud ArsonideX Demigodkinglol cerberuzsmiles TheHiveLeader jennavyr thecheezo Zizaran "
function gettwitch {
  for TWITCHER in $TWITCHSOURCES; do
    echo "======== $TWITCHER >>>"
    youtube-dl -F https://twitch.tv/$TWITCHER | egrep -v --color=never "twitch:stream|info"
  done
}
function starttwitch {
  mpv --no-config --ytdl-format=$2 https://www.twitch.tv/$1 &
}

_starttwitch() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=( $(compgen -W "$TWITCHSOURCES" -- ${cur}) )
  return 0
}
complete -F _starttwitch starttwitch #-o nospace
################################################################################
#weather
WEATHERLOCATIONS="Victoria YYJ Vancouver Ottawa Nara Osaka KIX Kyoto"
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
_weathercomplete() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=( $(compgen -W "$WEATHERLOCATIONS" -- ${cur}) )
  return 0
}
complete -F _weathercomplete getweather
complete -F _weathercompelte getweatherloop
################################################################################
#youtube
# TO DO:  add support for just end link for TY, add soundcloud? other?
function ytm { #music
  mpv $1 --loop-playlist=inf --autofit-larger=30%x30% &
}
function ytv { #video
  mpv $1 --autofit-larger=50%x50% &
}
MPLAYCOUNT="1 2 3"
function mplay {
  mplaylink=""
  case $1 in
    1 )
      mplaylink="https://www.youtube.com/watch?v=2PA6JBhUhn8" ;;
    2 )
      mplaylink="https://www.youtube.com/watch?v=Vhn73idb7Jg" ;;
    3 )
      mplaylink="https://www.youtube.com/watch?v=b9EqnSrswEU" ;;
    * )
      mplaylink="" ;;
  esac
  if [ -z "$mplaylink" ]; then
    printf "\033[0;31mNo fav song specified\033[0m\n"
  else
    ytm $mplaylink
  fi
}
_mplaycomplete() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=( $(compgen -W "$MPLAYCOUNT" -- ${cur}) )
  return 0
}
complete -F _mplaycomplete mplay
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
#input
function doclick {
  xdotool click --repeat $1 --delay 1 1
}
################################################################################
################################################################################

#clock in corner of shell top right
# while sleep 1;do tput sc;tput cup 0 $(($(tput cols)-25));date;tput rc;done &
