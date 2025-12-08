import 'level_model.dart';
import 'move_record.dart';
import 'tube_model.dart';

class GameState {
  final String levelId;
  final List<TubeModel> tubes;
  final int moves;
  final List<MoveRecord> history;
  final bool isCompleted;
  final int hintsUsed;
  final Duration elapsed;

  const GameState({
    required this.levelId,
    required this.tubes,
    this.moves = 0,
    this.history = const [],
    this.isCompleted = false,
    this.hintsUsed = 0,
    this.elapsed = Duration.zero,
  });

  GameState copyWith({
    List<TubeModel>? tubes,
    int? moves,
    List<MoveRecord>? history,
    bool? isCompleted,
    int? hintsUsed,
    Duration? elapsed,
  }) {
    return GameState(
      levelId: levelId,
      tubes: tubes?.map((t) => t.copy()).toList() ?? this.tubes.map((t) => t.copy()).toList(),
      moves: moves ?? this.moves,
      history: history ?? List<MoveRecord>.from(this.history),
      isCompleted: isCompleted ?? this.isCompleted,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      elapsed: elapsed ?? this.elapsed,
    );
  }

  bool get isSolved => tubes.every((tube) => tube.isEmpty || tube.isUniform);

  Map<String, dynamic> toJson() => {
        'levelId': levelId,
        'moves': moves,
        'history': history.map((m) => m.toJson()).toList(),
        'isCompleted': isCompleted,
        'hintsUsed': hintsUsed,
        'elapsedMs': elapsed.inMilliseconds,
        'tubes': tubes.map((t) => t.toJson()).toList(),
      };

  factory GameState.fromJson(Map<String, dynamic> json) => GameState(
        levelId: json['levelId'] as String,
        moves: json['moves'] as int? ?? 0,
        history: (json['history'] as List<dynamic>? ?? [])
            .map((e) => MoveRecord.fromJson(e as Map<String, dynamic>))
            .toList(),
        isCompleted: json['isCompleted'] as bool? ?? false,
        hintsUsed: json['hintsUsed'] as int? ?? 0,
        elapsed: Duration(milliseconds: json['elapsedMs'] as int? ?? 0),
        tubes: (json['tubes'] as List<dynamic>)
            .map((e) => TubeModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  factory GameState.fromLevel(LevelModel level) => GameState(
        levelId: level.id,
        tubes: level.tubes.map((t) => t.copy()).toList(),
      );
}
