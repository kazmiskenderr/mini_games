import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Dart uçuş fizik modeli
/// Parabolik hareket, hız, açı ve yerçekimi hesaplamaları
class DartFlightModel {
  // Başlangıç ve hedef noktaları
  final Offset startPoint;
  final Offset targetPoint;
  
  // Fizik parametreleri
  final double gravity; // 0.9 - 1.2 arası önerilen
  final double initialSpeed; // Başlangıç hızı
  final double arcHeight; // Parabol yüksekliği
  
  // Mevcut durum
  Offset currentPosition;
  Offset previousPosition;
  double currentAngle;
  double currentSpeed;
  double progress; // 0.0 - 1.0
  
  // Hesaplanmış değerler
  late double _flightDistance;
  late double _flightAngle;
  late Offset _velocity;
  
  DartFlightModel({
    required this.startPoint,
    required this.targetPoint,
    this.gravity = 1.0,
    this.initialSpeed = 1.5,
    this.arcHeight = 0.15, // Ekran yüksekliğinin %15'i kadar yükselir
  })  : currentPosition = startPoint,
        previousPosition = startPoint,
        currentAngle = 0,
        currentSpeed = initialSpeed,
        progress = 0 {
    _calculateFlightPath();
  }
  
  void _calculateFlightPath() {
    // Toplam uçuş mesafesi
    _flightDistance = (targetPoint - startPoint).distance;
    
    // Başlangıç açısı (hedefe doğru)
    _flightAngle = math.atan2(
      targetPoint.dy - startPoint.dy,
      targetPoint.dx - startPoint.dx,
    );
    
    // Başlangıç hızı vektörü
    _velocity = Offset(
      math.cos(_flightAngle) * initialSpeed,
      math.sin(_flightAngle) * initialSpeed,
    );
    
    currentAngle = _flightAngle;
  }
  
  /// Parabolik pozisyon hesaplama
  /// t: 0.0 (başlangıç) - 1.0 (hedef)
  Offset calculatePosition(double t) {
    // Doğrusal interpolasyon (x ve y)
    double linearX = startPoint.dx + (targetPoint.dx - startPoint.dx) * t;
    double linearY = startPoint.dy + (targetPoint.dy - startPoint.dy) * t;
    
    // Parabolik yükselme: 0'dan başla, ortada max, 1'de 0'a dön
    // y = -4 * arcHeight * (t - 0.5)^2 + arcHeight
    double parabolicOffset = -4 * arcHeight * _flightDistance * math.pow(t - 0.5, 2) + 
                             arcHeight * _flightDistance;
    
    // Yerçekimi etkisi (ilerleme arttıkça aşağı çeker)
    double gravityOffset = gravity * 50 * math.pow(t, 2);
    
    // Parabolic Y = linear Y - yükselme + yerçekimi düşüşü
    double finalY = linearY - parabolicOffset + gravityOffset;
    
    return Offset(linearX, finalY);
  }
  
  /// Belirli bir t değerindeki açıyı hesapla
  double calculateAngle(double t) {
    // Küçük bir delta ile türev al
    double delta = 0.01;
    double t1 = (t - delta).clamp(0.0, 1.0);
    double t2 = (t + delta).clamp(0.0, 1.0);
    
    Offset p1 = calculatePosition(t1);
    Offset p2 = calculatePosition(t2);
    
    // Hareket yönünün açısı
    return math.atan2(p2.dy - p1.dy, p2.dx - p1.dx);
  }
  
  /// Belirli bir t değerindeki hızı hesapla
  double calculateSpeed(double t) {
    // Başta hızlı, ortada yavaş, sonda tekrar hızlı
    // Easing: easeInOutQuad benzeri
    double speedMultiplier;
    if (t < 0.5) {
      speedMultiplier = 1.0 - t * 0.3; // Yavaşla
    } else {
      speedMultiplier = 0.85 + (t - 0.5) * 0.6; // Hızlan (yerçekimi)
    }
    return initialSpeed * speedMultiplier * gravity;
  }
  
  /// Frame güncelleme
  void update(double t) {
    previousPosition = currentPosition;
    progress = t.clamp(0.0, 1.0);
    currentPosition = calculatePosition(progress);
    currentAngle = calculateAngle(progress);
    currentSpeed = calculateSpeed(progress);
  }
  
  /// Hedef açısı (mevcut konumdan hedefe)
  double get angleToTarget {
    return math.atan2(
      targetPoint.dy - currentPosition.dy,
      targetPoint.dx - currentPosition.dx,
    );
  }
  
  /// Kalan mesafe
  double get remainingDistance {
    return (targetPoint - currentPosition).distance;
  }
  
  /// Uçuş tamamlandı mı
  bool get isComplete => progress >= 1.0;
  
  /// Slow motion bölgesinde mi (hedefe %30 kala)
  bool get isInSlowMotionZone => progress >= 0.7;
  
  /// Hedefe yakın mı (son %10)
  bool get isNearTarget => progress >= 0.9;
}
