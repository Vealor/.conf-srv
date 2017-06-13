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
OLDDIR=~/.dotfiles_old  # old dotfiles backup directory

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
# Helper function to change directory
#   $1 - directory location
function changedir {
  #first in variable is location of directory change
  local THEDIR=$1
  local TEXT="Changing to the $THEDIR directory"

  (sleep 1) &
  #the $! gets last process ID
  spinny $! $TEXT

  #used hyphen to make out not empty on success
  #main output for function
  local OUT="-$(cd $THEDIR 2>&1)"
  #status icon for function running
  spinny $! $TEXT

  #display good/pass/fail output
  if [[ $OUT == *No\ such* ]]; then #if folder does not exist
    echo -e "$FAIL\t$TEXT"
    exit 1
  elif [[ $OUT == *[!\ ]* ]]; then #only hyphen
    echo -e "$GOOD\t$TEXT"
  else #any other output that contains a space
    echo -e "$FAIL\t$TEXT"
    exit 1
  fi
}
################################################################################
# Create backup directory for existing dotfiles
function makeolddir {
  local TEXT="Creating $OLDDIR for backup of any existing dotfiles in ~/"

  (sleep 1) &
  spinny $! $TEXT

  #used hyphen to make out not empty on success
  #main output for function
  local OUT="-$(mkdir $OLDDIR 2>&1 &)"
  #status icon for function running
  spinny $! $TEXT

  #display good/pass/fail output
  if [[ $OUT == *File\ exists* ]]; then #if folder exists
    echo -e "$PASS\t$TEXT"
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
  local TEXT="Moving any existing dotfiles from ~ to $OLDDIR"
  echo -e "[||||]\t$TEXT"
  for FILE in $FILES; do
      local OUT="-$(mv ~/$FILE ~/.dotfiles_old/ &)"
      spinny $! $FILE 1
      #display good/pass/fail output
      if [[ $OUT == *File\ exists* ]]; then #if a symlink exists
        echo -e "     $PASS\t$FILE"
      elif [[ $OUT == *[!\ ]* ]]; then #only hyphen
        echo -e "     $GOOD\t$FILET"
      else #any other output that contains a space
        echo -e "     $FAIL\t$FILE"
        exit 1
      fi
  done


  #reset output var
  local OUT=""

  # create symlinks for new dotfiles in DIR
  local TEXT="Creating symlink to Files in home directory."
  for FILE in $FILES; do
      local OUT="-$(ln -s $DIR/$FILE ~/$FILE &)"
      spinny $! $FILE 1
      #display good/pass/fail output
      if [[ $OUT == *File\ exists* ]]; then #if a symlink exists
        echo -e "     $PASS\t$FILE"
      elif [[ $OUT == *[!\ ]* ]]; then #only hyphen
        echo -e "     $GOOD\t$FILET"
      else #any other output that contains a space
        echo -e "     $FAIL\t$FILE"
        exit 1
      fi
  done
}
################################################################################
# creates symlinks for dotfiles
function restore {

  # move existing dotfiles in DIR to OLDDIR directory
  local TEXT="Deleting symlinks in home directory."
  echo -e "[||||]\t$TEXT"
  for FILE in $FILES; do
    if test -h $FILE; then
      local OUT="-$(rm ~/$FILE &)"
      spinny $! $FILE 1
      #display good/pass/fail output
      if [[ $OUT == *No\ such* ]]; then #if a file doesn't exist
        echo -e "     $FAIL\t$FILE"
      elif [[ $OUT == *[!\ ]* ]]; then #only hyphen
        echo -e "     $GOOD\t$FILET"
      else #any other output that contains a space
        echo -e "     $FAIL\t$FILE"
        exit 1
      fi
    fi
  done

  #reset output var
  local OUT=""

  #restores old system dotfiles
  local TEXT="Restoring old dotfiles from $OLDDIR"
  echo -e "[||||]\t$TEXT"
  for FILE in $FILES; do
      local OUT="-$(mv ~/.dotfiles_old/ ~/$FILE &)"
      spinny $! $FILE 1
      #display good/pass/fail output
      if [[ $OUT == *[!\ ]* ]]; then #only hyphen
        echo -e "     $GOOD\t$FILE"
      else #any other output that contains a space
        echo -e "     $FAIL\t$FILE"
        exit 1
      fi
  done

  #reset output var
  local OUT=""

  spinny $! $FILE 0
  #display good/pass/fail output
  local OUT="-$(rm -r $OLDDIR &)"
  if [[ $OUT == *No\ such* ]]; then #if a file doesn't exist
    echo -e "     $FAIL\t$FILE"
  elif [[ $OUT == *[!\ ]* ]]; then #only hyphen
    echo -e "     $GOOD\t$FILET"
  else #any other output that contains a space
    echo -e "     $FAIL\t$FILE"
    exit 1
  fi

}
################################################################################
################################################################################
# main body
# Usage:
#   bash updatedots.sh create  #create/update dotfile symlinks
#   bash updatedots.sh restore #restores pre-existing dotfiles for system

MODE=$1
if [ "$MODE" == "create" ]; then
  if test -e $DIR; then
    echo -e "$PASS\tDotfile directory exists"
  else
    mv ./dotfiles $DIR
  fi
  echo -e "create" #replace with main create function
elif [ "$MODE" == "restore" ]; then
  if test -e $OLDDIR; then
    echo -e "restore" #replace with main restore function
  else
    echo -e "$FAIL\tOld dotfile directory does not exist or match!"
  fi
else
  echo -e "~~~ \e[33mUSAGE:\e[39m ~~~"
  echo -e "\e[34mbash updatedots.sh create  # create/update dotfile symlinks"
  echo -e "\e[35mbash updatedots.sh restore # restores pre-existing dotfiles for system\e[39m"
fi

#reload configurations
source ~/.bashrc
#source ~/.vimrc

################################################################################
