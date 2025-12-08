import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/utils/haptics.dart';
import '../../models/level_model.dart';
import '../../router/color_routes.dart';
import '../../services/level_generator.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  late final LevelGenerator _generator;
  late final List<LevelModel> _levels;

  @override
  void initState() {
    super.initState();
    _generator = LevelGenerator(random: Random(77));
    _levels = _generatePreset();
  }

  List<LevelModel> _generatePreset() {
    final presets = <LevelModel>[];
    void add(int count, LevelDifficulty diff, int capacity) {
      for (var i = 0; i < count; i++) {
        presets.add(_generator.generate(
          difficulty: diff,
          tubeCapacity: capacity,
          id: '${diff.name}_${capacity}x_$i',
        ));
      }
    }

    add(3, LevelDifficulty.easy, 4);
    add(3, LevelDifficulty.medium, 4);
    add(2, LevelDifficulty.hard, 4);
    add(2, LevelDifficulty.expert, 5);
    return presets;
  }

  void _openLevel(LevelModel level) {
    Navigator.pushNamed(context, ColorRoutes.game, arguments: level);
    Haptics.selection();
  }

  Color _difficultyColor(LevelDifficulty difficulty, ColorScheme scheme) {
    switch (difficulty) {
      case LevelDifficulty.easy:
        return Colors.greenAccent.shade400;
      case LevelDifficulty.medium:
        return scheme.primary;
      case LevelDifficulty.hard:
        return Colors.deepOrangeAccent.shade200;
      case LevelDifficulty.expert:
        return Colors.pinkAccent.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seviye Seç'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.9,
        ),
        itemCount: _levels.length,
        itemBuilder: (context, index) {
          final level = _levels[index];
          final color = _difficultyColor(level.difficulty, theme.colorScheme);
          return GestureDetector(
            onTap: () => _openLevel(level),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.18), blurRadius: 16, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(level.difficulty.label, style: theme.textTheme.labelMedium?.copyWith(color: color, fontWeight: FontWeight.bold)),
                      ),
                      Text('${level.tubeCapacity}x', style: theme.textTheme.labelMedium),
                    ],
                  ),
                  const Spacer(),
                  Text(level.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text('${level.colorCount} renk, ${level.tubes.length} tüp',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(4, (i) => Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            height: 6,
                            decoration: BoxDecoration(
                              color: i < 3 ? color.withOpacity(0.5 + (i * 0.15)) : theme.colorScheme.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        )),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
