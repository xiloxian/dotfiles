#!/bin/bash

# ================================
# save-apt-list.sh
# Сохранение списка установленных пакетов
# ================================

# Цвета для красивого лога
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
BLUE="\e[34m"
RESET="\e[0m"

# Директория для сохранения
BACKUP_DIR="$HOME/.backups"
DATE=$(date +%F)
FILE_SIMPLE="$BACKUP_DIR/apt-packages-$DATE.list"
FILE_DETAILED="$BACKUP_DIR/apt-packages-detailed-$DATE.list"

# Функция логирования
log() {
    echo -e "${BLUE}[INFO]${RESET} $1"
}

ok() {
    echo -e "${GREEN}[OK]${RESET} $1"
}

error() {
    echo -e "${RED}[ERROR]${RESET} $1"
}

# --- Основная логика ---
log "Проверка директории $BACKUP_DIR..."
mkdir -p "$BACKUP_DIR" && ok "Директория готова: $BACKUP_DIR" || { error "Не удалось создать директорию!"; exit 1; }

log "Сохранение списка вручную установленных пакетов..."
if apt-mark showmanual > "$FILE_SIMPLE"; then
    ok "Файл сохранён: $FILE_SIMPLE"
else
    error "Ошибка при сохранении списка вручную установленных пакетов!"
fi

log "Сохранение подробного списка пакетов с версиями..."
if dpkg-query -f '${binary:Package} ${Version}\n' -W > "$FILE_DETAILED"; then
    ok "Файл сохранён: $FILE_DETAILED"
else
    error "Ошибка при сохранении подробного списка!"
fi

ok "Завершено успешно!"
