#!/bin/bash

# ..         mh         g               d                ext
# l          mrc        gk              unrpm
# ll         med        br              clean_cmake
# dev        mopt       gpom            clean_LINUX
# up                    glog            clean_orig
# findby                grb
#                       gp
#                       gpush
#                       gcheck
#                       grebase
#                       retag, deltag


# Configuration.
# ==============================================================================

export HISTSIZE=20000

#  General aliases and functions.
# ==============================================================================

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias l='ls -L'
alias ll="ls -lhA"
alias dev='cd ~/dev'

function up {     # Up N directories.
    LIMIT=$1
    P=$PWD
    for ((i=1; i <= LIMIT; i++))
    do
        P=$P/..
    done
    cd $P
    export MPWD=$P
}

function findby {  # Find all files with specified string.
    grep -r "$1" .
}


#  CMAKE related commands
# ==============================================================================

alias mh='make help'
alias mrc='make rebuild_cache'
alias med='make edit_cache'
alias mopt='make BUILD_TYPE=opt'


#  GIT related commands
# ==============================================================================

alias g='git gui'
alias gk='gitk --all'
alias br='git branch -a'
alias glog='git log --pretty=format:"%H - %an, %ar : %s"'
alias grb='grb1.9'
alias gp='git pull'
alias gpt='git push --tags'
alias grpo='git remote prune origin'

function gpush {     # Push current branch
    branch=$(git rev-parse --abbrev-ref HEAD)
    echo "Pushing branch '${branch}'..."
    git push origin $branch
}

function gcheck {    # Checkout remote branch, $1 = branch_name
    git checkout -t -b $1 origin/$1
}

function grebase {
    git stash
    git pull --rebase
    git stash pop
}

function retag {     # Remove the old tag and create a new one
    echo "Retagging '${1}'..."
    git tag -d $1 
    git push origin :refs/tags/$1
    git tag $1
    git push --tags
}

function deltag {    # Delete tag, $1 = tag_name
    echo "Deleting tag '${1}'..."
    git tag -d $1 
    git push origin :refs/tags/$1
}


#  Custom functions
# ==============================================================================

function d {         # run gdb with the full executable and its args.
    gdb --args "$@"
}

function nospace {
    sed -i 's/[ \t]*$//' "$1"
}

function unrpm {     # Extract rpm into the curren folder
    rpm2cpio $1 | cpio -idmv
}

function ntpsync {   # Resynchronize system clock.
    sudo service ntp stop
    sudo ntpdate -s time.nist.gov
    sudo service ntp start
}

function clean_cmake {
    rm -rf `find . -type d -name CMakeFiles`
    rm -rf `find . -name CMakeCache.txt`
    rm -rf `find . -name *.cmake`
}

function clean_LINUX {
    rm -rf `find . -type d -name Linux`
}

function clean_orig {
    rm -rf `find -iname *.orig`
}

function mountnas()
{
    sudo mount 192.168.1.100:/volume1/alpha /nas/alpha  
    sudo mount 192.168.1.100:/volume2/beta /nas/beta
    sudo mount 192.168.1.100:/volume4/delta /nas/delta
}


# Big functions
# ==============================================================================

function repeat {   # Repeat a following command N times.
    number=$1
    shift
    for n in $(seq $number); do
        echo "repeat: ${n}"
        $@
        if [ $? -ne 0]; then
            echo "ERROR"
            return 1
        fi
    done
}

function ext {
 if [ -z "$1" ]; then
    # display usage if no parameters given
    echo "Usage: ext <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|tar.bz2|tar.gz|tar.xz>"
 else
    if [ -f $1 ] ; then
        # NAME=${1%.*}
        # mkdir $NAME && cd $NAME
        case $1 in
          *.tar.bz2)   tar xvjf ../$1    ;;
          *.tar.gz)    tar xvzf ../$1    ;;
          *.tar.xz)    tar xvJf ../$1    ;;
          *.lzma)      unlzma ../$1      ;;
          *.bz2)       bunzip2 ../$1     ;;
          *.rar)       unrar x -ad ../$1 ;;
          *.gz)        gunzip ../$1      ;;
          *.tar)       tar xvf ../$1     ;;
          *.tbz2)      tar xvjf ../$1    ;;
          *.tgz)       tar xvzf ../$1    ;;
          *.zip)       unzip ../$1       ;;
          *.Z)         uncompress ../$1  ;;
          *.7z)        7z x ../$1        ;;
          *.xz)        unxz ../$1        ;;
          *)           echo "extract: '$1' - unknown archive method" ;;
        esac
    else
        echo "$1 - file does not exist"
    fi
fi
}
