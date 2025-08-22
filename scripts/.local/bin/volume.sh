#!/bin/bash

# Script to manage volume (PipeWire via pamixer) and show notifications + update Polybar

# Get current volume
get_volume() {
    pamixer --get-volume
}

# Get mute status
is_muted() {
    pamixer --get-mute
}

# Get appropriate icon based on volume
get_icon() {
    vol=$(get_volume)
    muted=$(is_muted)

    if [[ "$muted" == "true" ]]; then
        echo '/usr/share/icons/Papirus-Dark/symbolic/status/audio-volume-muted-symbolic.svg'
    elif (( vol <= 30 )); then
        echo '/usr/share/icons/Papirus-Dark/symbolic/status/audio-volume-low-symbolic.svg'
    elif (( vol <= 60 )); then
        echo '/usr/share/icons/Papirus-Dark/symbolic/status/audio-volume-medium-symbolic.svg'
    elif (( vol <= 90 )); then
        echo '/usr/share/icons/Papirus-Dark/symbolic/status/audio-volume-high-symbolic.svg'
    else
        echo '/usr/share/icons/Papirus-Dark/symbolic/status/audio-volume-overamplified-symbolic.svg'
    fi
}

# Send dunst notification
notify_volume() {
    vol=$(get_volume)
    icon=$(get_icon)
    muted=$(is_muted)

    if [[ "$muted" == "true" ]]; then
        dunstify -u low --replace=69 -i "$icon" "Mute"
    else
        dunstify -u low --replace=69 -i "$icon" "Volume: ${vol}%"
    fi
}

# Update polybar via polybar-msg (if using module name 'alsa')
update_polybar() {
    polybar-msg hook alsa 1 > /dev/null 2>&1
}

# Volume controls
case "$1" in
    --up)
        pamixer -i 5 --unmute
        notify_volume
        update_polybar
        ;;
    --down)
        pamixer -d 5 --unmute
        notify_volume
        update_polybar
        ;;
    --toggle)
        pamixer --toggle-mute
        notify_volume
        update_polybar
        ;;
    --get)
        get_volume
        ;;
    *)
        echo "Usage: $0 [--up|--down|--toggle|--get]"
        exit 1
        ;;
esac

