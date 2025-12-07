import 'package:flutter/material.dart';
import 'dart:math' as math;

/// İsabet metin animasyonu servisi
/// TRIPLE!, DOUBLE!, BULL! vb. metinler için profesyonel animasyon
class HitTextController {
  late AnimationController controller;
  late Animation<double> scaleAnimation;
  late Animation<double> opacityAnimation;
  
  static const Duration duration = Duration(milliseconds: 600);
  
  String? currentText;
  Color currentColor = Colors.white;
  
  void initialize(TickerProvider vsync) {
    controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    
    // Scale: 0.6 → 1.2 (250ms), sonra 1.2 kalır
    scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.6, end: 1.2)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.15),
        weight: 40,
      ),
    ]).animate(controller);
    
    // Opacity: Başta 0 → 1, sonra 1 → 0 fade out
    opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
    ]).animate(controller);
  }
  
  void dispose() {
    controller.dispose();
  }
  
  /// Metin animasyonunu göster
  Future<void> show(String text, HitType type) async {
    currentText = text;
    currentColor = _getColorForType(type);
    
    controller.forward(from: 0);
    await controller.forward();
    currentText = null;
  }
  
  Color _getColorForType(HitType type) {
    switch (type) {
      case HitType.triple:
        return const Color(0xFF00A2FF); // Mavi
      case HitType.double:
        return const Color(0xFF9B59B6); // Mor
      case HitType.bull:
        return const Color(0xFFE8504E); // Kırmızı
      case HitType.bullseye:
        return const Color(0xFFFFD700); // Altın
      case HitType.normal:
        return Colors.white;
    }
  }
  
  /// Metin widget'ı oluştur
  Widget buildText() {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (currentText == null) return const SizedBox.shrink();
        
        return Transform.scale(
          scale: scaleAnimation.value,
          child: Opacity(
            opacity: opacityAnimation.value.clamp(0.0, 1.0),
            child: Text(
              currentText!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: currentColor,
                letterSpacing: 4,
                shadows: [
                  // Drop shadow
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(3, 3),
                  ),
                  // Glow
                  Shadow(
                    color: currentColor.withOpacity(0.8),
                    blurRadius: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// İsabet tipi
enum HitType {
  triple,
  double,
  bull,
  bullseye,
  normal,
}

/// Outlined text widget - stroke efekti için
class OutlinedText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;
  
  const OutlinedText({
    super.key,
    required this.text,
    this.fontSize = 48,
    required this.fillColor,
    this.strokeColor = Colors.black,
    this.strokeWidth = 3,
  });
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Stroke
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = strokeColor,
          ),
        ),
        // Fill
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            color: fillColor,
            shadows: [
              Shadow(
                color: fillColor.withOpacity(0.8),
                blurRadius: 15,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
