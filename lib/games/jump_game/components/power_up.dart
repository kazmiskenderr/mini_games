import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../pro_jump_game.dart';
import 'animated_player.dart';

enum PowerUpType { shield, doubleJump, slowMotion, magnet, scoreBoost }

class PowerUp extends PositionComponent with HasGameReference<JumpGame> {
  static const double powerUpSize = 40.0;
  
  final PowerUpType type;
  double speed;
  double animationTime = 0;
  double glowIntensity = 0;
  
  PowerUp({
    required Vector2 position,
    required this.type,
    required this.speed,
  }) : super(
    position: position,
    size: Vector2.all(powerUpSize),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    animationTime += dt;
    glowIntensity = (sin(animationTime * 4) + 1) / 2;
    
    // Yukarı aşağı sallanma
    position.y += sin(animationTime * 3) * 0.5;
    
    // Sola hareket
    position.x -= speed * dt;
    
    if (position.x + size.x < 0) {
      removeFromParent();
    }
  }

  Color get primaryColor {
    switch (type) {
      case PowerUpType.shield:
        return Colors.cyan;
      case PowerUpType.doubleJump:
        return Colors.purple;
      case PowerUpType.slowMotion:
        return Colors.amber;
      case PowerUpType.magnet:
        return Colors.red;
      case PowerUpType.scoreBoost:
        return Colors.green;
    }
  }
  
  Color get secondaryColor {
    switch (type) {
      case PowerUpType.shield:
        return Colors.blue;
      case PowerUpType.doubleJump:
        return Colors.pink;
      case PowerUpType.slowMotion:
        return Colors.orange;
      case PowerUpType.magnet:
        return Colors.pink;
      case PowerUpType.scoreBoost:
        return Colors.teal;
    }
  }
  
  IconData get icon {
    switch (type) {
      case PowerUpType.shield:
        return Icons.shield;
      case PowerUpType.doubleJump:
        return Icons.keyboard_double_arrow_up;
      case PowerUpType.slowMotion:
        return Icons.speed;
      case PowerUpType.magnet:
        return Icons.attractions;
      case PowerUpType.scoreBoost:
        return Icons.star;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final center = Offset(size.x / 2, size.y / 2);
    
    // Dış parlaklık
    for (int i = 3; i > 0; i--) {
      canvas.drawCircle(
        center,
        size.x / 2 + i * 4 + glowIntensity * 3,
        Paint()
          ..color = primaryColor.withValues(alpha: 0.15 - i * 0.04)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }
    
    // Ana daire
    final gradient = RadialGradient(
      colors: [
        secondaryColor,
        primaryColor,
      ],
    );
    
    canvas.drawCircle(
      center,
      size.x / 2,
      Paint()..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: size.x / 2),
      ),
    );
    
    // İç parlaklık
    canvas.drawCircle(
      center - const Offset(5, 5),
      size.x / 4,
      Paint()..color = Colors.white.withValues(alpha: 0.4),
    );
    
    // Dönen yıldızlar
    _drawSpinningStars(canvas, center);
    
    // İkon çiz
    _drawIcon(canvas, center);
  }
  
  void _drawSpinningStars(Canvas canvas, Offset center) {
    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.8);
    
    for (int i = 0; i < 4; i++) {
      final angle = animationTime * 2 + (i * pi / 2);
      final distance = size.x / 2 + 8;
      final starPos = center + Offset(
        cos(angle) * distance,
        sin(angle) * distance,
      );
      
      _drawStar(canvas, starPos, 4, starPaint);
    }
  }
  
  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 4 * pi / 5) - pi / 2;
      final point = center + Offset(cos(angle) * size, sin(angle) * size);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }
  
  void _drawIcon(Canvas canvas, Offset center) {
    final iconPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    
    switch (type) {
      case PowerUpType.shield:
        final shieldPath = Path();
        shieldPath.moveTo(center.dx, center.dy - 10);
        shieldPath.lineTo(center.dx + 10, center.dy - 5);
        shieldPath.lineTo(center.dx + 10, center.dy + 5);
        shieldPath.quadraticBezierTo(center.dx, center.dy + 12, center.dx - 10, center.dy + 5);
        shieldPath.lineTo(center.dx - 10, center.dy - 5);
        shieldPath.close();
        canvas.drawPath(shieldPath, iconPaint);
        break;
        
      case PowerUpType.doubleJump:
        canvas.drawLine(
          center + const Offset(-6, 4),
          center + const Offset(0, -4),
          iconPaint,
        );
        canvas.drawLine(
          center + const Offset(0, -4),
          center + const Offset(6, 4),
          iconPaint,
        );
        canvas.drawLine(
          center + const Offset(-6, 10),
          center + const Offset(0, 2),
          iconPaint,
        );
        canvas.drawLine(
          center + const Offset(0, 2),
          center + const Offset(6, 10),
          iconPaint,
        );
        break;
        
      case PowerUpType.slowMotion:
        canvas.drawCircle(center, 8, iconPaint);
        canvas.drawLine(center, center + const Offset(0, -6), iconPaint);
        canvas.drawLine(center, center + const Offset(5, 3), iconPaint);
        break;
        
      case PowerUpType.magnet:
        final magnetPath = Path();
        magnetPath.addArc(
          Rect.fromCenter(center: center, width: 16, height: 16),
          pi,
          pi,
        );
        canvas.drawPath(magnetPath, iconPaint);
        canvas.drawLine(center + const Offset(-8, 0), center + const Offset(-8, 8), iconPaint);
        canvas.drawLine(center + const Offset(8, 0), center + const Offset(8, 8), iconPaint);
        break;
        
      case PowerUpType.scoreBoost:
        _drawStar(canvas, center, 10, iconPaint..style = PaintingStyle.fill);
        break;
    }
  }
  
  void applyEffect(Player player, JumpGame game) {
    switch (type) {
      case PowerUpType.shield:
        player.activateShield(5.0);
        game.showPowerUpMessage('Kalkan Aktif!', primaryColor);
        break;
      case PowerUpType.doubleJump:
        player.activateDoubleJump();
        game.showPowerUpMessage('Çift Zıplama!', primaryColor);
        break;
      case PowerUpType.slowMotion:
        game.activateSlowMotion(3.0);
        game.showPowerUpMessage('Yavaş Mod!', primaryColor);
        break;
      case PowerUpType.magnet:
        // Gelecekte coin mıknatısı için
        game.showPowerUpMessage('Mıknatıs!', primaryColor);
        break;
      case PowerUpType.scoreBoost:
        game.addBonusScore(50);
        game.showPowerUpMessage('+50 Puan!', primaryColor);
        break;
    }
  }
}
