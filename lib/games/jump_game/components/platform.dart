import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

class Platform extends PositionComponent {
  static const double platformHeight = 100.0;
  
  @override
  final double width;

  Platform({
    required Vector2 position,
    required this.width,
  }) : super(
          position: position,
          size: Vector2(width, platformHeight),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Draw grass on top
    final grassPaint = Paint()
      ..color = Colors.green.shade600
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, 20), grassPaint);
    
    // Draw soil
    final soilPaint = Paint()
      ..color = Colors.brown.shade700
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 20, size.x, size.y - 20), soilPaint);
    
    // Draw grass blades
    final grassBladePaint = Paint()
      ..color = Colors.green.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    for (var i = 0; i < size.x / 15; i++) {
      final x = i * 15.0;
      canvas.drawLine(
        Offset(x, 15),
        Offset(x - 2, 5),
        grassBladePaint,
      );
      canvas.drawLine(
        Offset(x + 5, 15),
        Offset(x + 7, 5),
        grassBladePaint,
      );
    }
  }
}
