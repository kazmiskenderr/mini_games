import 'package:flutter/material.dart';

/// Sinematik zoom efekti servisi
/// Dart atışı sırasında tahta üzerinde profesyonel zoom-in/out animasyonu
class ZoomEffectController {
  late AnimationController controller;
  late Animation<double> zoomAnimation;
  late Animation<double> uiOffsetAnimation;
  
  static const Duration zoomInDuration = Duration(milliseconds: 280);
  static const Duration zoomOutDuration = Duration(milliseconds: 250);
  static const double maxZoom = 1.35; // %135 scale
  
  bool _isZoomedIn = false;
  
  void initialize(TickerProvider vsync) {
    controller = AnimationController(
      duration: zoomInDuration,
      reverseDuration: zoomOutDuration,
      vsync: vsync,
    );
    
    // Zoom animasyonu - easeOutCubic ile yaklaş
    zoomAnimation = Tween<double>(
      begin: 1.0,
      end: maxZoom,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));
    
    // UI elementleri yukarı kayma animasyonu
    uiOffsetAnimation = Tween<double>(
      begin: 0.0,
      end: -30.0, // 30px yukarı kay
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));
  }
  
  void dispose() {
    controller.dispose();
  }
  
  /// Zoom in başlat (dart atıldığında)
  Future<void> zoomIn() async {
    if (_isZoomedIn) return;
    _isZoomedIn = true;
    await controller.forward();
  }
  
  /// Zoom out (dart saplandığında)
  Future<void> zoomOut() async {
    if (!_isZoomedIn) return;
    _isZoomedIn = false;
    await controller.reverse();
  }
  
  /// Anlık zoom değeri
  double get currentZoom => zoomAnimation.value;
  
  /// UI offset değeri
  double get currentUIOffset => uiOffsetAnimation.value;
  
  /// Zoom durumu
  bool get isZoomed => _isZoomedIn;
  
  /// Widget builder - zoom efekti uygular
  Widget buildZoomedWidget({
    required Widget child,
    required Offset zoomCenter,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Transform.scale(
          scale: zoomAnimation.value,
          alignment: Alignment.center,
          child: Transform.translate(
            offset: Offset(0, uiOffsetAnimation.value),
            child: child,
          ),
        );
      },
    );
  }
}
