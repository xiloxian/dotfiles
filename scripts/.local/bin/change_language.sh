#!/usr/bin/env bash

CURRENT_LAYOUT=$(setxkbmap -query | awk '/layout/ {print $2}')
ICON_DIR="$HOME/.config/dunst/icons"

if [[ "$CURRENT_LAYOUT" == "us" ]]; then
    setxkbmap ru
    notify-send -a langswitch -c lang -i "$ICON_DIR/translate.png" "RU" "" -u low -t 1000
else
    setxkbmap us
    notify-send -a langswitch -c lang -i "$ICON_DIR/translate.png" "EN" "" -u low -t 1000
fi

