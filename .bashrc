# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

#06/14/12 
alias grepc='/bin/grep --color=always' 

#06/17/12 
#add a function to search a string in cpp an h
#file ignoring hxx, cxx file and svn dir
#with color highlighting
function findstri()
{
    echo $1
    echo "**********************************************************************"
    #grep dont match binary file (-I)
    #/bin/find . -type f -print |grep -v svn|grep -v tags |xargs grep -n "${@:2}" -i -I --color=auto $1
    #grep and friends detect whether output is to a terminal. When piped to less, it isn't, so they disable colouring.
    #use it with less -r or -R or -SR
    #/bin/find . -type f -print |grep -v svn|grep -v tags |xargs grep -n "${@:2}" -i -I --color=always $1
    #for mac
    #grep $1  -rin "${@:2}"  --include=\*.{cpp,h} --color=auto .
    grep $1  -rinI "${@:2}"  --include=\*.* --color=auto .
    echo "**********************************************************************"
}

function findstr()
{
    #echo $1
    echo "**********************************************************************"
    #grep dont match binary file (-I)
    #/bin/find . -type f -print |grep -v svn|grep -v tags |xargs grep -n -I "${@:2}" --color=auto $1
    #/bin/find . -type f -print |grep -v svn|grep -v tags |xargs grep -n -I "${@:2}" --color=always $1
    #for mac
    # I is ignore nbinary
    #grep $1  -rnI "${@:2}"  --include=\*.{cpp,h} --color=auto .
    grep $1  -rnI "${@:2}"  --include=\*.* --color=auto .
    echo "**********************************************************************"
}

function extract()      # Handy Extract Program.
{
     if [ -f $1 ] ; then
         case $1 in
             *.tar.bz2)   tar xvjf $1     ;;
             *.tar.gz)    tar xvzf $1     ;;
             *.bz2)       bunzip2 $1      ;;
             *.rar)       unrar x $1      ;;
             *.gz)        gunzip $1       ;;
             *.tar)       tar xvf $1      ;;
             *.tbz2)      tar xvjf $1     ;;
             *.tgz)       tar xvzf $1     ;;
             *.zip)       unzip $1        ;;
             *.Z)         uncompress $1   ;;
             *.7z)        7z x $1         ;;
             *)           echo "'$1' cannot be extracted via >extract<" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
}
#06/20/12 
# This will list all the cpp and h files in a subdir
# It excludes cxx,hxx and svn subdir
function listfiles()
{
#echo $1
/usr/bin/find . -type f -print |grep -v svn|grep -v cxx| grep -v hxx
}

#alias ll="ls -l --group-directories-first"
#alias ls='ls -hF --color'  # add colors for filetype recognition
#alias la='ls -Al'          # show hidden files
#alias lx='ls -lXB'         # sort by extension
#alias lk='ls -lSr'         # sort by size, biggest last
#alias lc='ls -ltcr'        # sort by and show change time, most recent last
#alias lu='ls -ltur'        # sort by and show access time, most recent last
#alias lt='ls -ltr'         # sort by date, most recent last
#alias lm='ls -al |more'    # pipe through 'more'
#alias lr='ls -lR'          # recursive ls
#alias tree='tree -Csu'     # nice alternative to 'recursive ls'
#alias less='less -g -N -SR'    # highlight, line number, color


# Find a file with a pattern in name:
function ff() { find . -type f -iname '*'$*'*' -ls ; }

# Find a file with pattern $1 in name and Execute $2 on it:
function fe()
{ find . -type f -iname '*'${1:-}'*' -exec ${2:-file} {} \;  ; }

# Colors

