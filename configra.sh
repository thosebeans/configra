#!/bin/bash

#PREPARE
deps="git grep"
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
list    [SETNAME]            - list all your sets and their files
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
    
    absolutepath=$(readlink -f $3)
    homepath=$(echo $absolutepath | grep -Poh --color=never "(?<=($HOME))(\w|\W|\d|\D\s\S)+")
    linkpath=$absolutepath
    if [[ "$homepath" != "" ]]; then
        linkpath="~$homepath"
    fi
    
    cleanfilename=$(basename $3 | grep -Poh --color=never "([^.])(\w|\d|\W|\D)+")
    origname=$(basename $3)
    
    linkdir=${linkpath%/*}
    
    if [[ ! -e ~/CONFIGRA/$2/configrainstall.sh ]]; then
        echo '#!/bin/bash
#
#This script will be executed every time, you do "configra install".
#Since its a normal bash-script, feel free to modify it.
#
#' > ~/CONFIGRA/$2/configrainstall.sh
    fi
    
    echo "mkdir -p $linkdir" >> ~/CONFIGRA/$2/configrainstall.sh
    echo "ln -s -r -f ~/CONFIGRA/$2/$cleanfilename $linkdir/$origname" >> ~/CONFIGRA/$2/configrainstall.sh
    echo "#" >> ~/CONFIGRA/$2/configrainstall.sh
    
    cp -p $3 ~/CONFIGRA/$2/$cleanfilename
    ln -s -r -f ~/CONFIGRA/$2/$cleanfilename $3
}

function installf () {
    if [[ ! -e ~/CONFIGRA/$2 ]]; then
        echo 'set "'$2'" not found'
        list
        exit
    fi
    bash ~/CONFIGRA/$2/configrainstall.sh
}

function list () {
    sets=$(ls --color=never ~/CONFIGRA/)
    for i in $sets ; do
        echo $i
        setcontent=$(ls --color=never ~/CONFIGRA/$i)
        for j in $setcontent ; do
            if [[ "$j" != "configrainstall.sh" ]]; then
                echo "-- $j"
            fi
            if [[ "$j" = "configrainstall.sh" ]]; then
                echo "--** $j"
            fi
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
    hash=$(date | md5sum | grep -Poh --color=never "(\d|[a-z]){16}")
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
