import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../jump_game.dart';
import 'obstacle.dart';
import 'platform.dart';

class Player extends PositionComponent with HasGameReference<JumpGame>, CollisionCallbacks {
  static const double gravity = 980.0;
  static const double jumpVelocity = -500.0;
  static const double playerSize = 50.0;
  
  double velocityY = 0;
  bool isOnGround = false;
  Vector2 initialPosition = Vector2.zero();

  Player({required Vector2 position}) : super(position: position, size: Vector2.all(playerSize)) {
    initialPosition = position.clone();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Apply gravity
    velocityY += gravity * dt;
    position.y += velocityY * dt;
    
    // Check if on ground (simplified)
    if (position.y >= game.size.y - 150) {
      position.y = game.size.y - 150;
      velocityY = 0;
      isOnGround = true;
    }
  }

  void jump() {
    if (isOnGround) {
      velocityY = jumpVelocity;
      isOnGround = false;
    }
  }

  void reset() {
    position = initialPosition.clone();
    velocityY = 0;
    isOnGround = false;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    
    if (other is Obstacle) {
      game.gameOver();
    } else if (other is Platform) {
      if (velocityY > 0) {
        position.y = other.position.y - size.y;
        velocityY = 0;
        isOnGround = true;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(8),
      ),
      paint,
    );
    
    // Draw eyes
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(size.x * 0.3, size.y * 0.3), 5, eyePaint);
    canvas.drawCircle(Offset(size.x * 0.7, size.y * 0.3), 5, eyePaint);
    
    // Draw pupils
    final pupilPaint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(size.x * 0.3, size.y * 0.3), 2, pupilPaint);
    canvas.drawCircle(Offset(size.x * 0.7, size.y * 0.3), 2, pupilPaint);
  }
}
