import { join } from 'path';

import { PoolClient } from 'pg';

import { USER_IDS } from 'src/common/database/test-database';
import { Context } from 'src/common/types/bot';
import { disconnect } from 'src/common/database/connection';
import {
  getTestBotInfo,
  getTestingModule,
  getTestTelegram,
  getTestConnection,
} from 'src/common/utils/test-utils';
import { MiddlewaresModule } from 'src/modules/telegram-bot/middlewares/middlewares.module';
import { TemplatesModule } from 'src/modules/telegram-bot/templates/templates.module';
import { TemplatesService } from 'src/modules/telegram-bot/templates/templates.service';
import { EntitiesModule } from 'src/modules/entities/entities.module';

import { SetTelegramPubCommandService } from './set-telegram-pub-command.service';

describe('Test SetTelegramPubCommandService', () => {
  let service: SetTelegramPubCommandService;
  let templatesService: TemplatesService;
  let connection: PoolClient;

  beforeEach(async () => {
    const module = await getTestingModule(
      [SetTelegramPubCommandService],
      [MiddlewaresModule, TemplatesModule, EntitiesModule],
    );

    service = module.get(SetTelegramPubCommandService);
    templatesService = module.get(TemplatesService);
    connection = await getTestConnection();
    await connection.query('START TRANSACTION');
  });

  afterEach(async () => {
    await connection.query('ROLLBACK');
    connection.release();
  });

  afterAll(async () => {
    await disconnect();
  });

  test('Service instantiated', async () => {
    expect(service).toBeInstanceOf(SetTelegramPubCommandService);
  });

  test('Sets telegram pub link for valid channel', async () => {
    const doneText = await templatesService.renderTemplate(
      join(__dirname, 'templates', 'done.mustache'),
      {},
    );

    const telegram = getTestTelegram();

    const ctx = new Context(
      {
        update_id: 1,
        message: {
          message_id: 2,
          from: {
            id: Number(USER_IDS.BILLY),
            first_name: 'Billy',
            is_bot: false,
          },
          chat: {
            id: 265,
            type: 'private',
            first_name: 'Billy',
          },
          text: '/settelegrampub',
          date: Date.now(),
          reply_to_message: {
            message_id: 1,
            from: {
              id: Number(USER_IDS.BILLY),
              first_name: 'Billy',
              is_bot: false,
            },
            chat: {
              id: 265,
              type: 'private',
              first_name: 'Billy',
            },
            text: 'https://t.me/my_channel',
            date: Date.now(),
            reply_to_message: undefined,
          },
        },
      },
      telegram,
      getTestBotInfo(),
    );

    ctx.database = {
      connection,
    };

    await service['processCommand'](ctx);

    expect(telegram.sendMessage).toBeCalledWith(265, doneText, {
      message_thread_id: undefined,
      reply_parameters: {
        message_id: 2,
      },
      parse_mode: 'MarkdownV2',
    });
  });

  test('Sets telegram pub link for alphanumeric channel', async () => {
    const doneText = await templatesService.renderTemplate(
      join(__dirname, 'templates', 'done.mustache'),
      {},
    );

    const telegram = getTestTelegram();

    const ctx = new Context(
      {
        update_id: 1,
        message: {
          message_id: 2,
          from: {
            id: Number(USER_IDS.BILLY),
            first_name: 'Billy',
            is_bot: false,
          },
          chat: {
            id: 265,
            type: 'private',
            first_name: 'Billy',
          },
          text: '/settelegrampub',
          date: Date.now(),
          reply_to_message: {
            message_id: 1,
            from: {
              id: Number(USER_IDS.BILLY),
              first_name: 'Billy',
              is_bot: false,
            },
            chat: {
              id: 265,
              type: 'private',
              first_name: 'Billy',
            },
            text: 'https://t.me/my_channel_test',
            date: Date.now(),
            reply_to_message: undefined,
          },
        },
      },
      telegram,
      getTestBotInfo(),
    );

    ctx.database = {
      connection,
    };

    await service['processCommand'](ctx);

    expect(telegram.sendMessage).toBeCalledWith(265, doneText, {
      message_thread_id: undefined,
      reply_parameters: {
        message_id: 2,
      },
      parse_mode: 'MarkdownV2',
    });
  });

  test('Sets telegram pub link for channel with underscores and dashes', async () => {
    const doneText = await templatesService.renderTemplate(
      join(__dirname, 'templates', 'done.mustache'),
      {},
    );

    const telegram = getTestTelegram();

    const ctx = new Context(
      {
        update_id: 1,
        message: {
          message_id: 2,
          from: {
            id: Number(USER_IDS.BILLY),
            first_name: 'Billy',
            is_bot: false,
          },
          chat: {
            id: 265,
            type: 'private',
            first_name: 'Billy',
          },
          text: '/settelegrampub',
          date: Date.now(),
          reply_to_message: {
            message_id: 1,
            from: {
              id: Number(USER_IDS.BILLY),
              first_name: 'Billy',
              is_bot: false,
            },
            chat: {
              id: 265,
              type: 'private',
              first_name: 'Billy',
            },
            text: 'https://t.me/my-channel_test',
            date: Date.now(),
            reply_to_message: undefined,
          },
        },
      },
      telegram,
      getTestBotInfo(),
    );

    ctx.database = {
      connection,
    };

    await service['processCommand'](ctx);

    expect(telegram.sendMessage).toBeCalledWith(265, doneText, {
      message_thread_id: undefined,
      reply_parameters: {
        message_id: 2,
      },
      parse_mode: 'MarkdownV2',
    });
  });

  test('Rejects on invalid string', async () => {
    const invalidLinkText = await templatesService.renderTemplate(
      join(__dirname, 'templates', 'invalid-link.mustache'),
      {},
    );

    const telegram = getTestTelegram();

    const ctx = new Context(
      {
        update_id: 1,
        message: {
          message_id: 2,
          from: {
            id: Number(USER_IDS.BILLY),
            first_name: 'Billy',
            is_bot: false,
          },
          chat: {
            id: 265,
            type: 'private',
            first_name: 'Billy',
          },
          text: '/settelegrampub',
          date: Date.now(),
          reply_to_message: {
            message_id: 1,
            from: {
              id: Number(USER_IDS.BILLY),
              first_name: 'Billy',
              is_bot: false,
            },
            chat: {
              id: 265,
              type: 'private',
              first_name: 'Billy',
            },
            text: 'httpwww.srava.com/athletes/123456',
            date: Date.now(),
            reply_to_message: undefined,
          },
        },
      },
      telegram,
      getTestBotInfo(),
    );

    ctx.database = {
      connection,
    };

    await service['processCommand'](ctx);

    expect(telegram.sendMessage).toBeCalledWith(265, invalidLinkText, {
      message_thread_id: undefined,
      reply_parameters: {
        message_id: 2,
      },
      parse_mode: 'MarkdownV2',
    });
  });

  test('Rejects if no reply message provided', async () => {
    const noReplyToText = await templatesService.renderTemplate(
      join(__dirname, 'templates', 'no-reply-to.mustache'),
      {},
    );

    const telegram = getTestTelegram();

    const ctx = new Context(
      {
        update_id: 1,
        message: {
          message_id: 2,
          from: {
            id: Number(USER_IDS.BILLY),
            first_name: 'Billy',
            is_bot: false,
          },
          chat: {
            id: 265,
            type: 'private',
            first_name: 'Billy',
          },
          text: '/settelegrampub',
          date: Date.now(),
        },
      },
      telegram,
      getTestBotInfo(),
    );

    ctx.database = {
      connection,
    };

    await service['processCommand'](ctx);

    expect(telegram.sendMessage).toBeCalledWith(265, noReplyToText, {
      message_thread_id: undefined,
      reply_parameters: {
        message_id: 2,
      },
      parse_mode: 'MarkdownV2',
    });
  });

  test('Rejects if reply message is from another user', async () => {
    const notYourMessageText = await templatesService.renderTemplate(
      join(__dirname, 'templates', 'not-your-message.mustache'),
      {},
    );

    const telegram = getTestTelegram();

    const ctx = new Context(
      {
        update_id: 1,
        message: {
          message_id: 2,
          from: {
            id: Number(USER_IDS.BILLY),
            first_name: 'Billy',
            is_bot: false,
          },
          chat: {
            id: 265,
            type: 'private',
            first_name: 'Billy',
          },
          text: '/settelegrampub',
          date: Date.now(),
          reply_to_message: {
            message_id: 1,
            from: {
              id: Number(USER_IDS.VAN),
              first_name: 'Van',
              is_bot: false,
            },
            chat: {
              id: 265,
              type: 'private',
              first_name: 'Billy',
            },
            text: 'https://t.me/my_channel
            date: Date.now(),
            reply_to_message: undefined,
          },
        },
      },
      telegram,
      getTestBotInfo(),
    );

    ctx.database = {
      connection,
    };

    await service['processCommand'](ctx);

    expect(telegram.sendMessage).toBeCalledWith(265, notYourMessageText, {
      message_thread_id: undefined,
      reply_parameters: {
        message_id: 2,
      },
      parse_mode: 'MarkdownV2',
    });
  });
});
