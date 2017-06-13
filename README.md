## dotfiles
This has two functions: to symlink specified dotfiles in your home directory and to restore pre-existing dotfiles when you want to remove your environment.

Initial Installation:
```bash
$ git clone https://github.com/Vealor/dotfiles
$ bash ./dotfiles/updatedots.sh
```

The repository should now be found by default in ~/.dotfiles.   
For information on usage:
```bash
$ bash ~/.dotfiles/updatedots.sh
~~~ USAGE: ~~~
bash updatedots.sh create  # create/update dotfile symlinks
bash updatedots.sh restore # restores pre-existing dotfiles for system
```
