[[ -f /etc/bashrc ]] && . /etc/bashrc
[[ -f "$HOME/.bash_profile_env" ]] && . "$HOME/.bash_profile_env"

# Function to resolve soft links
function delink()
{
  f=$1
  while [[ -h "$f" ]]; do
    ls=`ls -ld "$f"`
    link=`expr "$ls" : '.*-> \(.*\)$'`
    if expr "$link" : '/.*' > /dev/null; then f="$link"
    else f=`dirname "$f"`/"$link"
    fi
  done
  echo $f
}

# General Settings
export DOTFILES=$(dirname `delink ~/.bashrc` )
export PATH="/usr/local/sbin:/usr/local/bin:/opt/local/bin:/Developer/usr/bin:/usr/sbin:/usr/bin:$PATH:/opt/bin:/opt/local/bin"
export PATH="$HOME/bin:$DOTFILES/bin:$PATH"
export PWD_LENGTH=50
set -o notify
shopt -s cdspell >/dev/null 2>&1
shopt -s checkwinsize >/dev/null 2>&1
shopt -s dotglob >/dev/null 2>&1
shopt -s extglob >/dev/null 2>&1
shopt -s hostcomplete >/dev/null 2>&1
shopt -s interactive_comments >/dev/null 2>&1
shopt -u mailwarn >/dev/null 2>&1
shopt -s no_empty_cmd_completion >/dev/null 2>&1
bind Space:magic-space

BASE16_SCHEME="tomorrow"
BASE16_SHELL="$DOTFILES/base16-shell/base16-$BASE16_SCHEME.dark.sh"
[[ -s $BASE16_SHELL ]] && . $BASE16_SHELL

# Bash History
export HISTIGNORE="&:ls:ll:la:l.:pwd:exit:clear"
export HISTCONTROL=ignoreboth
export HISTSIZE=1000
# never ending history file
export HISTFILESIZE=""
shopt -s histappend >/dev/null 2>&1

# NVM
[[ -s $HOME/.nvm/nvm.sh ]] && source $HOME/.nvm/nvm.sh

# SSH specific config.
if [[ -n "$SSH_CLIENT" ]]; then
  # show host only if this is an ssh session
  ps1_host="\[\e[01;32m\]\h"
fi

USER_NAME="Holger Just"
USER_EMAIL="web@meine-er.de"

# Only if we are in an interactive session
if [[ $- =~ 'i' ]]; then
  # Disable XON/XOFF flow control (^s/^q).
  stty -ixon
fi

