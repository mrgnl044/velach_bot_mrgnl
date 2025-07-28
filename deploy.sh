#!/bin/bash

# Скрипт автоматического развертывания Velach Bot
# Использование: ./deploy.sh

set -e

echo "🚀 Начинаем развертывание Velach Bot..."

# Проверка наличия Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js не установлен. Устанавливаем..."
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    sudo apt-get install -y nodejs
else
    echo "✅ Node.js уже установлен"
fi

# Проверка наличия PostgreSQL
if ! command -v psql &> /dev/null; then
    echo "❌ PostgreSQL не установлен. Устанавливаем..."
    sudo apt update
    sudo apt install -y postgresql postgresql-contrib
else
    echo "✅ PostgreSQL уже установлен"
fi

# Проверка наличия PM2
if ! command -v pm2 &> /dev/null; then
    echo "❌ PM2 не установлен. Устанавливаем..."
    sudo npm install -g pm2
else
    echo "✅ PM2 уже установлен"
fi

# Проверка наличия .env файла
if [ ! -f ".env" ]; then
    echo "❌ Файл .env не найден. Создаем пример..."
    cat > .env << EOF
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
EOF
    echo "⚠️  Пожалуйста, отредактируйте файл .env и настройте переменные окружения"
    echo "   Особенно важно настроить VELACH_BOT_TELEGRAM_TOKEN и VELACH_BOT_DB_PASSWORD"
    exit 1
fi

# Установка зависимостей
echo "📦 Устанавливаем зависимости..."
npm install

# Сборка проекта
echo "🔨 Собираем проект..."
npm run build

# Проверка подключения к базе данных
echo "🔍 Проверяем подключение к базе данных..."
if npm run execute-ts ./src/cli.ts -- --create-tables 2>/dev/null; then
    echo "✅ Подключение к базе данных успешно"
else
    echo "❌ Ошибка подключения к базе данных"
    echo "   Убедитесь, что PostgreSQL запущен и настройки в .env корректны"
    exit 1
fi

# Применение миграций
echo "🔄 Применяем миграции..."
npm run apply-migrations

# Запуск через PM2
echo "🚀 Запускаем бота через PM2..."
pm2 delete velach-bot 2>/dev/null || true
pm2 start dist/main.js --name "velach-bot"
pm2 save

echo "✅ Развертывание завершено!"
echo ""
echo "📋 Полезные команды:"
echo "   Просмотр логов: pm2 logs velach-bot"
echo "   Перезапуск: pm2 restart velach-bot"
echo "   Статус: pm2 status"
echo "   Мониторинг: pm2 monit"
echo ""
echo "🔗 Бот должен быть доступен на порту 20000" 