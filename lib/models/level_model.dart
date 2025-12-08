import 'tube_model.dart';

enum LevelDifficulty { easy, medium, hard, expert }

extension LevelDifficultyLabel on LevelDifficulty {
  String get label => switch (this) {
        LevelDifficulty.easy => 'Easy',
        LevelDifficulty.medium => 'Medium',
        LevelDifficulty.hard => 'Hard',
        LevelDifficulty.expert => 'Expert',
      };

  static LevelDifficulty fromString(String value) {
    return LevelDifficulty.values.firstWhere(
      (d) => d.name == value,
      orElse: () => LevelDifficulty.easy,
    );
  }
}

class LevelModel {
  final String id;
  final String name;
  final LevelDifficulty difficulty;
  final int tubeCapacity;
  final int colorCount;
  final List<TubeModel> tubes;

  const LevelModel({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.tubeCapacity,
    required this.colorCount,
    required this.tubes,
  });

  bool get isSolved => tubes.every((tube) => tube.isEmpty || tube.isUniform);

  LevelModel copyWith({List<TubeModel>? tubes}) => LevelModel(
        id: id,
        name: name,
        difficulty: difficulty,
        tubeCapacity: tubeCapacity,
        colorCount: colorCount,
        tubes: tubes?.map((t) => t.copy()).toList() ?? this.tubes.map((t) => t.copy()).toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'difficulty': difficulty.name,
        'tubeCapacity': tubeCapacity,
        'colorCount': colorCount,
        'tubes': tubes.map((t) => t.toJson()).toList(),
      };

  factory LevelModel.fromJson(Map<String, dynamic> json) => LevelModel(
        id: json['id'] as String,
        name: json['name'] as String,
        difficulty: LevelDifficultyLabel.fromString(json['difficulty'] as String),
        tubeCapacity: json['tubeCapacity'] as int,
        colorCount: json['colorCount'] as int,
        tubes: (json['tubes'] as List<dynamic>)
            .map((e) => TubeModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
