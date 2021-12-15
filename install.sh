
# update
sudo apt update
sudo apt dist-upgrade -y

# installs
sudo apt -y install stow vim feh git ssh wget build-essential curl vlc mpv gparted tmux tree nmap netcat whois meld default-jdk mocp xdotool

# NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install --lts
nvm use --lts
npm install -g npm

# python
sudo apt -y install libreadline-dev libncursesw5 make libssl-dev
libedit-dev libncurses5-dev
libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev llvm libncurses5-dev xz-utils tk-dev
curl https://pyenv.run | bash
exec $SHELL
# eval "$(pyenv virtualenv-init -)"
pyenv install 3.8.0
pyenv global 3.8.0

# configs
stow --verbose=5 bash git moc tmux vim
