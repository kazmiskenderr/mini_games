import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../pro_jump_game.dart';

class ParallaxBackground extends Component with HasGameReference<JumpGame> {
  final List<Cloud> clouds = [];
  final List<Mountain> mountains = [];
  final List<Star> stars = [];
  double time = 0;
  bool isNight = false;
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Uzak dağlar
    for (int i = 0; i < 5; i++) {
      mountains.add(Mountain(
        position: Vector2(i * 250.0, 0),
        height: 150 + Random().nextDouble() * 100,
        color: Colors.indigo.shade300,
        speed: 20,
      ));
    }
    
    // Yakın dağlar
    for (int i = 0; i < 4; i++) {
      mountains.add(Mountain(
        position: Vector2(i * 300.0 + 50, 0),
        height: 100 + Random().nextDouble() * 80,
        color: Colors.indigo.shade400,
        speed: 40,
      ));
    }
    
    // Bulutlar
    for (int i = 0; i < 6; i++) {
      clouds.add(Cloud(
        position: Vector2(
          Random().nextDouble() * 800,
          50 + Random().nextDouble() * 150,
        ),
        size: 30 + Random().nextDouble() * 40,
        speed: 15 + Random().nextDouble() * 25,
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    time += dt;
    
    if (game.isGameOver) return;
    
    // Bulutları hareket ettir
    for (var cloud in clouds) {
      cloud.position.x -= cloud.speed * dt;
      if (cloud.position.x + cloud.size * 3 < 0) {
        cloud.position.x = game.size.x + 50;
        cloud.position.y = 50 + Random().nextDouble() * 150;
      }
    }
    
    // Dağları hareket ettir
    for (var mountain in mountains) {
      mountain.position.x -= mountain.speed * dt;
      if (mountain.position.x + 300 < 0) {
        mountain.position.x = game.size.x + Random().nextDouble() * 200;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final screenRect = Rect.fromLTWH(0, 0, game.size.x, game.size.y);
    
    // Dinamik gökyüzü gradient
    final skyGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.lerp(const Color(0xFF1a237e), const Color(0xFF64b5f6), 
          (sin(time * 0.1) + 1) / 2)!,
        Color.lerp(const Color(0xFF283593), const Color(0xFF90caf9), 
          (sin(time * 0.1) + 1) / 2)!,
        Color.lerp(const Color(0xFF3949ab), const Color(0xFFe3f2fd), 
          (sin(time * 0.1) + 1) / 2)!,
      ],
    );
    
    canvas.drawRect(
      screenRect,
      Paint()..shader = skyGradient.createShader(screenRect),
    );
    
    // Güneş / Ay
    _drawCelestialBody(canvas);
    
    // Bulutları çiz
    for (var cloud in clouds) {
      _drawCloud(canvas, cloud);
    }
    
    // Dağları çiz
    for (var mountain in mountains) {
      _drawMountain(canvas, mountain);
    }
    
    // Yer gradient
    _drawGround(canvas);
  }

  void _drawCelestialBody(Canvas canvas) {
    final sunX = game.size.x * 0.8;
    final sunY = game.size.y * 0.12;
    
    // Güneş parlaması
    for (int i = 3; i > 0; i--) {
      canvas.drawCircle(
        Offset(sunX, sunY),
        45 + i * 15.0,
        Paint()
          ..color = Colors.yellow.withValues(alpha: 0.1)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
      );
    }
    
    // Ana güneş
    final sunGradient = RadialGradient(
      colors: [
        Colors.yellow.shade200,
        Colors.orange.shade400,
      ],
    );
    
    canvas.drawCircle(
      Offset(sunX, sunY),
      45,
      Paint()..shader = sunGradient.createShader(
        Rect.fromCircle(center: Offset(sunX, sunY), radius: 45),
      ),
    );
  }

  void _drawCloud(Canvas canvas, Cloud cloud) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    
    final x = cloud.position.x;
    final y = cloud.position.y;
    final s = cloud.size;
    
    // Kabarık bulut şekli
    canvas.drawCircle(Offset(x, y), s * 0.6, paint);
    canvas.drawCircle(Offset(x + s * 0.5, y - s * 0.2), s * 0.5, paint);
    canvas.drawCircle(Offset(x + s, y), s * 0.65, paint);
    canvas.drawCircle(Offset(x + s * 1.5, y - s * 0.1), s * 0.45, paint);
    canvas.drawCircle(Offset(x + s * 0.7, y + s * 0.2), s * 0.4, paint);
    
    // Alt gölge
    canvas.drawCircle(
      Offset(x + s * 0.5, y + s * 0.3),
      s * 0.3,
      Paint()..color = Colors.white.withValues(alpha: 0.5),
    );
  }

  void _drawMountain(Canvas canvas, Mountain mountain) {
    final path = Path();
    final baseY = game.size.y - 100;
    
    path.moveTo(mountain.position.x, baseY);
    path.lineTo(mountain.position.x + 150, baseY - mountain.height);
    path.lineTo(mountain.position.x + 300, baseY);
    path.close();
    
    // Dağ gövdesi
    canvas.drawPath(path, Paint()..color = mountain.color);
    
    // Kar tepesi
    final snowPath = Path();
    final peakX = mountain.position.x + 150;
    final peakY = baseY - mountain.height;
    final snowHeight = mountain.height * 0.25;
    
    snowPath.moveTo(peakX, peakY);
    snowPath.lineTo(peakX - snowHeight * 0.8, peakY + snowHeight);
    snowPath.quadraticBezierTo(
      peakX - snowHeight * 0.4, peakY + snowHeight * 0.7,
      peakX, peakY + snowHeight * 0.5,
    );
    snowPath.quadraticBezierTo(
      peakX + snowHeight * 0.4, peakY + snowHeight * 0.7,
      peakX + snowHeight * 0.8, peakY + snowHeight,
    );
    snowPath.close();
    
    canvas.drawPath(snowPath, Paint()..color = Colors.white.withValues(alpha: 0.9));
  }

  void _drawGround(Canvas canvas) {
    final groundRect = Rect.fromLTWH(0, game.size.y - 100, game.size.x, 100);
    
    // Çimen üst katman
    final grassGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF4caf50),
        const Color(0xFF2e7d32),
        const Color(0xFF1b5e20),
      ],
    );
    
    canvas.drawRect(
      groundRect,
      Paint()..shader = grassGradient.createShader(groundRect),
    );
    
    // Çimen detayları
    final grassPaint = Paint()
      ..color = const Color(0xFF66bb6a)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    for (int i = 0; i < game.size.x / 8; i++) {
      final x = i * 8.0;
      final grassHeight = 8 + sin(x * 0.5 + time * 2) * 3;
      
      canvas.drawLine(
        Offset(x, game.size.y - 100),
        Offset(x - 2, game.size.y - 100 - grassHeight),
        grassPaint,
      );
    }
  }
}

class Cloud {
  Vector2 position;
  double size;
  double speed;
  
  Cloud({required this.position, required this.size, required this.speed});
}

class Mountain {
  Vector2 position;
  double height;
  Color color;
  double speed;
  
  Mountain({
    required this.position,
    required this.height,
    required this.color,
    required this.speed,
  });
}

class Star {
  Vector2 position;
  double size;
  double brightness;
  
  Star({required this.position, required this.size, required this.brightness});
}
