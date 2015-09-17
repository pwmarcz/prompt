#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 exitcode"
    exit 1
fi

EXIT_CODE=$1

WHITE="\[\e[1;37m\]"
GRAY="\[\e[0;37m\]"
RED="\[\e[1;31m\]"
YELLOW="\[\e[1;33m\]"
BLUE="\[\e[1;34m\]"
GREEN="\[\e[1;32m\]"
NO_COLOR="\[\e[0m\]"

PATH_STR=$($(dirname $0)/path.sh)

PROMPT=""
PROMPT+="$BLUE`whoami` "

HOSTNAME_PART=""
if [[ "$SSH_CLIENT" != "" ]]; then
    HOSTNAME_PART="(`hostname`) "
    PROMPT+="$BLUE$HOSTNAME_PART "
fi
#PROMPT+="$GRAY`date +%H:%m` "

#source `dirname $0`/git-prompt.sh
#PROMPT+="$GRAY"
#export GIT_PS1_SHOWDIRTYSTATE=true
#export GIT_PS1_SHOWSTASHSTAT=true
#export GIT_PS1_SHOWUNTRACKEDFILES=true
#export GIT_PS1_SHOWCOLORHINTS=true
#PROMPT="`__git_ps1 \"$PROMPT\" \"\" \"[%s]\"; echo $PS1` "

BRANCH="`git rev-parse --symbolic-full-name --abbrev-ref HEAD 2>/dev/null`"
UPSTREAM="`git rev-parse --symbolic-full-name --abbrev-ref '@{upstream}' 2>/dev/null`"

if [ -n "$BRANCH" ] && [[ $(git rev-parse --is-inside-work-tree) == true ]]; then
    DETECT_CHANGES=1
fi

if [ -n "$BRANCH" ]; then
    if [ -n "$DETECT_CHANGES" ]; then
        BRANCH_DESC="$GREEN$BRANCH"
        STATUS="$(git status --porcelain)"
        MODIFIED="$(grep -v '^?' <<<"$STATUS")"
        NEW="$(grep '^?' <<<"$STATUS")"
        if [ "$MODIFIED" ]; then
            BRANCH_DESC="$YELLOW$BRANCH*"
        fi
        if [ "$NEW" ]; then
            BRANCH_DESC="$BRANCH_DESC+"
        fi
    else
        BRANCH_DESC="$GRAY$BRANCH"
    fi

    if [ -n "$UPSTREAM" ]; then
        COUNTS="`git rev-list --count --left-right $UPSTREAM...$BRANCH 2>/dev/null`"
        case "$COUNTS" in
            "") BRANCH_STATUS="" ;;
            "0	0") BRANCH_STATUS="$GREEN=" ;;
            "0	"*) BRANCH_STATUS="$YELLOW>" ;;
            *"	0") BRANCH_STATUS="$BLUE<" ;;
            *) BRANCH_STATUS="$RED<>" ;;
        esac
    fi

    PROMPT+="$GRAY[$BRANCH_STATUS$BRANCH_DESC$GRAY] "
fi

if [ $EXIT_CODE -ne 0 ]; then
    PROMPT+="$GRAY[$RED$EXIT_CODE$GRAY] "
fi

#PROMPT+="\n"
PROMPT+="$WHITE$PATH_STR "

PROMPT+="$WHITE\$ "
PROMPT+="$NO_COLOR"

# Terminal window title

case "$TERM" in
xterm*|rxvt*)
    PROMPT="\[\e]0;$HOSTNAME_PART$PATH_STR\a\]$PROMPT"
    ;;
*)
    ;;
esac

# disabled
# [0G - beginnning of line
# [0K - clear line
# PROMPT="\[\e[0G\e[0K\]$PROMPT"

echo -ne $PROMPT
