#!/bin/bash

# settings
TARGET="${1:-/}"                                # Путь для сканирования
TIMESTAMP=$(date '+%Y%m%d-%H%M')                # Время запуска
LOGDIR="$HOME/clamav_logs"                      # Папка для логов
LOGFILE="$LOGDIR/scan-$TIMESTAMP.log"           # Путь до лога
QUARANTINE="$HOME/quarantine"                   # Папка карантина
DBDIR="$HOME/.local/share/clamav"                # Локальная база ClamAV

# create directory, если их нет
mkdir -p "$LOGDIR" "$QUARANTINE" "$DBDIR"

# upd database
echo "🔄 Updating ClamAV database in $DBDIR..." | tee "$LOGFILE"
freshclam --quiet --datadir="$DBDIR"
if [ $? -ne 0 ]; then
    echo "⚠️ Failed to update database. Using existing DB." | tee -a "$LOGFILE"
fi

# cheak database
if ! ls "$DBDIR"/*.cvd "$DBDIR"/*.cld >/dev/null 2>&1; then
    echo "❌ No ClamAV database found in $DBDIR" | tee -a "$LOGFILE"
    exit 1
fi

# Start information
echo "🚨 ClamAV Scan Started at $(date)" | tee -a "$LOGFILE"
echo "📁 Scanning: $TARGET" | tee -a "$LOGFILE"
echo "🛑 Infected files will be moved to: $QUARANTINE" | tee -a "$LOGFILE"
echo "------------------------------------------" | tee -a "$LOGFILE"

# Start scan
SCAN_OUTPUT=$(clamscan -r -i \
    --move="$QUARANTINE" \
    --database="$DBDIR" \
    "$TARGET" 2>&1 | tee -a "$LOGFILE")

# Извлечение статистики
DIRS_SCANNED=$(echo "$SCAN_OUTPUT" | grep "Scanned directories" | awk '{print $3}')
FILES_SCANNED=$(echo "$SCAN_OUTPUT" | grep "Scanned files" | awk '{print $3}')
INFECTED=$(echo "$SCAN_OUTPUT" | grep "Infected files" | awk '{print $3}')

# Финальный отчёт
echo "------------------------------------------" | tee -a "$LOGFILE"
echo "📊 Scan Summary:" | tee -a "$LOGFILE"
echo "   - Directories scanned: $DIRS_SCANNED" | tee -a "$LOGFILE"
echo "   - Files scanned:       $FILES_SCANNED" | tee -a "$LOGFILE"
echo "   - Infected files:      $INFECTED" | tee -a "$LOGFILE"

echo "✅ Scan Completed at $(date)" | tee -a "$LOGFILE"
echo "📄 Log saved to $LOGFILE" | tee -a "$LOGFILE"
