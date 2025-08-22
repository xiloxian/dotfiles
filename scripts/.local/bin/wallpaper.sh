#!/bin/bash

# ===========================
# Wallpaper Randomizer Script
# ===========================

export DISPLAY=:0
export XAUTHORITY="$HOME/.Xauthority"

set -euo pipefail

WALLPAPER_DIR="$HOME/.config/Images"
QUEUE_FILE="$HOME/.cache/wallpaper_queue.txt"
LOG_FILE="$HOME/.cache/wallpaper.log"

# Проверка: директория с обоями существует?
if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "[$(date)] ERROR: Wallpaper directory not found: $WALLPAPER_DIR" >> "$LOG_FILE"
    notify-send "Wallpaper Error" "Directory not found: $WALLPAPER_DIR"
    exit 1
fi

# Проверка: есть ли изображения?
IMAGE_COUNT=$(find "$WALLPAPER_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' \) | wc -l)
if [ "$IMAGE_COUNT" -eq 0 ]; then
    echo "[$(date)] ERROR: No image files found in $WALLPAPER_DIR" >> "$LOG_FILE"
    notify-send "Wallpaper Error" "No images found in $WALLPAPER_DIR"
    exit 1
fi

# Создание новой очереди, если пусто
if [ ! -s "$QUEUE_FILE" ]; then
    find "$WALLPAPER_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' \) | shuf > "$QUEUE_FILE"
    echo "[$(date)] INFO: New wallpaper queue created." >> "$LOG_FILE"
fi

# Чтение следующего обоя
NEXT_WALLPAPER=$(head -n 1 "$QUEUE_FILE")

# Проверка: существует ли файл
if [ ! -f "$NEXT_WALLPAPER" ]; then
    echo "[$(date)] WARNING: File not found: $NEXT_WALLPAPER. Skipping..." >> "$LOG_FILE"
    # удаляем и переходим к следующему вызову
    tail -n +2 "$QUEUE_FILE" > "$QUEUE_FILE.tmp" && mv "$QUEUE_FILE.tmp" "$QUEUE_FILE"
    exit 0
fi

# Установка обоев
feh --bg-fill "$NEXT_WALLPAPER" && \
    echo "[$(date)] Wallpaper set: $NEXT_WALLPAPER" >> "$LOG_FILE"

# Удаляем использованный обой
tail -n +2 "$QUEUE_FILE" > "$QUEUE_FILE.tmp" && mv "$QUEUE_FILE.tmp" "$QUEUE_FILE"

# Отправка уведомления
# if command -v notify-send >/dev/null; then
#    notify-send " Wallpaper Updated" "$(basename "$NEXT_WALLPAPER")"
# fi

