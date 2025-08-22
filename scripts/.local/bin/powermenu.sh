#!/usr/bin/env bash

# Настройки
LOCK_SCRIPT="$HOME/bin/screen-lock"

# Проверки
command -v rofi >/dev/null 2>&1 || { echo "Ошибка: rofi не найден."; exit 1; }
command -v systemctl >/dev/null 2>&1 || { echo "Ошибка: systemctl не найден."; exit 1; }

# Выбор действия
choice=$(printf "Lock\nLogout\nSuspend\nReboot\nShutdown" | rofi -dmenu -p "Выберите действие:")

# Проверка отмены
[ -z "$choice" ] && exit 0

# Основной блок действий
case "$choice" in
  Lock)
    if [ -x "$LOCK_SCRIPT" ]; then
      bash "$LOCK_SCRIPT"
    else
      echo "Скрипт блокировки не найден или не исполняемый: $LOCK_SCRIPT" >&2
      exit 1
    fi
    ;;
  Logout)
    # Предпочтительнее использовать лог-аут через десктоп-менеджер, если возможно.
    if command -v loginctl >/dev/null; then
      loginctl terminate-user "$USER"
    else
      pkill -KILL -u "$USER"
    fi
    ;;
  Suspend)
    if systemctl suspend; then
      sleep 1
      [ -x "$LOCK_SCRIPT" ] && bash "$LOCK_SCRIPT"
    else
      echo "Ошибка при переходе в спящий режим." >&2
    fi
    ;;
  Reboot)
    systemctl reboot
    ;;
  Shutdown)
    systemctl poweroff
    ;;
  *)
    echo "Неизвестный выбор: $choice" >&2
    exit 1
    ;;
esac

