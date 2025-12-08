import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Profesyonel Uçan Dart Painter
/// Motion blur, 3D rotasyon, perspektif
class ProFlyingDartPainter extends CustomPainter {
  final double progress; // 0-1 uçuş ilerlemesi
  final double rotation; // Dart açısı (radyan)
  final double scale; // Perspektif scale
  final double speed; // Motion blur için hız
  final Color baseColor;
  
  // Motion blur ghost sayısı
  final int ghostCount;
  
  ProFlyingDartPainter({
    required this.progress,
    required this.rotation,
    required this.scale,
    required this.speed,
    required this.baseColor,
    this.ghostCount = 5,
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
    
    canvas.save();
    canvas.translate(cx, cy);
    
    // Rotasyon uygula - dart ucu hareket yönüne bakar
    canvas.rotate(rotation + math.pi / 2);
    
    // Scale uygula
    canvas.scale(scale);
    
    canvas.translate(-cx, -cy);
    
    // Motion blur ghostlar (en arkada)
    if (speed > 0.3) {
      _drawMotionBlur(canvas, size);
    }
    
    // Ana dart
    _drawDart(canvas, size, 1.0);
    
    canvas.restore();
  }
  
  void _drawMotionBlur(Canvas canvas, Size size) {
    int blurCount = (ghostCount * speed).round().clamp(1, ghostCount);
    
    for (int i = blurCount; i > 0; i--) {
      double opacity = (1 - i / ghostCount) * 0.25;
      double offset = i * 8.0 * speed;
      
      canvas.save();
      canvas.translate(0, offset);
      _drawDart(canvas, size, opacity);
      canvas.restore();
    }
  }
  
  void _drawDart(Canvas canvas, Size size, double opacity) {
    final cx = size.width / 2;
    final h = size.height;
    final w = size.width;
    
    final bright = _shift(baseColor, 0.3);
    final dark = _shift(baseColor, -0.3);
    
    // === PROFESYONEL DART TASARIMI ===
    
    // 1. SİVRİ METAL UÇ
    final tipPath = Path()
      ..moveTo(cx, 0)
      ..lineTo(cx - w * 0.06, h * 0.12)
      ..lineTo(cx + w * 0.06, h * 0.12)
      ..close();
    
    canvas.drawPath(
      tipPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey.shade300.withOpacity(opacity),
            Colors.grey.shade600.withOpacity(opacity),
          ],
        ).createShader(Rect.fromLTWH(cx - w * 0.06, 0, w * 0.12, h * 0.12)),
    );
    
    // Uç parlaması
    canvas.drawLine(
      Offset(cx - w * 0.02, h * 0.02),
      Offset(cx - w * 0.02, h * 0.08),
      Paint()
        ..color = Colors.white.withOpacity(opacity * 0.7)
        ..strokeWidth = 1.5,
    );
    
