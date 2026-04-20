#!/bin/bash

# Абсолютный путь к папке с сертификатами
CERT_DIR="/Users/nikitapiurenko/Desktop/Кибербезопасность/LB4/certs"

echo "1. Создание корневого сертификата (Root CA)"
# Генерация приватного ключа для Root CA
openssl genrsa -out "$CERT_DIR/root.key" 4096
# Создание самоподписанного корневого сертификата сроком на 10 лет
openssl req -x509 -new -nodes -key "$CERT_DIR/root.key" -sha256 -days 3650 \
    -out "$CERT_DIR/root.crt" -config "$CERT_DIR/root.cnf" -extensions v3_ca

echo "2. Создание промежуточного сертификата (Intermediate CA)"
# Генерация приватного ключа для Intermediate CA
openssl genrsa -out "$CERT_DIR/intermediate.key" 4096
# Создание запроса на подпись сертификата (CSR) для Intermediate CA
openssl req -new -key "$CERT_DIR/intermediate.key" -out "$CERT_DIR/intermediate.csr" \
    -config "$CERT_DIR/intermediate.cnf"
# Подпись Intermediate CA сертификата с помощью Root CA
openssl x509 -req -in "$CERT_DIR/intermediate.csr" -CA "$CERT_DIR/root.crt" \
    -CAkey "$CERT_DIR/root.key" -CAcreateserial -out "$CERT_DIR/intermediate.crt" \
    -days 1825 -sha256 -extfile <(echo "basicConstraints=critical,CA:TRUE,pathlen:0")

echo "3. Создание конечного (листового) сертификата для nginx"
# Генерация приватного ключа для сервера nginx
openssl genrsa -out "$CERT_DIR/nginx.key" 2048
# Создание CSR для сервера nginx
openssl req -new -key "$CERT_DIR/nginx.key" -out "$CERT_DIR/nginx.csr" \
    -config "$CERT_DIR/leaf.cnf"
# Подпись сертификата сервера nginx с помощью Intermediate CA
openssl x509 -req -in "$CERT_DIR/nginx.csr" -CA "$CERT_DIR/intermediate.crt" \
    -CAkey "$CERT_DIR/intermediate.key" -CAcreateserial -out "$CERT_DIR/nginx.crt" \
    -days 365 -sha256 -extfile "$CERT_DIR/leaf.cnf" -extensions v3_req

echo "4. Создание файла цепочки сертификатов (certificate bundle)"
# Объединение конечного и промежуточного сертификатов в один файл
cat "$CERT_DIR/nginx.crt" "$CERT_DIR/intermediate.crt" > "$CERT_DIR/nginx-chain.crt"

echo "5. Проверка сертификатов"
# Проверка конечного сертификата с помощью цепочки доверия
openssl verify -CAfile "$CERT_DIR/root.crt" -untrusted "$CERT_DIR/intermediate.crt" "$CERT_DIR/nginx.crt"

echo "=== Готово! Все сертификаты созданы в директории '$CERT_DIR' ==="
