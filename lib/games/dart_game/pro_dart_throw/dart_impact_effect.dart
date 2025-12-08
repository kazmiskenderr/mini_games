import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Dart saplanma efektleri
/// Gömülme, bounce, shake, glow ve toz partikülleri
class DartImpactEffect {
  // Efekt ayarları
  final double embedDepth; // 4-6px gömülme
  final double bounceScale; // 1.12 max bounce
  final double shakeIntensity;
  final int particleCount;
  
  // Durum
  bool _isActive = false;
  double _embedProgress = 0; // 0-1
  double _bounceProgress = 0; // 0-1
  double _shakeProgress = 0; // 0-1
  double _glowProgress = 0; // 0-1
  Offset _impactPoint = Offset.zero;
  double _impactAngle = 0;
  
  // Partikül sistemi
  final List<DustParticle> _particles = [];
  
  DartImpactEffect({
    this.embedDepth = 5.0,
    this.bounceScale = 1.12,
    this.shakeIntensity = 3.0,
    this.particleCount = 12,
  });
  
  /// Saplanma efektini başlat
  void trigger(Offset impactPoint, double angle) {
    _isActive = true;
    _impactPoint = impactPoint;
    _impactAngle = angle;
    _embedProgress = 0;
    _bounceProgress = 0;
    _shakeProgress = 0;
    _glowProgress = 0;
    
    // Toz partikülleri oluştur
    _createDustParticles();
  }
  
  void _createDustParticles() {
    _particles.clear();
    final random = math.Random();
    
    for (int i = 0; i < particleCount; i++) {
      // Rastgele yön (saplanma noktasından dışarı)
      double angle = random.nextDouble() * math.pi * 2;
      double speed = 50 + random.nextDouble() * 100;
      double size = 2 + random.nextDouble() * 4;
      double life = 0.5 + random.nextDouble() * 0.5;
      
      _particles.add(DustParticle(
        position: _impactPoint,
        velocity: Offset(
          math.cos(angle) * speed,
          math.sin(angle) * speed - 30, // Hafif yukarı
        ),
        size: size,
        life: life,
        maxLife: life,
        color: Colors.brown.shade300,
      ));
    }
  }
  
  /// Frame güncelleme
  void update(double dt) {
    if (!_isActive) return;
    
    // Embed animasyonu (hızlı)
    if (_embedProgress < 1.0) {
      _embedProgress = (_embedProgress + dt * 8).clamp(0.0, 1.0);
    }
    
    // Bounce animasyonu (embed sonrası)
    if (_embedProgress >= 0.8 && _bounceProgress < 1.0) {
      _bounceProgress = (_bounceProgress + dt * 6).clamp(0.0, 1.0);
    }
    
    // Shake animasyonu
    if (_bounceProgress > 0 && _shakeProgress < 1.0) {
      _shakeProgress = (_shakeProgress + dt * 10).clamp(0.0, 1.0);
    }
    
    // Glow animasyonu
    if (_embedProgress >= 0.5) {
      if (_glowProgress < 1.0) {
        _glowProgress = (_glowProgress + dt * 4).clamp(0.0, 1.0);
      }
    }
    
    // Partikülleri güncelle
    for (var particle in _particles) {
      particle.update(dt);
    }
    _particles.removeWhere((p) => p.isDead);
    
    // Tüm animasyonlar bitti mi?
    if (_bounceProgress >= 1.0 && _shakeProgress >= 1.0 && _particles.isEmpty) {
      // Efekt tamamlandı, ama aktif kal (dart saplanmış durumda)
    }
  }
  
  /// Mevcut gömülme miktarı
  double get currentEmbedOffset {
    // Easing: easeOutBack
    double t = _embedProgress;
    double c1 = 1.70158;
    double c3 = c1 + 1;
    double eased = 1 + c3 * math.pow(t - 1, 3) + c1 * math.pow(t - 1, 2);
    return embedDepth * eased;
  }
  
