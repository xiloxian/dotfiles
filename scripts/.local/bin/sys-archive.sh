#!/bin/bash
set -euo pipefail

if [[ ! -f /etc/os-release ]]; then
  echo "❌ Ошибка: /etc/os-release не найден. Невозможно определить дистрибутив."
  exit 1
fi


BACKUP_DEST=${1:-}
if [[ -z "$BACKUP_DEST" ]]; then
    echo "❌ Ошибка: нужно указать путь для сохранения бэкапа:"
    echo "👉 Пример: ./backup_system.sh /mnt/usb"
    exit 1
fi

if [[ ! -d "$BACKUP_DEST" || ! -w "$BACKUP_DEST" ]]; then
    echo "❌ Директория $BACKUP_DEST не существует или не доступна для записи."
    exit 1
fi

### --- Конфигурация ---
DATE=$(date +%F)
DISTRO=$(grep '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
BACKUP_DIR="$BACKUP_DEST/${DISTRO}_backup_$DATE"
LOG_FILE="$BACKUP_DIR/backup.log"
EXCLUDES_FILE="$HOME/.backup_excludes"
# TMP_DIR=$(mktemp -d)

declare -a REQUIRED_CMDS=("tar" "sha256sum")

if [[ "$DISTRO" == "arch" ]]; then
  REQUIRED_CMDS+=("pacman")
elif [[ "$DISTRO" == "debian" || "$DISTRO" == "ubuntu" ]]; then
  REQUIRED_CMDS+=("apt-mark")
fi

for cmd in "${REQUIRED_CMDS[@]}"; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "❌ Не найдено: $cmd. Установите перед запуском."
    exit 1
  fi
done

# Проверка прав root (если нужно)
if [[ $EUID -ne 0 ]]; then
   echo "❌ Скрипт должен запускаться с правами root."
   exit 1
fi

declare -A ARCHIVE_PATHS=(
    [home]="/home"
    [etc]="/etc"
    [boot]="/boot"
    [root]="/root"
    [usr-local]="/usr/local"
    [var-log]="/var/log"
)

# Проверка пути назначения
for path in "${ARCHIVE_PATHS[@]}"; do
    if [[ "$BACKUP_DIR/" == "$path/"* ]]; then
        echo "❌ Ошибка: каталог назначения $BACKUP_DIR находится внутри архивируемого пути $path."
        echo "👉 Выберите другой путь, вне: $path"
        exit 1
    fi
done

### --- Проверки ---
mkdir -p "$BACKUP_DIR"
echo "📁 Сохраняем бэкап в: $BACKUP_DIR" | tee "$LOG_FILE"
echo "📌 Система: $DISTRO" | tee -a "$LOG_FILE"

### --- Исключения ---
EXCLUDES_ARGS=()
EXCLUDES_ARGS+=("--exclude=$BACKUP_DIR")

if [[ -f "$EXCLUDES_FILE" ]]; then
    while IFS= read -r line; do
        EXCLUDES_ARGS+=("--exclude=$line")
    done < "$EXCLUDES_FILE"
fi

### --- Архивация и SHA256 ---
for name in "${!ARCHIVE_PATHS[@]}"; do
    SRC="${ARCHIVE_PATHS[$name]}"
    DEST_ARCHIVE="$BACKUP_DIR/${name}.tar.gz"
    DEST_HASH="$DEST_ARCHIVE.sha256"

    echo "📦 Архивируем $SRC → $DEST_ARCHIVE" | tee -a "$LOG_FILE"
    if ! tar -czpf "$DEST_ARCHIVE" "${EXCLUDES_ARGS[@]}" "$SRC" >> "$LOG_FILE" 2>&1; then
       echo "❌ Ошибка архивации $SRC. Подробнее в логе $LOG_FILE"
       exit 1
    fi

    echo "🔐 Генерируем SHA256 → $DEST_HASH" | tee -a "$LOG_FILE"
    (
      cd "$BACKUP_DIR"
      sha256sum "$(basename "$DEST_ARCHIVE")" > "$(basename "$DEST_ARCHIVE").sha256"
    )

done

### --- Список пакетов ---
echo "📋 Сохраняем списки пакетов" | tee -a "$LOG_FILE"

if ! $GET_PKG_LIST_CMD > "$BACKUP_DIR/pkg-explicit.txt"; then
    echo "❌ Не удалось сохранить список пакетов." | tee -a "$LOG_FILE"
    exit 1
fi

# AUR или альтернативный вывод
$GET_AUR_LIST_CMD > "$BACKUP_DIR/pkg-aur.txt"

sha256sum "$BACKUP_DIR/pkg-explicit.txt" > "$BACKUP_DIR/pkg-explicit.txt.sha256"
sha256sum "$BACKUP_DIR/pkg-aur.txt"      > "$BACKUP_DIR/pkg-aur.txt.sha256"



echo "✅ Бэкап завершён успешно: $(date)" | tee -a "$LOG_FILE"
