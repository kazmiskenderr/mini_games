import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../jump_game.dart';

class Background extends Component with HasGameReference<JumpGame> {
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Sky gradient
    final rect = Rect.fromLTWH(0, 0, game.size.x, game.size.y);
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.lightBlue.shade300,
        Colors.lightBlue.shade100,
        Colors.white,
      ],
    );
    
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
    
    // Sun
    final sunPaint = Paint()
      ..color = Colors.yellow.shade600
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(game.size.x * 0.85, game.size.y * 0.15),
      40,
      sunPaint,
    );
    
    // Clouds
    drawCloud(canvas, Offset(game.size.x * 0.2, game.size.y * 0.15));
    drawCloud(canvas, Offset(game.size.x * 0.6, game.size.y * 0.25));
  }

  void drawCloud(Canvas canvas, Offset position) {
    final cloudPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(position, 25, cloudPaint);
    canvas.drawCircle(position + const Offset(20, 0), 30, cloudPaint);
    canvas.drawCircle(position + const Offset(40, 0), 25, cloudPaint);
    canvas.drawCircle(position + const Offset(20, -10), 20, cloudPaint);
  }
}
