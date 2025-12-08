import '../models/pawn.dart';
import '../game/ludo_engine.dart';
import '../game/ludo_rules.dart';
import 'ludo_ai.dart';

// ZOR - Stratejik hamle hesaplama
class AIHard extends LudoAI {
  @override
  Future<Pawn?> chooseMove(LudoEngine engine) async {
    await Future.delayed(thinkingDuration);

    final possibleMoves = engine.getPossibleMoves();
    if (possibleMoves.isEmpty) return null;

    Pawn? bestPawn;
    int bestScore = -9999;

    for (var pawn in possibleMoves) {
      int score = _evaluateMove(pawn, engine);
      if (score > bestScore) {
        bestScore = score;
        bestPawn = pawn;
      }
    }

    return bestPawn ?? possibleMoves.first;
  }

  int _evaluateMove(Pawn pawn, LudoEngine engine) {
    int score = 0;
    int newPos = LudoRules.calculateNewPosition(pawn, engine.diceValue);

    // Rakip ye (+30)
    final killedPawn = LudoRules.checkKill(pawn, newPos, engine.players);
    if (killedPawn != null) score += 30;

    // Güvenli kareye git (+20)
    if (LudoRules.isSafeSquare(newPos)) score += 20;

    // Ev yoluna gir (+15)
    if (newPos >= 52) score += 15;

    // Eve yaklaş (+10)
    if (pawn.isInHomePath) score += 10;

    // Üste çıkart (+8)
    if (pawn.isInBase) score += 8;

    // İleriye git
    score += (newPos - pawn.position).abs().toInt();

    return score;
  }

  @override
  Duration get thinkingDuration => const Duration(milliseconds: 1000);
}
