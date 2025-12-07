import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../pro_jump_game.dart';

enum ObstacleType { spike, bird, rock, laser, movingSpike }

class AdvancedObstacle extends PositionComponent with HasGameReference<JumpGame> {
  final ObstacleType type;
  double speed;
  double animationTime = 0;
  double initialY = 0;
  
  // Kuş için kanat animasyonu
  double wingAngle = 0;
  
  // Lazer için
  bool laserActive = true;
  double laserTimer = 0;
  
  AdvancedObstacle({
    required Vector2 position,
    required this.type,
    required this.speed,
    Vector2? customSize,
  }) : super(
    position: position,
    size: customSize ?? _getDefaultSize(type),
  ) {
    initialY = position.y;
  }
  
  static Vector2 _getDefaultSize(ObstacleType type) {
    switch (type) {
      case ObstacleType.spike:
        return Vector2(35, 50);
      case ObstacleType.bird:
        return Vector2(50, 35);
      case ObstacleType.rock:
        return Vector2(55, 45);
      case ObstacleType.laser:
        return Vector2(20, 80);
      case ObstacleType.movingSpike:
        return Vector2(40, 55);
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    if (type == ObstacleType.bird) {
      add(RectangleHitbox(
        size: Vector2(size.x * 0.7, size.y * 0.6),
        position: Vector2(size.x * 0.15, size.y * 0.2),
      ));
    } else if (type == ObstacleType.laser) {
      add(RectangleHitbox(
        size: Vector2(size.x * 0.4, size.y),
        position: Vector2(size.x * 0.3, 0),
      ));
    } else {
      add(RectangleHitbox(
        size: Vector2(size.x * 0.8, size.y * 0.8),
        position: Vector2(size.x * 0.1, size.y * 0.1),
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    animationTime += dt;
    
    // Sola hareket
    position.x -= speed * dt;
    
    // Tipe göre özel hareket
    switch (type) {
      case ObstacleType.bird:
        wingAngle = sin(animationTime * 12) * 0.4;
        position.y = initialY + sin(animationTime * 3) * 30;
        break;
      case ObstacleType.movingSpike:
        position.y = initialY + sin(animationTime * 4) * 50;
        break;
      case ObstacleType.laser:
        laserTimer += dt;
        if (laserTimer > 1.5) {
          laserActive = !laserActive;
          laserTimer = 0;
        }
        break;
      default:
        break;
    }
    
    if (position.x + size.x < -50) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    switch (type) {
      case ObstacleType.spike:
        _drawSpike(canvas);
        break;
      case ObstacleType.bird:
        _drawBird(canvas);
        break;
      case ObstacleType.rock:
        _drawRock(canvas);
        break;
      case ObstacleType.laser:
        _drawLaser(canvas);
        break;
      case ObstacleType.movingSpike:
        _drawMovingSpike(canvas);
        break;
    }
  }
  
  void _drawSpike(Canvas canvas) {
    // Gölge
    canvas.drawPath(
      Path()
        ..moveTo(size.x / 2, 5)
        ..lineTo(size.x + 5, size.y + 5)
        ..lineTo(-5, size.y + 5)
        ..close(),
      Paint()..color = Colors.black.withValues(alpha: 0.3),
    );
    
    // Ana diken
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.red.shade300,
        Colors.red.shade700,
        Colors.red.shade900,
      ],
    );
    
    final path = Path()
      ..moveTo(size.x / 2, 0)
      ..lineTo(size.x, size.y)
      ..lineTo(0, size.y)
      ..close();
    
    canvas.drawPath(
      path,
      Paint()..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.x, size.y),
      ),
    );
    
    // Parlaklık
    canvas.drawPath(
      Path()
        ..moveTo(size.x / 2, 5)
        ..lineTo(size.x / 2 + 5, size.y * 0.4)
        ..lineTo(size.x / 2 - 2, size.y * 0.3)
        ..close(),
      Paint()..color = Colors.white.withValues(alpha: 0.4),
    );
    
    // Dikenler
    for (int i = 0; i < 3; i++) {
      final x = size.x * 0.2 + i * size.x * 0.3;
      canvas.drawPath(
        Path()
          ..moveTo(x, size.y)
          ..lineTo(x + 4, size.y - 12)
          ..lineTo(x + 8, size.y)
          ..close(),
        Paint()..color = Colors.red.shade800,
      );
    }
  }
  
