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
      Paint()..color = color.withValues(alpha: 0.4),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x, y, size, size), radius),
      Paint()
        ..color = white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawPaths(Canvas canvas, double c) {
    final gridPaint = Paint()
      ..color = grid
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

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
      ..strokeWidth = 1;

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
    final darkColor = Color.lerp(color, Colors.black, 0.3)!;
    
    // Gölge
    final shadowPath = Path()
      ..moveTo(x - size * 0.5 + 2, y + size * 0.6 + 2)
      ..lineTo(x + size * 0.5 + 2, y + size * 0.6 + 2)
      ..quadraticBezierTo(x + size * 0.3 + 2, y + size * 0.3 + 2, x + size * 0.25 + 2, y + 2)
      ..quadraticBezierTo(x + size * 0.4 + 2, y - size * 0.3 + 2, x + size * 0.2 + 2, y - size * 0.5 + 2)
      ..arcToPoint(
        Offset(x - size * 0.2 + 2, y - size * 0.5 + 2),
        radius: Radius.circular(size * 0.25),
        clockwise: true,
      )
      ..quadraticBezierTo(x - size * 0.4 + 2, y - size * 0.3 + 2, x - size * 0.25 + 2, y + 2)
      ..quadraticBezierTo(x - size * 0.3 + 2, y + size * 0.3 + 2, x - size * 0.5 + 2, y + size * 0.6 + 2)
      ..close();
    canvas.drawPath(shadowPath, Paint()..color = Colors.black.withValues(alpha: 0.4));

    // Piyon gövdesi
    final pawnPath = Path()
      ..moveTo(x - size * 0.5, y + size * 0.6)
      ..lineTo(x + size * 0.5, y + size * 0.6)
      ..quadraticBezierTo(x + size * 0.3, y + size * 0.3, x + size * 0.25, y)
      ..quadraticBezierTo(x + size * 0.4, y - size * 0.3, x + size * 0.2, y - size * 0.5)
      ..arcToPoint(
        Offset(x - size * 0.2, y - size * 0.5),
        radius: Radius.circular(size * 0.25),
        clockwise: true,
      )
      ..quadraticBezierTo(x - size * 0.4, y - size * 0.3, x - size * 0.25, y)
      ..quadraticBezierTo(x - size * 0.3, y + size * 0.3, x - size * 0.5, y + size * 0.6)
      ..close();

    canvas.drawPath(pawnPath, Paint()..color = color);
    canvas.drawPath(
      pawnPath,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Üst parlama
    canvas.drawCircle(
      Offset(x - size * 0.05, y - size * 0.45),
      size * 0.12,
      Paint()..color = Colors.white.withValues(alpha: 0.5),
    );
  }

  void _drawBorder(Canvas canvas, double s) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, s, s),
      Paint()
        ..color = grid
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
