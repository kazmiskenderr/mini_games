import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Impact efektleri servisi
/// Dart saplandığında görsel efektler: glow, shake, bounce
class ImpactEffectController {
  late AnimationController glowController;
  late AnimationController shakeController;
  late AnimationController bounceController;
  
  late Animation<double> glowAnimation;
  late Animation<double> shakeAnimation;
  late Animation<double> bounceAnimation;
  
  static const Duration glowDuration = Duration(milliseconds: 300);
  static const Duration shakeDuration = Duration(milliseconds: 50);
  static const Duration bounceDuration = Duration(milliseconds: 200);
  static const double shakeAmount = 12.0; // 12px sağ-sol titreşim (güçlendirildi)
  
  void initialize(TickerProvider vsync) {
    // Glow efekti controller
    glowController = AnimationController(
      duration: glowDuration,
      vsync: vsync,
    );
    glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: glowController,
      curve: Curves.easeOut,
    ));
    
    // Shake efekti controller
    shakeController = AnimationController(
      duration: shakeDuration,
      vsync: vsync,
    );
    shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(shakeController);
    
    // Bounce efekti controller
    bounceController = AnimationController(
      duration: bounceDuration,
      vsync: vsync,
    );
    bounceAnimation = Tween<double>(
      begin: 1.05,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: bounceController,
      curve: Curves.elasticOut,
    ));
  }
  
  void dispose() {
    glowController.dispose();
    shakeController.dispose();
    bounceController.dispose();
  }
  
  /// Tüm impact efektlerini başlat
  Future<void> playImpact() async {
    // Paralel olarak tüm efektleri başlat
    glowController.forward(from: 0);
    
    // Shake efekti - 3 kez tekrarla
    for (int i = 0; i < 3; i++) {
      await shakeController.forward(from: 0);
      await shakeController.reverse();
    }
    
    bounceController.forward(from: 0);
  }
  
  /// Shake offset değeri (sağ-sol titreşim)
  double get shakeOffset {
    if (!shakeController.isAnimating) return 0;
    return math.sin(shakeAnimation.value * math.pi * 2) * shakeAmount;
  }
  
  /// Bounce scale değeri
  double get bounceScale => bounceAnimation.value;
  
  /// Glow opacity değeri
  double get glowOpacity => (1 - glowAnimation.value) * 0.8;
  
  /// Glow radius değeri
  double get glowRadius => glowAnimation.value * 30;
}

/// Dart glow widget'ı
class DartGlowEffect extends StatelessWidget {
  final Animation<double> animation;
  final Offset position;
  final double size;
  
  const DartGlowEffect({
    super.key,
    required this.animation,
    required this.position,
    this.size = 40,
  });
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        double progress = animation.value;
        double opacity = (1 - progress) * 0.8;
        double radius = progress * 30 + 10;
        
        return Positioned(
          left: position.dx - radius,
          top: position.dy - radius,
          child: Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(opacity),
                  Colors.yellow.withOpacity(opacity * 0.7),
                  Colors.orange.withOpacity(opacity * 0.3),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.3, 0.6, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Dart gölge widget'ı
class DartShadowEffect extends StatelessWidget {
  final Offset position;
  final double opacity;
  
  const DartShadowEffect({
    super.key,
    required this.position,
    this.opacity = 0.2,
  });
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx - 8,
      top: position.dy + 5,
      child: Container(
        width: 16,
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(opacity),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}
