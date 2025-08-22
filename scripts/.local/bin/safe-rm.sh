#!/bin/bash

TRASH_DIR="$HOME/.trash"

mkdir -p "$TRASH_DIR"

confirm_delete() {
    read -p "❗ Внимание: удалить '$1' без возможности восстановления? (y/n): " ans
    case "$ans" in
        y|Y) return 0 ;;
        *) echo "Пропущено: $1"; return 1 ;;
    esac
}

if [ "$1" == "--purge" ]; then
    shift
    if [ $# -eq 0 ]; then
        echo "Очистка всей корзины $TRASH_DIR"
        for file in "$TRASH_DIR"/*; do
            [ -e "$file" ] || continue
            if confirm_delete "$(basename "$file")"; then
                rm -rf "$file"
                echo "Удалено: $file"
            fi
        done
    else
        for file in "$@"; do
            target="$TRASH_DIR/$file"
            if [ -e "$target" ]; then
                if confirm_delete "$file"; then
                    rm -rf "$target"
                    echo "Удалено: $target"
                fi
            else
                echo "Нет такого в корзине: $file"
            fi
        done
    fi
    exit 0
fi

# Обычный режим: перемещаем в корзину
for file in "$@"; do
    if [ -e "$file" ]; then
        base_name=$(basename "$file")
        timestamp=$(date +%Y%m%d_%H%M%S)
        mv "$file" "$TRASH_DIR/$base_name.$timestamp"
        echo "Перемещено: $file → $TRASH_DIR/$base_name.$timestamp"
    else
        echo "Файл $file не существует"
    fi
done

