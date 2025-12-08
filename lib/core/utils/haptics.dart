import 'package:flutter/services.dart';

class Haptics {
  static bool enabled = true;

  static Future<void> success() async {
    if (!enabled) return;
    await HapticFeedback.lightImpact();
  }

  static Future<void> warn() async {
    if (!enabled) return;
    await HapticFeedback.mediumImpact();
  }

  static Future<void> heavy() async {
    if (!enabled) return;
    await HapticFeedback.heavyImpact();
  }

  static Future<void> selection() async {
    if (!enabled) return;
    await HapticFeedback.selectionClick();
  }
}
