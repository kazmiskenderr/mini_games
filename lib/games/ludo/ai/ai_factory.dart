import '../models/game_mode.dart';
import '../models/ludo_color.dart';
import '../models/player.dart';
import 'ai_easy.dart';
import 'ai_normal.dart';
import 'ai_hard.dart';
import 'ai_pro.dart';
import 'ai_god.dart';
import 'ludo_ai.dart';

class AIFactory {
  static LudoAI createAI(AIDifficulty difficulty) {
    switch (difficulty) {
      case AIDifficulty.easy:
        return AIEasy();
      case AIDifficulty.normal:
        return AINormal();
      case AIDifficulty.hard:
        return AIHard();
      case AIDifficulty.pro:
        return AIPro();
      case AIDifficulty.godMode:
        return AIGod();
    }
  }

  static List<Player> createPlayers(GameMode mode, AIDifficulty? aiDifficulty) {
    switch (mode) {
      case GameMode.singlePlayer:
        return [
          Player(color: LudoColor.red, isBot: false),
          Player(color: LudoColor.yellow, isBot: true, aiDifficulty: aiDifficulty ?? AIDifficulty.normal),
        ];
      case GameMode.twoPlayer:
        return [
          Player(color: LudoColor.red, isBot: false),
          Player(color: LudoColor.blue, isBot: false),
        ];
      case GameMode.fourPlayer:
        return [
          Player(color: LudoColor.red, isBot: false),
          Player(color: LudoColor.yellow, isBot: false),
          Player(color: LudoColor.green, isBot: false),
          Player(color: LudoColor.blue, isBot: false),
        ];
    }
  }
}
