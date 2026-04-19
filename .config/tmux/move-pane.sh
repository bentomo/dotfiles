#!/usr/bin/env bash
# Move the given pane to a user-selected window via fzf popup.
# $1 = source pane ID (e.g. %5)
# $2 = current window to exclude from the list (e.g. mysession:2)
PANE="$1"
CURRENT_WIN="$2"

SEL=$(tmux list-windows -a -F '#{session_name}:#{window_index} [#{window_name}]' \
    | grep -v "^${CURRENT_WIN} " \
    | fzf --no-sort)
[ -z "$SEL" ] && exit 0

TARGET=$(echo "$SEL" | sed 's/ .*//')
tmux join-pane -t "$TARGET" -s "$PANE"
