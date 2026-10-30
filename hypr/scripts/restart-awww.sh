#!/bin/sh

if pgrep -x "awww-daemon" > /dev/null 
then
    killall awww-daemon
fi

awww-daemon --no-cache --format xrgb &
awww img $1 --transition-type grow --transition-pos "$(hyprctl cursorpos)" --transition-duration 3
