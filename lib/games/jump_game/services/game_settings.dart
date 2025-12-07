import 'package:shared_preferences/shared_preferences.dart';
import '../components/advanced_obstacle.dart';

enum GameDifficulty { easy, medium, hard, extreme }

class GameSettings {
  static GameSettings? _instance;
  late SharedPreferences _prefs;
  
  // Ayar anahtarları
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _musicEnabledKey = 'music_enabled';
  static const String _vibrationEnabledKey = 'vibration_enabled';
  static const String _volumeKey = 'volume';
  static const String _difficultyKey = 'difficulty';
  
  GameSettings._();
  
  static Future<GameSettings> getInstance() async {
    if (_instance == null) {
      _instance = GameSettings._();
      _instance!._prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }
  
  // Ses ayarları
  bool get soundEnabled => _prefs.getBool(_soundEnabledKey) ?? true;
  Future<void> setSoundEnabled(bool value) => _prefs.setBool(_soundEnabledKey, value);
  
  bool get musicEnabled => _prefs.getBool(_musicEnabledKey) ?? true;
  Future<void> setMusicEnabled(bool value) => _prefs.setBool(_musicEnabledKey, value);
  
  bool get vibrationEnabled => _prefs.getBool(_vibrationEnabledKey) ?? true;
  Future<void> setVibrationEnabled(bool value) => _prefs.setBool(_vibrationEnabledKey, value);
  
  double get volume => _prefs.getDouble(_volumeKey) ?? 0.7;
  Future<void> setVolume(double value) => _prefs.setDouble(_volumeKey, value);
  
  // Zorluk ayarı
  GameDifficulty get difficulty {
    final index = _prefs.getInt(_difficultyKey) ?? 1;
    return GameDifficulty.values[index.clamp(0, GameDifficulty.values.length - 1)];
  }
  Future<void> setDifficulty(GameDifficulty value) => 
      _prefs.setInt(_difficultyKey, value.index);
}

/// Zorluk seviyesi parametreleri
class DifficultyParams {
  final double initialSpeed;
  final double speedIncrease;
  final double maxSpeed;
  final double obstacleSpawnInterval;
  final double minObstacleSpawnInterval;
  final double powerUpSpawnInterval;
  final double playerJumpForce;
  final double gravity;
  final bool hasMovingObstacles;
  final bool hasLaserObstacles;
  final bool hasBirdObstacles;
  final bool hasFallingObstacles; // Yukarıdan düşen engeller
  final double fallingObstacleChance; // Düşen engel olasılığı
  final String name;
  final String description;
  final String emoji;
  
  const DifficultyParams({
    required this.initialSpeed,
    required this.speedIncrease,
    required this.maxSpeed,
    required this.obstacleSpawnInterval,
    required this.minObstacleSpawnInterval,
    required this.powerUpSpawnInterval,
    required this.playerJumpForce,
    required this.gravity,
    required this.hasMovingObstacles,
    required this.hasLaserObstacles,
    required this.hasBirdObstacles,
    this.hasFallingObstacles = false,
    this.fallingObstacleChance = 0.0,
    required this.name,
    required this.description,
    required this.emoji,
  });
  
  /// Oyun süresine göre mevcut engelleri döndürür
  List<ObstacleType> getAvailableObstacles(double gameTime) {
    List<ObstacleType> types = [ObstacleType.spike, ObstacleType.rock];
    
    if (hasBirdObstacles && gameTime > 10) {
      types.add(ObstacleType.bird);
    }
    
    if (hasMovingObstacles && gameTime > 20) {
      types.add(ObstacleType.movingSpike);
    }
    
    if (hasLaserObstacles && gameTime > 30) {
      types.add(ObstacleType.laser);
    }
    
    return types;
  }
  
  static DifficultyParams fromDifficulty(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return const DifficultyParams(
          initialSpeed: 200,
          speedIncrease: 2.0,
          maxSpeed: 380,
          obstacleSpawnInterval: 2.8,
          minObstacleSpawnInterval: 1.6,
          powerUpSpawnInterval: 5.0,
          playerJumpForce: 680,
          gravity: 1000,
          hasMovingObstacles: false,
          hasLaserObstacles: false,
          hasBirdObstacles: false,
          hasFallingObstacles: false,
          fallingObstacleChance: 0.0,
          name: 'Kolay',
          description: 'Yeni başlayanlar için ideal',
          emoji: '😊',
        );
      case GameDifficulty.medium:
        return const DifficultyParams(
          initialSpeed: 280,
          speedIncrease: 4.0,
          maxSpeed: 550,
          obstacleSpawnInterval: 2.0,
          minObstacleSpawnInterval: 1.0,
          powerUpSpawnInterval: 8.0,
          playerJumpForce: 620,
          gravity: 1300,
          hasMovingObstacles: true,
          hasLaserObstacles: false,
          hasBirdObstacles: true,
          hasFallingObstacles: true,
          fallingObstacleChance: 0.15,
          name: 'Orta',
          description: 'Dengelenmiş zorluk',
          emoji: '😏',
        );
      case GameDifficulty.hard:
        return const DifficultyParams(
          initialSpeed: 380,
          speedIncrease: 6.0,
          maxSpeed: 750,
          obstacleSpawnInterval: 1.5,
          minObstacleSpawnInterval: 0.7,
          powerUpSpawnInterval: 14.0,
          playerJumpForce: 580,
          gravity: 1500,
          hasMovingObstacles: true,
          hasLaserObstacles: true,
          hasBirdObstacles: true,
          hasFallingObstacles: true,
          fallingObstacleChance: 0.3,
          name: 'Zor',
          description: 'Cesurlar için',
          emoji: '😤',
        );
      case GameDifficulty.extreme:
        return const DifficultyParams(
          initialSpeed: 480,
          speedIncrease: 8.0,
          maxSpeed: 950,
          obstacleSpawnInterval: 1.1,
          minObstacleSpawnInterval: 0.4,
          powerUpSpawnInterval: 20.0,
          playerJumpForce: 550,
          gravity: 1800,
          hasMovingObstacles: true,
          hasLaserObstacles: true,
          hasBirdObstacles: true,
          hasFallingObstacles: true,
          fallingObstacleChance: 0.45,
          name: 'Ekstrem',
          description: 'Sadece ustalar için!',
          emoji: '🔥',
        );
    }
  }
}
