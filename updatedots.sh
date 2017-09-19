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
FILES=".moc .bash_aliases .bashrc .gitconfig .tmux.conf .vimrc"

DIR=~/.dotfiles         # dotfiles directory
OLDDIR=~/.dotfiles/.dotfiles_old  # old dotfiles backup directory

LINE="[\e[34m==================================\e[39m]"
GOOD="[\e[92mGOOD\e[39m]"
PASS="[\e[93mPASS\e[39m]"
FAIL="[\e[31mFAIL\e[39m]"
################################################################################
################################################################################
# Create backup directory for existing dotfiles
function makeolddir {
  local TEXT="Creating $OLDDIR for backup of any existing dotfiles in ~/"

  #used hyphen to make out not empty on success
  #main output for function
  local OUT="-$(mkdir $OLDDIR 2>&1 &)"
  #status icon for function running

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
  sudo apt-get -y install build-essential git wget libssl-dev libreadline-dev libncurses5-dev zlib1g-dev m4 curl wx-common libwxgtk3.0-dev autoconf
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

  echo " #- Doing pip Installs:"
  sudo pip install youtube-dl

  #add java installs
  #add python installs

  #add to alias for weather with arg for location
  #clear && curl -s wttr.in/Nara |egrep -v "Follow"|egrep -v "feature"


  #add i3





  echo " #- System Upgrade:"
  sudo apt -y dist-upgrade

#------------------------------------------------------------------------------#
# NOTES:

  # need script to check twitch followers that are active and their best
  # stream quality

  #twitch stuff
  # youtube-dl -F https://twitch.tv/summit1g
  # mpv https://twitch.tv/summit1g --ytdl-format=best &


}
################################################################################
################################################################################
# main body
# Usage:
#   bash updatedots.sh create  #create/update dotfile symlinks
#   bash updatedots.sh restore #restores pre-existing dotfiles for system
echo -e "$LINE"
MODE=$1
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

elif [ "$MODE" == "install" ]; then
  #installs from sys information
  echo " ## DOING INSTALLS ## "
  local TEMP="-$(uname -a)"
  if [[ $TEMP =~ Ubuntu ]]; then
    ubuntu_install
  else
    echo " # System not compatible with given installs"
  fi
elif [ "$MODE" == "update" ]; then
  #installs from sys information
  echo " ## Performing Update from GitHub ## "
  echo " ## ~~Restoring Files: "
  if [ -d "$OLDDIR" ]; then
    # main restore function
    restore
  echo " ## ~~Updating: "
    git pull
  echo " ## ~~Creating new links: "
    if [ -d "$DIR" ]; then
      echo -e "$PASS\t ~/.dotfile directory exists, no need to move"
    else
      mv ~/dotfiles $DIR
    fi
    makeolddir
    create
  else
    echo -e "$FAIL\tOld dotfile directory does not exist or match!"
  fi

else
  echo -e "~~~ \e[33mUSAGE:\e[39m ~~~"
  echo -e "\e[34mbash updatedots.sh create  # create/update dotfile symlinks"
  echo -e "\e[35mbash updatedots.sh restore # restores pre-existing dotfiles for system"
  echo -e "\e[93mbash updatedots.sh install # installs software for system\e[39m"
  echo -e "\e[93mbash updatedots.sh update  # updates new dotfiles from github\e[39m"
fi

echo -e "$LINE"
#reload configurations
source ~/.bashrc
#source ~/.vimrc

################################################################################