if [[ -d "$DOTFILES/bash_completion.d" ]]; then
  for i in $DOTFILES/bash_completion.d/*; do
    if [[ -r "$i" ]]; then
      . "$i"
    fi
  done
  unset i
fi

# OS specific config.
case `uname` in
  Darwin)
    export JAVA_HOME="/System/Library/Frameworks/JavaVM.framework/Versions/1.6/Home"

    export EDITOR="vim"
    export BACKGROUND_EDITOR="subl -n"
    export SVN_EDITOR="$EDITOR"

    alias ls='ls -G'

    export PG_DATA=/usr/local/var/postgres

    gitx() { open -a GitX $@; }
    alias gx=gitx
    pdfman() { man -t $1 | open -a /Applications/Skim.app -f; }

    # Bash completion
    if [[ -f "$(brew --prefix)/etc/bash_completion" ]]; then
      . "$(brew --prefix)/etc/bash_completion"
    fi

    # Set the JAVA_HOME environment variable to the correct versob
    jhome() {
      if [ "$#" -ge 1 ]; then
        export JAVA_HOME="$(/usr/libexec/java_home -v "$@")"
      else
        export JAVA_HOME="$(/usr/libexec/java_home)"
      fi
      echo "JAVA_HOME:" "$JAVA_HOME"
      java -version
    }

    ;;
  Linux)
    PATH=$PATH:/var/lib/gems/1.8/bin:/var/lib/gems/1.9/bin
    alias ls='ls --color=auto'

    # enable bash completion in interactive shells
    if [[ -f /etc/bash_completion ]]; then
        . /etc/bash_completion
    fi
    ;;
  SunOS)
    stty istrip
    export PATH=/opt/csw/bin:/opt/sfw/bin:$PATH:/etc

    if [[ -f /etc/bash_completion ]]; then
        . /etc/bash_completion
    fi

    # home key
    bind '"\e[1~":beginning-of-line'
    # del key
    bind '"\e[3~":delete-char'
    # end key
    bind '"\e[4~":end-of-line'
    # pgup key
    bind '"\e[5~":history-search-forward'
    # pgdn key
    bind '"\e[6~":history-search-backward'
    ;;
  *) echo "OS unknown to bashrc." ;;
esac

# Load RVM
if [[ -s $HOME/.rvm/scripts/rvm ]]; then
  source $HOME/.rvm/scripts/rvm
  # tab completion for RVM
  [[ -r $rvm_path/scripts/completion ]] && . $rvm_path/scripts/completion
  PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
fi

# setting up editor if not yet done
[[ -z "$EDITOR" ]] && EDITOR="nano"
[[ -z "$SVN_EDITOR" ]] && SVN_EDITOR="$EDITOR"

# Appliction config
export PLANIO_SKIP_AMA=1

# Don't show user name if it's me. make root red.
case $USER in
  hjust) ;;
  *)
    case $UID in
      0) ps1_user="\[\e[01;31m\]\u" ;;
      *) ps1_user="\[\e[01;32m\]\u" ;;
    esac
esac

ps1_host='\h'

. $HOME/bin/bash_vcs.sh
ps1_vcs='$(__prompt_command)'
ps1_ruby=' \[\e[0;34m\]$(rvm-prompt v g)\[\e[00m\]'

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi
PS1="${debian_chroot:+($debian_chroot)}"

# Short PWD, if it's to long.
short_pwd() {
  FIXED_PWD="${PWD/#$HOME/~}"
  if [[ ${#FIXED_PWD} -gt $PWD_LENGTH ]]; then
    echo "${FIXED_PWD:0:$((4))}...${FIXED_PWD:$((${#PWD}-$PWD_LENGTH+7)):$(($PWD_LENGTH-7))}"
  else
    echo "$FIXED_PWD"
  fi
}
ps1_pwd='$(short_pwd)'
#ps1_pwd='\[\e[1;30m\]\W\[\e[00m\]'

# Building $PS1.
if [[ -n "$ps1_user" ]] && [[ -n "$ps1_host" ]]; then ps1_user="$ps1_user@"; fi
PS1="$ps1_user$ps1_host"
if [[ "$PS1" != "" ]]; then PS1="$PS1\[\e[00m\]:"; fi
export PS1="$PS1$ps1_pwd$ps1_vcs$ps1_ruby \$ "


# Make less more friendly for non-text input files, see lesspipe(1)
[[ -x /usr/bin/lesspipe ]] && eval "$(lesspipe)"

# Enable color support. Don't add ls here, it behaves different on Darwin/BSD.
if [[ -x /usr/bin/dircolors ]]; then eval "$(dircolors -b)"; fi
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Some more aliases.
alias ll='ls -Alh'
alias la='ls -A'
alias l='ls -CF'
alias l.="ls -d .*"
alias pdflatex='pdflatex -shell-escape'
alias vi='vim'
alias screen='screen -U'
alias use='rvm use'
alias gems='gem list | less'
alias less='less -R'

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

alias g=git
complete -o default -o nospace -F _git g
alias got='git'
alias goit='git'
alias gsvn='git svn'
alias gdiff='git diff'
alias st='git st'
alias log='git lg'
alias ciam='git ci -am'
alias cia='git ci -a'
alias ga='git add -p'
ghead() { git rev-parse --verify "${1:-HEAD}"; }

alias be="bundle exec"
alias rs="rails server -b 127.0.0.1"
alias rc="rails console"

ss() { if [[ -x script/server ]]; then script/server -b 127.0.0.1 $@; else rs $@; fi }
sc() { if [[ -x script/console ]]; then script/console $@; else rc $@; fi }
http() {
  port=${1:-8000}
  python -m SimpleHTTPServer $port
}

# if cat is called on a directory, call ls instead
cat() {
  if [[ $# = 1 ]] && [[ -d $1 ]]; then
    ls "$1"
  else
    /usr/bin/env cat "$@"
  fi
}

mc() {
  mkdir "$@" && cd "$@"
}

# directory for project
project_dirs() {
  local dirs="__path__:$HOME/workspace/__path__:$HOME/__path__:/Volumes/Finn/__path__:$GEM_HOME/gems/__gempath__:$GEM_HOME/gems/__path__:$GEM_HOME/bundler/gems/__gempath__:$GEM_HOME/bundler/gems/__path__"
  if [[ -n "$1" ]]; then
    dirs="${dirs//__gempath__/__path__-*}"
    echo  ${dirs//__path__/$1}
  else
    dirs="${dirs//\/__gempath__/}"
    echo  ${dirs//\/__path__/}
  fi
}

d() {
  local dirs="$(project_dirs "$1")"
  local IFS=$':'
  local dir
  for dir in $dirs; do
    if [[ -d "$dir" ]]; then
      echo $dir
      break
    fi
  done
}

# do stuff with project
with_project() {
  local target=$(d "$1")
  if [[ $target ]]; then
    echo -e "\033[0;34m$2 $target\033[00m"
    $2 "$target"
  else
    echo "unknown project"
  fi
}

# cd to project
c() { with_project "$1" cd; }

# open project in editor
e() { with_project "${1:-.}" "$BACKGROUND_EDITOR"; }

# Enable programmable completion features.
if [[ -f /etc/bash_completion ]]; then . /etc/bash_completion; fi
if [[ -f ~/.tabtab.bash ]]; then . ~/.tabtab.bash; fi
set show-all-if-ambiguous on

# bash completion with with_project and functions using it
_with_project() {
  local CDPATH="$(project_dirs):$CDPATH"
  _cd
}

if shopt -q cdable_vars; then
  complete -v -F _with_project -o nospace c e with_project
else
  complete -F _with_project -o nospace c e with_project
fi

# Clean up.
unset ps1_user ps1_host ps1_vcs ps_ruby ps1_pwd ps1_ruby script this dir bin
