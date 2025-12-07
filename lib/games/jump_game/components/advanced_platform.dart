import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../pro_jump_game.dart';

class AdvancedPlatform extends PositionComponent with HasGameReference<JumpGame> {
  static const double platformHeight = 100.0;
  
  @override
  final double width;
  
  double time = 0;
  final List<GrassDetail> grassDetails = [];
  final List<FlowerDetail> flowers = [];

  AdvancedPlatform({
    required Vector2 position,
    required this.width,
  }) : super(
    position: position,
    size: Vector2(width, platformHeight),
  ) {
    // Rastgele çimen detayları
    final random = Random();
    for (int i = 0; i < width / 12; i++) {
      grassDetails.add(GrassDetail(
        x: i * 12.0 + random.nextDouble() * 6,
        height: 8 + random.nextDouble() * 8,
        phase: random.nextDouble() * pi * 2,
      ));
    }
    
    // Rastgele çiçekler
    for (int i = 0; i < width / 100; i++) {
      flowers.add(FlowerDetail(
        x: random.nextDouble() * width,
        color: [
          Colors.red,
          Colors.yellow,
          Colors.pink,
          Colors.white,
        ][random.nextInt(4)],
        size: 6 + random.nextDouble() * 4,
      ));
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox(
      size: Vector2(width, 20),
      position: Vector2(0, 0),
    ));
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    time += dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Toprak katmanları
    _drawSoilLayers(canvas);
    
    // Çimen üst yüzey
    _drawGrassSurface(canvas);
    
    // Çimen detayları
    _drawGrassDetails(canvas);
    
    // Çiçekler
    _drawFlowers(canvas);
  }
  
  void _drawSoilLayers(Canvas canvas) {
    // Ana toprak
    final soilRect = Rect.fromLTWH(0, 25, size.x, size.y - 25);
    final soilGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF8B4513),
        const Color(0xFF654321),
        const Color(0xFF4a3728),
      ],
    );
    
    canvas.drawRect(
      soilRect,
      Paint()..shader = soilGradient.createShader(soilRect),
    );
    
    // Taş ve kök detayları
    final detailPaint = Paint()..color = const Color(0xFF3d2817);
    for (int i = 0; i < size.x / 40; i++) {
      final x = i * 40.0 + 10;
      final y = 40.0 + sin(i * 1.5) * 15;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 12, height: 8),
        detailPaint,
      );
    }
    
    // Kökler
    final rootPaint = Paint()
      ..color = const Color(0xFF5d4037)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    for (int i = 0; i < size.x / 80; i++) {
      final startX = i * 80.0 + 30;
      final path = Path()
        ..moveTo(startX, 25)
        ..quadraticBezierTo(
          startX + 15, 45,
          startX + 5, 65,
        );
      canvas.drawPath(path, rootPaint);
    }
  }
  
  void _drawGrassSurface(Canvas canvas) {
    // Çimen üst yüzey
    final grassRect = Rect.fromLTWH(0, 0, size.x, 28);
    final grassGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF66BB6A),
        const Color(0xFF43A047),
        const Color(0xFF2E7D32),
      ],
    );
    
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        grassRect,
        topLeft: const Radius.circular(8),
        topRight: const Radius.circular(8),
      ),
      Paint()..shader = grassGradient.createShader(grassRect),
    );
    
    // Çimen üst doku
    final texturePaint = Paint()..color = const Color(0xFF81C784).withValues(alpha: 0.5);
    for (int i = 0; i < size.x / 8; i++) {
      final x = i * 8.0;
      canvas.drawRect(
        Rect.fromLTWH(x, 2, 4, 3),
        texturePaint,
      );
    }
  }
  
  void _drawGrassDetails(Canvas canvas) {
    for (var grass in grassDetails) {
      final sway = sin(time * 2 + grass.phase) * 3;
      
      final grassPaint = Paint()
        ..color = Color.lerp(
          const Color(0xFF4CAF50),
          const Color(0xFF8BC34A),
          (grass.height - 8) / 8,
        )!
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      
      final path = Path()
        ..moveTo(grass.x, 0)
        ..quadraticBezierTo(
          grass.x + sway,
          -grass.height / 2,
          grass.x + sway * 1.5,
          -grass.height,
        );
      
      canvas.drawPath(path, grassPaint);
    }
  }
  
  void _drawFlowers(Canvas canvas) {
    for (var flower in flowers) {
      final sway = sin(time * 1.5 + flower.x) * 2;
      
      // Sap
      canvas.drawLine(
        Offset(flower.x, 0),
        Offset(flower.x + sway, -15),
        Paint()
          ..color = const Color(0xFF388E3C)
          ..strokeWidth = 2,
      );
      
      // Yapraklar
      final petalCount = 5;
      for (int i = 0; i < petalCount; i++) {
        final angle = (i / petalCount) * pi * 2 + time * 0.5;
        final petalPath = Path();
        final center = Offset(flower.x + sway, -15);
        
        petalPath.moveTo(center.dx, center.dy);
        petalPath.quadraticBezierTo(
          center.dx + cos(angle) * flower.size * 1.2,
          center.dy + sin(angle) * flower.size * 1.2,
          center.dx + cos(angle) * flower.size,
          center.dy + sin(angle) * flower.size,
        );
        
        canvas.drawCircle(
          Offset(
            center.dx + cos(angle) * flower.size * 0.7,
            center.dy + sin(angle) * flower.size * 0.7,
          ),
          flower.size * 0.4,
          Paint()..color = flower.color,
        );
      }
      
      // Merkez
      canvas.drawCircle(
        Offset(flower.x + sway, -15),
        flower.size * 0.3,
        Paint()..color = Colors.yellow.shade700,
      );
    }
  }
}

class GrassDetail {
  final double x;
  final double height;
  final double phase;
  
  GrassDetail({required this.x, required this.height, required this.phase});
}

class FlowerDetail {
  final double x;
  final Color color;
  final double size;
  
  FlowerDetail({required this.x, required this.color, required this.size});
}
