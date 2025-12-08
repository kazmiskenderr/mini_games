import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Cinematic kamera takip sistemi
/// Dart'ı takip eden, zoom yapan ve slow-motion uygulayan kamera
class CameraFollowController {
  // Kamera ayarları
  final double minZoom;
  final double maxZoom;
  final double slowMotionThreshold; // 0.7 = %70'ten sonra slow-mo
  final double slowMotionFactor; // 0.4 = %40 hız
  final double followSmoothness; // Takip yumuşaklığı
  
  // Ekran boyutları
  Size screenSize;
  Offset screenCenter;
  
  // Mevcut kamera durumu
  Offset _targetPosition;
  Offset _currentPosition;
  double _targetZoom;
  double _currentZoom;
  double _targetRotation;
  double _currentRotation;
  
  // Slow motion durumu
  bool _isSlowMotion = false;
  double _timeScale = 1.0;
  
  // Bounce efekti
  double _bounceScale = 1.0;
  bool _isBouncing = false;
  
  CameraFollowController({
    required this.screenSize,
    this.minZoom = 1.0,
    this.maxZoom = 2.5,
    this.slowMotionThreshold = 0.7,
    this.slowMotionFactor = 0.4,
    this.followSmoothness = 0.12,
  })  : screenCenter = Offset(screenSize.width / 2, screenSize.height / 2),
        _targetPosition = Offset(screenSize.width / 2, screenSize.height / 2),
        _currentPosition = Offset(screenSize.width / 2, screenSize.height / 2),
        _targetZoom = 1.0,
        _currentZoom = 1.0,
        _targetRotation = 0,
        _currentRotation = 0;
  
  /// Kamera hedefini güncelle
  void setTarget(Offset position, {double? zoom, double? rotation}) {
    _targetPosition = position;
    if (zoom != null) _targetZoom = zoom.clamp(minZoom, maxZoom);
    if (rotation != null) _targetRotation = rotation;
  }
  
  /// Dart takibi için kamerayı güncelle
  void followDart({
    required Offset dartPosition,
    required Offset targetPosition,
    required double progress,
    required double dartAngle,
  }) {
    // İlerlemeye göre zoom hesapla
    // Başta az zoom, hedefe yaklaştıkça artır
    double zoomProgress = Curves.easeInOutCubic.transform(progress);
    double targetZoom = minZoom + (maxZoom - minZoom) * zoomProgress;
    
    // Slow motion kontrolü
    if (progress >= slowMotionThreshold && !_isSlowMotion) {
      _isSlowMotion = true;
      _timeScale = slowMotionFactor;
    }
    
    // Kamera pozisyonu: dart ile hedef arasında, hedefe yaklaştıkça hedefe odaklan
    double focusFactor = Curves.easeInQuad.transform(progress);
    Offset focusPoint = Offset.lerp(dartPosition, targetPosition, focusFactor * 0.7)!;
    
    // Ekran merkezine göre offset
    Offset cameraOffset = focusPoint;
    
    setTarget(cameraOffset, zoom: targetZoom);
    
    // Hafif rotasyon (dart açısına göre)
    _targetRotation = dartAngle * 0.02; // Çok hafif
  }
  
  /// Frame güncelleme (smooth lerp)
  void update(double dt) {
    // Pozisyon yumuşak geçiş
    _currentPosition = Offset.lerp(
      _currentPosition,
      _targetPosition,
      followSmoothness,
    )!;
    
    // Zoom yumuşak geçiş
    _currentZoom = _currentZoom + (_targetZoom - _currentZoom) * followSmoothness;
    
    // Rotasyon yumuşak geçiş
    _currentRotation = _currentRotation + (_targetRotation - _currentRotation) * followSmoothness * 0.5;
    
    // Bounce efekti
    if (_isBouncing) {
      _bounceScale = _bounceScale + (1.0 - _bounceScale) * 0.15;
      if ((_bounceScale - 1.0).abs() < 0.001) {
        _bounceScale = 1.0;
        _isBouncing = false;
      }
    }
  }
  
  /// Saplanma anında kamera bounce efekti
  void triggerImpactBounce() {
    _bounceScale = 1.15; // Hafif geri çekil
    _isBouncing = true;
    _targetZoom = _currentZoom * 0.92; // Zoom out bounce
    _isSlowMotion = false;
    _timeScale = 1.0;
  }
  
  /// Kamerayı sıfırla
  void reset() {
    _targetPosition = screenCenter;
    _currentPosition = screenCenter;
    _targetZoom = 1.0;
    _currentZoom = 1.0;
    _targetRotation = 0;
    _currentRotation = 0;
    _isSlowMotion = false;
    _timeScale = 1.0;
    _bounceScale = 1.0;
    _isBouncing = false;
  }
  
  /// Kamera transform matrisi
  Matrix4 get matrix {
    final Matrix4 m = Matrix4.identity();
    
    // Ekran merkezine taşı
    m.translate(screenCenter.dx, screenCenter.dy);
    
    // Zoom uygula
    double finalZoom = _currentZoom * _bounceScale;
    m.scale(finalZoom, finalZoom);
    
    // Rotasyon uygula
    m.rotateZ(_currentRotation);
    
    // Kamera pozisyonunu uygula (ters yönde)
    m.translate(-_currentPosition.dx, -_currentPosition.dy);
    
    return m;
  }
  
  /// Mevcut zoom değeri
  double get currentZoom => _currentZoom * _bounceScale;
  
  /// Mevcut pozisyon
  Offset get currentPosition => _currentPosition;
  
  /// Slow motion aktif mi
  bool get isSlowMotion => _isSlowMotion;
  
  /// Zaman ölçeği (slow-mo için)
  double get timeScale => _timeScale;
  
  /// Bounce aktif mi
  bool get isBouncing => _isBouncing;
}
