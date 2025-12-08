import 'package:flutter/material.dart';
import '../../core/utils/haptics.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _haptics;

  @override
  void initState() {
    super.initState();
    _haptics = Haptics.enabled;
  }

  void _toggleHaptics(bool value) {
    setState(() => _haptics = value);
    Haptics.enabled = value;
    Haptics.selection();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        children: [
          SwitchListTile.adaptive(
            title: const Text('Titreşim / Haptics'),
            subtitle: const Text('Hamlelerde dokunsal geri bildirim'),
            value: _haptics,
            onChanged: _toggleHaptics,
            activeColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
