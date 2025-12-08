import '../models/pawn.dart';
import '../game/ludo_engine.dart';
import '../game/ludo_rules.dart';
import 'ludo_ai.dart';

// ORTA - Güvenli hamleleri önceliklendirir
class AINormal extends LudoAI {
  @override
  Future<Pawn?> chooseMove(LudoEngine engine) async {
    await Future.delayed(thinkingDuration);

    final possibleMoves = engine.getPossibleMoves();
    if (possibleMoves.isEmpty) return null;

    // Öncelik: Güvenli kareye git
    for (var pawn in possibleMoves) {
      int newPos = LudoRules.calculateNewPosition(pawn, engine.diceValue);
      if (LudoRules.isSafeSquare(newPos)) {
        return pawn;
      }
    }

    // Ev yoluna gir
    for (var pawn in possibleMoves) {
      int newPos = LudoRules.calculateNewPosition(pawn, engine.diceValue);
      if (newPos >= 52) {
        return pawn;
      }
    }

    // Üste çıkar (6 attıysa)
    for (var pawn in possibleMoves) {
      if (pawn.isInBase) {
        return pawn;
      }
    }

    // Rastgele
    return possibleMoves[random.nextInt(possibleMoves.length)];
  }

  @override
  Duration get thinkingDuration => const Duration(milliseconds: 700);
}