    // 2. BARREL (Metal gövde)
    final barrelRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - w * 0.11, h * 0.12, w * 0.22, h * 0.22),
      const Radius.circular(4),
    );
    
    // Barrel gölge
    canvas.drawRRect(
      barrelRect.shift(const Offset(2, 2)),
      Paint()..color = Colors.black.withOpacity(opacity * 0.3),
    );
    
    // Barrel ana
    canvas.drawRRect(
      barrelRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.grey.shade600.withOpacity(opacity),
            Colors.grey.shade400.withOpacity(opacity),
            Colors.grey.shade300.withOpacity(opacity),
            Colors.grey.shade400.withOpacity(opacity),
            Colors.grey.shade600.withOpacity(opacity),
          ],
          stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
        ).createShader(Rect.fromLTWH(cx - w * 0.11, h * 0.12, w * 0.22, h * 0.22)),
    );
    
    // Barrel grip çizgileri
    for (int i = 0; i < 5; i++) {
      final y = h * 0.14 + i * h * 0.038;
      canvas.drawLine(
        Offset(cx - w * 0.09, y),
        Offset(cx + w * 0.09, y),
        Paint()
          ..color = Colors.black.withOpacity(opacity * 0.2)
          ..strokeWidth = 1,
      );
    }
    
    // 3. SHAFT (Renkli sap)
    final shaftRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - w * 0.07, h * 0.34, w * 0.14, h * 0.25),
      const Radius.circular(2),
    );
    
    canvas.drawRRect(
      shaftRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            dark.withOpacity(opacity),
            baseColor.withOpacity(opacity),
            bright.withOpacity(opacity),
            baseColor.withOpacity(opacity),
            dark.withOpacity(opacity),
          ],
        ).createShader(Rect.fromLTWH(cx - w * 0.07, h * 0.34, w * 0.14, h * 0.25)),
    );
    
    // Shaft kenar
    canvas.drawRRect(
      shaftRect,
      Paint()
        ..color = dark.withOpacity(opacity * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );
    
    // 4. FLIGHT (Kanatlar - X şekli)
    _drawFlights(canvas, size, opacity, cx, h, w, bright, dark);
    
    // 5. PARLAMA EFEKTİ
    canvas.drawLine(
      Offset(cx - w * 0.08, h * 0.15),
      Offset(cx - w * 0.08, h * 0.30),
      Paint()
        ..color = Colors.white.withOpacity(opacity * 0.4)
        ..strokeWidth = 2,
    );
  }
  
  void _drawFlights(Canvas canvas, Size size, double opacity, 
                    double cx, double h, double w, Color bright, Color dark) {
    final flightTop = h * 0.58;
    final flightBottom = h * 0.95;
    final flightSpread = w * 0.42;
    
    // Sol kanat
    final leftWing = Path()
      ..moveTo(cx - w * 0.05, flightTop)
      ..lineTo(cx - flightSpread, flightBottom * 0.85)
      ..quadraticBezierTo(
        cx - flightSpread * 0.8, flightBottom,
        cx - w * 0.03, flightBottom * 0.9,
      )
      ..close();
    
    // Sol kanat gölge
    canvas.drawPath(
      leftWing.shift(const Offset(2, 2)),
      Paint()..color = Colors.black.withOpacity(opacity * 0.3),
    );
    
    canvas.drawPath(
      leftWing,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            baseColor.withOpacity(opacity),
            bright.withOpacity(opacity),
            baseColor.withOpacity(opacity * 0.9),
          ],
        ).createShader(Rect.fromLTWH(cx - flightSpread, flightTop, flightSpread, flightBottom - flightTop)),
    );
    
    canvas.drawPath(
      leftWing,
      Paint()
        ..color = dark.withOpacity(opacity * 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    
    // Sağ kanat
    final rightWing = Path()
      ..moveTo(cx + w * 0.05, flightTop)
      ..lineTo(cx + flightSpread, flightBottom * 0.85)
      ..quadraticBezierTo(
        cx + flightSpread * 0.8, flightBottom,
        cx + w * 0.03, flightBottom * 0.9,
      )
      ..close();
    
    // Sağ kanat gölge
    canvas.drawPath(
      rightWing.shift(const Offset(2, 2)),
      Paint()..color = Colors.black.withOpacity(opacity * 0.3),
    );
    
    canvas.drawPath(
      rightWing,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            baseColor.withOpacity(opacity),
            bright.withOpacity(opacity),
            baseColor.withOpacity(opacity * 0.9),
          ],
        ).createShader(Rect.fromLTWH(cx, flightTop, flightSpread, flightBottom - flightTop)),
    );
    
    canvas.drawPath(
      rightWing,
      Paint()
        ..color = dark.withOpacity(opacity * 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    
    // Kanat orta çizgileri (parlama)
    canvas.drawLine(
      Offset(cx - flightSpread * 0.5, flightTop + (flightBottom - flightTop) * 0.2),
      Offset(cx - flightSpread * 0.3, flightBottom * 0.85),
      Paint()
        ..color = bright.withOpacity(opacity * 0.4)
        ..strokeWidth = 1,
    );
    canvas.drawLine(
      Offset(cx + flightSpread * 0.5, flightTop + (flightBottom - flightTop) * 0.2),
      Offset(cx + flightSpread * 0.3, flightBottom * 0.85),
      Paint()
        ..color = bright.withOpacity(opacity * 0.4)
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant ProFlyingDartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.rotation != rotation ||
           oldDelegate.scale != scale ||
           oldDelegate.speed != speed ||
           oldDelegate.baseColor != baseColor;
  }
}

/// Profesyonel Saplanmış Dart Painter
/// Eğik görünüm, gölge, penetrasyon efekti
class ProStuckDartPainter extends CustomPainter {
  final Color baseColor;
  final double penetrationDepth; // 3-5px
  final double boardAngle; // Tahta normali
  
  ProStuckDartPainter({
    required this.baseColor,
    this.penetrationDepth = 4,
    this.boardAngle = 0,
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

    final bright = _shift(baseColor, 0.3);
    final dark = _shift(baseColor, -0.3);

    // === PROFESYONEL SAPLI DART - EĞİK GÖRÜNÜM ===
    
    canvas.save();
    canvas.translate(cx, cy);
    // Hafif eğik saplanmış görünüm
    canvas.rotate(-math.pi / 10);
    canvas.translate(-cx, -cy);
    
    // 1. GÖLGE
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + 4, cy + h * 0.38),
        width: w * 0.3,
        height: w * 0.1,
      ),
      Paint()
        ..color = Colors.black38
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    
    // 2. PENETRASYON NOKTASI (tahtaya gömülü uç)
    final tipEndY = cy + h * 0.28 + penetrationDepth;
    final tipPath = Path()
      ..moveTo(cx, tipEndY)
      ..lineTo(cx - w * 0.05, cy + h * 0.15)
      ..lineTo(cx + w * 0.05, cy + h * 0.15)
      ..close();
    
    canvas.drawPath(
      tipPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.grey.shade500, Colors.grey.shade700],
        ).createShader(Rect.fromLTWH(cx - w * 0.05, cy + h * 0.15, w * 0.1, h * 0.15)),
    );
    
    // 3. BARREL
    final barrelRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - w * 0.12, cy - h * 0.05, w * 0.24, h * 0.22),
      const Radius.circular(4),
    );
    
    canvas.drawRRect(
      barrelRect.shift(const Offset(2, 2)),
      Paint()..color = Colors.black38,
    );
    
    canvas.drawRRect(
      barrelRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.grey.shade600,
            Colors.grey.shade400,
            Colors.grey.shade300,
            Colors.grey.shade400,
            Colors.grey.shade600,
          ],
          stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
        ).createShader(Rect.fromLTWH(cx - w * 0.12, cy - h * 0.05, w * 0.24, h * 0.22)),
    );
    
    // Grip çizgileri
    for (int i = 0; i < 5; i++) {
      final y = cy - h * 0.03 + i * h * 0.038;
      canvas.drawLine(
        Offset(cx - w * 0.10, y),
        Offset(cx + w * 0.10, y),
        Paint()
          ..color = Colors.black26
          ..strokeWidth = 1,
      );
    }
    
    // 4. SHAFT
    final shaftRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - w * 0.07, cy - h * 0.28, w * 0.14, h * 0.25),
      const Radius.circular(2),
    );
    
    canvas.drawRRect(
      shaftRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [dark, baseColor, bright, baseColor, dark],
        ).createShader(Rect.fromLTWH(cx - w * 0.07, cy - h * 0.28, w * 0.14, h * 0.25)),
    );
    
    canvas.drawRRect(
      shaftRect,
      Paint()
        ..color = dark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );
    
    // 5. FLIGHT (Kanatlar)
    final flightTop = cy - h * 0.45;
    final flightBottom = cy - h * 0.26;
    final flightSpread = w * 0.38;
    
    // Sol kanat
    final leftWing = Path()
      ..moveTo(cx - w * 0.04, flightBottom)
      ..lineTo(cx - flightSpread, flightTop)
      ..quadraticBezierTo(
        cx - flightSpread * 0.7, flightTop - h * 0.03,
        cx, flightBottom + h * 0.02,
      )
      ..close();
    
    canvas.drawPath(
      leftWing,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [baseColor, bright, baseColor.withOpacity(0.9)],
        ).createShader(Rect.fromLTWH(cx - flightSpread, flightTop, flightSpread, flightBottom - flightTop)),
    );
    canvas.drawPath(leftWing, Paint()..color = dark..style = PaintingStyle.stroke..strokeWidth = 1);
    
    // Sağ kanat
    final rightWing = Path()
      ..moveTo(cx + w * 0.04, flightBottom)
      ..lineTo(cx + flightSpread, flightTop)
      ..quadraticBezierTo(
        cx + flightSpread * 0.7, flightTop - h * 0.03,
        cx, flightBottom + h * 0.02,
      )
      ..close();
    
    canvas.drawPath(
      rightWing,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [baseColor, bright, baseColor.withOpacity(0.9)],
        ).createShader(Rect.fromLTWH(cx, flightTop, flightSpread, flightBottom - flightTop)),
    );
    canvas.drawPath(rightWing, Paint()..color = dark..style = PaintingStyle.stroke..strokeWidth = 1);
    
    // 6. PARLAMA
    canvas.drawLine(
      Offset(cx - w * 0.09, cy - h * 0.02),
      Offset(cx - w * 0.09, cy + h * 0.12),
      Paint()
        ..color = Colors.white.withOpacity(0.4)
        ..strokeWidth = 2,
    );
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ProStuckDartPainter oldDelegate) {
    return oldDelegate.baseColor != baseColor ||
           oldDelegate.penetrationDepth != penetrationDepth ||
           oldDelegate.boardAngle != boardAngle;
  }
}
