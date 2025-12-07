import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../pro_jump_game.dart';
import 'animated_player.dart';

/// Yukarıdan düşen engeller - Meteor, buz, taş vb.
enum FallingType { meteor, ice, boulder, bomb }

class FallingObstacle extends PositionComponent 
    with HasGameReference<JumpGame>, CollisionCallbacks {
  
  final FallingType type;
  final double fallSpeed;
  double rotationSpeed = 0;
  double currentRotation = 0;
  bool hasWarning = true;
  double warningTimer = 0.8; // Uyarı süresi
  bool isFalling = false;
  double targetX = 0;
  
  // Partikül efektleri
  final List<FallingParticle> particles = [];
  
  FallingObstacle({
    required Vector2 position,
    required this.type,
    this.fallSpeed = 400,
  }) : super(position: position, anchor: Anchor.center) {
    size = _getSize();
    rotationSpeed = (Random().nextDouble() - 0.5) * 4;
    targetX = position.x;
  }
  
  Vector2 _getSize() {
    switch (type) {
      case FallingType.meteor:
        return Vector2(45, 45);
      case FallingType.ice:
        return Vector2(35, 50);
      case FallingType.boulder:
        return Vector2(50, 50);
      case FallingType.bomb:
        return Vector2(40, 45);
    }
  }
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Hitbox ekle (düşmeye başladığında aktif olacak)
    add(CircleHitbox(
      radius: size.x * 0.4,
      position: Vector2(size.x * 0.1, size.y * 0.1),
    ));
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    if (hasWarning) {
      warningTimer -= dt;
      if (warningTimer <= 0) {
        hasWarning = false;
        isFalling = true;
      }
      return;
    }
    
    if (isFalling) {
      position.y += fallSpeed * dt;
      currentRotation += rotationSpeed * dt;
      
      // Partikül efekti
      if (Random().nextDouble() < 0.3) {
        particles.add(FallingParticle(
          position: position.clone(),
          color: _getParticleColor(),
        ));
      }
      
      // Ekran dışına çıktıysa kaldır
      if (position.y > game.size.y + 50) {
        removeFromParent();
      }
    }
    
    // Partikülleri güncelle
    particles.removeWhere((p) {
      p.update(dt);
      return p.isDead;
    });
  }
  
  Color _getParticleColor() {
    switch (type) {
      case FallingType.meteor:
        return Colors.orange;
      case FallingType.ice:
        return Colors.lightBlue;
      case FallingType.boulder:
        return Colors.brown;
      case FallingType.bomb:
        return Colors.grey;
    }
  }
  
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Uyarı göstergesi
    if (hasWarning) {
      _renderWarning(canvas);
      return;
    }
    
    // Partiküller
    for (final p in particles) {
      final paint = Paint()..color = p.color.withValues(alpha: p.alpha);
      canvas.drawCircle(
        Offset(
          p.position.x - position.x + size.x / 2,
          p.position.y - position.y + size.y / 2,
        ),
        p.size,
        paint,
      );
    }
    
    // Ana engel
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.rotate(currentRotation);
    canvas.translate(-size.x / 2, -size.y / 2);
    
    switch (type) {
      case FallingType.meteor:
        _renderMeteor(canvas);
        break;
      case FallingType.ice:
        _renderIce(canvas);
        break;
      case FallingType.boulder:
        _renderBoulder(canvas);
        break;
      case FallingType.bomb:
        _renderBomb(canvas);
        break;
    }
    
    canvas.restore();
  }
  
  void _renderWarning(Canvas canvas) {
    // Yanıp sönen uyarı işareti
    final flash = (warningTimer * 8).floor() % 2 == 0;
    if (!flash) return;
    
    final warningPaint = Paint()
      ..color = Colors.red.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    
    // Üçgen uyarı
    final path = Path()
      ..moveTo(size.x / 2, 0)
      ..lineTo(size.x, size.y)
      ..lineTo(0, size.y)
      ..close();
    
    canvas.drawPath(path, warningPaint);
    
    // Ünlem işareti
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '!',
        style: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(size.x / 2 - textPainter.width / 2, size.y / 2 - textPainter.height / 2 + 5),
    );
  }
  
  void _renderMeteor(Canvas canvas) {
    // Ateşli meteor
    final firePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.yellow,
          Colors.orange,
          Colors.red.shade900,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));
    
    canvas.drawOval(
      Rect.fromLTWH(0, 0, size.x, size.y),
      firePaint,
    );
    
    // Çatlaklar
    final crackPaint = Paint()
      ..color = Colors.black54
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    canvas.drawLine(
      Offset(size.x * 0.3, size.y * 0.3),
      Offset(size.x * 0.6, size.y * 0.7),
      crackPaint,
    );
  }
  
  void _renderIce(Canvas canvas) {
    // Buz parçası
    final icePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.lightBlue.shade100,
          Colors.lightBlue.shade300,
          Colors.blue.shade400,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));
    
    final path = Path()
      ..moveTo(size.x / 2, 0)
      ..lineTo(size.x * 0.9, size.y * 0.3)
      ..lineTo(size.x, size.y * 0.7)
      ..lineTo(size.x * 0.6, size.y)
      ..lineTo(size.x * 0.2, size.y * 0.9)
      ..lineTo(0, size.y * 0.5)
      ..lineTo(size.x * 0.2, size.y * 0.2)
      ..close();
    
    canvas.drawPath(path, icePaint);
    
    // Parlaklık
    final shinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6);
    canvas.drawCircle(
      Offset(size.x * 0.35, size.y * 0.35),
      5,
      shinePaint,
    );
  }
  
  void _renderBoulder(Canvas canvas) {
    // Kaya
    final rockPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.grey.shade400,
          Colors.grey.shade600,
          Colors.grey.shade800,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));
    
    // Düzensiz şekil
    final path = Path()
      ..moveTo(size.x * 0.2, 0)
      ..lineTo(size.x * 0.8, size.y * 0.1)
      ..lineTo(size.x, size.y * 0.4)
      ..lineTo(size.x * 0.9, size.y * 0.8)
      ..lineTo(size.x * 0.5, size.y)
      ..lineTo(size.x * 0.1, size.y * 0.85)
      ..lineTo(0, size.y * 0.4)
      ..close();
    
    canvas.drawPath(path, rockPaint);
  }
  
  void _renderBomb(Canvas canvas) {
    // Bomba gövdesi
    final bodyPaint = Paint()..color = Colors.grey.shade800;
    canvas.drawOval(
      Rect.fromLTWH(5, 10, size.x - 10, size.y - 15),
      bodyPaint,
    );
    
    // Fitil
    final wickPaint = Paint()
      ..color = Colors.brown
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    final wickPath = Path()
      ..moveTo(size.x / 2, 10)
      ..quadraticBezierTo(size.x * 0.7, 0, size.x * 0.6, -5);
    
    canvas.drawPath(wickPath, wickPaint);
    
    // Kıvılcım
    final sparkPaint = Paint()..color = Colors.orange;
    canvas.drawCircle(
      Offset(size.x * 0.6, -5),
      4 + Random().nextDouble() * 2,
      sparkPaint,
    );
    
    // Parlaklık
    final shinePaint = Paint()..color = Colors.white.withValues(alpha: 0.3);
    canvas.drawOval(
      Rect.fromLTWH(15, 20, 12, 8),
      shinePaint,
    );
  }
  
  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    
    if (other is Player && !other.hasShield && isFalling) {
      game.gameOver();
    }
  }
}

class FallingParticle {
  Vector2 position;
  Color color;
  double size = 3;
  double alpha = 1.0;
  double velocityY = -50;
  
  bool get isDead => alpha <= 0;
  
  FallingParticle({
    required this.position,
    required this.color,
  }) {
    size = 2 + Random().nextDouble() * 3;
    velocityY = -30 - Random().nextDouble() * 40;
  }
  
  void update(double dt) {
    position.y += velocityY * dt;
    alpha -= dt * 2;
  }
}
