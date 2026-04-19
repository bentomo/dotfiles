#!/usr/bin/env bash
# fzf tmux paste buffer picker
# Called by tmux with the originating pane ID so paste targets the right pane.
TARGET="$1"

SEL=$(tmux list-buffers -F '#{buffer_name}: #{buffer_sample}' | fzf --no-sort)
[ -z "$SEL" ] && exit 0

NAME=$(echo "$SEL" | sed 's/:.*//')
tmux paste-buffer -b "$NAME" -t "$TARGET"
