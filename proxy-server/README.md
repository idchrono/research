# Инструкция по развертыванию прокси‑сервера и настройке локального подключения

## Требования
- Сервер с Ubuntu (или Debian‑похожей) и доступом к интернету.
- Доступ по SSH от локального компьютера.
- Достаточно прав *sudo*.

---

## 1. Установка TinyProxy

```bash
sudo apt-get update
sudo apt-get install -y tinyproxy
```

### Настройка
```bash
sudo systemctl restart tinyproxy
sudo systemctl enable tinyproxy
sudo systemctl status tinyproxy
```

## 2. Проверка работы TinyProxy
```bash
curl -x http://127.0.0.1:8888 http://ipinfo.io
```
Если вывод содержит ваш серверный IP – всё работает.

## 3. Создание SSH‑туннеля
На локальном компьютере выполните:

```bash
ssh -L 8888:localhost:8888 user@remote
```
Замена `user@remote` на актуальные данные.

> После запуска этого порты `127.0.0.1:8888` на локальной машине будут проксировать трафик через сервер.

## 4. Настройка приложений
### В браузере
Перейдите в настройки → Сеть → Прокси → HTTP. Укажите `127.0.0.1` и порт `8888`.

### В командной строке (Linux/Windows)
```bash
export http_proxy="http://127.0.0.1:8888"
export https_proxy="http://127.0.0.1:8888"
```
Запускайте приложения в такой же оболочке.

## 5. Ограничение доступа (опционально)
В `tinyproxy.conf` включите список разрешенных IP:

```
Allow 127.0.0.1
#Allow 192.168.1.42   # добавьте собственный IP
```

## 6. Автоматизация на сервере
Создайте скрипт `setup_server.sh` (см. ниже), который:
- Устанавливает TinyProxy.
- Пишет нужный конфиг.
- Открывает порт в UFW.

## Скрипт `setup_server.sh`
```bash
#!/usr/bin/env bash
set -e

# Пакетный менеджер
sudo apt-get update
sudo apt-get install -y tinyproxy

# Конфигурация TinyProxy
cat <<'EOF' | sudo tee /etc/tinyproxy.conf > /dev/null
# TinyProxy – минимальный HTTP/HTTPS прокси
Listen 127.0.0.1
Port 8888
# TinyProxy не экспортирует наружу, поэтому не нужно открывать порт в UFW.
LogFile /var/log/tinyproxy.log
EOF

# Порт 8888 слушается только на localhost, поэтому открывать его через UFW не требуется.

# Перезапускаем сервис
sudo systemctl daemon-reload
sudo systemctl restart tinyproxy
sudo systemctl enable tinyproxy

echo "TinyProxy настроен и запущен!"
```

## Как использовать
1. Поместите `setup_server.sh` на сервер.
2. Сделайте его исполняемым:
   ```bash
   chmod +x setup_server.sh
   ```
3. Запустите:
   ```bash
   ./setup_server.sh
   ```

## Локальный скрипт `start_tunnel.sh`
Если хочется автоматизировать создание туннеля, можно создать вспомогательный скрипт на локальном компьютере:

```bash
#!/usr/bin/env bash
set -e

REMOTE_USER="user"
REMOTE_HOST="remote"
REMOTE_PORT="8888"
LOCAL_PORT="8888"

ssh -N -L ${LOCAL_PORT}:localhost:${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST}
```

> Параметры `REMOTE_USER`, `REMOTE_HOST` задайте в соответствии с вашими данными.

---

**Примечание**
Если вам нужен SOCKS5‑прокси, используйте команду `ssh -D 1080 user@remote` и настройте приложения на `socks5://127.0.0.1:1080`.

---

## Полная работа

1. На сервере выполнить `./setup_server.sh`.
2. На локальном компьютере открыть SSH‑туннель (можно через `./start_tunnel.sh`).
3. Настроить приложения на прокси `127.0.0.1:8888`.
4. Работайте, наслаждайтесь проксированным соединением!