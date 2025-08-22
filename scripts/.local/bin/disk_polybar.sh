#!/bin/bash

# Цвета для Polybar
COLOR_OK="#00FF00"    # Зеленый
COLOR_WARN="#FFFF00"  # Желтый
COLOR_CRIT="#FF0000"  # Красный

# Путь к файловой системе (например, корень /)
DISK="/"

# Получаем процент использования и свободное место
USED_PCT=$(df -h "$DISK" | awk 'NR==2 {print $5}' | tr -d '%')
FREE_SPACE=$(df -h "$DISK" | awk 'NR==2 {print $4}')

# Определяем цвет в зависимости от процента использования
if [ "$USED_PCT" -ge 90 ]; then
    COLOR=$COLOR_CRIT
elif [ "$USED_PCT" -ge 70 ]; then
    COLOR=$COLOR_WARN
else
    COLOR=$COLOR_OK
fi

# Вывод для Polybar
echo "%{F$COLOR} $FREE_SPACE (%${USED_PCT})%{F-}"
