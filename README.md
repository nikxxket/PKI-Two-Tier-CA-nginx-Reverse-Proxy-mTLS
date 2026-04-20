# PKI: Two-Tier CA, nginx Reverse Proxy & mTLS

> **Учебный проект** по созданию собственной инфраструктуры открытых ключей (PKI), настройке защищённого веб-сервера с обратным проксированием и внедрению двусторонней TLS‑аутентификации (mTLS) в локальном окружении macOS.

Цели проекта:

1) Автоматизированная генерация двухуровневой цепочки сертификатов (Root CA → Intermediate CA → Leaf);
2) Развёртывание nginx в качестве **reverse proxy** с поддержкой HTTPS;
3) Проксирование запросов к двум независимым backend-сервисам;
4) Добавление корневого сертификата в системное хранилище macOS для полного доверия;
5) Реализация **Mutual TLS** – обязательная проверка клиентского сертификата сервером.

Технологический стек:

1) PKI - OpenSSL 3.x, Bash‑скрипты;
2) Веб‑сервер - nginx;
3) Backend‑сервисы - Python 3;
4) Тестирование - `curl`, Safari, Keychain Access;
5) Окружение - macOS (Apple Silicon).

Структура проекта:

├── certs/ # Сертификаты и ключи
│ ├── root.crt / root.key # Root CA
│ ├── intermediate.* # Intermediate CA
│ ├── nginx.* # Серверный сертификат + цепочка
│ ├── client1.* # Клиентский сертификат (для mTLS)
│ └── ca-bundle.crt # Бандл Intermediate + Root (для проверки клиента)
│
├── scripts/ # Скрипты автоматизации
│ ├── generate_certs.sh # Создание всей PKI‑инфраструктуры
│ └── client_cert.sh # Генерация клиентского сертификата
│
├── backend/ # Тестовые микросервисы
│ ├── api/ # API‑сервис (порт 3001)
│ │ ├── index.html
│ │ └── server.py
│ ├── app/ # Основное приложение (порт 3002)
│ │ ├── index.html
│ │ └── server.py
│ ├── logs/ # Логи сервисов
│ └── start.sh # Одновременный запуск обоих бэкендов
│
└── nginx-config/ # Конфигурация nginx (lab.local.conf)

Генерация сертификатов:

chmod +x scripts/*.sh
./scripts/generate_certs.sh

Скрипт создаст:

1) Самоподписанный Root CA;
2) Intermediate CA, подписанный корневым;
3) Серверный сертификат для lab.local (включая SAN: api.lab.local, app.lab.local);
4) Цепочку nginx-chain.crt для nginx.

nginx проксирует запросы в зависимости от пути:

1) https://lab.local/ - http://127.0.0.1:3002/ -	Основное приложение;
2) https://lab.local/api/	http://127.0.0.1:3001/	API‑сервис (JSON);
3) Оба бэкенда работают на 127.0.0.1 (одна подсеть) и могут обмениваться HTTP‑запросами.

Mutual TLS:

Генерация клиентского сертификата
./scripts/client_cert.sh
Создаётся client1.p12 с паролем lab123

Включение проверки в nginx:

В конфиге lab.local.conf (nginx) добавлены директивы:
ssl_client_certificate /path/to/ca-bundle.crt;
ssl_verify_client on.


Тестирование:

❌ Без сертификата:

curl --cacert certs/root.crt --resolve lab.local:443:127.0.0.1 https://lab.local/
# 400 Bad Request – No required SSL certificate was sent

✅ С сертификатом:

curl --cacert certs/root.crt \
     --cert certs/client1.crt \
     --key certs/client1.key \
     --resolve lab.local:443:127.0.0.1 \
     https://lab.local/
# Успешный ответ с HTML-страницей

Импорт в браузер:

Дважды кликните client1.p12, введите пароль lab123 и выберите связку «Вход».
После перезагрузки браузера при заходе на https://lab.local будет предложено выбрать клиентский сертификат.
