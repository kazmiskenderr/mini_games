import 'dart:convert';

class PlayerProgress {
  final int highestUnlocked;
  final Set<String> completedLevels;
  final Map<String, int> bestMoves;
  final int totalHints;

  const PlayerProgress({
    this.highestUnlocked = 1,
    this.completedLevels = const {},
    this.bestMoves = const {},
    this.totalHints = 0,
  });

  PlayerProgress copyWith({
    int? highestUnlocked,
    Set<String>? completedLevels,
    Map<String, int>? bestMoves,
    int? totalHints,
  }) {
    return PlayerProgress(
      highestUnlocked: highestUnlocked ?? this.highestUnlocked,
      completedLevels: completedLevels ?? this.completedLevels,
      bestMoves: bestMoves ?? this.bestMoves,
      totalHints: totalHints ?? this.totalHints,
    );
  }

  Map<String, dynamic> toJson() => {
        'highestUnlocked': highestUnlocked,
        'completedLevels': completedLevels.toList(),
        'bestMoves': bestMoves,
        'totalHints': totalHints,
      };

  factory PlayerProgress.fromJson(Map<String, dynamic> json) => PlayerProgress(
        highestUnlocked: json['highestUnlocked'] as int? ?? 1,
        completedLevels: Set<String>.from(json['completedLevels'] as List<dynamic>? ?? []),
        bestMoves: (json['bestMoves'] as Map<String, dynamic>? ?? {})
            .map((key, value) => MapEntry(key, (value as num).toInt())),
        totalHints: json['totalHints'] as int? ?? 0,
      );

  String toStorage() => jsonEncode(toJson());
  static PlayerProgress fromStorage(String? raw) {
    if (raw == null || raw.isEmpty) return const PlayerProgress();
    try {
      return PlayerProgress.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const PlayerProgress();
    }
  }
}
