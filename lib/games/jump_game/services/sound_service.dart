import 'package:flutter/foundation.dart';

/// Oyun ses efektleri yöneticisi
/// Şimdilik stub implementasyonu - ses dosyaları eklendiğinde tam olarak çalışacak
class GameSoundService {
  static GameSoundService? _instance;
  
  bool _soundEnabled = true;
  double _volume = 0.7;
  
  GameSoundService._();
  
  static GameSoundService get instance {
    _instance ??= GameSoundService._();
    return _instance!;
  }
  
  bool get soundEnabled => _soundEnabled;
  double get volume => _volume;
  
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }
  
  void setVolume(double vol) {
    _volume = vol.clamp(0.0, 1.0);
  }
  
  /// Zıplama sesi
  Future<void> playJump() async {
    if (!_soundEnabled) return;
    debugPrint('🔊 Jump sound');
    // TODO: Ses dosyası eklendiğinde aktifleştir
  }
  
  /// Ölüm/çarpma sesi
  Future<void> playDeath() async {
    if (!_soundEnabled) return;
    debugPrint('🔊 Death sound');
    // TODO: Ses dosyası eklendiğinde aktifleştir
  }
  
  /// Power-up alma sesi
  Future<void> playPowerUp() async {
    if (!_soundEnabled) return;
    debugPrint('🔊 PowerUp sound');
    // TODO: Ses dosyası eklendiğinde aktifleştir
  }
  
  /// Skor sesi
  Future<void> playScore() async {
    if (!_soundEnabled) return;
    debugPrint('🔊 Score sound');
    // TODO: Ses dosyası eklendiğinde aktifleştir
  }
  
  /// Combo sesi
  Future<void> playCombo(int comboLevel) async {
    if (!_soundEnabled) return;
    debugPrint('🔊 Combo \$comboLevel sound');
    // TODO: Ses dosyası eklendiğinde aktifleştir
  }
  
  /// Tüm sesleri durdur
  Future<void> stopAll() async {
    // TODO: Aktif sesleri durdur
  }
  
  /// Kaynakları serbest bırak
  void dispose() {
    // TODO: Dispose audio players
  }
}