Black="$(tput setaf 0)"
BlackBG="$(tput setab 0)"
DarkGrey="$(tput bold ; tput setaf 0)"
LightGrey="$(tput setaf 7)"
LightGreyBG="$(tput setab 7)"
White="$(tput bold ; tput setaf 7)"
Red="$(tput setaf 1)"
RedBG="$(tput setab 1)"
LightRed="$(tput bold ; tput setaf 1)"
Green="$(tput setaf 2)"
GreenBG="$(tput setab 2)"
LightGreen="$(tput bold ; tput setaf 2)"
Brown="$(tput setaf 3)"
BrownBG="$(tput setab 3)"
Yellow="$(tput bold ; tput setaf 3)"
Blue="$(tput setaf 4)"
BlueBG="$(tput setab 4)"
LightBlue="$(tput bold ; tput setaf 4)"
Purple="$(tput setaf 5)"
PurpleBG="$(tput setab 5)"
Pink="$(tput bold ; tput setaf 5)"
Cyan="$(tput setaf 6)"
CyanBG="$(tput setab 6)"
LightCyan="$(tput bold ; tput setaf 6)"
NC="$(tput sgr0)" # No Color
# If id command returns zero, you’ve root access.
#if [ $(id -u) -eq 0 ];
#then # you are root, set red colour prompt
#  PS1="\\[$(tput setaf 1)\\]\\u@\\h:\\w #\\[$(tput sgr0)\\]"
#else # normal
#  PS1="[\\w\\u@\\h:] $"
#fi
#07/10/12 
#CDPATH=~/:~/WindRiver/workspace/develop/
#export CDPATH
# makes easy to jump to subfolders
#[Shankar@dasher ~]$ cd cmd
#/home/Shankar/WindRiver/workspace/dev/cmd
#[Shankar@dasher cmd]$ 
# 07/11/12 
# The default editor for gtags-cscope
#CSCOPE_EDITOR=/usr/bin/vim
#export CSCOPE_EDITOR
EDITOR=/usr/bin/vim
export EDITOR
#export VECTORCAST_DIR=/home/Vectorcast/
#export LM_LICENSE_FILE=/home/demo.dat 
#export VECTOR_LICENSE_FILE=40000@192.168.1.6
unset CDPATH
#export CDPATH
export JAVA_HOME=$(/usr/libexec/java_home)
export PATH=${JAVA_HOME}/bin:$PATH
export M2_HOME=/usr/share/maven
export PATH=/usr/local/bin:${M2_HOME}/bin:$PATH
export PATH=$PATH:/Users/schakkere/bin
# Generate password
#usage genpasswd 16
genpasswd() {
    local l=$1
        [ "$l" == "" ] && l=20
        tr -dc A-Za-z0-9_ < /dev/urandom | head -c ${l} | xargs
}
#02/19/14 

#function pdfman() {
#   man -t $@ | pstopdf -i -o /tmp/$1.pdf && open /tmp/$1.pdf
#}
#
## Also always useful - external IP address
#alias ipext='curl -s http://checkip.dyndns.org/ | grep -o [0-9][0-9]*.[0-9][0-9]*.[0-9][0-9]*.[0-9]*'
#pman()
#{
#man -t "${1}" | open -f -a /Appllication/Preview.app
#}
alias mytree="find . -type d | sed -e 1d -e 's/[^-][^\/]*\//--/g' -e 's/^/ /' -e 's/-/|-/'"
function manpdf() {
man -t $@ | open -f -a /Applications/Preview.app/
}
# for Z command
. `brew --prefix`/etc/profile.d/z.sh
#name tab in iterm2
function title {
    #echo -ne "\033]0;"$*"\007"
    DIRNAME=`basename $(pwd)`
    echo -ne "\033]0;"$DIRNAME"\007"
}
#02/19/14 
#for using source-highlight
export LESSOPEN="| /usr/local/Cellar/source-highlight/3.1.7/bin/src-hilite-lesspipe.sh %s"
export LESS=' -RFX '
#use vim as less
alias vless='vim -R -c "set number" -u /usr/share/vim/vim73/macros/less.vim'
#02/20/14 
#for bash completion
if [ -f `brew --prefix`/etc/bash_completion ]; then
     . `brew --prefix`/etc/bash_completion
fi

# pip should only run if there is a virtualenv currently activated
export PIP_REQUIRE_VIRTUALENV=true
# cache pip-installed packages to avoid re-downloading
export PIP_DOWNLOAD_CACHE=$HOME/.pip/cache
# Note there is a mercurial hg
#function hg()
#{
#    history | grep $*;
#}
#export HISTCONTROL=ignoredups
export HISTCONTROL=ignoreboth
# Let gtags use ctags
export GTAGSLABEL=ctags
function usdate() {
date "+DATE: %m/%d/%y%nTIME: %H:%M:%S"
}
# for pandoc: pdflatex not found
export PATH=$PATH:/usr/texbin
