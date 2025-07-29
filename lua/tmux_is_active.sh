#!/bin/bash

if [[ -n $TMUX ]]; then
    IFS=',' read -ra tmux_data <<< "$TMUX"
    session_id="${tmux_data[-1]}"
    sessions="$(tmux ls -F "#{session_id}:#{session_attached}")"
    if echo "$sessions" | grep -q "${session_id}:1"; then
        echo 0
        exit
    else
        echo 1
        exit
    fi

fi 

echo 2
