import 'dart:math';
import '../models/ludo_color.dart';
import '../models/player.dart';
import '../models/pawn.dart';
import '../models/game_mode.dart';
import 'ludo_rules.dart';

class LudoEngine {
  final GameMode gameMode;
  final List<Player> players;
  int currentPlayerIndex = 0;
  int diceValue = 0;
  bool hasRolled = false;
  bool canRollAgain = false;
  final Random _random = Random();

  LudoEngine({
    required this.gameMode,
    required this.players,
  });

  Player get currentPlayer => players[currentPlayerIndex];

  bool get isCurrentPlayerBot => currentPlayer.isBot;

  // Zar at
  int rollDice() {
    if (hasRolled && !canRollAgain) return diceValue;
    
    diceValue = _random.nextInt(6) + 1;
    hasRolled = true;
    canRollAgain = LudoRules.shouldRollAgain(diceValue);
    
    return diceValue;
  }

  // Hamle yap
  MoveResult? movePawn(Pawn pawn) {
    if (!hasRolled) return null;
    if (!LudoRules.canPawnMove(pawn, diceValue, players)) return null;

    int newPosition = LudoRules.calculateNewPosition(pawn, diceValue);
    
    // Yeme kontrolü
    Pawn? killedPawn = LudoRules.checkKill(pawn, newPosition, players);

    // Hareketi uygula
    final player = players.firstWhere((p) => p.color == pawn.color);
    
    if (pawn.isInBase) {
      player.updatePawn(pawn.id, position: newPosition, isInBase: false);
    } else if (newPosition == 58) {
      player.updatePawn(pawn.id, position: newPosition, isFinished: true);
    } else {
      player.updatePawn(pawn.id, position: newPosition);
    }

    // Eğer piyon yendiyse eve gönder
    if (killedPawn != null) {
      final killedPlayer = players.firstWhere((p) => p.color == killedPawn.color);
      killedPlayer.updatePawn(killedPawn.id, position: -1, isInBase: true);
    }

    // Hamle sonrası
    if (!canRollAgain) {
      nextTurn();
    } else {
      hasRolled = false; // Tekrar atabilir
    }

    return MoveResult(
      movedPawn: player.pawns[pawn.id],
      killedPawn: killedPawn,
      rolledAgain: canRollAgain,
    );
  }

  // Sırayı geçir
  void nextTurn() {
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    hasRolled = false;
    canRollAgain = false;
    diceValue = 0;
  }

  // Hamle yapılabilir mi kontrol
  bool hasValidMoves() {
    if (!hasRolled) return false;
    return LudoRules.hasValidMove(currentPlayer, diceValue, players);
  }

  // Oyuncu geçer (hamle yoksa)
  void skipTurn() {
    if (!hasValidMoves()) {
      nextTurn();
    }
  }

  // Kazanan var mı?
  Player? checkWinner() {
    return LudoRules.checkWinner(players);
  }

  // Olası hamleler
  List<Pawn> getPossibleMoves() {
    if (!hasRolled) return [];
    return currentPlayer.pawns
        .where((p) => LudoRules.canPawnMove(p, diceValue, players))
        .toList();
  }
}

class MoveResult {
  final Pawn movedPawn;
  final Pawn? killedPawn;
  final bool rolledAgain;

  MoveResult({
    required this.movedPawn,
    this.killedPawn,
    this.rolledAgain = false,
  });
}
