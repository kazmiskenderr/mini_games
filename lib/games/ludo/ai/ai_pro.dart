import '../models/pawn.dart';
import '../game/ludo_engine.dart';
import '../game/ludo_rules.dart';
import 'ludo_ai.dart';

// USTA - Rakip hamlelerini tahmin eder, tehlike değerlendirir
class AIPro extends LudoAI {
  @override
  Future<Pawn?> chooseMove(LudoEngine engine) async {
    await Future.delayed(thinkingDuration);

    final possibleMoves = engine.getPossibleMoves();
    if (possibleMoves.isEmpty) return null;

    Pawn? bestPawn;
    int bestScore = -9999;

    for (var pawn in possibleMoves) {
      int score = _evaluateMoveWithThreat(pawn, engine);
      if (score > bestScore) {
        bestScore = score;
        bestPawn = pawn;
      }
    }

    return bestPawn ?? possibleMoves.first;
  }

  int _evaluateMoveWithThreat(Pawn pawn, LudoEngine engine) {
    int score = 0;
    int newPos = LudoRules.calculateNewPosition(pawn, engine.diceValue);

    // Rakip ye (+30)
    final killedPawn = LudoRules.checkKill(pawn, newPos, engine.players);
    if (killedPawn != null) score += 30;

    // Güvenli kareye git (+20)
    if (LudoRules.isSafeSquare(newPos)) score += 20;

    // Ev yoluna gir (+15)
    if (newPos >= 52) score += 15;

    // Tehlike değerlendirmesi
    int threat = _evaluateThreat(newPos, pawn, engine);
    score -= threat;

    // Eve yakınlık
    if (pawn.isInHomePath) {
      score += (58 - newPos) * 2; // Eve ne kadar yakınsa o kadar iyi
    }

    // Üste çıkart
    if (pawn.isInBase) score += 8;

    // İlerleme bonusu
    score += (newPos - pawn.position).abs().toInt();

    return score;
  }

  int _evaluateThreat(int position, Pawn pawn, LudoEngine engine) {
    if (LudoRules.isSafeSquare(position)) return 0;
    if (position >= 52) return 0; // Ev yolunda tehlike yok

    int threat = 0;

    // Rakip piyonlarına bak
    for (var player in engine.players) {
      if (player.color == pawn.color) continue;

      for (var opponentPawn in player.pawnsOnBoard) {
        int distance = (position - opponentPawn.position + 52) % 52;
        
        // 1-6 adım mesafedeki rakipler tehlikeli
        if (distance > 0 && distance <= 6) {
          threat += (7 - distance) * 5; // Yakın rakip = yüksek tehlike
        }
      }
    }

    return threat;
  }

  @override
  Duration get thinkingDuration => const Duration(milliseconds: 1200);
}
