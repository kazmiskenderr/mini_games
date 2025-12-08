import 'dart:math';
import '../models/pawn.dart';
import '../models/player.dart';
import '../game/ludo_engine.dart';

abstract class LudoAI {
  final Random random = Random();

  // AI hamle seç
  Future<Pawn?> chooseMove(LudoEngine engine);

  // Bekleme süresi (düşünme animasyonu için)
  Duration get thinkingDuration => const Duration(milliseconds: 800);
}
