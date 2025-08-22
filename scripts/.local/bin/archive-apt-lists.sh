#!/bin/bash

# ================================
# archive-apt-lists.sh
# Архивация файлов apt-packages по дате
# ================================

# Цвета для лога
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
BLUE="\e[34m"
RESET="\e[0m"

# Директория бэкапов
BACKUP_DIR="$HOME/.backups"

# Дата из аргумента или сегодняшняя
DATE=${1:-$(date +%F)}

# Файлы для архивации
FILES=$(ls "$BACKUP_DIR"/apt-packages-"$DATE".list "$BACKUP_DIR"/apt-packages-detailed-"$DATE".list 2>/dev/null)

# Имена архивов
TAR_ARCHIVE="$BACKUP_DIR/apt-packages-$DATE.tar.gz"
ZIP_ARCHIVE="$BACKUP_DIR/apt-packages-$DATE.zip"

# --- Лог функции ---
log() {
    echo -e "${BLUE}[INFO]${RESET} $1"
}

ok() {
    echo -e "${GREEN}[OK]${RESET} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${RESET} $1"
}

error() {
    echo -e "${RED}[ERROR]${RESET} $1"
}

# --- Основная логика ---
if [ -z "$FILES" ]; then
    error "Нет файлов для даты $DATE в $BACKUP_DIR"
    exit 1
fi

log "Найдены файлы для даты $DATE:"
echo "$FILES"

# Создание tar.gz
log "Создание архива $TAR_ARCHIVE..."
if tar -czf "$TAR_ARCHIVE" -C "$BACKUP_DIR" $(basename -a $FILES); then
    ok "Создан: $TAR_ARCHIVE"
else
    error "Ошибка при создании $TAR_ARCHIVE"
fi

# Создание zip
log "Создание архива $ZIP_ARCHIVE..."
if zip -j "$ZIP_ARCHIVE" $FILES >/dev/null; then
    ok "Создан: $ZIP_ARCHIVE"
else
    error "Ошибка при создании $ZIP_ARCHIVE"
fi

ok "Архивация завершена!"
