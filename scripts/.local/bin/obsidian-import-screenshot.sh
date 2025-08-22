#!/bin/bash

snapshots_dir="/home/user/Загрузки/snapshots"
obsidian_dir="$HOME/Documents/Knowledge_Base/attachments"

mkdir -p "$obsidian_dir"

# Найти все изображения и сохранить список путей
mapfile -t files < <(find "$snapshots_dir" -type f \( -iname "*.png" -o -iname "*.jpg" \) | sort)

# Создаём список только имён файлов
choices=()
for file in "${files[@]}"; do
    choices+=("$(basename "$file")")
done

# Выбор через rofi
selected=$(printf '%s\n' "${choices[@]}" | rofi -dmenu -p "Select image to import")

# Проверка, был ли сделан выбор
if [[ -n "$selected" ]]; then
    # Найти оригинальный путь по имени файла
    for i in "${!choices[@]}"; do
        if [[ "${choices[i]}" == "$selected" ]]; then
            src="${files[i]}"
            break
        fi
    done

    # Копирование и уведомление
    cp "$src" "$obsidian_dir/$selected"
    echo "![[${selected}]]" | xclip -selection clipboard
    notify-send "Obsidian" "Imported $selected"
else
    notify-send "Obsidian" "No image selected"
fi

