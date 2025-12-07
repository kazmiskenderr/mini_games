import 'package:shared_preferences/shared_preferences.dart';

class ScoreService {
  static const String _highScoreKey = 'jump_game_high_score';
  static const String _totalGamesKey = 'jump_game_total_games';
  static const String _totalScoreKey = 'jump_game_total_score';
  
  static ScoreService? _instance;
  late SharedPreferences _prefs;
  
  ScoreService._();
  
  static Future<ScoreService> getInstance() async {
    if (_instance == null) {
      _instance = ScoreService._();
      _instance!._prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }
  
  int get highScore => _prefs.getInt(_highScoreKey) ?? 0;
  int get totalGames => _prefs.getInt(_totalGamesKey) ?? 0;
  int get totalScore => _prefs.getInt(_totalScoreKey) ?? 0;
  
  double get averageScore {
    if (totalGames == 0) return 0;
    return totalScore / totalGames;
  }
  
  Future<bool> submitScore(int score) async {
    // Toplam oyun sayısını artır
    await _prefs.setInt(_totalGamesKey, totalGames + 1);
    
    // Toplam skoru güncelle
    await _prefs.setInt(_totalScoreKey, totalScore + score);
    
    // Yeni yüksek skor mu?
    if (score > highScore) {
      await _prefs.setInt(_highScoreKey, score);
      return true;
    }
    return false;
  }
  
  Future<void> resetStats() async {
    await _prefs.remove(_highScoreKey);
    await _prefs.remove(_totalGamesKey);
    await _prefs.remove(_totalScoreKey);
  }
}
