import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../jump_game.dart';

class Obstacle extends PositionComponent with HasGameReference<JumpGame> {
  static const double obstacleWidth = 40.0;
  static const double obstacleHeight = 50.0;
  
  double speed;

  Obstacle({
    required Vector2 position,
    required this.speed,
  }) : super(
          position: position,
          size: Vector2(obstacleWidth, obstacleHeight),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Move obstacle to the left
    position.x -= speed * dt;
    
    // Remove when off screen
    if (position.x + size.x < 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    
    // Draw cactus-like shape
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(5),
      ),
      paint,
    );
    
    // Add spikes
    final spikePaint = Paint()
      ..color = Colors.red.shade700
      ..style = PaintingStyle.fill;
    
    for (var i = 0; i < 3; i++) {
      final path = Path()
        ..moveTo(size.x * 0.2 + i * 12, 0)
        ..lineTo(size.x * 0.2 + i * 12 + 6, -8)
        ..lineTo(size.x * 0.2 + i * 12 + 12, 0)
        ..close();
      canvas.drawPath(path, spikePaint);
    }
  }
}
