import 'package:flutter/material.dart';
import '../models/tube_model.dart';

class TubeView extends StatelessWidget {
  final TubeModel tube;
  final bool selected;
  final VoidCallback onTap;

  const TubeView({super.key, required this.tube, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = selected ? theme.colorScheme.primary : theme.colorScheme.outline.withOpacity(0.4);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 74,
            height: 176,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [theme.colorScheme.surface, theme.colorScheme.surface.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: selected ? 2 : 1),
              boxShadow: [
                BoxShadow(color: borderColor.withOpacity(0.18), blurRadius: 16, offset: const Offset(0, 8)),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: List.generate(tube.capacity, (index) {
                final reversedIndex = tube.capacity - 1 - index;
                final hasColor = reversedIndex < tube.units.length;
                final color = hasColor ? tube.units[reversedIndex].color : Colors.transparent;
                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    decoration: BoxDecoration(
                      color: hasColor ? color : theme.colorScheme.surfaceVariant.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: hasColor
                            ? Colors.black.withOpacity(0.08)
                            : theme.colorScheme.outlineVariant.withOpacity(0.25),
                        width: 0.9,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
