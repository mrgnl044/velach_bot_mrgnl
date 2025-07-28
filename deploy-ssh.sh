#!/bin/bash

# Скрипт развертывания Velach Bot через SSH
# Использование: ./deploy-ssh.sh

set -e

echo "🚀 Развертывание Velach Bot через SSH"
echo "======================================"

# Запрос данных для подключения
read -p "Введите IP адрес сервера: " SERVER_IP
read -p "Введите имя пользователя на сервере: " SERVER_USER
read -p "Введите путь к SSH ключу (или нажмите Enter для использования пароля): " SSH_KEY_PATH

# Запрос токена бота
read -p "Введите токен Telegram бота: " BOT_TOKEN

# Запрос пароля для базы данных
read -s -p "Введите пароль для базы данных: " DB_PASSWORD
echo ""

# Создание временного файла с переменными окружения
cat > temp_env.txt << EOF
# Database Configuration
VELACH_BOT_DB_HOST=127.0.0.1
VELACH_BOT_DB_PORT=5432
VELACH_BOT_DB_DATABASE=velach_bot
VELACH_BOT_DB_USER=velach_bot
VELACH_BOT_DB_PASSWORD=$DB_PASSWORD
VELACH_BOT_DB_MIN_POOL_SIZE=1
VELACH_BOT_DB_MAX_POOL_SIZE=10

# Telegram Bot Configuration
VELACH_BOT_TELEGRAM_TOKEN=$BOT_TOKEN

# Server Configuration
VELACH_BOT_HOST=127.0.0.1
VELACH_BOT_PORT=20000

# Security
VELACH_BOT_JWT_SECRET=$(openssl rand -hex 32)
VELACH_BOT_ADMIN_PASSCODE_TTL=60

# Message Configuration
VELACH_BOT_MAX_MESSAGE_AGE=60
EOF

echo "📋 Подготовка к развертыванию..."

# Определение команды SSH
if [ -n "$SSH_KEY_PATH" ]; then
    SSH_CMD="ssh -i $SSH_KEY_PATH $SERVER_USER@$SERVER_IP"
    SCP_CMD="scp -i $SSH_KEY_PATH"
else
    SSH_CMD="ssh $SERVER_USER@$SERVER_IP"
    SCP_CMD="scp"
fi

echo "🔗 Подключение к серверу $SERVER_USER@$SERVER_IP..."

# Создание скрипта развертывания для сервера
cat > remote_deploy.sh << 'REMOTE_SCRIPT'
#!/bin/bash

set -e

echo "🚀 Начинаем развертывание Velach Bot на сервере..."

# Обновление системы
echo "📦 Обновляем систему..."
sudo apt update

# Установка Node.js
if ! command -v node &> /dev/null; then
    echo "📦 Устанавливаем Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    sudo apt-get install -y nodejs
else
    echo "✅ Node.js уже установлен"
fi

# Установка PostgreSQL
if ! command -v psql &> /dev/null; then
    echo "📦 Устанавливаем PostgreSQL..."
    sudo apt install -y postgresql postgresql-contrib
else
    echo "✅ PostgreSQL уже установлен"
fi

# Установка PM2
if ! command -v pm2 &> /dev/null; then
    echo "📦 Устанавливаем PM2..."
    sudo npm install -g pm2
else
    echo "✅ PM2 уже установлен"
fi

# Создание пользователя базы данных
echo "🗄️ Настраиваем базу данных..."
sudo -u postgres psql -c "CREATE USER velach_bot WITH PASSWORD '$DB_PASSWORD';" 2>/dev/null || echo "Пользователь velach_bot уже существует"
sudo -u postgres psql -c "CREATE DATABASE velach_bot OWNER velach_bot;" 2>/dev/null || echo "База данных velach_bot уже существует"

# Создание директории для проекта
echo "📁 Создаем директорию проекта..."
sudo mkdir -p /opt/velach_bot
sudo chown $USER:$USER /opt/velach_bot

# Клонирование репозитория
echo "📥 Клонируем репозиторий..."
cd /opt/velach_bot
if [ -d "velach_bot_mrgnl" ]; then
    cd velach_bot_mrgnl
    git pull origin master
else
    git clone https://github.com/mrgnl044/velach_bot_mrgnl.git
    cd velach_bot_mrgnl
fi

# Переход в папку server
cd server

# Установка зависимостей
echo "📦 Устанавливаем зависимости..."
npm install

# Создание .env файла
echo "⚙️ Создаем конфигурацию..."
cp .env.example .env
sed -i "s/your_telegram_bot_token_here/$BOT_TOKEN/g" .env
sed -i "s/your_secure_password/$DB_PASSWORD/g" .env

# Сборка проекта
echo "🔨 Собираем проект..."
npm run build

# Создание таблиц
echo "🗄️ Создаем таблицы базы данных..."
npm run create-tables

# Применение миграций
echo "🔄 Применяем миграции..."
npm run apply-migrations

# Запуск через PM2
echo "🚀 Запускаем бота..."
pm2 delete velach-bot 2>/dev/null || true
pm2 start dist/main.js --name "velach-bot"
pm2 save
pm2 startup

echo "✅ Развертывание завершено!"
echo ""
echo "📋 Полезные команды:"
echo "   Просмотр логов: pm2 logs velach-bot"
echo "   Перезапуск: pm2 restart velach-bot"
echo "   Статус: pm2 status"
echo ""
echo "🔗 Бот доступен на порту 20000"
REMOTE_SCRIPT

# Копирование файлов на сервер
echo "📤 Копируем файлы на сервер..."
$SCP_CMD remote_deploy.sh $SERVER_USER@$SERVER_IP:/tmp/
$SCP_CMD temp_env.txt $SERVER_USER@$SERVER_IP:/tmp/

# Выполнение развертывания на сервере
echo "🔧 Выполняем развертывание на сервере..."
$SSH_CMD "chmod +x /tmp/remote_deploy.sh && DB_PASSWORD='$DB_PASSWORD' BOT_TOKEN='$BOT_TOKEN' /tmp/remote_deploy.sh"

# Очистка временных файлов
echo "🧹 Очищаем временные файлы..."
rm -f temp_env.txt remote_deploy.sh
$SSH_CMD "rm -f /tmp/remote_deploy.sh /tmp/temp_env.txt"

echo "✅ Развертывание завершено!"
echo ""
echo "🔗 Бот должен быть доступен на сервере $SERVER_IP:20000"
echo "📋 Для управления ботом подключитесь к серверу и используйте команды PM2" 