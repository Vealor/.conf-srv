## dotfiles
This has four functions:
- create symlinks for these dotfiles while backing up existing ones
- restore old dotfiles and remove the symlinks to these
- install basic packages (only support for Ubuntu currently)
- update this repository

Initial Installation:
```bash
cd ~
git clone https://github.com/Vealor/dotfiles
cd dotfiles
bash updatedots.sh create
```

The repository should now be found by default in ~/.dotfiles.   
For information on usage:
```bash
$ bash ~/.dotfiles/updatedots.sh
~~~ USAGE: ~~~
bash updatedots.sh create  # create/update dotfile symlinks
bash updatedots.sh restore # restores pre-existing dotfiles for system
bash updatedots.sh install # installs base software for ubuntu with apt
bash updatedots.sh update  # performes a restore + git pull + create
```
#### Requirements
tmux >= 2.1 (for mouse support)
