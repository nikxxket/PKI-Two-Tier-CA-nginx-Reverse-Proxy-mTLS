#!/bin/bash

# Путь к сертификатам
CERT_DIR="/Users/nikitapiurenko/Desktop/Кибербезопасность/LB4/certs"
CLIENT_NAME="client1"
PASSWORD="lab123" # Пароль для PCKS 

echo "СОЗДАНИЕ КЛИЕНТСКОГО СЕРТИФИКАТА"

# 1. Генерация приватного ключа клиента
echo "1. Генерация ключа..."
openssl genrsa -out "$CERT_DIR/${CLIENT_NAME}.key" 2048

# 2. Создание запроса на подпись (CSR)
echo "2. Создание CSR..."
openssl req -new -key "$CERT_DIR/${CLIENT_NAME}.key" -out "$CERT_DIR/${CLIENT_NAME}.csr" \
    -subj "/C=RU/ST=Moscow/L=Moscow/O=MyLab/OU=Clients/CN=${CLIENT_NAME}"

# 3. Подпись CSR с помощью Intermediate CA
echo "3. Подпись Intermediate CA..."
openssl x509 -req -in "$CERT_DIR/${CLIENT_NAME}.csr" \
    -CA "$CERT_DIR/intermediate.crt" -CAkey "$CERT_DIR/intermediate.key" \
    -CAcreateserial -out "$CERT_DIR/${CLIENT_NAME}.crt" \
    -days 365 -sha256 \
    -extfile <(printf "basicConstraints=CA:FALSE\nkeyUsage=digitalSignature,keyEncipherment\nextendedKeyUsage=clientAuth")

# 4. Экспорт в PKCS#12 для импорта в браузер/ОС
echo "4. Экспорт в PKCS#12 (client1.p12)..."
openssl pkcs12 -export -out "$CERT_DIR/${CLIENT_NAME}.p12" \
    -inkey "$CERT_DIR/${CLIENT_NAME}.key" \
    -in "$CERT_DIR/${CLIENT_NAME}.crt" \
    -certfile "$CERT_DIR/root.crt" \
    -password pass:$PASSWORD

echo "Клиентский сертификат создан!"
echo "Сертификат: $CERT_DIR/${CLIENT_NAME}.crt"
echo "Ключ:       $CERT_DIR/${CLIENT_NAME}.key"
echo "PKCS#12:    $CERT_DIR/${CLIENT_NAME}.p12"
