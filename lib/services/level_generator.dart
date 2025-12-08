import 'dart:math';
import 'package:flutter/material.dart';
import '../core/utils/color_palette.dart';
import '../models/color_unit.dart';
import '../models/level_model.dart';
import '../models/tube_model.dart';

class LevelGenerator {
  final Random _rng;

  LevelGenerator({Random? random}) : _rng = random ?? Random();

  LevelModel generate({
    LevelDifficulty difficulty = LevelDifficulty.easy,
    int tubeCapacity = 4,
    String? id,
  }) {
    final config = _configFor(difficulty, tubeCapacity);
    final colors = _pickColors(config.colorCount);
    final tubes = _buildShuffledTubes(colors, tubeCapacity, config.extraEmptyTubes);
    final levelId = id ?? 'lvl_${DateTime.now().millisecondsSinceEpoch}';

    // Solve check; if accidentally solved, reshuffle once.
    if (tubes.every((t) => t.isEmpty || t.isUniform)) {
      final reshuffled = _buildShuffledTubes(colors, tubeCapacity, config.extraEmptyTubes);
      return LevelModel(
        id: levelId,
        name: config.name,
        difficulty: difficulty,
        tubeCapacity: tubeCapacity,
        colorCount: colors.length,
        tubes: reshuffled,
      );
    }

    return LevelModel(
      id: levelId,
      name: config.name,
      difficulty: difficulty,
      tubeCapacity: tubeCapacity,
      colorCount: colors.length,
      tubes: tubes,
    );
  }

  _LevelConfig _configFor(LevelDifficulty difficulty, int tubeCapacity) {
    switch (difficulty) {
      case LevelDifficulty.easy:
        return _LevelConfig(name: 'Easy ${tubeCapacity}x', colorCount: 4, extraEmptyTubes: 2);
      case LevelDifficulty.medium:
        return _LevelConfig(name: 'Medium ${tubeCapacity}x', colorCount: 5, extraEmptyTubes: 2);
      case LevelDifficulty.hard:
        return _LevelConfig(name: 'Hard ${tubeCapacity}x', colorCount: 6, extraEmptyTubes: 2);
      case LevelDifficulty.expert:
        return _LevelConfig(name: 'Expert ${tubeCapacity}x', colorCount: 7, extraEmptyTubes: 2);
    }
  }

  List<Color> _pickColors(int count) {
    final pool = [...ColorPalette.neon, ...ColorPalette.pastel];
    pool.shuffle(_rng);
    if (count <= pool.length) return pool.take(count).toList();
    // If asked more than palette, repeat shuffled colors.
    final result = <Color>[];
    while (result.length < count) {
      pool.shuffle(_rng);
      result.addAll(pool);
    }
    return result.take(count).toList();
  }

  List<TubeModel> _buildShuffledTubes(List<Color> colors, int capacity, int extraEmpty) {
    final units = <ColorUnit>[];
    for (final color in colors) {
      for (var i = 0; i < capacity; i++) {
        units.add(ColorUnit(color));
      }
    }
    units.shuffle(_rng);

    final totalTubes = colors.length + extraEmpty;
    final tubes = List.generate(totalTubes, (_) => TubeModel(capacity: capacity));
    var tubeIndex = 0;
    for (final unit in units) {
      tubes[tubeIndex].units.add(unit);
      tubeIndex = (tubeIndex + 1) % (totalTubes - extraEmpty);
    }
    return tubes;
  }
}

class _LevelConfig {
  final String name;
  final int colorCount;
  final int extraEmptyTubes;

  const _LevelConfig({
    required this.name,
    required this.colorCount,
    required this.extraEmptyTubes,
  });
}
