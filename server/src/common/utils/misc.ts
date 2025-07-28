export function getNextIndex(currentIndex: number, arraySize: number): number {
  return (currentIndex + 1) % arraySize;
}

export function getPreviousIndex(
  currentIndex: number,
  arraySize: number,
): number {
  if (currentIndex === 0) {
    return arraySize - 1;
  }

  return currentIndex - 1;
}

export function isNil(value: unknown): value is null | undefined {
  return value == null;
}

/**
 * Извлекает название паблика из телеграм ссылки
 * @param link - ссылка на телеграм паблик (например, https://t.me/velach_bot)
 * @returns название паблика или null если не удалось извлечь
 */
export function extractTelegramPubName(link: string | null | undefined): string | null {
  if (!link) {
    return null;
  }

  // Регулярное выражение для извлечения названия паблика
  const match = link.match(/(?:https?:\/\/)?(?:t\.me\/|telegram\.me\/)([a-zA-Z0-9_]{5,})/);
  
  if (match && match[1]) {
    return match[1];
  }

  return null;
}
