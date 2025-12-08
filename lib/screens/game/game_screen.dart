import 'package:flutter/material.dart';
import '../../core/utils/haptics.dart';
import '../../models/game_state.dart';
import '../../models/level_model.dart';
import '../../models/move_record.dart';
import '../../models/tube_model.dart';
import '../../services/hint_service.dart';
import '../../services/move_engine.dart';
import '../../widgets/tube_view.dart';

class GameScreen extends StatefulWidget {
  final LevelModel level;
  const GameScreen({super.key, required this.level});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameState _state;
  late final MoveEngine _engine;
  late final HintService _hintService;
  late final List<TubeModel> _seedTubes;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _engine = MoveEngine();
    _hintService = HintService(_engine);
    _seedTubes = widget.level.tubes.map((t) => t.copy()).toList();
    _state = GameState.fromLevel(widget.level);
  }

  void _onTubeTap(int index) {
    if (_state.isCompleted) return;
    if (_selectedIndex == null) {
      setState(() => _selectedIndex = index);
      return;
    }
    if (_selectedIndex == index) {
      setState(() => _selectedIndex = null);
      return;
    }

    final next = _engine.applyMove(_state, _selectedIndex!, index);
    final changed = !identical(next, _state);
    setState(() {
      _state = next;
      _selectedIndex = null;
    });
    if (!changed) return;

    if (_state.isCompleted) {
      Haptics.success();
      _showCompleted();
    } else {
      Haptics.selection();
    }
  }

  void _undo() {
    setState(() {
      _state = _engine.undo(_state);
      _selectedIndex = null;
    });
    Haptics.selection();
  }

  void _restart() {
    setState(() {
      _state = _engine.restartWith(_state, _seedTubes);
      _selectedIndex = null;
    });
    Haptics.warn();
  }

  void _hint() {
    if (_state.isCompleted) return;
    final MoveRecord? hint = _hintService.firstHint(_state);
    if (hint == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hamle yok')));
      return;
    }
    final hinted = _engine.applyMove(_state, hint.fromIndex, hint.toIndex);
    setState(() {
      _state = hinted.copyWith(hintsUsed: _state.hintsUsed + 1);
      _selectedIndex = null;
    });
    Haptics.selection();
  }

  void _showCompleted() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Tebrikler! Çözdün.'),
      duration: Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.level.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Yeniden başlat',
            onPressed: _restart,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.colorScheme.surface, theme.colorScheme.surfaceVariant.withOpacity(0.4)],
          ),
        ),
        child: Column(
          children: [
            _StatsBar(moves: _state.moves, hints: _state.hintsUsed, completed: _state.isCompleted),
            if (_state.isCompleted)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Colors.green),
                      const SizedBox(width: 10),
                      Expanded(child: Text('Tamamlandı, başka bir seviye seçmeyi dene.', style: theme.textTheme.bodyMedium)),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 700;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Center(
                      child: Wrap(
                        spacing: 18,
                        runSpacing: 18,
                        alignment: isWide ? WrapAlignment.start : WrapAlignment.center,
                        children: List.generate(_state.tubes.length, (index) {
                          final tube = _state.tubes[index];
                          final selected = _selectedIndex == index;
                          return TubeView(
                            tube: tube,
                            selected: selected,
                            onTap: () => _onTubeTap(index),
                          );
                        }),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.4)),
                        foregroundColor: theme.colorScheme.primary,
                      ),
                      onPressed: _undo,
                      icon: const Icon(Icons.undo_rounded),
                      label: const Text('Geri al'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _hint,
                      icon: const Icon(Icons.lightbulb_rounded),
                      label: const Text('İpucu'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsBar extends StatelessWidget {
  final int moves;
  final int hints;
  final bool completed;

  const _StatsBar({required this.moves, required this.hints, required this.completed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = completed ? Colors.greenAccent.shade400 : theme.colorScheme.primary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: theme.colorScheme.surface, boxShadow: [
        BoxShadow(color: theme.shadowColor.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4)),
      ]),
      child: Row(
        children: [
          _StatItem(icon: Icons.touch_app_rounded, label: 'Hamle', value: moves.toString(), color: color),
          const SizedBox(width: 16),
          _StatItem(icon: Icons.tips_and_updates_rounded, label: 'İpucu', value: hints.toString(), color: Colors.orangeAccent),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
                Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
