/* @name findById */
SELECT *
FROM "User"
WHERE "id" = :id;

/*
  @name insertUser
  @param values -> ((id, firstName, lastName, username, isBot, telegramPubLink)...)
*/
INSERT INTO "User" ("id", "firstName", "lastName", "username", "isBot", "telegramPubLink")
VALUES :values
RETURNING *;

/*
  @name updateUser
*/
UPDATE "User"
SET
  "firstName" = :firstName,
  "lastName" = :lastName,
  "username" = :username,
  "isBot" = :isBot,
  "telegramPubLink" = :telegramPubLink
WHERE "id" = :id
RETURNING *;
