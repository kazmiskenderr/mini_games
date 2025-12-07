import 'package:flutter/material.dart';

enum DartDistance { near, medium, far }

enum ArrowStyle { classic, modern, minimal }

class DartGameSettings {
  DartDistance distance;
  ArrowStyle arrowStyle;
  Color dartColor;
  Color boardPrimaryColor;
  Color boardSecondaryColor;

  DartGameSettings({
    this.distance = DartDistance.medium,
    this.arrowStyle = ArrowStyle.classic,
    this.dartColor = Colors.red,
    this.boardPrimaryColor = const Color(0xFFE8E6D8),
    this.boardSecondaryColor = const Color(0xFF2C2C2C),
  });

  // Dart başlangıç konumu - mesafeye göre (BÜYÜK FARK)
  double getDartStartOffsetY(double screenHeight) {
    switch (distance) {
      case DartDistance.near:
        return screenHeight - 80; // Yakın - ekranın alt kısmına yakın
      case DartDistance.medium:
        return screenHeight - 200; // Orta
      case DartDistance.far:
        return screenHeight - 400; // Uzak - ekranın ortasına yakın
    }
  }

  // Dart başlangıç boyutu - mesafeye göre
  double getDartStartScale() {
    switch (distance) {
      case DartDistance.near:
        return 1.8; // Yakın - büyük başlar
      case DartDistance.medium:
        return 1.4; // Orta
      case DartDistance.far:
        return 0.9; // Uzak - küçük başlar
    }
  }

  // Zoom level - mesafeye göre
  double getZoomMultiplier() {
    switch (distance) {
      case DartDistance.near:
        return 2.00; // Daha az zoom (yakın olduğu için)
      case DartDistance.medium:
        return 3.00; // Dengeli zoom
      case DartDistance.far:
        return 4.50; // Daha fazla zoom (uzak olduğu için)
    }
  }

  String getDistanceLabel() {
    switch (distance) {
      case DartDistance.near:
        return 'Yakın';
      case DartDistance.medium:
        return 'Orta';
      case DartDistance.far:
        return 'Uzak';
    }
  }

  String getArrowLabel() {
    switch (arrowStyle) {
      case ArrowStyle.classic:
        return 'Klasik';
      case ArrowStyle.modern:
        return 'Modern';
      case ArrowStyle.minimal:
        return 'Minimal';
    }
  }

  // Ayarları kaydet/yükle için
  Map<String, dynamic> toMap() {
    return {
      'distance': distance.index,
      'arrowStyle': arrowStyle.index,
      'dartColor': dartColor.value,
      'boardPrimaryColor': boardPrimaryColor.value,
      'boardSecondaryColor': boardSecondaryColor.value,
    };
  }

  factory DartGameSettings.fromMap(Map<String, dynamic> map) {
    return DartGameSettings(
      distance: DartDistance.values[map['distance'] ?? 1],
      arrowStyle: ArrowStyle.values[map['arrowStyle'] ?? 0],
      dartColor: Color(map['dartColor'] ?? Colors.red.value),
      boardPrimaryColor: Color(map['boardPrimaryColor'] ?? 0xFFE8E6D8),
      boardSecondaryColor: Color(map['boardSecondaryColor'] ?? 0xFF2C2C2C),
    );
  }
}
