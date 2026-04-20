#!/bin/bash
echo "Остановка сервисов..."
pkill -f "python3 server.py"
echo "Сервисы остановлены!"