  void _drawBird(Canvas canvas) {
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    
    // Gövde
    final bodyGradient = RadialGradient(
      colors: [
        Colors.purple.shade300,
        Colors.purple.shade700,
      ],
    );
    
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: size.x * 0.6, height: size.y * 0.5),
      Paint()..shader = bodyGradient.createShader(
        Rect.fromCenter(center: Offset.zero, width: size.x * 0.6, height: size.y * 0.5),
      ),
    );
    
    // Sol kanat
    canvas.save();
    canvas.rotate(wingAngle);
    canvas.drawPath(
      Path()
        ..moveTo(-5, 0)
        ..quadraticBezierTo(-size.x * 0.4, -size.y * 0.6, -size.x * 0.5, -size.y * 0.3)
        ..lineTo(-5, 5)
        ..close(),
      Paint()..color = Colors.purple.shade400,
    );
    canvas.restore();
    
    // Sağ kanat
    canvas.save();
    canvas.rotate(-wingAngle);
    canvas.drawPath(
      Path()
        ..moveTo(-5, 0)
        ..quadraticBezierTo(-size.x * 0.4, size.y * 0.6, -size.x * 0.5, size.y * 0.3)
        ..lineTo(-5, -5)
        ..close(),
      Paint()..color = Colors.purple.shade400,
    );
    canvas.restore();
    
    // Gaga
    canvas.drawPath(
      Path()
        ..moveTo(size.x * 0.3, 0)
        ..lineTo(size.x * 0.5, -3)
        ..lineTo(size.x * 0.5, 3)
        ..close(),
      Paint()..color = Colors.orange.shade700,
    );
    
    // Göz
    canvas.drawCircle(
      Offset(size.x * 0.1, -size.y * 0.08),
      4,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(size.x * 0.12, -size.y * 0.08),
      2,
      Paint()..color = Colors.black,
    );
    
    // Kızgın kaş
    canvas.drawLine(
      Offset(size.x * 0.02, -size.y * 0.18),
      Offset(size.x * 0.18, -size.y * 0.14),
      Paint()
        ..color = Colors.black
        ..strokeWidth = 2,
    );
    
    canvas.restore();
  }
  
  void _drawRock(Canvas canvas) {
    // Gölge
    canvas.drawOval(
      Rect.fromLTWH(5, size.y - 5, size.x - 5, 10),
      Paint()..color = Colors.black.withValues(alpha: 0.3),
    );
    
    // Ana kaya
    final rockPath = Path();
    rockPath.moveTo(size.x * 0.1, size.y * 0.8);
    rockPath.lineTo(size.x * 0.05, size.y * 0.5);
    rockPath.lineTo(size.x * 0.2, size.y * 0.2);
    rockPath.lineTo(size.x * 0.5, size.y * 0.05);
    rockPath.lineTo(size.x * 0.8, size.y * 0.15);
    rockPath.lineTo(size.x * 0.95, size.y * 0.4);
    rockPath.lineTo(size.x * 0.9, size.y * 0.8);
    rockPath.close();
    
    final rockGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.grey.shade400,
        Colors.grey.shade600,
        Colors.grey.shade800,
      ],
    );
    
    canvas.drawPath(
      rockPath,
      Paint()..shader = rockGradient.createShader(
        Rect.fromLTWH(0, 0, size.x, size.y),
      ),
    );
    
    // Çatlaklar
    final crackPaint = Paint()
      ..color = Colors.grey.shade900
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    
    canvas.drawLine(
      Offset(size.x * 0.3, size.y * 0.3),
      Offset(size.x * 0.5, size.y * 0.6),
      crackPaint,
    );
    canvas.drawLine(
      Offset(size.x * 0.5, size.y * 0.6),
      Offset(size.x * 0.4, size.y * 0.75),
      crackPaint,
    );
    canvas.drawLine(
      Offset(size.x * 0.6, size.y * 0.4),
      Offset(size.x * 0.75, size.y * 0.55),
      crackPaint,
    );
    
    // Parlaklık
    canvas.drawPath(
      Path()
        ..moveTo(size.x * 0.25, size.y * 0.25)
        ..lineTo(size.x * 0.4, size.y * 0.15)
        ..lineTo(size.x * 0.35, size.y * 0.35)
        ..close(),
      Paint()..color = Colors.white.withValues(alpha: 0.3),
    );
  }
  
  void _drawLaser(Canvas canvas) {
    final centerX = size.x / 2;
    
    // Üst ve alt cihaz
    _drawLaserDevice(canvas, Offset(centerX, 0), false);
    _drawLaserDevice(canvas, Offset(centerX, size.y), true);
    
    if (laserActive) {
      // Lazer ışını
      for (int i = 3; i > 0; i--) {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(centerX, size.y / 2),
            width: 4 + i * 3,
            height: size.y - 30,
          ),
          Paint()
            ..color = Colors.red.withValues(alpha: 0.2)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
        );
      }
      
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(centerX, size.y / 2),
          width: 4,
          height: size.y - 30,
        ),
        Paint()..color = Colors.red.shade400,
      );
      
      // Merkez çizgi
      canvas.drawLine(
        Offset(centerX, 15),
        Offset(centerX, size.y - 15),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 1,
      );
    } else {
      // Kapalı lazer göstergesi
      final dashPaint = Paint()
        ..color = Colors.red.withValues(alpha: 0.3)
        ..strokeWidth = 2;
      
      for (double y = 20; y < size.y - 20; y += 15) {
        canvas.drawLine(
          Offset(centerX, y),
          Offset(centerX, y + 8),
          dashPaint,
        );
      }
    }
  }
  
  void _drawLaserDevice(Canvas canvas, Offset position, bool isBottom) {
    final rect = Rect.fromCenter(
      center: position,
      width: size.x,
      height: 15,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      Paint()..color = Colors.grey.shade800,
    );
    
    // Lens
    canvas.drawCircle(
      position,
      5,
      Paint()..color = laserActive ? Colors.red : Colors.grey,
    );
  }
  
  void _drawMovingSpike(Canvas canvas) {
    // Uyarı göstergesi
    final warningAlpha = (sin(animationTime * 8) + 1) / 2;
    canvas.drawCircle(
      Offset(size.x / 2, -15),
      8,
      Paint()..color = Colors.yellow.withValues(alpha: warningAlpha * 0.8),
    );
    canvas.drawCircle(
      Offset(size.x / 2, -15),
      5,
      Paint()..color = Colors.orange,
    );
    
    // Çizgi
    canvas.drawLine(
      Offset(size.x / 2, -7),
      Offset(size.x / 2, 0),
      Paint()
        ..color = Colors.yellow.withValues(alpha: 0.5)
        ..strokeWidth = 2,
    );
    
    // Dikeni çiz
    _drawSpike(canvas);
  }
}
