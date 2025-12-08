import 'ludo_color.dart';
import 'pawn.dart';
import 'game_mode.dart';

class Player {
  final LudoColor color;
  final bool isBot;
  final AIDifficulty? aiDifficulty;
  final List<Pawn> pawns;
  int finishedPawns = 0;

  Player({
    required this.color,
    this.isBot = false,
    this.aiDifficulty,
  }) : pawns = List.generate(
          4,
          (i) => Pawn(color: color, id: i),
        );

  bool get hasWon => finishedPawns >= 4;

  List<Pawn> get activePawns => pawns.where((p) => p.canMove).toList();

  List<Pawn> get pawnsInBase => pawns.where((p) => p.isInBase).toList();

  List<Pawn> get pawnsOnBoard => pawns.where((p) => p.isOnBoard).toList();

  void updatePawn(int pawnId, {int? position, bool? isInBase, bool? isFinished}) {
    final pawn = pawns[pawnId];
    pawns[pawnId] = pawn.copyWith(
      position: position,
      isInBase: isInBase,
      isFinished: isFinished,
    );
    if (isFinished == true) {
      finishedPawns++;
    }
  }

  @override
  String toString() => '${color.turkishName} ${isBot ? "(Bot)" : "(Oyuncu)"}';
}
