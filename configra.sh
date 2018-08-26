#!/bin/bash

#PREPARE
#checks if all depencies are available
#if not, the script echos the missing dependencies and exits
deps="sha256sum base64 git"
missingdeps=""

for d in $deps; do
    which $d &>/dev/null || missingdeps="$d $missingdeps"
done

if [[ "$missingdeps" != "" ]]; then
    echo "missing dependencies:"
    echo "$missingdeps"
    exit
fi

function showhelp () {
    echo '
CONFIGRA - HELP

add     [SETNAME] [FILENAME] - adds a file to the set "SETNAME" of your configra-collection
list                         - list all your sets and their files
install [SETNAME]            - executes the install-script of the set "SETNAME"
init                         - initialises your "CONFIGRA"-Directory as a git-repository
sync                         - synchronizes the remote-repository with your local copy
    '
}

function add () { # $2 setname $3 filename
    if [[ "$2" = "" ]]; then                    #checks if user entered a setname
        echo "Please input a set to use"
        exit
    fi
    if [[ "$3" = "" ]]; then                    #checks if user entered a filename
        echo "Please input a File to add"
        exit
    fi
    if [[ ! -e "$3" ]]; then                    #checks if file exists
        echo 'File "'$3'" doesent exist'
        exit
    fi
    if [[ -d "$3" ]]; then                      #checks if file is a directory
        echo 'File "'$3'" is a directory'
        exit
    fi
    
    mkdir -p ~/CONFIGRA/$2                      #creates the set-directory 
    
    cleanname=$(basename $3)                    #filename without a . at the beginning 
    cleanname=${cleanname#.}

    if [[ "$cleanname" == "configrainstall.sh" ]]; then
        cleanname="$cleanname$RANDOM"
    fi
    
    #generating a random name-prefix without numbers
    rand=$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM
    rand=$(echo $rand | sha256sum | base64)
    rand=${rand//[[:digit:]]/""}
    rand=${rand:0:5}
    
    #creating the file-specific directory inside the set-directory
    mkdir -p ~/CONFIGRA/$2/$rand-$cleanname

    #echo the configra.sh-script into its file
    echo '#!/bin/bash
#
#this is the install-script of ' $cleanname '
#its a normal bash-script, so feel free to modify it
#' > ~/CONFIGRA/$2/$rand-$cleanname/configrainstall.sh
    chmod +x ~/CONFIGRA/$2/$rand-$cleanname/configrainstall.sh
    
    #link to the file, that shall be added
    fullpath=$(readlink -f $3)

    #path, where the symlink-file shall be created
    linkpath=$fullpath
    
    #checks if the file is inside your HOME-directory
    #if yes, the install-script will use a relative-link to the current users $HOME
    #if no, the install-script will use the absolute path
    if [[ $fullpath = *$HOME* ]]; then
        linkpath=${fullpath#"$HOME"}
        linkpath="~$linkpath"
    fi
    
    #copies the file into the set-directory
    cp -p $3 ~/CONFIGRA/$2/$rand-$cleanname/$cleanname
    
    #determines the directory, in which the file is located
    filedir=$(dirname $3)
    filedir=$(readlink -f $filedir)
    if [[ $filedir = *$HOME* ]]; then
        filedir=${filedir#"$HOME"}
        filedir="~$filedir"
    fi
    
    #will create the directory for the symlink
    echo "mkdir -p $filedir" >> ~/CONFIGRA/$2/$rand-$cleanname/configrainstall.sh

    #force-creates the symlink
    echo "ln -srf $cleanname $linkpath" >> ~/CONFIGRA/$2/$rand-$cleanname/configrainstall.sh
    echo "#" >> ~/CONFIGRA/$2/$rand-$cleanname/configrainstall.sh
    
    ln -srf ~/CONFIGRA/$2/$rand-$cleanname/$cleanname $3
}

function installf () { #$2 set
    #checks if $2 is a set
    if [[ ! -d ~/CONFIGRA/$2 ]]; then
        echo "$2 isnt a set"
        echo ""
        exit
    fi
    
    #cd into the set-directory
    cd ~/CONFIGRA/$2
    
    #lists all file-directorys in the set-directory
    files=$(ls --color=never)
    
    #loop cds into the file-dir and executes configrainstall.sh from there
    for i in $files; do
        $(cd $i && ./configrainstall.sh)
    done
}

function list () {
    #lists all dirs in $HOME/CONFIGRA
    sets=$(ls --color=never $HOME/CONFIGRA/)

    for i in $sets ; do
        echo $i
        setcontent=$(ls --color=never $HOME/CONFIGRA/$i)
        for j in $setcontent ; do
            echo "-- $j"
        done
        echo ""
    done
}

function initf () {
    mkdir -p ~/CONFIGRA
    git init ~/CONFIGRA/
}

function syncf () {
    cd ~/CONFIGRA/
    git fetch
    git pull
    hash=$(date | sha256sum)
    hash=${hash:0:16}
    git add -A
    git commit -m "$hash"
    git push
}

case $1 in
    "add")
        add $*
    ;;
    "install")
        installf $*
    ;;
    "list")
        list
    ;;
    "--help")
        showhelp
    ;;
    "-h")
        showhelp
    ;;
    "init")
        initf
    ;;
    "sync")
        syncf
    ;;
    *)
        showhelp
    ;;
esac
