import 'ludo_color.dart';

class Pawn {
  final LudoColor color;
  final int id; // 0-3 for each color
  int position; // -1 = home, 0-51 = board, 52-57 = home path, 58 = finished
  bool isInBase;
  bool isFinished;

  Pawn({
    required this.color,
    required this.id,
    this.position = -1,
    this.isInBase = true,
    this.isFinished = false,
  });

  Pawn copyWith({
    int? position,
    bool? isInBase,
    bool? isFinished,
  }) {
    return Pawn(
      color: color,
      id: id,
      position: position ?? this.position,
      isInBase: isInBase ?? this.isInBase,
      isFinished: isFinished ?? this.isFinished,
    );
  }

  bool get canMove => !isFinished;

  bool get isOnBoard => position >= 0 && position < 52;
  
  bool get isInHomePath => position >= 52 && position < 58;

  @override
  String toString() => '${color.turkishName} Piyon $id (pos: $position)';
}
