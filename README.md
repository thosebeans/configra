# configra

Tool for managing your dotfiles, written in bash.

## Installation

simply clone the repo and do `make install`, with write-permissions on `/usr/local/bin`, to install it there
or copy to into your `$PATH` yourself.

## How to use

Configra organises your files in "set's",
all sets are stored inside `~/CONFIGRA/` (configra won't automatically create a git-repository).

Simply do `configra add SET FILE` to add `FILE` to `SET`.
If `SET`, doesen't exist, it will be created.  
**!!!BEWARE!!!** This will automaticaly replace `FILE` with a symlink, to its copy in `SET`.

`configra list` will show you all your set's and their files.

Every set contains, at least, one folder which contains a `configrainstall.sh`.
Using `configra install SET`, configra will `cd` into all the subdirectorys of `SET` and execute the `configra.sh`-scripts **from there** .

**IMPORTANT**  
By default, `configra.sh` will be a bash-script, but any executable-file can be used, as long as your system can fullfill the dependencies.
