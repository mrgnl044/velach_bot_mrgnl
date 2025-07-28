# Развертывание через SSH

## 🚀 Быстрое развертывание

### Вариант 1: Автоматический скрипт (рекомендуется)

```bash
./deploy-ssh.sh
```

Скрипт запросит:
- IP адрес сервера
- Имя пользователя
- Путь к SSH ключу (опционально)
- Токен Telegram бота
- Пароль для базы данных

### Вариант 2: Ручное развертывание

#### 1. Подключение к серверу
```bash
ssh username@your-server-ip
```

#### 2. Установка необходимого ПО
```bash
# Обновление системы
sudo apt update

# Установка Node.js
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs

# Установка PostgreSQL
sudo apt install -y postgresql postgresql-contrib

# Установка PM2
sudo npm install -g pm2

# Установка Git
sudo apt install -y git
```

#### 3. Настройка базы данных
```bash
# Подключение к PostgreSQL
sudo -u postgres psql

# В PostgreSQL консоли:
CREATE USER velach_bot WITH PASSWORD 'your_secure_password';
CREATE DATABASE velach_bot OWNER velach_bot;
GRANT ALL PRIVILEGES ON DATABASE velach_bot TO velach_bot;
\q
```

#### 4. Клонирование проекта
```bash
# Создание директории
sudo mkdir -p /opt/velach_bot
sudo chown $USER:$USER /opt/velach_bot
cd /opt/velach_bot

# Клонирование репозитория
git clone https://github.com/mrgnl044/velach_bot_mrgnl.git
cd velach_bot_mrgnl/server
```

#### 5. Настройка конфигурации
```bash
# Копирование примера конфигурации
cp .env.example .env

# Редактирование конфигурации
nano .env
```

Содержимое .env:
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

#### 6. Установка и сборка
```bash
# Установка зависимостей
npm install

# Сборка проекта
npm run build

# Создание таблиц
npm run create-tables

# Применение миграций
npm run apply-migrations
```

#### 7. Запуск бота
```bash
# Запуск через PM2
pm2 start dist/main.js --name "velach-bot"
pm2 save
pm2 startup
```

## 📋 Управление ботом

### Просмотр логов
```bash
pm2 logs velach-bot
```

### Перезапуск
```bash
pm2 restart velach-bot
```

### Статус
```bash
pm2 status
```

### Остановка
```bash
pm2 stop velach-bot
```

### Обновление
```bash
cd /opt/velach_bot/velach_bot_mrgnl
git pull origin master
cd server
npm install
npm run build
pm2 restart velach-bot
```

## 🔧 Получение токена бота

1. Найдите @BotFather в Telegram
2. Отправьте команду `/newbot`
3. Следуйте инструкциям
4. Скопируйте полученный токен

## 🛡️ Безопасность

- Используйте сложные пароли
- Настройте файрвол: `sudo ufw enable`
- Регулярно обновляйте систему
- Создавайте резервные копии

## 🆘 Устранение неполадок

### Проверка логов
```bash
pm2 logs velach-bot --lines 100
```

### Проверка базы данных
```bash
psql -U velach_bot -d velach_bot -h 127.0.0.1
```

### Проверка портов
```bash
sudo netstat -tlnp | grep :20000
```

### Перезапуск PostgreSQL
```bash
sudo systemctl restart postgresql
``` 