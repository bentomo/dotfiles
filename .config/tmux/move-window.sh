#!/usr/bin/env bash
# Move the given window to a user-selected session via fzf popup.
# $1 = source window (e.g. mysession:2)
# $2 = current session to exclude from the list
WINDOW="$1"
CURRENT_SESSION="$2"

SEL=$(tmux list-sessions -F '#{session_name}' \
    | grep -v "^${CURRENT_SESSION}$" \
    | fzf --no-sort)
[ -z "$SEL" ] && exit 0

tmux move-window -t "${SEL}:" -s "$WINDOW"
