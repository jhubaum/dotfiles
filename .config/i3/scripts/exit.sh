#!/bin/bash

#!/bin/sh
lock() {
    if ! (pgrep i3lock)
    then
        scrot --overwrite /tmp/screensaver.png
        convert /tmp/screensaver.png -blur 0x5 /tmp/screensaver.png
        i3lock -i /tmp/screensaver.png -e -f
    fi
}

case "$1" in
    lock)
        lock
        ;;
    logout)
        i3-msg exit
        ;;
    suspend)
        lock && systemctl suspend
        ;;
    hibernate)
        lock && systemctl hibernate
        ;;
    reboot)
        systemctl reboot
        ;;
    shutdown)
        systemctl poweroff
        ;;
    *)
        echo "Usage: $0 {lock|logout|suspend|hibernate|reboot|shutdown}"
        exit 2
esac

exit 0
