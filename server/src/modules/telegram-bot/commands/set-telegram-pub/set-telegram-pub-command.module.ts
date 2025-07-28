import { Module } from '@nestjs/common';

import { TemplatesModule } from 'src/modules/telegram-bot/templates/templates.module';
import { MiddlewaresModule } from 'src/modules/telegram-bot/middlewares/middlewares.module';
import { EntitiesModule } from 'src/modules/entities/entities.module';

import { SetTelegramPubCommandService } from './set-telegram-pub-command.service';

@Module({
  imports: [TemplatesModule, MiddlewaresModule, EntitiesModule],
  providers: [SetTelegramPubCommandService],
  exports: [SetTelegramPubCommandService],
})
export class SetTelegramPubCommandModule {}
