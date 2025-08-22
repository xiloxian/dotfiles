import subprocess
import argparse
import os

def download_video(url, output_dir, quality, ext):
    # Формируем формат для yt-dlp
    # Пример: "bv*+ba/b" + сортировка по разрешению и расширению
    format_str = f"bv*+ba/b"
    sort_str = f"res:{quality},ext:{ext}"

    # Путь и имя файла (используем шаблон yt-dlp)
    output_template = os.path.join(output_dir, "%(title)s.%(ext)s")

    cmd = [
        "yt-dlp",
        "-f", format_str,
        "-S", sort_str,
        "-o", output_template,
        url
    ]

    print(f"Запускаем: {' '.join(cmd)}")
    subprocess.run(cmd)

def main():
    parser = argparse.ArgumentParser(description="Скрипт для скачивания видео с YouTube через yt-dlp из файла с URL")
    parser.add_argument("-i", "--input", default="urls1808.txt", help="Файл с URL (по одному в строке), по умолчанию urls.txt")
    parser.add_argument("-o", "--output", default="wow_downloads", help="Папка для сохранения видео, по умолчанию ./downloads")
    parser.add_argument("-q", "--quality", default="720", help="Желаемое качество видео, например 1080, 720")
    parser.add_argument("-e", "--ext", default="mp4", help="Желаемый формат видео, например mp4, mkv")

    args = parser.parse_args()

    # Создаем папку, если нет
    if not os.path.exists(args.output):
        os.makedirs(args.output)

    with open(args.input, "r", encoding="utf-8") as f:
        urls = [line.strip() for line in f if line.strip()]

    for url in urls:
        print(f"\nСкачиваем: {url}")
        download_video(url, args.output, args.quality, args.ext)

if __name__ == "__main__":
    main()
