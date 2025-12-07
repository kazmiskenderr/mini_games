import 'package:flutter/material.dart';
import 'dart_game_settings.dart';

class DartGameSettingsScreen extends StatefulWidget {
  final DartGameSettings settings;
  final ValueChanged<DartGameSettings> onSettingsChanged;

  const DartGameSettingsScreen({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<DartGameSettingsScreen> createState() => _DartGameSettingsScreenState();
}

class _DartGameSettingsScreenState extends State<DartGameSettingsScreen> {
  late DartGameSettings _currentSettings;

  @override
  void initState() {
    super.initState();
    _currentSettings = DartGameSettings(
      distance: widget.settings.distance,
      arrowStyle: widget.settings.arrowStyle,
      dartColor: widget.settings.dartColor,
      boardPrimaryColor: widget.settings.boardPrimaryColor,
      boardSecondaryColor: widget.settings.boardSecondaryColor,
    );
  }

  void _updateSettings() {
    widget.onSettingsChanged(_currentSettings);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Oyun Ayarları'),
        backgroundColor: Colors.brown.shade700,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.brown.shade400, Colors.brown.shade700],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          children: [
            // Mesafe Seçeneği
            _buildSectionTitle('Mesafe'),
            _buildDistanceSelector(),
            const SizedBox(height: 24),

            // Arrow Stili Seçeneği
            _buildSectionTitle('Ok Stili'),
            _buildArrowStyleSelector(),
            const SizedBox(height: 24),

            // Dart Rengi
            _buildSectionTitle('Dart Rengi'),
            _buildColorPicker('Dart', _currentSettings.dartColor, (color) {
              setState(() => _currentSettings.dartColor = color);
            }),
            const SizedBox(height: 24),

            // Board Renkleri
            _buildSectionTitle('Board Renkleri'),
            _buildColorPicker(
              'Açık Bölge',
              _currentSettings.boardPrimaryColor,
              (color) {
                setState(() => _currentSettings.boardPrimaryColor = color);
              },
            ),
            const SizedBox(height: 12),
            _buildColorPicker(
              'Koyu Bölge',
              _currentSettings.boardSecondaryColor,
              (color) {
                setState(() => _currentSettings.boardSecondaryColor = color);
              },
            ),
            const SizedBox(height: 32),

            // Kaydet Butonu
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _updateSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Ayarları Kaydet',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDistanceSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.brown.shade600,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: DartDistance.values.map((distance) {
          bool isSelected = _currentSettings.distance == distance;
          return ListTile(
            title: Text(
              distance == DartDistance.near
                  ? 'Yakın'
                  : distance == DartDistance.medium
                  ? 'Orta'
                  : 'Uzak',
              style: TextStyle(
                color: isSelected ? Colors.amber : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text(
              distance == DartDistance.near
                  ? 'Daha az zoom, yakın mesafe'
                  : distance == DartDistance.medium
                  ? 'Deneli zoom, orta mesafe'
                  : 'Daha çok zoom, uzak mesafe',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            trailing: Radio<DartDistance>(
              value: distance,
              groupValue: _currentSettings.distance,
              onChanged: (value) {
                setState(() => _currentSettings.distance = value!);
              },
              activeColor: Colors.amber,
            ),
            onTap: () {
              setState(() => _currentSettings.distance = distance);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildArrowStyleSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.brown.shade600,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: ArrowStyle.values.map((style) {
          bool isSelected = _currentSettings.arrowStyle == style;
          return ListTile(
            title: Text(
              style == ArrowStyle.classic
                  ? 'Klasik'
                  : style == ArrowStyle.modern
                  ? 'Modern'
                  : 'Minimal',
              style: TextStyle(
                color: isSelected ? Colors.amber : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text(
              style == ArrowStyle.classic
                  ? 'Geleneksel ok tasarımı'
                  : style == ArrowStyle.modern
                  ? 'Modern ve şık görünüm'
                  : 'Basit ve temiz tasarım',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            trailing: Radio<ArrowStyle>(
              value: style,
              groupValue: _currentSettings.arrowStyle,
              onChanged: (value) {
                setState(() => _currentSettings.arrowStyle = value!);
              },
              activeColor: Colors.amber,
            ),
            onTap: () {
              setState(() => _currentSettings.arrowStyle = style);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildColorPicker(
    String label,
    Color color,
    ValueChanged<Color> onColor,
  ) {
    return GestureDetector(
      onTap: () => _showColorPicker(context, color, onColor),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.brown.shade600,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            Container(
              width: 60,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(
    BuildContext context,
    Color initialColor,
    ValueChanged<Color> onColorSelected,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        Color selectedColor = initialColor;
        return AlertDialog(
          title: const Text('Renk Seç'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildColorGrid((color) {
                  selectedColor = color;
                }, initialColor),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                onColorSelected(selectedColor);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              child: const Text('Seç'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildColorGrid(
    ValueChanged<Color> onColorSelected,
    Color initialColor,
  ) {
    final colors = [
      Colors.red,
      Colors.redAccent,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.blueAccent,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.greenAccent,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.white,
    ];

    return GridView.count(
      crossAxisCount: 5,
      shrinkWrap: true,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      physics: const NeverScrollableScrollPhysics(),
      children: colors.map((color) {
        bool isSelected = color.value == initialColor.value;
        return GestureDetector(
          onTap: () {
            onColorSelected(color);
          },
          child: Container(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.black, width: 3)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
