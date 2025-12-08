import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart_throw_controller.dart';

/// Profesyonel dart çizici
/// Parabolik uçuş, açı rotasyonu, motion blur desteği
class ProDartPainter extends CustomPainter {
  final Color baseColor;
  final double angle;
  final double progress;
  final bool showMotionBlur;
  
  ProDartPainter({
    required this.baseColor,
    this.angle = 0,
    this.progress = 0,
    this.showMotionBlur = true,
  });
  
  Color _shift(Color color, double delta) {
    final hsl = HSLColor.fromColor(color);
    final l = (hsl.lightness + delta).clamp(0.0, 1.0);
    return hsl.withLightness(l).toColor();
  }
  
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final w = size.width;
    final h = size.height;
    
    // Canlı renkler
    final bright = _shift(baseColor, 0.40);
    final mid = _shift(baseColor, 0.15);
    final dark = _shift(baseColor, -0.30);
    
    // Motion blur efekti (hız çizgileri)
    if (showMotionBlur && progress > 0 && progress < 1) {
      final blurLength = h * 0.4 * progress;
      final blurPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            baseColor.withOpacity(0.3),
            baseColor.withOpacity(0.1),
          ],
        ).createShader(Rect.fromLTWH(cx - 3, cy + h * 0.3, 6, blurLength));
      
      canvas.drawRect(
        Rect.fromLTWH(cx - 3, cy + h * 0.3, 6, blurLength),
        blurPaint,
      );
    }
    
    // X KANATLAR - Profesyonel görünüm
    final wingLength = w * 0.42;
    final wingWidth = w * 0.12;
    
    // Kanat gölgeleri
    final wingShadow = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = wingWidth + 2
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    
    // Kanat ana renk
    final wingMain = Paint()
      ..color = dark
      ..style = PaintingStyle.stroke
      ..strokeWidth = wingWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    
    // Sol-üst → Sağ-alt
    canvas.drawLine(
      Offset(cx - wingLength, cy - wingLength * 0.8),
      Offset(cx + wingLength, cy + wingLength * 0.8),
      wingShadow,
    );
    canvas.drawLine(
      Offset(cx - wingLength, cy - wingLength * 0.8),
      Offset(cx + wingLength, cy + wingLength * 0.8),
      wingMain,
    );
    
    // Sağ-üst → Sol-alt
    canvas.drawLine(
      Offset(cx + wingLength, cy - wingLength * 0.8),
      Offset(cx - wingLength, cy + wingLength * 0.8),
      wingShadow,
    );
    canvas.drawLine(
      Offset(cx + wingLength, cy - wingLength * 0.8),
      Offset(cx - wingLength, cy + wingLength * 0.8),
      wingMain,
    );
    
    // Kanat highlight
    final wingHighlight = Paint()
      ..color = mid.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = wingWidth * 0.3
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    
    canvas.drawLine(
      Offset(cx - wingLength * 0.8, cy - wingLength * 0.65),
      Offset(cx + wingLength * 0.8, cy + wingLength * 0.65),
      wingHighlight,
    );
    canvas.drawLine(
      Offset(cx + wingLength * 0.8, cy - wingLength * 0.65),
      Offset(cx - wingLength * 0.8, cy + wingLength * 0.65),
      wingHighlight,
    );
    
    // GÖVDE - Ortada renkli halka
    final bodyRadius = w * 0.18;
    
    // Gölge
    canvas.drawCircle(
      Offset(cx + 1.5, cy + 1.5),
      bodyRadius + 2,
      Paint()
        ..color = Colors.black.withOpacity(0.5)
        ..isAntiAlias = true,
    );
    
    // Siyah çerçeve
    canvas.drawCircle(
      Offset(cx, cy),
      bodyRadius + 2,
      Paint()
        ..color = Colors.black
        ..isAntiAlias = true,
    );
    
    // Dış koyu halka
    canvas.drawCircle(
      Offset(cx, cy),
      bodyRadius,
      Paint()
        ..color = dark
        ..isAntiAlias = true,
    );
    
    // Orta ana renk halka
    canvas.drawCircle(
      Offset(cx, cy),
      bodyRadius * 0.72,
      Paint()
        ..color = baseColor
        ..isAntiAlias = true,
    );
    
    // Parlak iç halka
    canvas.drawCircle(
      Offset(cx, cy),
      bodyRadius * 0.45,
      Paint()
        ..color = bright
        ..isAntiAlias = true,
    );
    
    // Beyaz merkez (sivri uç simgesi)
    canvas.drawCircle(
      Offset(cx, cy),
      bodyRadius * 0.22,
      Paint()
        ..color = Colors.white
        ..isAntiAlias = true,
    );
    
    // Parlama efekti
    canvas.drawCircle(
      Offset(cx - bodyRadius * 0.25, cy - bodyRadius * 0.25),
      bodyRadius * 0.1,
      Paint()
        ..color = Colors.white.withOpacity(0.7)
        ..isAntiAlias = true,
    );
  }
  
  @override
  bool shouldRepaint(covariant ProDartPainter oldDelegate) {
    return oldDelegate.baseColor != baseColor ||
           oldDelegate.angle != angle ||
           oldDelegate.progress != progress ||
           oldDelegate.showMotionBlur != showMotionBlur;
  }
}

/// Profesyonel dart widget
class ProDartWidget extends StatelessWidget {
  final Color color;
  final double size;
  final double angle;
  final double progress;
  final double scale;
  final bool showMotionBlur;
  
  const ProDartWidget({
    super.key,
    required this.color,
    this.size = 80,
    this.angle = 0,
    this.progress = 0,
    this.scale = 1.0,
    this.showMotionBlur = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Transform.rotate(
        angle: angle + math.pi / 2, // Dikey hizala
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: ProDartPainter(
              baseColor: color,
              angle: angle,
              progress: progress,
              showMotionBlur: showMotionBlur,
            ),
          ),
        ),
      ),
    );
  }
}
