# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

# PATH=$PATH:$HOME/bin:$HOME/klockwork/bin:/home/vectorcast

# export PATH

#PS1='\[\e[0;33m\]\h:\W \u\$\[\e[m\] '
# color the ls
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad

# If you are using a black background:
# export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcxexport PATH=/usr/local/sbin:$PATH
#01/16/15 
# Load in the git branch prompt script
#[Put Your Git Branch in Your Bash Prompt - Code Worrier](http://code-worrier.com/blog/git-branch-in-bash-prompt/)
source ~/.git-prompt.sh
#PS1='\[\e[0;33m\]:\W \[\e[m\]$'

# Setting PATH for Python 2.7
# The orginal version is saved in .bash_profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/2.7/bin:${PATH}"
export PATH

#THIS MUST BE AT THE END OF THE FILE FOR GVM TO WORK!!!
[[ -s "/Users/schakkere/.gvm/bin/gvm-init.sh" ]] && source "/Users/schakkere/.gvm/bin/gvm-init.sh"