  /// Mevcut bounce scale
  double get currentBounceScale {
    if (_bounceProgress <= 0) return 1.0;
    
    // Bounce: 1.0 → 1.12 → 1.0
    // Easing: easeOutElastic benzeri
    double t = _bounceProgress;
    double bounce = math.sin(t * math.pi) * (bounceScale - 1.0);
    return 1.0 + bounce * (1 - t * 0.5);
  }
  
  /// Mevcut shake offset
  Offset get currentShakeOffset {
    if (_shakeProgress >= 1.0 || _shakeProgress <= 0) return Offset.zero;
    
    // Azalan şiddetle rastgele shake
    double intensity = shakeIntensity * (1 - _shakeProgress);
    double shakeX = math.sin(_shakeProgress * 40) * intensity;
    double shakeY = math.cos(_shakeProgress * 35) * intensity * 0.7;
    
    return Offset(shakeX, shakeY);
  }
  
  /// Mevcut glow opacity
  double get currentGlowOpacity {
    // Glow: parlak başla, sönsün
    if (_glowProgress <= 0) return 0;
    return (1 - _glowProgress) * 0.8;
  }
  
  /// Glow yarıçapı
  double get currentGlowRadius {
    return 20 + _glowProgress * 30;
  }
  
  /// Efekt aktif mi
  bool get isActive => _isActive;
  
  /// Saplanma noktası
  Offset get impactPoint => _impactPoint;
  
  /// Partiküller
  List<DustParticle> get particles => _particles;
  
  /// Sıfırla
  void reset() {
    _isActive = false;
    _embedProgress = 0;
    _bounceProgress = 0;
    _shakeProgress = 0;
    _glowProgress = 0;
    _particles.clear();
  }
  
  /// Saplanmış dart'ı çiz (efektlerle birlikte)
  void paintEffects(Canvas canvas) {
    if (!_isActive) return;
    
    // Glow halkası
    if (currentGlowOpacity > 0) {
      canvas.drawCircle(
        _impactPoint,
        currentGlowRadius,
        Paint()
          ..color = Colors.white.withOpacity(currentGlowOpacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
      );
      
      // İç glow
      canvas.drawCircle(
        _impactPoint,
        currentGlowRadius * 0.5,
        Paint()
          ..color = Colors.amber.withOpacity(currentGlowOpacity * 0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }
    
    // Toz partikülleri
    for (var particle in _particles) {
      particle.paint(canvas);
    }
  }
  
  /// Efekt widget'ları
  List<Widget> buildEffectWidgets() {
    List<Widget> widgets = [];
    
    // Glow widget
    if (_isActive && currentGlowOpacity > 0) {
      widgets.add(
        Positioned(
          left: _impactPoint.dx - currentGlowRadius,
          top: _impactPoint.dy - currentGlowRadius,
          child: Container(
            width: currentGlowRadius * 2,
            height: currentGlowRadius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(currentGlowOpacity),
                  Colors.amber.withOpacity(currentGlowOpacity * 0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      );
    }
    
    // Partikül widget'ları
    for (var particle in _particles) {
      widgets.add(
        Positioned(
          left: particle.position.dx - particle.size / 2,
          top: particle.position.dy - particle.size / 2,
          child: Opacity(
            opacity: particle.opacity,
            child: Container(
              width: particle.size,
              height: particle.size,
              decoration: BoxDecoration(
                color: particle.color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      );
    }
    
    return widgets;
  }
}

/// Toz partikülleri
class DustParticle {
  Offset position;
  Offset velocity;
  double size;
  double life;
  final double maxLife;
  final Color color;
  
  static const double gravity = 200;
  
  DustParticle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.life,
    required this.maxLife,
    required this.color,
  });
  
  void update(double dt) {
    // Hareket
    position = position + velocity * dt;
    
    // Yerçekimi
    velocity = Offset(velocity.dx * 0.98, velocity.dy + gravity * dt);
    
    // Yaşam süresi
    life -= dt;
    
    // Küçülme
    size *= 0.98;
  }
  
  bool get isDead => life <= 0 || size < 0.5;
  
  double get opacity => (life / maxLife).clamp(0.0, 1.0);
  
  void paint(Canvas canvas) {
    canvas.drawCircle(
      position,
      size,
      Paint()..color = color.withOpacity(opacity),
    );
  }
}
