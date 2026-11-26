#!/usr/bin/env bash

warning=10

# Get minutes from argument or user input
if [ -z "$1" ]; then
    read -p "Enter number of minutes for the timer: " minutes
else
    minutes="$1"
fi

if ! [[ "$minutes" =~ ^[0-9]+$ ]]; then
    echo "Error: Minutes must be a positive integer."
    exit 1
fi

# Function to beep using SoX
function beep {
    if command -v play >/dev/null 2>&1; then
        play -nq -t alsa synth 0.1 sine 440
        sleep 0.1
    else
        echo "\aTime's up! (SoX 'play' command not found)"
    fi
}
function time_up {
    echo -e "\nTime's up!"
}
# Countdown timer function
function timer {
    local add=0


    [[ $2 == "-a" ]] && add=10
    local mins="$1"
    local seconds=$((mins * 60))

    while [ $seconds -gt 0 ]; do
        local m=$((seconds / 60 + add))
        local s=$((seconds % 60))
        printf "\rTime left: %02d:%02d " $m $s
        sleep 1
        seconds=$((seconds - 1))
    done
}

# Timer with 10-minute warning
function ten_min_warning_timer {

    local remaining=$((minutes - 10))
    if [ $remaining -gt 0 ]; then
        echo "Countdown: minutes (with 10-min to finish warning)";
        timer $remaining -a;
        beep;
    fi

    echo "10 min left"
    timer 10
    time_up
}

# Main logic
if [ $minutes -gt 24 ]; then
    ten_min_warning_timer;
    beep; beep; beep;
else
    timer $minutes
    time_up
    beep; beep; beep;
fi
