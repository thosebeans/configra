#!/bin/bash

#PREPARE
deps="sha256sum base64"
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
    if [[ "$2" = "" ]]; then
        echo "Please input a set to use"
        exit
    fi
    if [[ "$3" = "" ]]; then
        echo "Please input a File to add"
        exit
    fi
    if [[ ! -e "$3" ]]; then
        echo 'File "'$3'" doesent exist'
        exit
    fi
    if [[ -d "$3" ]]; then
        echo 'File "'$3'" is a directory'
        exit
    fi
    
    mkdir -p ~/CONFIGRA/$2
    
    cleanname=$(basename $3)
    cleanname=${cleanname#.}
    
    echo $cleanname
    
    rand=$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM
    rand=$(echo $rand | sha256sum | base64)
    rand=${rand//[[:digit:]]/""}
    rand=${rand:0:5}
    
    echo $rand
    
    mkdir -p ~/CONFIGRA/$2/$cleanname-$rand
    echo '#!/bin/bash
#
#this is the install-script of ' $cleanname '
#its a normal bash-script, so feel free to modify it
#' > ~/CONFIGRA/$2/$cleanname-$rand/configrainstall.sh
    chmod +x ~/CONFIGRA/$2/$cleanname-$rand/configrainstall.sh
    
    fullpath=$(readlink -f $3)
    linkpath=$fullpath
    
    if [[ $fullpath = *$HOME* ]]; then
        linkpath=${fullpath#"$HOME"}
        linkpath="~$linkpath"
    fi
    echo $linkpath
    
    cp -p $3 ~/CONFIGRA/$2/$cleanname-$rand/$cleanname
    
    filedir=$(dirname $3)
    filedir=$(readlink -f $filedir)
    if [[ $filedir = *$HOME* ]]; then
        filedir=${filedir#"$HOME"}
        filedir="~$filedir"
    fi
    echo $filedir
    
    echo "mkdir -p $filedir" >> ~/CONFIGRA/$2/$cleanname-$rand/configrainstall.sh
    echo "ln -srf $cleanname $linkpath" >> ~/CONFIGRA/$2/$cleanname-$rand/configrainstall.sh
    echo "#" >> ~/CONFIGRA/$2/$cleanname-$rand/configrainstall.sh
    
    ln -srf ~/CONFIGRA/$2/$cleanname-$rand/$cleanname $3
}

function installf () { #$2 set
    if [[ ! -d ~/CONFIGRA/$2 ]]; then
        echo "$2 isnt a set"
        echo ""
        exit
    fi
    
    cd ~/CONFIGRA/$2
    
    files=$(ls --color=never)
    echo $files
    echo ""
    
    for i in $files; do
        echo $i
        $(cd $i && ./configrainstall.sh)
    done
}

function list () {
    sets=$(ls --color=never ~/CONFIGRA/)
    for i in $sets ; do
        echo $i
        setcontent=$(ls --color=never ~/CONFIGRA/$i)
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
