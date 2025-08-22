Если будут вопросы по bspwm, polybar, rofi, автозапуску, темам или даже по созданию своего lock-скрипта — всегда можешь обратиться.

Удачи с настройкой системы! 🧠⚙️
(И не забывай делать бэкапы конфигов 😉)

Хочешь — могу позже помочь собрать единый dotfiles-репозиторий на GitHub.


---



📌 Что ещё можно сделать:
🔐 Ещё больше безопасности:

    Проверка прав: убедись, что скрипт не выполняется от root без нужды.

    Проверка, активен ли SSH (если на сервере).

    Ведение лога действий — полезно для отладки и истории (например, в ~/.local/share/power-menu.log).

Пример логгера:

log_action() {
  echo "$(date): $1" >> "$HOME/.local/share/power-menu.log"
}

🎛 Возможности для расширения:

    Hibernate, Lock, Suspend позже можно просто добавить.

    Выбор пользователя для logout (если мульти-пользовательская система).

    Разные действия для разных DE (Wayland/X11).

    Настройка горячих клавиш через sxhkd или i3/config.


----

```


#!/usr/bin/env bash

# Опции с иконками (формат: "иконка label")
options=(
  "  Lock"
  "  Logout"
  "  Suspend"
  "  Reboot"
  "  Shutdown"
)

# Функция для запуска безопасно
run_command() {
  if command -v "$1" >/dev/null 2>&1; then
    "$@"
  else
    notify-send "Error" "Command not found: $1"
    exit 1
  fi
}

# Показываем меню
choice=$(printf '%s\n' "${options[@]}" | rofi -dmenu -p "Power" -theme-str 'window {width: 300;}' -i)

# Выделим только текст без иконки (вторая часть)
action=$(echo "$choice" | awk '{print $2}')

case "$action" in
  Lock)
    run_command "$HOME/bin/screen-lock"
    ;;
  Logout)
    pkill -KILL -u "$USER"
    ;;
  Suspend)
    systemctl suspend && run_command "$HOME/bin/screen-lock"
    ;;
  Reboot)
    systemctl reboot
    ;;
  Shutdown)
    systemctl poweroff
    ;;
  *)
    # Пустой выбор или неизвестное действие
    exit 0
    ;;
esac

```
