#!/bin/bash

function showhelp () {
    echo '
CONFIGRA - HELP

add     [SETNAME] [FILENAME] - adds a file to the set "SETNAME" of your configra-collection
list    [SETNAME]            - list all your sets and their files
install [SETNAME]            - executes the install-script of the set "SETNAME"
    '
}

function add () { # $2 setname $3 filename
    if [[ "$2" == "" ]]; then
        exit
    fi
    if [[ "$3" == "" ]]; then
        exit
    fi
    if [[ ! -e "$3" ]]; then
        exit
    fi
    
    mkdir -p ~/CONFIGRA/$2 || echo ""
    
    cleanfilename=$(echo $3 | grep -Poh --color=never "\w(\w|[.-])+$")
    cp $3 ~/CONFIGRA/$2/$cleanfilename
    rm $3
    ln -s -r ~/CONFIGRA/$2/$cleanfilename $3
    
    touch ~/CONFIGRA/$2/configrainstall.sh
    installcontent=$(more ~/CONFIGRA/$2/configrainstall.sh)
    if [[ "$installcontent" == "" ]]; then
        echo '#!/bin/bash
#
# This script will be executed, everytime you do "configra install"
# Its a normal bash-script, so feel free to modify it
#' > ~/CONFIGRA/$2/configrainstall.sh
    fi
    
    echo "# $cleanfilename" >> ~/CONFIGRA/$2/configrainstall.sh

    linkpath=""
    me=$(whoami)
    fullpath=$(pwd | grep -Poh --color=never "(/home/$me)")
    if [[ "$fullpath" != "" ]]; then
        fullpath=~$(pwd | grep -Poh --color=never "(?<=(/home/$me))(/(\w|\d|[.-_])+)*")
        linkpath=~$(pwd | grep -Poh --color=never "(?<=(/home/$me))(/(\w|\d|[.-_])+)*")/$3
    fi
    if [[ "$fullpath" == "" ]]; then
        fullpath=$(pwd)
        linkpath="$(pwd)/$3"
    fi
    
    echo "mkdir -p $fullpath" >> ~/CONFIGRA/$2/configrainstall.sh
    
    echo 'ln -s -r -f ~/CONFIGRA/'"$2/$cleanfilename $linkpath" >> ~/CONFIGRA/$2/configrainstall.sh
    echo "#" >> ~/CONFIGRA/$2/configrainstall.sh
}

function installf () {
    test -e ~/CONFIGRA/$2 || exit
    bash ~/CONFIGRA/$2/configrainstall.sh
}

function list () {
    tree ~/CONFIGRA
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
    *)
        showhelp
    ;;
esac
