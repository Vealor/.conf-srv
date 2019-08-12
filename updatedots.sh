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
FILES=".moc .bash_aliases .bash_functions .bash_profile .bash_sysspec .bashrc .gitconfig .tmux.conf .vimrc"

DIR=~/.dotfiles         # dotfiles directory
OLDDIR=~/.dotfiles/.dotfiles_old  # old dotfiles backup directory

LINE="[\e[34m==================================\e[39m]"
GOOD="[\e[92mGOOD\e[39m]"
PASS="[\e[93mPASS\e[39m]"
FAIL="[\e[31mFAIL\e[39m]"

RED=$'\e[31m'
GREEN=$'\e[92m'
BLUE=$'\e[34m'
YELLOW=$'\e[93m'
DEFAULT=$'\e[39m'
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
function do_apt {
  #preparatory update
  sudo apt update
  INSTALLS=$1
  LEN=${#INSTALLS[@]}
  for i in "${!INSTALLS[@]}"; do
    echo -e "$BLUE  ==>> $(($i + 1)) / $LEN$GREEN ${INSTALLS[$i]}$DEFAULT"
    (sudo apt -y install ${INSTALLS[$i]} && \
      echo -e "$GOOD: ${INSTALLS[$i]} INSTALLED")||\
      echo -e "$FAIL: $GREEN${INSTALLS[$i]}$RED FAILED TO INSTALL$DEFAULT"
  done
}

function ubuntu_install {
  echo " #- UBUNTU =>"
  read -r -p "  ${YELLOW}Do you want to add PPAs? [y/N]$DEFAULT " pparesponse
  if [[ "$pparesponse" =~ ^([yY][eE][sS]|[yY])+$ ]]
  then
    echo " #- Adding PPAs:"
    # pre-installs
    declare -a INSTALLS=(
                          "build-essential"
                          "git"
                          "wget"
                          "libssl-dev"
                          "libreadline-dev"
                          "libncurses5-dev"
                          "zlib1g-dev"
                          "m4"
                          "curl"
                          "wx-common"
                          "libwxgtk3.0-dev"
                          "autoconf"
                        )
    do_apt $INSTALLS
    # Core
    sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu \
      $(lsb_release -sc) main universe restricted multiverse"
    # Atom
    sudo add-apt-repository -y ppa:webupd8team/atom
    # chrome
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | \
      sudo apt-key add -
    sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ \
      stable main" >> /etc/apt/sources.list.d/google.list'
    # elixir
    wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && \
      sudo dpkg -i erlang-solutions_1.0_all.deb
    rm erlang-solutions_1.0_all.deb
    # ffmpeg
    sudo add-apt-repository -y ppa:jonathonf/ffmpeg-3
    # indicator-multiload
    sudo add-apt-repository -y ppa:indicator-multiload/stable-daily
    # mpv
    sudo add-apt-repository -y ppa:mc3man/mpv-tests
    # NodeJS and NPM
    curl -sL https://deb.nodesource.com/setup_10.x | sudo bash -
    # Theme
    sudo add-apt-repository -y ppa:ravefinity-project/ppa
  else
    echo " #- PPAS SKIPPED"
  fi

  echo " #- Doing apt Installs:"
  declare -a INSTALLS=(
                        # Repeat pre-installs
                        "build-essential"
                        "git"
                        "wget"
                        "libssl-dev"
                        "libreadline-dev"
                        "libncurses5-dev"
                        "zlib1g-dev"
                        "m4"
                        "curl"
                        "wx-common"
                        "libwxgtk3.0-dev"
                        "autoconf"
                        # By PPA
                        "atom"
                        "google-chrome-stable"
                        "esl-erlang"
                        "elixir"
                        "ffmpeg"
                        "indicator-multiload"
                        "mpv"
                        "vlc"
                        "browser-plugin-vlc"
                        "nodejs"
                        "ambiance-blackout-colors" #ambiance-blackout-aqua-pro
                        # Basics
                        "libc++1" #for Discord
                        "vim"
                        "gparted"
                        "tmux"
                        "inxi"
                        "tree"
                        "aptitude"
                        # Networking
                        "nmap"
                        "arp-scan"
                        "netcat"
                        "whois"
                        # LaTeX & Text stuff
                        "texmaker"
                        "texstudio"
                        "texlive-math-extra"
                        "texlive-science"
                        "texlive-bibtex-extra"
                        "biber"
                        "latex-cjk-all"
                        "meld"
                        "gedit-plugins"
                        # Media
                        "moc"
                        "lmms"
                        "feh"
                        "espeak"
                        "kolourpaint4"
                        "inkscape"
                        # Python
                        "python"
                        "python3"
                        # Java
                        "openjdk-8-jdk"
                        # Theme
                        "compizconfig-settings-manager"
                        # Funny
                        "sl"
                        # Final Fix Check
                        "-f"
                      )
  do_apt $INSTALLS

  # python's pip, pip2, pip3 installs
  curl -sS https://bootstrap.pypa.io/get-pip.py | sudo python
  curl -sS https://bootstrap.pypa.io/get-pip.py | sudo python3

  # add i3

  # Atom APM INSTALLS
  apm install atom-beautify\
              atom-bootstrap3\
              atom-django\
              atom-elixir\
              atom-jade\
              build\
              busy\
              busy-signal\
              color-picker\
              file-icons\
              git-blame\
              gitlab\
              highlight-selected\
              intentions\
              language-elixir\
              language-ini\
              linter\
              linter-elixirc\
              linter-eslint\
              linter-gcc\
              linter-ui-default\
              markdown-preview-enhanced\
              minimap\
              pdf-view\
              pigments\
              pretty-json\
              project-manager\
              script\
              terminal-plus

  # Discord
  read -r -p "  ${YELLOW}Do you want to install Discord? [y/N]$DEFAULT " discord
  if [[ "$discord" =~ ^([yY][eE][sS]|[yY])+$ ]]
  then
    wget -O discord-0.0.1.deb "https://discordapp.com/api/download?platform=linux&format=deb"
    sudo dpkg -i discord-0.0.1.deb
    rm discord-0.0.1.deb
  fi

  echo " #- Doing pip Installs:"
  sudo python3 -m pip install --upgrade pip
  (sudo pip3 install youtube-dl && \
    echo -e "$GOOD: youtube-dl INSTALLED")||\
    echo -e "$FAIL:$GREEN youtube-dl$RED FAILED TO INSTALL$DEFAULT"
  (sudo pip3 install pandas && \
    echo -e "$GOOD: pandas INSTALLED")||\
    echo -e "$FAIL:$GREEN pandas$RED FAILED TO INSTALL$DEFAULT"
  (sudo pip3 install pyxlsb && \
    echo -e "$GOOD: pyxlsb INSTALLED")||\
    echo -e "$FAIL:$GREEN pyxlsb$RED FAILED TO INSTALL$DEFAULT"
  (sudo pip3 install jupyter && \
    echo -e "$GOOD: jupyter INSTALLED")||\
    echo -e "$FAIL:$GREEN jupyter$RED FAILED TO INSTALL$DEFAULT"

  echo " #- Doing npm Installs:"
  (sudo npm -g install http-server && \
    echo -e "$GOOD: http-serverl INSTALLED")||\
    echo -e "$FAIL:$GREEN http-server$RED FAILED TO INSTALL$DEFAULT"

  echo "$YELLOW #- System Upgrade:$DEFAULT"
  sudo apt -y dist-upgrade

  echo "$YELLOW #- Package Removals:$DEFAULT"
  read -r -p "  ${YELLOW}Do you want to remove packages? [y/N]$DEFAULT " rempak
  if [[ "$rempak" =~ ^([yY][eE][sS]|[yY])+$ ]]
  then
    sudo apt purge thunderbird
    sudo apt purge libreoffice-*
  fi

  # WORKSPACES
  # add workspaces
  gsettings set org.compiz.core:/org/compiz/profiles/unity/plugins/core/ hsize 3
  gsettings set org.compiz.core:/org/compiz/profiles/unity/plugins/core/ vsize 2
  # remove workspace switcher icon
  WRKSPC=$(gsettings get com.canonical.Unity.Launcher favorites |sed -e "s/'unity:\/\/expo-icon', //")
  gsettings set com.canonical.Unity.Launcher favorites "$WRKSPC"
}


# does basic initial installs on a Arch system
function install {
  echo "$GREEN #- PACMAN INSTALLS:$DEFAULT"
  sudo pacman -Syyu pamac-gtk pamac-cli pamac-tray-appindicator
  echo "$GREEN #- PAMAC DEFAULT INSTALLS:$DEFAULT"
  pamac install atom tmux kolourpaint htop nmap bash-completion mpv xclip vim --no-confirm
  echo "$GREEN #- PAMAC AUR INSTALLS:$DEFAULT"
  pamac build google-chrome --no-confirm

  echo "$GREEN #- UPDATE PACMAN:$DEFAULT"
  sudo pacman -Syyu
  echo "$GREEN #- UPDATE PAMAC:$DEFAULT"
  pamac update
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

  echo -e "Please check mocp, there may be a config permission problem resolved with chmod 644"
  echo -e "It is recommended to now restart!"
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
  echo "$YELLOW ## DOING INSTALLS ## $DEFAULT"
  TEMP="-$(uname -a)"
  if [[ $TEMP =~ MANJARO ]]; then
    install
  else
    echo " # System not compatible with given installs"
  fi

  echo -e "Please check mocp, there may be a config permission problem resolved with chmod 644"
  echo -e "It is recommended to now restart!"
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

  echo -e "Please check mocp, there may be a config permission problem resolved with chmod 644"
  echo -e "It is recommended to now restart!"
########################################
else
  echo -e "~~~ \e[33mUSAGE:\e[39m ~~~"
  echo -e "\e[34mbash updatedots.sh create  # create/update dotfile symlinks"
  echo -e "\e[35mbash updatedots.sh restore # restores pre-existing dotfiles for system"
  echo -e "\e[93mbash updatedots.sh install # installs software for system\e[39m"
  echo -e "\e[93mbash updatedots.sh update  # updates new dotfiles from github\e[39m"
fi
echo -e "$LINE"
################################################################################
