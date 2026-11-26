#!/usr/bin/env bash

# get list of devices and select one via fuzzel
# SELECTED=$(wpctl status | sed -n '/Sinks:/,/Sources:/p' |  grep '[0-9]\+\.' | wmenu -ip "output audio device")
SELECTED=$(wpctl status | sed -n '/Sinks:/,/Sources:/p' |  grep '[0-9]\+\.' | fuzzel -dp "output audio device" --log-level=error -w 80)+


# get selected device ID
ID=$(echo $SELECTED | grep -oP '[0-9]+' | head -n 1)

echo $ID

# ask wpctl to set the device as defalut sink
if [ ! -z "$ID" ]; then
    wpctl set-default $ID
fi
