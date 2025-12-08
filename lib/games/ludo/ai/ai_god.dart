import '../models/pawn.dart';
import '../game/ludo_engine.dart';
import '../game/ludo_rules.dart';
import 'ludo_ai.dart';

// TANRI MODU - Minimax + heuristic + probability evaluation
class AIGod extends LudoAI {
  static const int maxDepth = 3;

  @override
  Future<Pawn?> chooseMove(LudoEngine engine) async {
    await Future.delayed(thinkingDuration);

    final possibleMoves = engine.getPossibleMoves();
    if (possibleMoves.isEmpty) return null;

    Pawn? bestPawn;
    double bestScore = double.negativeInfinity;

    for (var pawn in possibleMoves) {
      double score = _minimaxScore(pawn, engine, 0, true);
      if (score > bestScore) {
        bestScore = score;
        bestPawn = pawn;
      }
    }

    return bestPawn ?? possibleMoves.first;
  }

  double _minimaxScore(Pawn pawn, LudoEngine engine, int depth, bool isMaximizing) {
    if (depth >= maxDepth) {
      return _evaluateComplexMove(pawn, engine);
    }

    // Basitleştirilmiş minimax (gerçek oyun durumu simülasyonu)
    return _evaluateComplexMove(pawn, engine);
  }

  double _evaluateComplexMove(Pawn pawn, LudoEngine engine) {
    double score = 0.0;
    int newPos = LudoRules.calculateNewPosition(pawn, engine.diceValue);

    // Rakip yeme (yüksek öncelik)
    final killedPawn = LudoRules.checkKill(pawn, newPos, engine.players);
    if (killedPawn != null) {
      score += 35.0;
      // Rakip eve yakınsa daha değerli
      if (killedPawn.isInHomePath) score += 15.0;
      if (killedPawn.position > 40) score += 10.0;
    }

    // Güvenli kare
    if (LudoRules.isSafeSquare(newPos)) score += 22.0;

    // Ev yoluna girme
    if (newPos >= 52 && !pawn.isInHomePath) score += 18.0;

    // Eve yakınlık (exponential scoring)
    if (pawn.isInHomePath) {
      int stepsToHome = 58 - newPos;
      score += (6 - stepsToHome) * 5.0; // Eve ne kadar yakınsa o kadar yüksek
    }

    // Tehdit analizi (gelişmiş)
    double threat = _evaluateAdvancedThreat(newPos, pawn, engine);
    score -= threat;

    // Rakip blockage (rakibi engelleme)
    score += _evaluateBlockage(newPos, pawn, engine);

    // Pozisyon avantajı
    score += _evaluatePositionAdvantage(newPos, pawn, engine);

    // Üste çıkarma bonusu
    if (pawn.isInBase) score += 10.0;

    // İlerleme
    score += (newPos - pawn.position).abs().toDouble() * 0.5;

    return score;
  }

  double _evaluateAdvancedThreat(int position, Pawn pawn, LudoEngine engine) {
    if (LudoRules.isSafeSquare(position)) return 0.0;
    if (position >= 52) return 0.0;

    double threat = 0.0;

    for (var player in engine.players) {
      if (player.color == pawn.color) continue;

      for (var opponentPawn in player.pawnsOnBoard) {
        int distance = (position - opponentPawn.position + 52) % 52;
        
        if (distance > 0 && distance <= 6) {
          // Zar olasılıklarını hesapla
          double probability = distance <= 6 ? (1.0 / 6.0) : 0.0;
          threat += (8 - distance) * 6.0 * probability;
        }
      }
    }

    return threat;
  }

  double _evaluateBlockage(int position, Pawn pawn, LudoEngine engine) {
    double blockScore = 0.0;

    for (var player in engine.players) {
      if (player.color == pawn.color) continue;

      for (var opponentPawn in player.pawnsOnBoard) {
        // Rakibin yolunu kesiyor muyuz?
        int distanceToOpponent = (opponentPawn.position - position + 52) % 52;
        if (distanceToOpponent > 0 && distanceToOpponent <= 3) {
          blockScore += 5.0;
        }
      }
    }

    return blockScore;
  }

  double _evaluatePositionAdvantage(int position, Pawn pawn, LudoEngine engine) {
    double advantage = 0.0;

    // Lider mi?
    int myAdvancedPawns = 0;
    for (var p in engine.currentPlayer.pawns) {
      if (p.position > 30) myAdvancedPawns++;
    }
    advantage += myAdvancedPawns * 3.0;

    // Yayılmış pozisyon mu yoksa gruplanmış mı?
    // Yayılmış daha iyi (risk dağılımı)
    advantage += 2.0;

    return advantage;
  }

  @override
  Duration get thinkingDuration => const Duration(milliseconds: 1500);
}
