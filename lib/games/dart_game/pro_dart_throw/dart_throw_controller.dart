import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'dart_flight_model.dart';
import 'dart_motion_trail.dart';
import 'camera_follow_controller.dart';
import 'dart_impact_effect.dart';

/// Ana dart atış kontrol sınıfı
/// Tüm sistemleri koordine eder: fizik, kamera, trail, efektler
class DartThrowController extends ChangeNotifier {
  // Alt sistemler
  late DartFlightModel? _flightModel;
  late DartMotionTrail _motionTrail;
  late CameraFollowController _cameraController;
  late DartImpactEffect _impactEffect;
  
  // Animasyon
  AnimationController? _flightAnimController;
  AnimationController? _impactAnimController;
  
  // Ayarlar
  double gravity;
  double flightSpeed;
  double arcHeight;
  int trailCount;
  double slowMotionFactor;
  double maxZoom;
  
  // Durum
  ThrowState _state = ThrowState.idle;
  Offset? _currentDartPosition;
  double _currentDartAngle = 0;
  double _currentDartScale = 1.0;
  Offset? _targetPoint;
  
  // Callback'ler
  VoidCallback? onThrowComplete;
  Function(Offset hitPoint)? onDartHit;
  
  DartThrowController({
    this.gravity = 1.0,
    this.flightSpeed = 1.3,
    this.arcHeight = 0.12,
    this.trailCount = 7,
    this.slowMotionFactor = 0.4,
    this.maxZoom = 2.2,
  }) {
    _motionTrail = DartMotionTrail(trailCount: trailCount);
    _impactEffect = DartImpactEffect();
  }
  
  /// Controller'ı başlat (TickerProvider gerekli)
  void initialize(TickerProvider vsync, Size screenSize) {
    _cameraController = CameraFollowController(
      screenSize: screenSize,
      maxZoom: maxZoom,
      slowMotionFactor: slowMotionFactor,
    );
    
    _flightAnimController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: vsync,
    );
    
    _impactAnimController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: vsync,
    );
    
    _flightAnimController!.addListener(_onFlightUpdate);
    _flightAnimController!.addStatusListener(_onFlightStatusChange);
    _impactAnimController!.addListener(_onImpactUpdate);
  }
  
  /// Atışı başlat
  void startThrow(Offset startPoint, Offset targetPoint) {
    if (_state != ThrowState.idle) return;
    
    _targetPoint = targetPoint;
    
    // Uçuş modeli oluştur
    _flightModel = DartFlightModel(
      startPoint: startPoint,
      targetPoint: targetPoint,
      gravity: gravity,
      initialSpeed: flightSpeed,
      arcHeight: arcHeight,
    );
    
    // Trail'i temizle
    _motionTrail.clear();
    
    // Kamerayı sıfırla
    _cameraController.reset();
    
    // Efektleri sıfırla
    _impactEffect.reset();
    
    // Başlangıç durumu
    _currentDartPosition = startPoint;
    _currentDartScale = 1.0 + (1 - gravity) * 0.3; // Uzak atışlarda küçük başla
    
    // Animasyonu başlat
    _state = ThrowState.flying;
    _flightAnimController!.forward(from: 0);
    
    notifyListeners();
  }
  
  void _onFlightUpdate() {
    if (_flightModel == null) return;
    
    double t = _flightAnimController!.value;
    
    // Slow motion uygulaması
    if (_flightModel!.isInSlowMotionZone) {
      // Zaman yavaşlıyor ama animasyon devam ediyor
    }
    
    // Fizik güncelle
    _flightModel!.update(t);
    
    // Mevcut değerleri al
    _currentDartPosition = _flightModel!.currentPosition;
    _currentDartAngle = _flightModel!.currentAngle;
    
    // Scale: Yaklaştıkça küçül (perspektif)
    _currentDartScale = 1.0 - t * 0.65;
    _currentDartScale = _currentDartScale.clamp(0.25, 1.5);
    
    // Trail'e nokta ekle
    _motionTrail.addPoint(
      _currentDartPosition!,
      _currentDartAngle,
      _flightModel!.currentSpeed,
      _currentDartScale,
    );
    
    // Kamera takibi
    _cameraController.followDart(
      dartPosition: _currentDartPosition!,
      targetPosition: _flightModel!.targetPoint,
      progress: t,
      dartAngle: _currentDartAngle,
    );
    _cameraController.update(0.016);
    
    notifyListeners();
  }
  
  void _onFlightStatusChange(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _onDartHit();
    }
  }
  
  void _onDartHit() {
    _state = ThrowState.impacting;
    
    // Saplanma efektini başlat
    _impactEffect.trigger(_targetPoint!, _currentDartAngle);
    
    // Kamera bounce
    _cameraController.triggerImpactBounce();
    
    // Impact animasyonunu başlat
    _impactAnimController!.forward(from: 0);
    
    // Callback
    onDartHit?.call(_targetPoint!);
    
    notifyListeners();
  }
  
  void _onImpactUpdate() {
    double dt = 0.016; // ~60fps
    
    // Efektleri güncelle
    _impactEffect.update(dt);
    
    // Kamera güncelle
    _cameraController.update(dt);
    
    notifyListeners();
    
    // Impact animasyonu bittiğinde
    if (_impactAnimController!.isCompleted) {
      _state = ThrowState.stuck;
      onThrowComplete?.call();
    }
  }
  
  /// Sıfırla
  void reset() {
    _flightAnimController?.stop();
    _impactAnimController?.stop();
    _state = ThrowState.idle;
    _flightModel = null;
    _currentDartPosition = null;
    _currentDartAngle = 0;
    _currentDartScale = 1.0;
    _targetPoint = null;
    _motionTrail.clear();
    _impactEffect.reset();
    _cameraController.reset();
    notifyListeners();
  }
  
  /// Dispose
  @override
  void dispose() {
    _flightAnimController?.dispose();
    _impactAnimController?.dispose();
    super.dispose();
  }
  
  // Getters
  ThrowState get state => _state;
  bool get isFlying => _state == ThrowState.flying;
  bool get isImpacting => _state == ThrowState.impacting;
  bool get isStuck => _state == ThrowState.stuck;
  bool get isIdle => _state == ThrowState.idle;
  
  Offset? get currentPosition => _currentDartPosition;
  double get currentAngle => _currentDartAngle;
  double get currentScale => _currentDartScale;
  Offset? get targetPoint => _targetPoint;
  
  DartMotionTrail get motionTrail => _motionTrail;
  CameraFollowController get cameraController => _cameraController;
  DartImpactEffect get impactEffect => _impactEffect;
  DartFlightModel? get flightModel => _flightModel;
  
  double get flightProgress => _flightAnimController?.value ?? 0;
  bool get isSlowMotion => _cameraController.isSlowMotion;
  double get timeScale => _cameraController.timeScale;
  Matrix4 get cameraMatrix => _cameraController.matrix;
}

/// Atış durumları
enum ThrowState {
  idle,      // Beklemede
  flying,    // Uçuşta
  impacting, // Saplanıyor
  stuck,     // Saplanmış
}
