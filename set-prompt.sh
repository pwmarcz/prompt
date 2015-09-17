#!/bin/bash

PATH_CMD="$(dirname $0)/path.sh"
PROMPT_CMD="$(dirname $0)/prompt.sh"

if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    color_prompt=yes
else
    color_prompt=
fi

WHITE="\[\033[1;37m\]"
GRAY="\[\033[0;37m\]"
RED="\[\033[1;31m\]"
BLUE="\[\033[1;34m\]"
GREEN="\[\033[1;32m\]"
NO_COLOR="\[\033[0m\]"

if [ "$color_prompt" = yes ]; then
  #PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
  #PS1="$BLUE\u $GREEN\h $WHITE\`$PATH_CMD\` $ $NO_COLOR"
  PROMPT_COMMAND="PS1=\$(EXIT_CODE=\$?; stty -echo; $PROMPT_CMD \$EXIT_CODE; stty echo)"
  PS2="$BLUE> $NO_COLOR"
else
  PS1="\u@\h \`$PATH_CMD\` $ "
  #PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt

case "$TERM" in
xterm*|rxvt*)
    #PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
     PS1="\[\e]0;\`$PATH_CMD\`\a\]$PS1"
    show_command_in_title_bar()
    {
        case "$BASH_COMMAND" in
            *\033]0*)
                ;;
            *my-prompt*)
                ;;
            *)
                echo -ne "\e]0;${BASH_COMMAND} [`$PATH_CMD`]\007"
                ;;
        esac
    }
    trap show_command_in_title_bar DEBUG
    ;;
*)
    ;;
esac
