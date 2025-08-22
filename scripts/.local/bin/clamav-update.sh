#!/bin/bash

SYS_DB_DIR="/var/lib/clamav"
LOCAL_DB_DIR="$HOME/.local/share/clamav"
LOG_DIR="$HOME/clamav_logs"
TIMESTAMP=$(date '+%Y%m%d-%H%M')
LOGFILE="$LOG_DIR/update-$TIMESTAMP.log"

mkdir -p "$LOCAL_DB_DIR" "$LOG_DIR"

echo "🔍 Проверка состояния базы ClamAV..." | tee "$LOGFILE"

if [ -d "$SYS_DB_DIR" ]; then
    ls -lh --time-style=long-iso "$SYS_DB_DIR"/*.cvd "$SYS_DB_DIR"/*.cld 2>/dev/null | tee -a "$LOGFILE"
else
    echo "⚠️ Системная база не найдена в $SYS_DB_DIR" | tee -a "$LOGFILE"
fi

echo | tee -a "$LOGFILE"
read -p "Запустить обновление баз ClamAV? (y/N): " choice

if [[ "$choice" =~ ^[Yy]$ ]]; then
    echo "🌐 Запуск обновления баз ClamAV..." | tee -a "$LOGFILE"

    # Запуск freshclam от пользователя clamav, лог в системный дефолтный файл
    sudo -u clamav freshclam 2>&1 | tee -a "$LOGFILE"

    if [ $? -eq 0 ]; then
        echo "✅ Обновление завершено. Копируем базы в $LOCAL_DB_DIR..." | tee -a "$LOGFILE"
        cp -u "$SYS_DB_DIR"/* "$LOCAL_DB_DIR"/ 2>&1 | tee -a "$LOGFILE"
        chown "$USER:$USER" "$LOCAL_DB_DIR"/* 2>/dev/null
        echo "📦 Локальная база обновлена." | tee -a "$LOGFILE"
    else
        echo "❌ Ошибка при обновлении баз ClamAV." | tee -a "$LOGFILE"
    fi
else
    echo "⏭️ Обновление отменено." | tee -a "$LOGFILE"
fi

echo "📄 Лог сохранён: $LOGFILE"

