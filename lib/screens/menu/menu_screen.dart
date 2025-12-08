import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/utils/haptics.dart';
import '../../core/utils/color_palette.dart';
import '../../models/level_model.dart';
import '../../router/color_routes.dart';
import '../../services/level_generator.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late final LevelGenerator _generator;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _generator = LevelGenerator(random: Random(2025));
  }

  Future<void> _startQuickPlay() async {
    if (_loading) return;
    setState(() => _loading = true);
    final level = _generator.generate(difficulty: LevelDifficulty.medium, tubeCapacity: 4);
    await Haptics.selection();
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pushNamed(context, ColorRoutes.game, arguments: level);
  }

  void _openLevels() {
    Navigator.pushNamed(context, ColorRoutes.levels);
  }

  void _openSettings() {
    Navigator.pushNamed(context, ColorRoutes.settings);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final surface = theme.colorScheme.surface;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [surface, surface.withOpacity(0.55), primary.withOpacity(0.08)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Text('Color Tube Sort', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text('Pastel tüpler, temiz arayüz, rahatlatıcı oynanış.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
                const SizedBox(height: 24),
                _HeroCard(primary: primary),
                const SizedBox(height: 24),
                _MenuButton(
                  label: 'Hızlı Oyna',
                  icon: Icons.play_arrow_rounded,
                  onPressed: _startQuickPlay,
                  loading: _loading,
                  accent: primary,
                ),
                const SizedBox(height: 12),
                _MenuButton(
                  label: 'Seviye Seç',
                  icon: Icons.view_week_rounded,
                  onPressed: _openLevels,
                  accent: Colors.tealAccent.shade400,
                ),
                const SizedBox(height: 12),
                _MenuButton(
                  label: 'Ayarlar',
                  icon: Icons.tune_rounded,
                  onPressed: _openSettings,
                  accent: Colors.orangeAccent.shade200,
                ),
                const SizedBox(height: 12),
                _MenuButton(
                  label: 'Ana Menüye Dön',
                  icon: Icons.home_rounded,
                  onPressed: () => Navigator.pop(context),
                  accent: Colors.purpleAccent.shade200,
                ),
                const SizedBox(height: 28),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: ColorPalette.pastel.take(7).map((c) => _Dot(color: c)).toList(),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final Color primary;
  const _HeroCard({required this.primary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: primary.withOpacity(0.15), blurRadius: 24, offset: const Offset(0, 12)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Zen modu', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Yeni', style: theme.textTheme.labelMedium?.copyWith(color: primary, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Renkleri tüplere doğru sıralayarak rahatla ve odaklan.',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _Chip(icon: Icons.auto_awesome_rounded, label: 'Pastel palet'),
              _Chip(icon: Icons.bolt_rounded, label: 'Hızlı başlangıç'),
              _Chip(icon: Icons.psychology_rounded, label: 'Düşün & çöz'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool loading;
  final Color accent;

  const _MenuButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.loading = false,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          backgroundColor: accent.withOpacity(0.15),
          foregroundColor: theme.colorScheme.onSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        onPressed: loading ? null : onPressed,
        icon: loading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: accent),
              )
            : Icon(icon, color: accent),
        label: Text(label, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(label, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8, spreadRadius: 1)],
      ),
    );
  }
}
