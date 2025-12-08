import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Profesyonel Dart Uçuş Fiziği
/// Gerçekçi parabolik yörünge, rotasyon ve hız hesaplamaları
class ProFlightPhysics {
  // Başlangıç ve hedef noktaları
  final Offset startPoint;
  final Offset targetPoint;
  
  // Fizik parametreleri
  final double arcPeakPercent; // Parabol tepe noktası (%20-35)
  final double maxArcHeight; // Maksimum yükselme
  final double wobbleAmount; // Yatay sallanma (1-2px)
  
  // Hesaplanmış değerler
  late double _flightDistance;
  late double _baseAngle;
  late double _totalFlightTime;
  
  // Random for wobble
  final _random = math.Random();
  
  ProFlightPhysics({
    required this.startPoint,
    required this.targetPoint,
    this.arcPeakPercent = 0.2, // Daha düz, erken tepe
    this.maxArcHeight = 28, // Daha az yay, neredeyse dimdik
    this.wobbleAmount = 0.4, // Çok hafif sallanma
  }) {
    _initialize();
  }
  
  void _initialize() {
    _flightDistance = (targetPoint - startPoint).distance;
    _baseAngle = math.atan2(
      targetPoint.dy - startPoint.dy,
      targetPoint.dx - startPoint.dx,
    );
    _totalFlightTime = 1.0; // Normalized
  }
  
  /// Gerçekçi parabolik pozisyon hesaplama
  /// t: 0.0 (başlangıç) - 1.0 (hedef)
  Offset calculatePosition(double t) {
    // Easing curve - smooth in-out
    double easedT = _easeInOutCubic(t);
    
    // Doğrusal interpolasyon (x ve y)
    double baseX = startPoint.dx + (targetPoint.dx - startPoint.dx) * easedT;
    double baseY = startPoint.dy + (targetPoint.dy - startPoint.dy) * easedT;
    
    // PARABOLIK YÜKSELİŞ
    // Tepe noktası arcPeakPercent'te olacak şekilde asimetrik parabol
    double arcOffset = _calculateArcOffset(t);
    
    // Başlangıçta +25px lift
    double initialLift = 18 * (1 - t); // Daha az kalkış, dimdik his
    
    // Wobble (gerçekçi sallanma) - uçuş boyunca azalan
    double wobble = _calculateWobble(t);
    
    return Offset(
      baseX + wobble,
      baseY - arcOffset - initialLift,
    );
  }
  
  /// Asimetrik parabol hesaplama - tepe noktası %25'te
  double _calculateArcOffset(double t) {
    // Tepe noktası arcPeakPercent'te
    // Parabol formülü: y = a * (t - peak)^2 + maxHeight
    // Normalize edilmiş: tepe = arcPeakPercent
    
    double peak = arcPeakPercent;
    
    // Parabolün katsayısı (tepe noktasından düşüş hızı)
    // Sol taraf daha dik, sağ taraf daha yatık
    double a;
    if (t <= peak) {
      // Yükseliş fazı - hızlı
      a = maxArcHeight / (peak * peak);
      return maxArcHeight - a * math.pow(t - peak, 2);
    } else {
      // İniş fazı - daha yavaş
      a = maxArcHeight / math.pow(1 - peak, 2);
      return maxArcHeight - a * math.pow(t - peak, 2);
    }
  }
  
  /// Gerçekçi wobble hesaplama
  double _calculateWobble(double t) {
    // Uçuşun başında daha fazla, sonunda az
    double intensity = (1 - t) * wobbleAmount;
    // Sinüsoidal sallanma + rastgele gürültü
    double sineWobble = math.sin(t * math.pi * 8) * intensity;
    double noise = (_random.nextDouble() - 0.5) * intensity * 0.5;
    return sineWobble + noise;
  }
  
  /// Dart rotasyonu hesaplama (hareket yönüne göre)
  double calculateRotation(double t) {
    // Dimdik saplanma: hedef açısına kilitlen
    double startBias = -0.05; // hafif yukarı
    double endBias = 0.03; // hafif aşağı
    double bias = _easeInOutCubic(t) * (endBias - startBias) + startBias;
    return _baseAngle + bias;
  }
  
  /// Rotasyon hızı (başta hızlı, sonda yavaş)
  double calculateRotationSpeed(double t) {
    // Daha stabil dönüş: başta hafif hızlı, sonra yavaşlar
    if (t < 0.25) {
      return 0.9 - t * 0.6;
    } else if (t < 0.7) {
      return 0.6;
    } else {
      return 0.6 - (t - 0.7) * 1.2;
    }
  }
  
  /// Perspective scale (uzaklaştıkça küçülme)
  double calculateScale(double t) {
    // Başta büyük (yakın), sonda küçük (uzak)
    double startScale = 2.0;
    double endScale = 0.65;
    
    // Smooth transition
    double easedT = _easeOutCubic(t);
    return startScale - (startScale - endScale) * easedT;
  }
  
  /// Hız hesaplama (motion blur için)
  double calculateSpeed(double t) {
    // Başta hızlı, ortada yavaş, sonda hızlanma (yerçekimi)
    if (t < 0.3) {
      return 1.0;
    } else if (t < 0.7) {
      return 0.7 + (t - 0.3) * 0.3;
    } else {
      return 0.8 + (t - 0.7) * 1.5; // Yerçekimi ivmesi
    }
  }
  
  // Easing functions
  double _easeInOutCubic(double t) {
    return t < 0.5 
        ? 4 * t * t * t 
        : 1 - math.pow(-2 * t + 2, 3).toDouble() / 2;
  }
  
  double _easeOutCubic(double t) {
    return 1 - math.pow(1 - t, 3).toDouble();
  }
  
  double _easeInCubic(double t) {
    return t * t * t;
  }
}
