#!/bin/bash
################################################################################
# Create dotfiles on new system as per github.com/vealor preferences
# Has four usages.
#
# Usage:
#   bash updatedots.sh create  #create/update dotfile symlinks
#   bash updatedots.sh restore #restores pre-existing dotfiles for system
#   bash updatedots.sh install #installs software for system
#   bash updatedots.sh update  #updates new dotfiles from github
#
################################################################################
# list of files/folders to symlink in homedir
FILES=".moc .bash_aliases .bash_functions .bash_sysspec .bashrc .gitconfig .tmux.conf .vimrc"

DIR=~/.dotfiles         # dotfiles directory
OLDDIR=~/.dotfiles/.dotfiles_old  # old dotfiles backup directory

LINE="[\e[34m==================================\e[39m]"
GOOD="[\e[92mGOOD\e[39m]"
PASS="[\e[93mPASS\e[39m]"
FAIL="[\e[31mFAIL\e[39m]"
################################################################################
################################################################################
#Create backup directory for existing dotfiles
function dot_makeolddir {
  local TEXT="Creating $OLDDIR for backup of any existing dotfiles in ~/"
  local OUT="-$(mkdir $OLDDIR 2>&1 &)" #main output for function
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
#creates symlinks for dotfiles
function dot_create {
  # move existing dotfiles in DIR to OLDDIR directory
  local TEXT="\nMoving any existing dotfiles from ~ to $OLDDIR"
  echo -e "$TEXT"
  for FILE in $FILES; do
    if [ -f "$FILE" ] || [ -d "$FILE" ]; then
      local OUT="-$(mv ~/$FILE $OLDDIR &)" #main output for function
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

  #flush output var
  local OUT=""

  #create symlinks for new dotfiles in DIR
  local TEXT="\nCreating symlink to Files in home directory."
  echo -e "$TEXT"
  for FILE in $FILES; do
    local OUT="-$(ln -s $DIR/$FILE ~/$FILE &)" #main output for function
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
function dot_restore {
  # delete created symlinks
  local TEXT="Deleting symlinks in home directory."
  echo -e "$TEXT"
  for FILE in $FILES; do
    if [ -f "$FILE" ] || [ -d "$FILE" ]; then
      local OUT="-$(rm ~/$FILE &)" #main output for function
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

  #flush output var
  local OUT=""

  #restores old system dotfiles
  local TEXT="\nRestoring old dotfiles from $OLDDIR"
  echo -e "$TEXT"
  for FILE in $FILES; do
    if [ -f "$OLDDIR/$FILE" ] || [ -d "$OLDDIR/$FILE" ]; then
      local OUT="-$(mv $OLDDIR/$FILE ~/$FILE &)"
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
  sudo apt update

  #Atom
  sudo add-apt-repository -y ppa:webupd8team/atom
  #chrome
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key -y add -
  #elixir
  sudo apt -y install build-essential git wget libssl-dev libreadline-dev libncurses5-dev zlib1g-dev m4 curl wx-common libwxgtk3.0-dev autoconf
  wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && sudo dpkg -i erlang-solutions_1.0_all.deb
  #ffmpeg
  sudo add-apt-repository -y ppa:jonathonf/ffmpeg-3
  #mpv
  sudo add-apt-repository -y ppa:mc3man/mpv-tests
  #vlc
  sudo add-apt-repository -y ppa:videolan/master-daily

  sudo apt update
  echo " #- Doing apt Installs:"
  sudo apt -y install atom
  sudo apt -y install google-chrome-stable
  sudo apt -y install esl-erlang
  sudo apt -y install elixir
  sudo apt -y install texmaker texstudio texlive-math-extra texlive-science texlive-bibtex-extra biber latex-cjk-all
  sudo apt -y install git vim gparted http-server kolourpaint4 tmux feh nmap netcat mocp whois meld mpv ffmpeg vlc inxi
  sudo apt -y install python python-pip
  sudo apt -y install boinc-client boinc-manager
  sudo apt -y install sl espeak
  sud apt-get -y install -f #fix any broken package requirements

  echo " #- Doing pip Installs:"
  sudo pip install youtube-dl

  #add java installs
  #add python installs

  #get discord here


  #add i3

  echo " #- System Upgrade:"
  sudo apt -y dist-upgrade
}
# does basic initial installs on a ubuntu system
function arch_install {
  echo " #- ARCH =>"
  echo " #- Adding PPAs:"

  echo " #- Doing pacman Installs:"

  echo " #- Doing pip Installs:"

  echo " #- System Upgrade:"

}
################################################################################
################################################################################
# main body
# Usage:
#   bash updatedots.sh create  #create/update dotfile symlinks
#   bash updatedots.sh restore #restores pre-existing dotfiles for system
echo -e "$LINE"
MODE=$1
########################################
if [ "$MODE" == "create" ]; then
  if [ -d "$DIR" ]; then
    echo -e "$PASS\t ~/.dotfile directory exists, no need to move"
  else
    mv ~/dotfiles $DIR
  fi
  # create backup directory
  dot_makeolddir
  # main create function
  dot_create
########################################
elif [ "$MODE" == "restore" ]; then
  #test if the olddir already exists to prevent overwrite
  if [ -d "$OLDDIR" ]; then
    # main restore function
    dot_restore
  else
    echo -e "$FAIL\tOld dotfile directory does not exist or match!"
  fi
########################################
elif [ "$MODE" == "install" ]; then
  #installs from sys information
  echo " ## DOING INSTALLS ## "
  local TEMP="-$(uname -a)"
  if [[ $TEMP =~ Ubuntu ]]; then
    ubuntu_install
  elif [[ $TEMP =~ Arch ]]; then
    arch_install
  else
    echo " # System not compatible with given installs"
  fi
########################################
elif [ "$MODE" == "update" ]; then
  #installs from sys information
  echo " ## Performing Update from GitHub ## "
  echo " ## ~~Restoring Files: "
  if [ -d "$OLDDIR" ]; then
    # main restore function
    dot_restore
  echo " ## ~~Updating: "
    git pull
  echo " ## ~~Creating new links: "
    if [ -d "$DIR" ]; then
      echo -e "$PASS\t ~/.dotfile directory exists, no need to move"
    else
      mv ~/dotfiles $DIR
    fi
    dot_makeolddir
    dot_create
  else
    echo -e "$FAIL\tOld dotfile directory does not exist or match!"
  fi
########################################
else
  echo -e "~~~ \e[33mUSAGE:\e[39m ~~~"
  echo -e "\e[34mbash updatedots.sh create  # create/update dotfile symlinks"
  echo -e "\e[35mbash updatedots.sh restore # restores pre-existing dotfiles for system"
  echo -e "\e[93mbash updatedots.sh install # installs software for system\e[39m"
  echo -e "\e[93mbash updatedots.sh update  # updates new dotfiles from github\e[39m"
fi
echo -e "$LINE"
echo -e "Please check mocp, there may be a config permission problem resolved with chmod 644"
echo -e "It is recommended to now restart!"
################################################################################
