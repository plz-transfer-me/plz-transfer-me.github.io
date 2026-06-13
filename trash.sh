# 1. Очищаем
docker rm -f tg-web cloudflare-tunnel 2>/dev/null

# 2. Запускаем Telegram
docker run -d --name tg-web --security-opt seccomp=unconfined -e TZ=UTC -e CUSTOM_USER=asd8878 -e CUSTOM_PASSWORD=JjFcKJD023 -p 127.0.0.1:3000:3000 --restart unless-stopped lscr.io/linuxserver/telegram:latest

# 3. Ждём 30 секунд (важно!)
sleep 30

# 4. Запускаем туннель
docker run -d --name cloudflare-tunnel --restart unless-stopped --network host cloudflare/cloudflared:latest tunnel --url http://127.0.0.1:3000

# 5. Ждём 15 секунд
sleep 15

# 6. Получаем ссылку
docker logs cloudflare-tunnel 2>&1 | grep -o "https://[a-z0-9-]*\.trycloudflare\.com"
