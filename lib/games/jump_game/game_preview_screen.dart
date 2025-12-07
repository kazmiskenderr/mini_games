import 'dart:math';
import 'package:flutter/material.dart';
import 'services/game_settings.dart';
import '../../router/game_router.dart';

class GamePreviewScreen extends StatefulWidget {
  const GamePreviewScreen({super.key});

  @override
  State<GamePreviewScreen> createState() => _GamePreviewScreenState();
}

class _GamePreviewScreenState extends State<GamePreviewScreen> 
    with TickerProviderStateMixin {
  GameDifficulty _selectedDifficulty = GameDifficulty.medium;
  late AnimationController _floatController;
  late AnimationController _pulseController;
  GameSettings? _settings;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    _settings = await GameSettings.getInstance();
    setState(() {
      _selectedDifficulty = _settings!.difficulty;
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final params = DifficultyParams.fromDifficulty(_selectedDifficulty);
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFEF3E2),
              Color(0xFFFAE5D3),
              Color(0xFFF8D7C4),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context),
              
              // Game Preview
              Expanded(
                flex: 3,
                child: _buildGamePreview(params),
              ),
              
              // Difficulty Selector
              Expanded(
                flex: 2,
                child: _buildDifficultySelector(),
              ),
              
              // Play Button
              Padding(
                padding: const EdgeInsets.all(24),
                child: _buildPlayButton(context, params),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFFE07B39),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'ZIPLA & KOŞ',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D4037),
                letterSpacing: 1,
              ),
            ),
          ),
          // Settings button
          GestureDetector(
            onTap: () => _showSettings(context),
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.settings_rounded,
                color: Color(0xFF9575CD),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGamePreview(DifficultyParams params) {
    return Stack(
      children: [
        // Game screenshot/preview background
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF64B5F6),
                Color(0xFF90CAF9),
                Color(0xFF4CAF50),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Stack(
              children: [
                // Clouds
                ..._buildClouds(),
                
                // Mountains
                Positioned(
                  bottom: 60,
                  left: 0,
                  right: 0,
                  child: CustomPaint(
                    size: const Size(double.infinity, 100),
                    painter: MountainPainter(),
                  ),
                ),
                
                // Ground
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 60,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF66BB6A),
                          Color(0xFF43A047),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Character
                AnimatedBuilder(
                  animation: _floatController,
                  builder: (context, child) {
                    return Positioned(
                      bottom: 60 + sin(_floatController.value * pi) * 20,
                      left: 80,
                      child: _buildCharacter(),
                    );
                  },
                ),
                
                // Obstacles preview
                Positioned(
                  bottom: 60,
                  right: 60,
                  child: _buildObstaclePreview(),
                ),
              ],
            ),
          ),
        ),
        
        // Difficulty emoji indicator
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + _pulseController.value * 0.15,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _getDifficultyColor(_selectedDifficulty).withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        _getDifficultyIcon(_selectedDifficulty),
                        size: 35,
                        color: _getDifficultyColor(_selectedDifficulty),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
  
  IconData _getDifficultyIcon(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return Icons.sentiment_satisfied_rounded;
      case GameDifficulty.medium:
        return Icons.speed_rounded;
      case GameDifficulty.hard:
        return Icons.whatshot_rounded;
      case GameDifficulty.extreme:
        return Icons.bolt_rounded;
    }
  }

  List<Widget> _buildClouds() {
    return [
      Positioned(
        top: 30,
        left: 30,
        child: _buildCloud(40),
      ),
      Positioned(
        top: 60,
        right: 50,
        child: _buildCloud(50),
      ),
      Positioned(
        top: 100,
        left: 100,
        child: _buildCloud(35),
      ),
    ];
  }

  Widget _buildCloud(double size) {
    return Container(
      width: size * 2,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(size),
      ),
    );
  }

  Widget _buildCharacter() {
    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF5C6BC0),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5C6BC0).withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Eyes
          Positioned(
            top: 12,
            left: 10,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 10,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Pupils
          Positioned(
            top: 14,
            left: 13,
            child: Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 14,
            right: 13,
            child: Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObstaclePreview() {
    return CustomPaint(
      size: const Size(40, 50),
      painter: SpikePainter(),
    );
  }

  Widget _buildDifficultySelector() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          DifficultyParams.fromDifficulty(_selectedDifficulty).name.toUpperCase(),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: _getDifficultyColor(_selectedDifficulty),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          DifficultyParams.fromDifficulty(_selectedDifficulty).description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.brown.shade400,
          ),
        ),
        const SizedBox(height: 24),
        
        // Difficulty slider with icons
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: GameDifficulty.values.map((difficulty) {
              final isSelected = difficulty == _selectedDifficulty;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDifficulty = difficulty;
                    });
                    _settings?.setDifficulty(difficulty);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? _getDifficultyColor(difficulty) : Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                      child: Icon(
                        _getDifficultyIcon(difficulty),
                        size: 26,
                        color: isSelected ? Colors.white : Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        
        const SizedBox(height: 12),
        
        Text(
          'Zorluk seviyesini seçmek için dokun',
          style: TextStyle(
            fontSize: 12,
            color: Colors.brown.shade300,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayButton(BuildContext context, DifficultyParams params) {
    return Row(
      children: [
        // Help button
        Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            color: const Color(0xFF9575CD),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9575CD).withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.help_outline_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Play button
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context, 
                GameRoutes.jumpGame,
                arguments: _selectedDifficulty,
              );
            },
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFFA726),
                        Color.lerp(
                          const Color(0xFFFFA726),
                          const Color(0xFFFF8F00),
                          _pulseController.value,
                        )!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFA726).withValues(alpha: 0.5),
                        blurRadius: 15 + _pulseController.value * 5,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'OYNA',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Color _getDifficultyColor(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return const Color(0xFF66BB6A);
      case GameDifficulty.medium:
        return const Color(0xFFFFA726);
      case GameDifficulty.hard:
        return const Color(0xFFEF5350);
      case GameDifficulty.extreme:
        return const Color(0xFF7C4DFF);
    }
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const SettingsSheet(),
    );
  }
}

