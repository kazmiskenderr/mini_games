import 'package:flutter/material.dart';
import 'dart:math' as math;

class LudoBoardRenderer extends CustomPainter {
  static const Color yellow = Color(0xFFF7D154);
  static const Color blue = Color(0xFF64D3E0);
  static const Color red = Color(0xFFF06A6A);
  static const Color green = Color(0xFF6BCF74);
  static const Color white = Colors.white;
  static const Color grid = Color(0xFF333333);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final cell = s / 15;

    _drawBackground(canvas, s);
    _drawHomeAreas(canvas, cell);
    _drawPaths(canvas, cell);
    _drawHomePaths(canvas, cell);
    _drawCenter(canvas, cell);
    _drawSafeStars(canvas, cell);
    _drawHomePawns(canvas, cell);
    _drawBorder(canvas, s);
  }

  void _drawBackground(Canvas canvas, double s) {
    canvas.drawRect(Rect.fromLTWH(0, 0, s, s), Paint()..color = white);
  }

  void _drawHomeAreas(Canvas canvas, double c) {
    final homeSize = c * 6;
    final radius = Radius.circular(c * 0.5);

    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, homeSize, homeSize), radius), Paint()..color = yellow);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(c * 9, 0, homeSize, homeSize), radius), Paint()..color = blue);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, c * 9, homeSize, homeSize), radius), Paint()..color = red);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(c * 9, c * 9, homeSize, homeSize), radius), Paint()..color = green);

    _drawInnerHome(canvas, c * 1.5, c * 1.5, c * 3, yellow);
    _drawInnerHome(canvas, c * 10.5, c * 1.5, c * 3, blue);
    _drawInnerHome(canvas, c * 1.5, c * 10.5, c * 3, red);
    _drawInnerHome(canvas, c * 10.5, c * 10.5, c * 3, green);
  }

  void _drawInnerHome(Canvas canvas, double x, double y, double size, Color color) {
    final radius = Radius.circular(size * 0.15);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x, y, size, size), radius),
      Paint()..color = color.withOpacity(0.95),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x, y, size, size), radius),
      Paint()
        ..color = white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8,
    );
  }

  void _drawPaths(Canvas canvas, double c) {
    final gridPaint = Paint()
      ..color = grid
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6;

    for (int row = 6; row <= 8; row++) {
      for (int col = 0; col <= 5; col++) {
        _drawCell(canvas, col * c, row * c, c, white, gridPaint);
      }
      for (int col = 9; col <= 14; col++) {
        _drawCell(canvas, col * c, row * c, c, white, gridPaint);
      }
    }

    for (int col = 6; col <= 8; col++) {
      for (int row = 0; row <= 5; row++) {
        _drawCell(canvas, col * c, row * c, c, white, gridPaint);
      }
      for (int row = 9; row <= 14; row++) {
        _drawCell(canvas, col * c, row * c, c, white, gridPaint);
      }
    }
  }

  void _drawCell(Canvas canvas, double x, double y, double c, Color fill, Paint border) {
    canvas.drawRect(Rect.fromLTWH(x, y, c, c), Paint()..color = fill);
    canvas.drawRect(Rect.fromLTWH(x, y, c, c), border);
  }

  void _drawHomePaths(Canvas canvas, double c) {
    final gridPaint = Paint()
      ..color = grid
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6;

    // Sarı ev yolu - soldan merkeze doğru (satır 7, sütun 1-5)
    for (int i = 1; i <= 5; i++) {
      _drawCell(canvas, c * i, c * 7, c, yellow, gridPaint);
    }

    // Mavi ev yolu - üstten merkeze doğru (sütun 7, satır 1-5)
    for (int i = 1; i <= 5; i++) {
      _drawCell(canvas, c * 7, c * i, c, blue, gridPaint);
    }

    // Yeşil ev yolu - sağdan merkeze doğru (satır 7, sütun 9-13)
    for (int i = 1; i <= 5; i++) {
      _drawCell(canvas, c * (8 + i), c * 7, c, green, gridPaint);
    }

    // Kırmızı ev yolu - alttan merkeze doğru (sütun 7, satır 9-13)
    for (int i = 1; i <= 5; i++) {
      _drawCell(canvas, c * 7, c * (8 + i), c, red, gridPaint);
    }

    // Başlangıç kareleri (yıldızlı kareler)
    _drawCell(canvas, c * 1, c * 6, c, yellow, gridPaint);  // Sarı başlangıç
    _drawCell(canvas, c * 8, c * 1, c, blue, gridPaint);    // Mavi başlangıç
    _drawCell(canvas, c * 13, c * 8, c, green, gridPaint);  // Yeşil başlangıç
    _drawCell(canvas, c * 6, c * 13, c, red, gridPaint);    // Kırmızı başlangıç
  }

  void _drawCenter(Canvas canvas, double c) {
    final cx = c * 7.5;
    final cy = c * 7.5;

    // Mavi - üst (yukarı bakan üçgen)
    canvas.drawPath(
      Path()
        ..moveTo(cx, cy)
        ..lineTo(c * 6, c * 6)
        ..lineTo(c * 9, c * 6)
        ..close(),
      Paint()..color = blue,
    );

    // Yeşil - sağ (sağa bakan üçgen)
    canvas.drawPath(
      Path()
        ..moveTo(cx, cy)
        ..lineTo(c * 9, c * 6)
        ..lineTo(c * 9, c * 9)
        ..close(),
      Paint()..color = green,
    );

    // Kırmızı - alt (aşağı bakan üçgen)
    canvas.drawPath(
      Path()
        ..moveTo(cx, cy)
        ..lineTo(c * 9, c * 9)
        ..lineTo(c * 6, c * 9)
        ..close(),
      Paint()..color = red,
    );

    // Sarı - sol (sola bakan üçgen)
    canvas.drawPath(
      Path()
        ..moveTo(cx, cy)
        ..lineTo(c * 6, c * 9)
        ..lineTo(c * 6, c * 6)
        ..close(),
      Paint()..color = yellow,
    );
  }

  void _drawSafeStars(Canvas canvas, double c) {
    // Sadece 4 güvenli kare (başlangıç noktaları)
    final positions = [
      Offset(c * 1.5, c * 6.5),   // Sarı başlangıç
      Offset(c * 8.5, c * 1.5),   // Mavi başlangıç
      Offset(c * 13.5, c * 8.5),  // Yeşil başlangıç
      Offset(c * 6.5, c * 13.5),  // Kırmızı başlangıç
    ];

    for (final pos in positions) {
      _drawStar(canvas, pos, c * 0.25);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size) {
    final points = <Offset>[];
    for (int i = 0; i < 10; i++) {
      final angle = (i * math.pi) / 5 - math.pi / 2;
      final r = i.isEven ? size : size * 0.45;
      points.add(Offset(center.dx + r * math.cos(angle), center.dy + r * math.sin(angle)));
    }
    canvas.drawPath(Path()..addPolygon(points, true), Paint()..color = const Color(0xFFFFB800));
    // add thin dark stroke to star for clarity
    canvas.drawPath(
      Path()..addPolygon(points, true),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.black.withOpacity(0.55)
        ..strokeWidth = 1.4,
    );
  }

  void _drawHomePawns(Canvas canvas, double c) {
    _drawPawn(canvas, c * 2.25, c * 2.25, c * 0.7, yellow);
    _drawPawn(canvas, c * 2.25, c * 3.75, c * 0.7, yellow);
    _drawPawn(canvas, c * 3.75, c * 2.25, c * 0.7, yellow);
    _drawPawn(canvas, c * 3.75, c * 3.75, c * 0.7, yellow);

    _drawPawn(canvas, c * 11.25, c * 2.25, c * 0.7, blue);
    _drawPawn(canvas, c * 11.25, c * 3.75, c * 0.7, blue);
    _drawPawn(canvas, c * 12.75, c * 2.25, c * 0.7, blue);
    _drawPawn(canvas, c * 12.75, c * 3.75, c * 0.7, blue);

    _drawPawn(canvas, c * 2.25, c * 11.25, c * 0.7, red);
    _drawPawn(canvas, c * 2.25, c * 12.75, c * 0.7, red);
    _drawPawn(canvas, c * 3.75, c * 11.25, c * 0.7, red);
    _drawPawn(canvas, c * 3.75, c * 12.75, c * 0.7, red);

    _drawPawn(canvas, c * 11.25, c * 11.25, c * 0.7, green);
    _drawPawn(canvas, c * 11.25, c * 12.75, c * 0.7, green);
    _drawPawn(canvas, c * 12.75, c * 11.25, c * 0.7, green);
    _drawPawn(canvas, c * 12.75, c * 12.75, c * 0.7, green);
  }

  void _drawPawn(Canvas canvas, double x, double y, double size, Color color) {
    final darkColor = Color.lerp(color, Colors.black, 0.45)!;
    final darkerColor = Color.lerp(color, Colors.black, 0.6)!;
    final lightColor = Color.lerp(color, Colors.white, 0.35)!;
    final lighterColor = Color.lerp(color, Colors.white, 0.6)!;
    
    // === GÖLGE === (daha dolgun, daha az transparan)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x + size * 0.18, y + size * 0.45),
        width: size * 0.9,
        height: size * 0.36,
      ),
      Paint()
        ..color = Colors.black.withOpacity(0.68)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0),
    );

    // === ANA GÖVDE (büyük küre) ===
    final bodyRadius = size * 0.52;
    final bodyY = y + size * 0.1;

    // Gövde base
    canvas.drawCircle(Offset(x, bodyY), bodyRadius, Paint()..color = darkerColor);

    // Gövde 3D gradient (daha kontrastlı)
    final bodyGradient = RadialGradient(
      center: const Alignment(-0.5, -0.6),
      radius: 0.95,
      colors: [lighterColor, lightColor, color, darkColor, darkerColor],
      stops: const [0.0, 0.12, 0.36, 0.78, 1.0],
    );
    canvas.drawCircle(
      Offset(x, bodyY),
      bodyRadius,
      Paint()..shader = bodyGradient.createShader(
        Rect.fromCircle(center: Offset(x, bodyY), radius: bodyRadius),
      ),
    );

    // Gövde kontur (daha belirgin)
    canvas.drawCircle(
      Offset(x, bodyY),
      bodyRadius,
      Paint()
        ..color = darkerColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2,
    );

    // === KAFA (küçük küre - gövdenin üstünde) ===
    final headRadius = size * 0.35;
    final headY = y - size * 0.28;

    // Kafa base
    canvas.drawCircle(Offset(x, headY), headRadius, Paint()..color = darkerColor);

    // Kafa 3D gradient
    final headGradient = RadialGradient(
      center: const Alignment(-0.5, -0.5),
      radius: 0.95,
      colors: [lighterColor, lightColor, color, darkColor, darkerColor],
      stops: const [0.0, 0.14, 0.38, 0.82, 1.0],
    );
    canvas.drawCircle(
      Offset(x, headY),
      headRadius,
      Paint()..shader = headGradient.createShader(
        Rect.fromCircle(center: Offset(x, headY), radius: headRadius),
      ),
    );

    // Kafa kontur (daha belirgin)
    canvas.drawCircle(
      Offset(x, headY),
      headRadius,
      Paint()
        ..color = darkerColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8,
    );

    // === PARLAMA EFEKTLERİ === (daha net)

    // Kafa parlama (büyük)
    final headHighlight = RadialGradient(
      colors: [Colors.white.withOpacity(0.95), Colors.white.withOpacity(0.0)],
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x - headRadius * 0.35, headY - headRadius * 0.35),
        width: headRadius * 0.7,
        height: headRadius * 0.45,
      ),
      Paint()..shader = headHighlight.createShader(
        Rect.fromCenter(
          center: Offset(x - headRadius * 0.35, headY - headRadius * 0.35),
          width: headRadius * 0.7,
          height: headRadius * 0.45,
        ),
      ),
    );

    // Gövde parlama (büyük)
    final bodyHighlight = RadialGradient(
      colors: [Colors.white.withOpacity(0.85), Colors.white.withOpacity(0.0)],
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x - bodyRadius * 0.4, bodyY - bodyRadius * 0.4),
        width: bodyRadius * 0.7,
        height: bodyRadius * 0.45,
      ),
      Paint()..shader = bodyHighlight.createShader(
        Rect.fromCenter(
          center: Offset(x - bodyRadius * 0.4, bodyY - bodyRadius * 0.4),
          width: bodyRadius * 0.7,
          height: bodyRadius * 0.45,
        ),
      ),
    );
  }

  void _drawBorder(Canvas canvas, double s) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, s, s),
      Paint()
        ..color = grid
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.4,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
