import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Profesyonel Impact Efekt Sistemi
/// Saplanma, shake, star partikülleri, glow
class ProImpactController {
  // Impact durumu
  bool _isActive = false;
  Offset? _impactPoint;
  double _impactAngle = 0;
  double _penetrationDepth = 0;
  
  // Shake efekti
  Offset _shakeOffset = Offset.zero;
  int _shakeFrame = 0;
  static const int maxShakeFrames = 8;
  
  // Star partikülleri
  List<ImpactStar> _stars = [];
  
  // Glow efekti
  double _glowOpacity = 0;
  double _glowRadius = 0;
  
  // Random
  final _random = math.Random();
  
  // Getters
  bool get isActive => _isActive;
  Offset? get impactPoint => _impactPoint;
  double get impactAngle => _impactAngle;
  double get penetrationDepth => _penetrationDepth;
  Offset get shakeOffset => _shakeOffset;
  List<ImpactStar> get stars => _stars;
  double get glowOpacity => _glowOpacity;
  double get glowRadius => _glowRadius;
  
  /// Impact tetikle
  void trigger(Offset point, double angle, Color dartColor) {
    _isActive = true;
    _impactPoint = point;
    _impactAngle = angle;
    
    // Penetrasyon: 3-5px
    _penetrationDepth = 3 + _random.nextDouble() * 2;
    
    // Shake başlat
    _shakeFrame = 0;
    
    // Star partikülleri oluştur
    _createStars(point, dartColor);
    
    // Glow başlat
    _glowOpacity = 0.8;
    _glowRadius = 5;
  }
  
  void _createStars(Offset center, Color dartColor) {
    _stars.clear();
    
    // 12-16 star partikül
    int starCount = 12 + _random.nextInt(5);
    
    for (int i = 0; i < starCount; i++) {
      double angle = (i / starCount) * math.pi * 2 + _random.nextDouble() * 0.3;
      double speed = 80 + _random.nextDouble() * 120;
      double size = 3 + _random.nextDouble() * 4;
      
      // Renk çeşitliliği
      Color color;
      int colorChoice = _random.nextInt(5);
      switch (colorChoice) {
        case 0:
          color = Colors.white;
          break;
        case 1:
          color = Colors.yellow;
          break;
        case 2:
          color = Colors.orange;
          break;
        case 3:
          color = dartColor;
          break;
        default:
          color = Colors.amber;
      }
      
      _stars.add(ImpactStar(
        position: center,
        velocity: Offset(
          math.cos(angle) * speed,
          math.sin(angle) * speed,
        ),
        size: size,
        color: color,
        rotation: _random.nextDouble() * math.pi * 2,
        rotationSpeed: (_random.nextDouble() - 0.5) * 10,
        lifetime: 0.4 + _random.nextDouble() * 0.3,
        age: 0,
      ));
    }
  }
  
  /// Frame update
  void update(double dt) {
    if (!_isActive) return;
    
    // Shake update
    if (_shakeFrame < maxShakeFrames) {
      double intensity = (1 - _shakeFrame / maxShakeFrames) * 3;
      _shakeOffset = Offset(
        (_random.nextDouble() - 0.5) * intensity * 2,
        (_random.nextDouble() - 0.5) * intensity * 2,
      );
      _shakeFrame++;
    } else {
      _shakeOffset = Offset.zero;
    }
    
    // Star partikülleri update
    for (var star in _stars) {
      star.update(dt);
    }
    _stars.removeWhere((s) => s.isDead);
    
    // Glow fade out
    _glowOpacity = (_glowOpacity - dt * 2).clamp(0.0, 1.0);
    _glowRadius = _glowRadius + dt * 40;
    
    // Tüm efektler bitti mi?
    if (_stars.isEmpty && _glowOpacity <= 0 && _shakeFrame >= maxShakeFrames) {
      // _isActive = false; // Keep active for stuck dart
    }
  }
  
  /// Widget'ları oluştur
  List<Widget> buildEffectWidgets() {
    if (!_isActive || _impactPoint == null) return [];
    
    List<Widget> widgets = [];
    
    // Glow efekti
    if (_glowOpacity > 0) {
      widgets.add(
        Positioned(
          left: _impactPoint!.dx - _glowRadius,
          top: _impactPoint!.dy - _glowRadius,
          child: Container(
            width: _glowRadius * 2,
            height: _glowRadius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(_glowOpacity),
                  Colors.yellow.withOpacity(_glowOpacity * 0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      );
    }
    
    // Star partikülleri
    for (var star in _stars) {
      widgets.add(
        Positioned(
          left: star.position.dx - star.size / 2,
          top: star.position.dy - star.size / 2,
          child: Transform.rotate(
            angle: star.rotation,
            child: _buildStarShape(star),
          ),
        ),
      );
    }
    
    return widgets;
  }
  
  Widget _buildStarShape(ImpactStar star) {
    double opacity = star.opacity;
    
    return Container(
      width: star.size,
      height: star.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: star.color.withOpacity(opacity),
        boxShadow: [
          BoxShadow(
            color: star.color.withOpacity(opacity * 0.5),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
  
  /// Sıfırla
  void reset() {
    _isActive = false;
    _impactPoint = null;
    _shakeOffset = Offset.zero;
    _shakeFrame = maxShakeFrames;
    _stars.clear();
    _glowOpacity = 0;
    _glowRadius = 0;
  }
}

/// Star partikül sınıfı
class ImpactStar {
  Offset position;
  Offset velocity;
  double size;
  Color color;
  double rotation;
  double rotationSpeed;
  double lifetime;
  double age;
  
  ImpactStar({
    required this.position,
    required this.velocity,
    required this.size,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
    required this.lifetime,
    required this.age,
  });
  
  void update(double dt) {
    // Pozisyon güncelle
    position += velocity * dt;
    
    // Yavaşlama
    velocity *= 0.95;
    
    // Yerçekimi
    velocity = Offset(velocity.dx, velocity.dy + 200 * dt);
    
    // Rotasyon
    rotation += rotationSpeed * dt;
    
    // Yaş
    age += dt;
    
    // Küçülme
    size *= 0.98;
  }
  
  bool get isDead => age >= lifetime || size < 0.5;
  
  double get opacity => ((lifetime - age) / lifetime).clamp(0.0, 1.0);
}