class SettingsSheet extends StatefulWidget {
  const SettingsSheet({super.key});

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  GameSettings? _settings;
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _vibrationEnabled = true;
  double _volume = 0.7;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _settings = await GameSettings.getInstance();
    setState(() {
      _soundEnabled = _settings!.soundEnabled;
      _musicEnabled = _settings!.musicEnabled;
      _vibrationEnabled = _settings!.vibrationEnabled;
      _volume = _settings!.volume;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFEF3E2),
            Color(0xFFFAE5D3),
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.brown.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'AYARLAR',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8D6E63),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 30),
          
          // Volume slider
          _buildSliderSetting(
            'Ses Seviyesi',
            _volume,
            (value) {
              setState(() => _volume = value);
              _settings?.setVolume(value);
            },
          ),
          const SizedBox(height: 20),
          
          // Sound toggle
          _buildToggleSetting(
            'Ses Efektleri',
            _soundEnabled,
            (value) {
              setState(() => _soundEnabled = value);
              _settings?.setSoundEnabled(value);
            },
          ),
          const SizedBox(height: 16),
          
          // Music toggle
          _buildToggleSetting(
            'Müzik',
            _musicEnabled,
            (value) {
              setState(() => _musicEnabled = value);
              _settings?.setMusicEnabled(value);
            },
          ),
          const SizedBox(height: 16),
          
          // Vibration toggle
          _buildToggleSetting(
            'Titreşim',
            _vibrationEnabled,
            (value) {
              setState(() => _vibrationEnabled = value);
              _settings?.setVibrationEnabled(value);
            },
          ),
          
          const SizedBox(height: 30),
          
          SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
        ],
      ),
    );
  }

  Widget _buildSliderSetting(String label, double value, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF5D4037),
          ),
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: const Color(0xFF9575CD),
            inactiveTrackColor: const Color(0xFF9575CD).withValues(alpha: 0.3),
            thumbColor: const Color(0xFF9575CD),
            overlayColor: const Color(0xFF9575CD).withValues(alpha: 0.2),
            trackHeight: 8,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
          ),
          child: Slider(
            value: value,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleSetting(String label, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF5D4037),
          ),
        ),
        GestureDetector(
          onTap: () => onChanged(!value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 60,
            height: 32,
            decoration: BoxDecoration(
              color: value 
                  ? const Color(0xFF9575CD)
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(16),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    value ? Icons.check : Icons.close,
                    size: 16,
                    color: value ? const Color(0xFF9575CD) : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Custom painters
class MountainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF5D4037).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width * 0.2, size.height * 0.3)
      ..lineTo(size.width * 0.4, size.height)
      ..lineTo(size.width * 0.5, size.height * 0.4)
      ..lineTo(size.width * 0.7, size.height)
      ..lineTo(size.width * 0.85, size.height * 0.2)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SpikePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFEF5350), Color(0xFFC62828)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
