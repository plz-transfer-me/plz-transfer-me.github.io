#!/bin/bash

set -e

echo "=== Очистка старых контейнеров ==="
docker rm -f tg-web cloudflare-tunnel 2>/dev/null || true

echo "=== Запуск Telegram Web ==="
docker run -d \
  --name tg-web \
  --security-opt seccomp=unconfined \
  -e TZ=UTC \
  -e CUSTOM_USER=asd8878 \
  -e CUSTOM_PASSWORD=JjFcKJD023 \
  -p 127.0.0.1:3000:3000 \
  --restart unless-stopped \
  lscr.io/linuxserver/telegram:latest

echo "=== Ожидание запуска Telegram (30 сек) ==="
sleep 30

echo "=== Проверка Telegram ==="
if curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:3000 | grep -q "200"; then
  echo "Telegram OK (200)"
else
  echo "Ошибка: Telegram не отвечает"
  exit 1
fi

echo "=== Запуск Cloudflare Tunnel ==="
docker run -d \
  --name cloudflare-tunnel \
  --restart unless-stopped \
  --network host \
  cloudflare/cloudflared:latest tunnel \
  --url http://127.0.0.1:3000

echo "=== Ожидание туннеля (20 сек) ==="
sleep 20

echo "=== Получение ссылки ==="
TUNNEL_URL=$(docker logs cloudflare-tunnel 2>&1 | grep -o "https://[a-z0-9-]*\.trycloudflare\.com" | head -1)

if [ -n "$TUNNEL_URL" ]; then
  echo ""
  echo "========================================="
  echo "✅ ГОТОВО!"
  echo "========================================="
  echo "🌐 Откройте в браузере:"
  echo "   ${TUNNEL_URL}/?http=1"
  echo ""
  echo "🔐 Логин: asd8878"
  echo "🔐 Пароль: JjFcKJD023"
  echo "========================================="
else
  echo "❌ Не удалось получить ссылку"
  echo "Логи туннеля:"
  docker logs cloudflare-tunnel 2>&1 | tail -20
fi
