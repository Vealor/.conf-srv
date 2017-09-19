## dotfiles
This has two functions: to symlink specified dotfiles in your home directory and to restore pre-existing dotfiles when you want to remove your environment.

Initial Installation:
```bash
$ git clone https://github.com/Vealor/dotfiles
$ cd dotfiles
$ bash updatedots.sh create
```

The repository should now be found by default in ~/.dotfiles.   
For information on usage:
```bash
$ bash ~/.dotfiles/updatedots.sh
~~~ USAGE: ~~~
bash updatedots.sh insatll # installs base software for ubuntu with apt
bash updatedots.sh create  # create/update dotfile symlinks
bash updatedots.sh restore # restores pre-existing dotfiles for system
bash updatedots.sh update  # performes a restore + git pull + create
```
#### Requirements
tmux >= 2.1
