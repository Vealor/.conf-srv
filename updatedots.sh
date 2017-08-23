#!/bin/bash
################################################################################
# Create dotfiles on new system as per Veal's spec.
# Has two usages.
#
# Usage:
#   bash updatedots.sh create  #create/update dotfile symlinks
#   bash updatedots.sh restore #restores pre-existing dotfiles for system
#
################################################################################
# list of files/folders to symlink in homedir
FILES=".gitconfig .bashrc .bash_aliases .tmux.conf .vimrc .moc"

DIR=~/.dotfiles         # dotfiles directory
OLDDIR=~/.dotfiles/.dotfiles_old  # old dotfiles backup directory

LINE="[\e[34m==================================\e[39m]"
GOOD="[\e[92mGOOD\e[39m]"
PASS="[\e[93mPASS\e[39m]"
FAIL="[\e[31mFAIL\e[39m]"
################################################################################
################################################################################
# Helper function for loading
#   $1 - process ID, ususally last one  [ $! ]
#   $2 - input text
#   $3 - if there is an initial input tab to be displayed (0=no, else yes)
function spinny {
  local PID=$1
  local TEXT=$2
  local TAB=$3 #if initial tab or not
  local TEXT_LEN=${#TEXT}
  local DELAY=0.7
  local FRAMES='|/-\'
  while [ -d /proc/$PID ];
  do
    if [ "$TAB" -eq 0 ] ; then
      printf "[%c%c%c%c]\t%s" "$FRAMES" "$FRAMES" "$FRAMES" "$FRAMES" "$TEXT"
    else
      printf "     [%c%c%c%c]\t%s" "$FRAMES" "$FRAMES" "$FRAMES" "$FRAMES" "$TEXT"
    fi
    local TMP=${FRAMES#?}
    FRAMES=$TMP${FRAMES%"$TMP"}
    sleep $DELAY
    if [ "$TAB" -eq 0 ] ; then
      printf "\b\b\b\b\b\b\b\b\b"
    else
      printf "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b"
    fi
    local BEGIN=0
    for ((i=$BEGIN;i<$TEXT_LEN;i++)); do
      printf "\b"
    done
  done
}
################################################################################
# Create backup directory for existing dotfiles
function makeolddir {
  local TEXT="Creating $OLDDIR for backup of any existing dotfiles in ~/"
  # echo -e "$TEXT"
  # (sleep 1) &
  # spinny $! $TEXT 0

  #used hyphen to make out not empty on success
  #main output for function
  local OUT="-$(mkdir $OLDDIR 2>&1 &)"
  #status icon for function running
  # spinny $! $TEXT

  #display good/pass/fail output
  if [[ $OUT == *File\ exists* ]]; then #if folder exists
    echo -e "$PASS\t$TEXT"
    echo -e "\tFILES ALREADY BACKED UP -- EXITING"
    exit 1
  elif [[ $OUT == *[!\ ]* ]]; then #only hyphen
    echo -e "$GOOD\t$TEXT"
  else #any other output that contains a space
    echo -e "$FAIL\t$TEXT"
    exit 1
  fi
}
################################################################################
# creates symlinks for dotfiles
function create {

  # move existing dotfiles in DIR to OLDDIR directory
  local TEXT="\nMoving any existing dotfiles from ~ to $OLDDIR"
  echo -e "$TEXT"
  for FILE in $FILES; do
      if [ -f "$FILE" ] || [ -d "$FILE" ]; then
        local OUT="-$(mv ~/$FILE $OLDDIR &)"
        spinny $! $FILE 1
        #display good/pass/fail output
        if [[ $OUT == *File\ exists* ]]; then #if a symlink exists
          echo -e "     $PASS\tMOVING $FILE"
        elif [[ $OUT == *[!\ ]* ]]; then #only hyphen
          echo -e "     $GOOD\tMOVING $FILE"
        else #any other output that contains a space
          echo -e "     $FAIL\tMOVING $FILE"
          exit 1
        fi
      fi
  done


  #reset output var
  local OUT=""

  # create symlinks for new dotfiles in DIR
  local TEXT="\nCreating symlink to Files in home directory."
  echo -e "$TEXT"
  for FILE in $FILES; do
      local OUT="-$(ln -s $DIR/$FILE ~/$FILE &)"
      spinny $! $FILE 1
      #display good/pass/fail output
      if [[ $OUT == *File\ exists* ]]; then #if a symlink exists
        echo -e "     $PASS\tLINKING $FILE"
      elif [[ $OUT == *[!\ ]* ]]; then #only hyphen
        echo -e "     $GOOD\tLINKING $FILE"
      else #any other output that contains a space
        echo -e "     $FAIL\tLINKING $FILE"
        exit 1
      fi
  done
}
################################################################################
# creates symlinks for dotfiles
function restore {

  # move existing dotfiles in DIR to OLDDIR directory
  local TEXT="Deleting symlinks in home directory."
  echo -e "$TEXT"
  for FILE in $FILES; do
    if [ -f "$FILE" ] || [ -d "$FILE" ]; then
      local OUT="-$(rm ~/$FILE &)"
      # spinny $! $FILE 1
      #display good/pass/fail output
      if [[ $OUT == *No\ such* ]]; then #if a file doesn't exist
        echo -e "     $FAIL\tREMOVING $FILE"
      elif [[ $OUT == *[!\ ]* ]]; then #only hyphen
        echo -e "     $GOOD\tREMOVING $FILE"
      else #any other output that contains a space
        echo -e "     $FAIL\tREMOVING $FILE"
        exit 1
      fi
    fi
  done

  #reset output var
  local OUT=""

  #restores old system dotfiles
  local TEXT="\nRestoring old dotfiles from $OLDDIR"
  echo -e "$TEXT"
  for FILE in $FILES; do
    if [ -f "$OLDDIR/$FILE" ] || [ -d "$OLDDIR/$FILE" ]; then
      local OUT="-$(mv $OLDDIR/$FILE ~/$FILE &)"
      spinny $! $FILE 1
      #display good/pass/fail output
      if [[ $OUT == *[!\ ]* ]]; then #only hyphen
        echo -e "     $GOOD\tRESTORED $FILE"
      else #any other output that contains a space
        echo -e "     $FAIL\tRESTORED $FILE"
        exit 1
      fi
    fi
  done

  #reset output var
  local OUT=""

  #display good/pass/fail output
  local OUT="-$(rm -r $OLDDIR &)"
  if [[ $OUT == *No\ such* ]]; then #if a file doesn't exist
    echo -e "     $FAIL\tREMOVE OLD $OLDDIR"
  elif [[ $OUT == *[!\ ]* ]]; then #only hyphen
    echo -e "     $GOOD\tREMOVE OLD $OLDDIR"
  else #any other output that contains a space
    echo -e "     $FAIL\tREMOVE OLD $OLDDIR"
    exit 1
  fi

}
################################################################################
# does basic initial installs on a ubuntu system
function ubuntu_install {
  echo " #- UBUNTU =>"
  echo " #- Adding PPAs:"

  #initial update
  sudo apt-get -y update

  #Atom
  sudo add-apt-repository -y ppa:webupd8team/atom
  sudo apt-get install -y atom
  #chrome
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key -y add -
  sudo apt-get install -y google-chrome-stable
  #elixir
  sudo apt-get -y install build-essential git wget libssl-dev libreadline-dev libncurses5-dev zlib1g-dev m4 curl wx-common libwxgtk3.0-dev autoconf
  wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && sudo dpkg -i erlang-solutions_1.0_all.deb
  sudo apt-get -y update
  sudo apt-get install -y esl-erlang
  sudo apt-get install -y elixir

  #extra stuff
  sudo apt-get -y update
  sudo apt-get -y install git vim gparted http-server kolourpaint4 tmux feh nmap netcat

  #Add in stuff about making terminal go fullscreen on hotkey

  #enable workspaces
  #Add stuff for removing workspaces dock icon
}
################################################################################
################################################################################
# main body
# Usage:
#   bash updatedots.sh create  #create/update dotfile symlinks
#   bash updatedots.sh restore #restores pre-existing dotfiles for system
echo -e "$LINE"
MODE=$1
local TEMP="-$(uname -a)"
echo " ## DOING INSTALLS ## "
if [[ $TEMP =~ Ubuntu ]]; then
  ubuntu_install
else
  echo " # System not compatible with given installs"
fi

echo -e "$LINE"
if [ "$MODE" == "create" ]; then
  if [ -d "$DIR" ]; then
    echo -e "$PASS\t ~/.dotfile directory exists, no need to move"
  else
    mv ~/dotfiles $DIR
  fi
  # create backup directory
  makeolddir
  # main create function
  create
elif [ "$MODE" == "restore" ]; then
  #test if the olddir already exists to prevent overwrite
  if [ -d "$OLDDIR" ]; then
    # main restore function
    restore
  else
    echo -e "$FAIL\tOld dotfile directory does not exist or match!"
  fi
else
  echo -e "~~~ \e[33mUSAGE:\e[39m ~~~"
  echo -e "\e[34mbash updatedots.sh create  # create/update dotfile symlinks"
  echo -e "\e[35mbash updatedots.sh restore # restores pre-existing dotfiles for system\e[39m"
fi

echo -e "$LINE"
#reload configurations
source ~/.bashrc
#source ~/.vimrc

################################################################################
