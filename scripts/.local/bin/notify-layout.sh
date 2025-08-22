#!/usr/bin/env bash

# Получаем текущую раскладку (из xkb)
layout=$(setxkbmap -query | awk '/layout/ {print $2}')
variant=$(setxkbmap -query | awk '/variant/ {print $2}')

# Определяем отображаемое имя
case "$layout" in
  us) symbol="🇺🇸 EN" ;;
  ru) symbol="🇷🇺 RU" ;;
  ua) symbol="🇺🇦 UA" ;;
  *)  symbol="⌨️ $layout" ;;
esac

# Добавляем вариант (если есть)
[ -n "$variant" ] && symbol="$symbol ($variant)"

# Показываем уведомление через dunst
notify-send "Раскладка клавиатуры" "$symbol" -t 1500 -u low
