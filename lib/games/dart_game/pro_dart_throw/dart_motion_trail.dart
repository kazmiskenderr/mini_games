import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Motion Blur / Ghost Trail sistemi
/// Ok arkasında azalan opacity'li izler bırakır
class DartMotionTrail {
  // Trail ayarları
  final int trailCount; // 5-8 arası önerilen
  final double maxOpacity;
  final double minOpacity;
  final double blurIntensity; // Hıza göre çarpan
  
  // Trail pozisyonları (FIFO queue)
  final List<TrailPoint> _trailPoints = [];
  
  DartMotionTrail({
    this.trailCount = 7,
    this.maxOpacity = 0.6,
    this.minOpacity = 0.05,
    this.blurIntensity = 1.0,
  });
  
  /// Yeni pozisyon ekle
  void addPoint(Offset position, double angle, double speed, double scale) {
    // Yeni noktayı başa ekle
    _trailPoints.insert(0, TrailPoint(
      position: position,
      angle: angle,
      speed: speed,
      scale: scale,
      timestamp: DateTime.now(),
    ));
    
    // Fazla noktaları sil
    while (_trailPoints.length > trailCount) {
      _trailPoints.removeLast();
    }
  }
  
  /// Trail'i temizle
  void clear() {
    _trailPoints.clear();
  }
  
  /// Tüm trail noktalarını al
  List<TrailPoint> get points => List.unmodifiable(_trailPoints);
  
  /// Trail'i çiz
  void paint(Canvas canvas, Size dartSize, Color baseColor) {
    if (_trailPoints.isEmpty) return;
    
    for (int i = 0; i < _trailPoints.length; i++) {
      final point = _trailPoints[i];
      
      // Opacity: ilk nokta en parlak, son nokta en soluk
      double t = i / (_trailPoints.length - 1).clamp(1, double.infinity);
      double opacity = maxOpacity - (maxOpacity - minOpacity) * t;
      
      // Hıza göre blur yoğunluğu
      double speedFactor = (point.speed * blurIntensity).clamp(0.5, 2.0);
      opacity *= speedFactor;
      
      // Scale: uzaktaki izler daha küçük
      double trailScale = point.scale * (1.0 - t * 0.3);
      
      // Trail rengi
      Color trailColor = baseColor.withOpacity(opacity.clamp(0.0, 1.0));
      
      // Oval blur efekti
      canvas.save();
      canvas.translate(point.position.dx, point.position.dy);
      canvas.rotate(point.angle + math.pi / 2); // Dart dikey
      
      // Blur oval
      final blurRect = Rect.fromCenter(
        center: Offset.zero,
        width: dartSize.width * trailScale * 0.6,
        height: dartSize.height * trailScale * (0.3 + speedFactor * 0.2),
      );
      
      canvas.drawOval(
        blurRect,
        Paint()
          ..color = trailColor
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4 + speedFactor * 3),
      );
      
      canvas.restore();
    }
  }
  
  /// Trail widget'ları oluştur (Flutter widget olarak)
  List<Widget> buildTrailWidgets(Color baseColor, Size dartSize) {
    List<Widget> widgets = [];
    
    for (int i = _trailPoints.length - 1; i >= 0; i--) {
      final point = _trailPoints[i];
      
      double t = i / trailCount;
      double opacity = maxOpacity * (1.0 - t * 0.8);
      double scale = point.scale * (1.0 - t * 0.4);
      
      widgets.add(
        Positioned(
          left: point.position.dx - dartSize.width * scale / 2,
          top: point.position.dy - dartSize.height * scale / 2,
          child: Transform.rotate(
            angle: point.angle + math.pi / 2,
            child: Opacity(
              opacity: opacity.clamp(0.0, 1.0),
              child: Container(
                width: dartSize.width * scale,
                height: dartSize.height * scale,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      baseColor.withOpacity(opacity * 0.8),
                      baseColor.withOpacity(opacity * 0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    
    return widgets;
  }
}

/// Tek bir trail noktası
class TrailPoint {
  final Offset position;
  final double angle;
  final double speed;
  final double scale;
  final DateTime timestamp;
  
  TrailPoint({
    required this.position,
    required this.angle,
    required this.speed,
    required this.scale,
    required this.timestamp,
  });
  
  /// Nokta yaşı (ms)
  int get age => DateTime.now().difference(timestamp).inMilliseconds;
}
