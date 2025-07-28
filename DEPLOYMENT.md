# Инструкция по развертыванию Velach Bot

## Требования к серверу

### Системные требования:
- **ОС**: Ubuntu 20.04+ или Debian 11+
- **RAM**: минимум 512MB, рекомендуется 1GB+
- **CPU**: 1 ядро, рекомендуется 2 ядра
- **Диск**: минимум 5GB свободного места
- **Node.js**: версия 18+ (рекомендуется 22.11.0)
- **PostgreSQL**: версия 12+

### Программное обеспечение:
- Node.js и npm
- PostgreSQL
- Git
- PM2 (для управления процессами)

## Шаг 1: Подготовка сервера

### Установка Node.js:
```bash
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### Установка PostgreSQL:
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
```

### Установка PM2:
```bash
sudo npm install -g pm2
```

## Шаг 2: Настройка базы данных

### Создание пользователя и базы данных:
```bash
sudo -u postgres psql

# В PostgreSQL консоли:
CREATE USER velach_bot WITH PASSWORD 'your_secure_password';
CREATE DATABASE velach_bot OWNER velach_bot;
GRANT ALL PRIVILEGES ON DATABASE velach_bot TO velach_bot;
\q
```

### Настройка PostgreSQL для подключений:
```bash
sudo nano /etc/postgresql/*/main/postgresql.conf
# Убедитесь, что listen_addresses = 'localhost'

sudo nano /etc/postgresql/*/main/pg_hba.conf
# Добавьте строку для локальных подключений:
# local   velach_bot    velach_bot    md5

sudo systemctl restart postgresql
```

## Шаг 3: Клонирование и настройка проекта

### Клонирование репозитория:
```bash
git clone https://github.com/your-username/velach_bot_mrgnl.git
cd velach_bot_mrgnl/server
```

### Установка зависимостей:
```bash
npm install
```

### Создание файла конфигурации:
```bash
cp .env.example .env
nano .env
```

### Содержимое .env файла:
```env
# Database Configuration
VELACH_BOT_DB_HOST=127.0.0.1
VELACH_BOT_DB_PORT=5432
VELACH_BOT_DB_DATABASE=velach_bot
VELACH_BOT_DB_USER=velach_bot
VELACH_BOT_DB_PASSWORD=your_secure_password
VELACH_BOT_DB_MIN_POOL_SIZE=1
VELACH_BOT_DB_MAX_POOL_SIZE=10

# Telegram Bot Configuration
VELACH_BOT_TELEGRAM_TOKEN=your_telegram_bot_token_here

# Server Configuration
VELACH_BOT_HOST=127.0.0.1
VELACH_BOT_PORT=20000

# Security
VELACH_BOT_JWT_SECRET=your_jwt_secret_here
VELACH_BOT_ADMIN_PASSCODE_TTL=60

# Message Configuration
VELACH_BOT_MAX_MESSAGE_AGE=60
```

## Шаг 4: Создание Telegram бота

### Получение токена бота:
1. Найдите @BotFather в Telegram
2. Отправьте команду `/newbot`
3. Следуйте инструкциям для создания бота
4. Скопируйте полученный токен в переменную `VELACH_BOT_TELEGRAM_TOKEN`

## Шаг 5: Инициализация базы данных

### Создание таблиц:
```bash
npm run create-tables
```

### Применение миграций:
```bash
npm run apply-migrations
```

### (Опционально) Заполнение тестовыми данными:
```bash
npm run seed-test-db
```

## Шаг 6: Сборка и запуск

### Сборка проекта:
```bash
npm run build
```

### Тестовый запуск:
```bash
npm run start:prod:server
```

### Настройка PM2 для автозапуска:
```bash
pm2 start dist/main.js --name "velach-bot"
pm2 save
pm2 startup
```

## Шаг 7: Настройка файрвола (опционально)

### Открытие порта для веб-интерфейса:
```bash
sudo ufw allow 20000
```

## Шаг 8: Настройка Nginx (опционально)

### Установка Nginx:
```bash
sudo apt install nginx
```

### Создание конфигурации:
```bash
sudo nano /etc/nginx/sites-available/velach-bot
```

### Содержимое конфигурации:
```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://127.0.0.1:20000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### Активация конфигурации:
```bash
sudo ln -s /etc/nginx/sites-available/velach-bot /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

## Шаг 9: Настройка SSL (рекомендуется)

### Установка Certbot:
```bash
sudo apt install certbot python3-certbot-nginx
```

### Получение SSL сертификата:
```bash
sudo certbot --nginx -d your-domain.com
```

## Управление ботом

### Просмотр логов:
```bash
pm2 logs velach-bot
```

### Перезапуск:
```bash
pm2 restart velach-bot
```

### Остановка:
```bash
pm2 stop velach-bot
```

### Обновление бота:
```bash
git pull
npm install
npm run build
pm2 restart velach-bot
```

## Резервное копирование

### Создание дампа базы данных:
```bash
npm run backup-db
```

### Восстановление из дампа:
```bash
psql -U velach_bot -d velach_bot < backup_file.sql
```

## Мониторинг

### Проверка статуса:
```bash
pm2 status
```

### Мониторинг ресурсов:
```bash
pm2 monit
```

## Устранение неполадок

### Проверка логов:
```bash
pm2 logs velach-bot --lines 100
```

### Проверка подключения к базе данных:
```bash
psql -U velach_bot -d velach_bot -h 127.0.0.1
```

### Проверка переменных окружения:
```bash
pm2 env velach-bot
```

## Безопасность

### Рекомендации:
1. Используйте сложные пароли для базы данных
2. Регулярно обновляйте систему и зависимости
3. Настройте файрвол
4. Используйте SSL сертификаты
5. Регулярно создавайте резервные копии
6. Мониторьте логи на предмет подозрительной активности

## Поддержка

При возникновении проблем:
1. Проверьте логи: `pm2 logs velach-bot`
2. Убедитесь, что все переменные окружения настроены правильно
3. Проверьте подключение к базе данных
4. Убедитесь, что токен бота действителен 