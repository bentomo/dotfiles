#!/usr/bin/env bash
# Send stdin as OSC 52 clipboard data directly to the outer terminal's TTY.
# Bypasses tmux's set-clipboard/Ms re-emit path entirely — avoids all terminfo,
# terminal-features, and option-scope issues. Works as long as the outer
# terminal (WezTerm) handles OSC 52, which it does natively.
TTY=$(tmux display-message -p '#{client_tty}' 2>/dev/null)
[[ -z "$TTY" ]] && exit 1
printf '\033]52;c;%s\007' "$(base64 -w0)" > "$TTY"
