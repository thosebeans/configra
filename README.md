# configra

Tool for managing your dotfiles, entirely written in bash.

## Installation

simply clone the repo and do `make` to install it into `/usr/local/bin`
or copy to into your `$PATH` yourself.

## How-To

Configra organises your files in "set's",
all sets are stored inside `~/CONFIGRA/` (configra won't automatically create a git-repository).

Simply do `configra add SET FILE` to add `FILE` to `SET`.
If `SET`, doesen't exist, it will be created.
**!!!BEWARE!!!** This will automaticaly replace `FILE` with a symlink, to its copy in `SET`.

`configra list` will show you all your set's and their files.

Every set has an `configrainstall.sh`-bash-script, which holds the commands to reinstall the set,
which can be done with `configra install SET`.