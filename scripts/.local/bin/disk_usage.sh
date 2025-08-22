#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Получаем данные с помощью df, исключаем заголовок и tmpfs/snap
df -h --output=source,fstype,size,used,avail,pcent,target | grep -vE 'tmpfs|snap' | while read -r line; do
    # Разбиваем строку на поля
    source=$(echo "$line" | awk '{print $1}')
    fstype=$(echo "$line" | awk '{print $2}')
    size=$(echo "$line" | awk '{print $3}')
    used=$(echo "$line" | awk '{print $4}')
    avail=$(echo "$line" | awk '{print $5}')
    pcent=$(echo "$line" | awk '{print $6}' | tr -d '%')
    target=$(echo "$line" | awk '{print $7}')

    # Определяем цвет в зависимости от процента использования
    if [ "$pcent" -ge 90 ]; then
        color=$RED
    elif [ "$pcent" -ge 70 ]; then
        color=$YELLOW
    else
        color=$GREEN
    fi

    # Выводим форматированную строку
    printf "${color}%-10s | %-8s | Size: %-6s | Used: %-6s | Avail: %-6s | Use%%: %-3s%% | %-s${NC}\n" \
           "$source" "$fstype" "$size" "$used" "$avail" "$pcent" "$target"
done
