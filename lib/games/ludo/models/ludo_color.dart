import 'package:flutter/material.dart';

enum LudoColor {
  red,
  yellow,
  green,
  blue;

  String get turkishName {
    switch (this) {
      case LudoColor.red:
        return 'Kırmızı';
      case LudoColor.yellow:
        return 'Sarı';
      case LudoColor.green:
        return 'Yeşil';
      case LudoColor.blue:
        return 'Mavi';
    }
  }

  Color get value {
    switch (this) {
      case LudoColor.red:
        return const Color(0xFFFF4444);
      case LudoColor.yellow:
        return const Color(0xFFFFD700);
      case LudoColor.green:
        return const Color(0xFF4CAF50);
      case LudoColor.blue:
        return const Color(0xFF00BCD4);
    }
  }
}
