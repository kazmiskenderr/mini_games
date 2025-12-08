import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Profesyonel Kamera Animasyon Sistemi
/// Dart takibi, zoom, impact shake
class ProCameraController extends ChangeNotifier {
  // Ekran boyutları
  final Size screenSize;
  
  // Kamera durumu
  double _zoom = 1.0;
  Offset _offset = Offset.zero;
  Offset _shakeOffset = Offset.zero;
  
  // Hedefler
  double _targetZoom = 1.0;
  Offset _targetOffset = Offset.zero;
  
  // Animasyon parametreleri
  static const double zoomSpeed = 3.0;
  static const double panSpeed = 5.0;
  static const double maxZoom = 1.35;
  static const double flightZoom = 1.25;
  
  // Impact shake
  bool _isShaking = false;
  double _shakeIntensity = 0;
  int _shakeCount = 0;
  final _random = math.Random();
  
  // State
  CameraState _state = CameraState.idle;
  Offset? _impactPoint;
  
  ProCameraController({required this.screenSize});
  
  // Getters
  double get zoom => _zoom;
  Offset get offset => _offset + _shakeOffset;
  CameraState get state => _state;
  
  /// Dart fırlatıldığında - yavaşça zoom in
  void onThrowStart() {
    _state = CameraState.followingDart;
    _targetZoom = flightZoom;
    notifyListeners();
  }
  
  /// Dart uçuşu sırasında takip
  void followDart(Offset dartPosition, double progress) {
    if (_state != CameraState.followingDart) return;
    
    // Zoom: uçuş ilerledikçe artar
    _targetZoom = 1.0 + (flightZoom - 1.0) * progress * 1.5;
    _targetZoom = _targetZoom.clamp(1.0, flightZoom);
    
    // Dart'ı ekran ortasına al
    double dx = screenSize.width / 2 - dartPosition.dx;
    double dy = screenSize.height / 2 - dartPosition.dy;
    
    // Offset: zoom'a göre ayarla
    _targetOffset = Offset(
      dx * (_zoom - 1) * 0.9,
      dy * (_zoom - 1) * 0.9,
    );
    
    notifyListeners();
  }
  
  /// Impact anında - hedefe snap + shake
  void onImpact(Offset impactPoint) {
    _state = CameraState.impacting;
    _impactPoint = impactPoint;
    
    // Hedefe snap zoom
    _targetZoom = maxZoom;
    
    // Impact noktasına odaklan
    double dx = screenSize.width / 2 - impactPoint.dx;
    double dy = screenSize.height / 2 - impactPoint.dy;
    _targetOffset = Offset(dx * (_targetZoom - 1), dy * (_targetZoom - 1));
    
    // Shake başlat
    _triggerShake();
    
    notifyListeners();
  }
  
  /// Impact sonrası - 400ms sonra zoom out
  void onImpactComplete() {
    _state = CameraState.zoomingOut;
    _targetZoom = 1.0;
    _targetOffset = Offset.zero;
    notifyListeners();
  }
  
  /// Sıfırla
  void reset() {
    _state = CameraState.idle;
    _targetZoom = 1.0;
    _targetOffset = Offset.zero;
    _shakeOffset = Offset.zero;
    _isShaking = false;
    notifyListeners();
  }
  
  /// Frame update
  void update(double dt) {
    // Smooth zoom interpolation
    double zoomDiff = _targetZoom - _zoom;
    _zoom += zoomDiff * dt * zoomSpeed;
    
    // Smooth offset interpolation
    Offset offsetDiff = _targetOffset - _offset;
    _offset += offsetDiff * dt * panSpeed;
    
    // Shake update
    if (_isShaking) {
      _updateShake(dt);
    }
    
    // Zoom out tamamlandı mı?
    if (_state == CameraState.zoomingOut && (_zoom - 1.0).abs() < 0.01) {
      _state = CameraState.idle;
      _zoom = 1.0;
      _offset = Offset.zero;
    }
    
    notifyListeners();
  }
  
  void _triggerShake() {
    _isShaking = true;
    _shakeIntensity = 4.0; // px
    _shakeCount = 6;
  }
  
  void _updateShake(double dt) {
    if (_shakeCount <= 0) {
      _isShaking = false;
      _shakeOffset = Offset.zero;
      return;
    }
    
    // Random shake offset
    _shakeOffset = Offset(
      (_random.nextDouble() - 0.5) * _shakeIntensity * 2,
      (_random.nextDouble() - 0.5) * _shakeIntensity * 2,
    );
    
    // Intensity ve count azalt
    _shakeIntensity *= 0.7;
    _shakeCount--;
    
    if (_shakeCount <= 0) {
      _shakeOffset = Offset.zero;
      _isShaking = false;
    }
  }
  
  /// Kamera transform matrisi
  Matrix4 getTransformMatrix() {
    final totalOffset = offset;
    return Matrix4.identity()
      ..translate(totalOffset.dx, totalOffset.dy)
      ..scale(_zoom);
  }
}

enum CameraState {
  idle,
  followingDart,
  impacting,
  zoomingOut,
}
