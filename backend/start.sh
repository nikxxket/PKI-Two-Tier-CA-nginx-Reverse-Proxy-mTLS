#!/bin/bash

BASE_DIR="/Users/nikitapiurenko/Desktop/Кибербезопасность/LB4"

echo "ЗАПУСК BACKEND СЕРВИСОВ"

# Создаём папку для логов (на всякий случай)
mkdir -p "$BASE_DIR/backend/logs"

# Явно создаём пустые файлы логов
touch "$BASE_DIR/backend/logs/api.log"
touch "$BASE_DIR/backend/logs/app.log"

# Запуск API
cd "$BASE_DIR/backend/api"
python3 server.py >> "$BASE_DIR/backend/logs/api.log" 2>&1 &
echo "API запущен на порту 3001 (PID: $!)"

# Запуск App
cd "$BASE_DIR/backend/app"
python3 server.py >> "$BASE_DIR/backend/logs/app.log" 2>&1 &
echo "App запущен на порту 3002 (PID: $!)"

echo "Через nginx:"
echo "https://lab.local"
echo "https://lab.local/api/"
