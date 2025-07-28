-- Migration: rename-strava-to-telegram-pub

-- Переименовываем поле stravaLink в telegramPubLink
ALTER TABLE "User" RENAME COLUMN "stravaLink" TO "telegramPubLink";

-- Добавляем комментарий к полю
COMMENT ON COLUMN "User"."telegramPubLink" IS 'Ссылка на личный паблик пользователя в Telegram';