import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Yıldız partikülleri servisi
/// Impact anında 6 adet yıldız partikülü rastgele yönde dağılır
class StarParticlesController {
  late AnimationController controller;
  late Animation<double> animation;
  
  static const Duration duration = Duration(milliseconds: 350);
  static const int particleCount = 6;
  
  List<StarParticle> particles = [];
  final math.Random _random = math.Random();
  
  void initialize(TickerProvider vsync) {
    controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    
    animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
    );
  }
  
  void dispose() {
    controller.dispose();
  }
  
  /// Partikülleri oluştur ve animasyonu başlat
  Future<void> emit(Offset center) async {
    particles = List.generate(particleCount, (i) {
      double angle = (i / particleCount) * 2 * math.pi + _random.nextDouble() * 0.5;
      double distance = 60 + _random.nextDouble() * 80;
      double size = 12 + _random.nextDouble() * 12;
      double rotationSpeed = (_random.nextDouble() - 0.5) * 6;
      
      Color color = [
        Colors.amber,
        Colors.yellow,
        Colors.orange,
        Colors.white,
        const Color(0xFFFFD700), // Gold
        const Color(0xFFFFA500), // Orange
      ][i % 6];
      
      return StarParticle(
        startPosition: center,
        angle: angle,
        distance: distance,
        size: size,
        color: color,
        rotationSpeed: rotationSpeed,
      );
    });
    
    controller.forward(from: 0);
  }
  
  /// Partikülleri çiz
  Widget buildParticles() {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        if (particles.isEmpty) return const SizedBox.shrink();
        
        double t = animation.value;
        double opacity = 1 - (t * 0.9);
        
        return Stack(
          children: particles.map((particle) {
            double x = particle.startPosition.dx + 
                math.cos(particle.angle) * particle.distance * t;
            double y = particle.startPosition.dy + 
                math.sin(particle.angle) * particle.distance * t - 
                20 * t; // Yukarı doğru hareket
            double scale = 1 + t * 0.3;
            double rotation = particle.rotationSpeed * t * math.pi;
            
            return Positioned(
              left: x - particle.size / 2,
              top: y - particle.size / 2,
              child: Transform.rotate(
                angle: rotation,
                child: Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity.clamp(0.0, 1.0),
                    child: _buildStar(particle),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
  
  Widget _buildStar(StarParticle particle) {
    return CustomPaint(
      size: Size(particle.size, particle.size),
      painter: StarPainter(color: particle.color),
    );
  }
}

/// Tek bir yıldız partikülü
class StarParticle {
  final Offset startPosition;
  final double angle;
  final double distance;
  final double size;
  final Color color;
  final double rotationSpeed;
  
  StarParticle({
    required this.startPosition,
    required this.angle,
    required this.distance,
    required this.size,
    required this.color,
    required this.rotationSpeed,
  });
}

/// Yıldız şekli çizici
class StarPainter extends CustomPainter {
  final Color color;
  
  StarPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final shadowPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.4;
    
    final path = _createStarPath(center, outerRadius, innerRadius, 5);
    
    // Glow efekti
    canvas.drawPath(path, shadowPaint);
    // Yıldız
    canvas.drawPath(path, paint);
  }
  
  Path _createStarPath(Offset center, double outerRadius, double innerRadius, int points) {
    final path = Path();
    final angle = math.pi / points;
    
    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final x = center.dx + radius * math.cos(i * angle - math.pi / 2);
      final y = center.dy + radius * math.sin(i * angle - math.pi / 2);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.close();
    return path;
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
