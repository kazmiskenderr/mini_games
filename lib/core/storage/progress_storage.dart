import 'package:shared_preferences/shared_preferences.dart';

class ProgressStorage {
  static const _keyProgress = 'player_progress_v1';

  Future<void> save(String json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProgress, json);
  }

  Future<String?> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyProgress);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyProgress);
  }
}
