import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Dart uçuş animasyonu servisi
/// Bezier eğrisi ile profesyonel uçuş, motion blur efekti
class DartFlightController {
  late AnimationController controller;
  late Animation<double> flightAnimation;
  
  static const Duration flightDuration = Duration(milliseconds: 420);
  
  Offset? startPosition;
  Offset? endPosition;
  
  // Motion blur için önceki pozisyonlar
  List<Offset> trailPositions = [];
  static const int trailLength = 5;
  
  void initialize(TickerProvider vsync) {
    controller = AnimationController(
      duration: flightDuration,
      vsync: vsync,
    );
    
    flightAnimation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutExpo,
    );
    
    controller.addListener(_updateTrail);
  }
  
  void dispose() {
    controller.removeListener(_updateTrail);
    controller.dispose();
  }
  
  void _updateTrail() {
    if (startPosition == null || endPosition == null) return;
    
    Offset currentPos = getCurrentPosition();
    trailPositions.insert(0, currentPos);
    
    if (trailPositions.length > trailLength) {
      trailPositions.removeLast();
    }
  }
  
  /// Uçuş başlat
  Future<void> fly({
    required Offset start,
    required Offset end,
  }) async {
    startPosition = start;
    endPosition = end;
    trailPositions.clear();
    
    controller.forward(from: 0);
    await controller.forward();
  }
  
  /// Reset
  void reset() {
    controller.reset();
    trailPositions.clear();
    startPosition = null;
    endPosition = null;
  }
  
  /// Mevcut pozisyon - Bezier eğrisi ile
  Offset getCurrentPosition() {
    if (startPosition == null || endPosition == null) return Offset.zero;
    
    double t = flightAnimation.value;
    
    // Bezier kontrol noktası - yukarı yay çizer
    double midX = (startPosition!.dx + endPosition!.dx) / 2;
    double midY = math.min(startPosition!.dy, endPosition!.dy) - 100; // Yukarı yay
    
    // Quadratic Bezier
    double oneMinusT = 1 - t;
    double x = oneMinusT * oneMinusT * startPosition!.dx +
        2 * oneMinusT * t * midX +
        t * t * endPosition!.dx;
    double y = oneMinusT * oneMinusT * startPosition!.dy +
        2 * oneMinusT * t * midY +
        t * t * endPosition!.dy;
    
    return Offset(x, y);
  }
  
  /// Dart açısı - hareket yönüne göre
  double getCurrentAngle() {
    if (startPosition == null || endPosition == null) return 0;
    
    double t = flightAnimation.value;
    
    // Bezier türevi ile açı hesapla
    double midX = (startPosition!.dx + endPosition!.dx) / 2;
    double midY = math.min(startPosition!.dy, endPosition!.dy) - 100;
    
    double dx = 2 * (1 - t) * (midX - startPosition!.dx) +
        2 * t * (endPosition!.dx - midX);
    double dy = 2 * (1 - t) * (midY - startPosition!.dy) +
        2 * t * (endPosition!.dy - midY);
    
    return math.atan2(dy, dx) + math.pi / 2;
  }
  
  /// Dart ölçeği - perspektif efekti
  double getCurrentScale() {
    double t = flightAnimation.value;
    // Başta büyük (2.5x), sona doğru küçük (0.6x)
    return 2.5 - t * 1.9;
  }
  
  /// Motion blur widget'ı oluştur
  Widget buildDartWithTrail({
    required Widget dartWidget,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (startPosition == null || endPosition == null) {
          return const SizedBox.shrink();
        }
        
        Offset pos = getCurrentPosition();
        double angle = getCurrentAngle();
        double scale = getCurrentScale();
        
        return Stack(
          children: [
            // Motion blur trail
            ...trailPositions.asMap().entries.map((entry) {
              int index = entry.key;
              Offset trailPos = entry.value;
              double trailOpacity = 0.3 * (1 - index / trailLength);
              double trailScale = scale * (1 - index * 0.1);
              
              return Positioned(
                left: trailPos.dx - 25 * trailScale,
                top: trailPos.dy - 50 * trailScale,
                child: Opacity(
                  opacity: trailOpacity,
                  child: Transform.rotate(
                    angle: angle * 0.2,
                    child: Transform.scale(
                      scale: trailScale,
                      child: dartWidget,
                    ),
                  ),
                ),
              );
            }),
            // Ana dart
            Positioned(
              left: pos.dx - 25 * scale,
              top: pos.dy - 50 * scale,
              child: Transform.rotate(
                angle: angle * 0.15, // Hafif açı
                child: Transform.scale(
                  scale: scale,
                  child: dartWidget,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
