import 'dart:math';
import '../models/pawn.dart';
import '../game/ludo_engine.dart';
import 'ludo_ai.dart';

// KOLAY - Rastgele hamle
class AIEasy extends LudoAI {
  @override
  Future<Pawn?> chooseMove(LudoEngine engine) async {
    await Future.delayed(thinkingDuration);

    final possibleMoves = engine.getPossibleMoves();
    if (possibleMoves.isEmpty) return null;

    return possibleMoves[random.nextInt(possibleMoves.length)];
  }

  @override
  Duration get thinkingDuration => const Duration(milliseconds: 500);
}
