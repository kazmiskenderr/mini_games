import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/ludo_color.dart';
import '../models/pawn.dart';
import '../models/player.dart';

class BoardPainter extends CustomPainter {
  final List<Player> players;

  BoardPainter({required this.players});

  @override
  void paint(Canvas canvas, Size size) {
    // Tahtayı mümkün olan en büyük kare alana sığdırmak için
    // genişlik ve yükseklikten en küçüğünü alıyoruz.
    final boardSize = math.min(size.width, size.height) * 0.92;
    final boardX = (size.width - boardSize) / 2;
    final boardY = (size.height - boardSize) / 2;
    final cellSize = boardSize / 4;

    // Tahta arka planı
    canvas.drawRect(
      Rect.fromLTWH(boardX, boardY, boardSize, boardSize),
      Paint()..color = Colors.white,
    );

    // 4 ev alanı
    _drawHomeArea(canvas, boardX, boardY, cellSize, 0, LudoColor.yellow); // Sol üst
    _drawHomeArea(canvas, boardX + cellSize * 3, boardY, cellSize, 1, LudoColor.blue); // Sağ üst
    _drawHomeArea(canvas, boardX, boardY + cellSize * 3, cellSize, 2, LudoColor.red); // Sol alt
    _drawHomeArea(canvas, boardX + cellSize * 3, boardY + cellSize * 3, cellSize, 3, LudoColor.green); // Sağ alt

    // Merkez renkli üçgenler
    _drawCenter(canvas, boardX + cellSize * 2, boardY + cellSize * 2, cellSize);

    // Path kareleri
    _drawPathSquares(canvas, boardX, boardY, cellSize);

    // Güvenli bölgeler
    _drawSafeSquares(canvas, boardX, boardY, cellSize);

    // Tahta sınırı
    canvas.drawRect(
      Rect.fromLTWH(boardX, boardY, boardSize, boardSize),
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  void _drawHomeArea(Canvas canvas, double x, double y, double size, int playerIndex, LudoColor color) {
    // Arka plan
    canvas.drawRect(
      Rect.fromLTWH(x, y, size, size),
      Paint()..color = color.value,
    );

    // 4 piyonun konumu
    final player = players[playerIndex];
    final padding = size * 0.1;
    final pawnRadius = size * 0.15;
    final spacing = size * 0.5;

    final positions = [
      Offset(x + padding + pawnRadius, y + padding + pawnRadius),
      Offset(x + size - padding - pawnRadius, y + padding + pawnRadius),
      Offset(x + padding + pawnRadius, y + size - padding - pawnRadius),
      Offset(x + size - padding - pawnRadius, y + size - padding - pawnRadius),
    ];

    for (int i = 0; i < 4; i++) {
      _drawPawn(canvas, positions[i], pawnRadius, color);
    }
  }

  void _drawCenter(Canvas canvas, double centerX, double centerY, double cellSize) {
    final triSize = cellSize * 0.45;

    // Sarı üçgen (sol üst)
    final yellowPath = Path()
      ..moveTo(centerX, centerY)
      ..lineTo(centerX - triSize, centerY - triSize)
      ..lineTo(centerX, centerY - triSize)
      ..close();
    canvas.drawPath(yellowPath, Paint()..color = const Color(0xFFFFD700));

    // Cyan üçgen (sağ üst)
    final cyanPath = Path()
      ..moveTo(centerX, centerY)
      ..lineTo(centerX + triSize, centerY - triSize)
      ..lineTo(centerX + triSize, centerY)
      ..close();
    canvas.drawPath(cyanPath, Paint()..color = const Color(0xFF00BCD4));

    // Kırmızı üçgen (sol alt)
    final redPath = Path()
      ..moveTo(centerX, centerY)
      ..lineTo(centerX - triSize, centerY + triSize)
      ..lineTo(centerX, centerY + triSize)
      ..close();
    canvas.drawPath(redPath, Paint()..color = const Color(0xFFFF4444));

    // Yeşil üçgen (sağ alt)
    final greenPath = Path()
      ..moveTo(centerX, centerY)
      ..lineTo(centerX + triSize, centerY + triSize)
      ..lineTo(centerX + triSize, centerY)
      ..close();
    canvas.drawPath(greenPath, Paint()..color = const Color(0xFF4CAF50));
  }

  void _drawPathSquares(Canvas canvas, double boardX, double boardY, double cellSize) {
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final whitePaint = Paint()..color = Colors.white;

    // 4 satır path kare (center hariç)
    // Üst satır (0-12)
    for (int i = 0; i < 13; i++) {
      canvas.drawRect(
        Rect.fromLTWH(boardX + i * cellSize, boardY, cellSize, cellSize),
        whitePaint,
      );
      canvas.drawRect(
        Rect.fromLTWH(boardX + i * cellSize, boardY, cellSize, cellSize),
        borderPaint,
      );
    }

    // Sağ sütun (13-25)
    for (int i = 0; i < 13; i++) {
      canvas.drawRect(
        Rect.fromLTWH(boardX + cellSize * 3, boardY + i * cellSize, cellSize, cellSize),
        whitePaint,
      );
      canvas.drawRect(
        Rect.fromLTWH(boardX + cellSize * 3, boardY + i * cellSize, cellSize, cellSize),
        borderPaint,
      );
    }

    // Alt satır (26-38)
    for (int i = 0; i < 13; i++) {
      canvas.drawRect(
        Rect.fromLTWH(boardX + cellSize * 3 - (i * cellSize), boardY + cellSize * 3, cellSize, cellSize),
        whitePaint,
      );
      canvas.drawRect(
        Rect.fromLTWH(boardX + cellSize * 3 - (i * cellSize), boardY + cellSize * 3, cellSize, cellSize),
        borderPaint,
      );
    }

    // Sol sütun (39-51)
    for (int i = 0; i < 13; i++) {
      canvas.drawRect(
        Rect.fromLTWH(boardX, boardY + cellSize * 3 - (i * cellSize), cellSize, cellSize),
        whitePaint,
      );
      canvas.drawRect(
        Rect.fromLTWH(boardX, boardY + cellSize * 3 - (i * cellSize), cellSize, cellSize),
        borderPaint,
      );
    }
  }

  void _drawSafeSquares(Canvas canvas, double boardX, double boardY, double cellSize) {
    final starPaint = Paint()..color = const Color(0xFFFFB800);

    // Safe position yıldızları
    final safePositions = [1, 9, 14, 22, 27, 35, 40, 48];
    for (var pos in safePositions) {
      final offset = _getPathPosition(boardX, boardY, cellSize, pos);
      _drawStar(canvas, offset, cellSize * 0.12, starPaint);
    }
  }

  Offset _getPathPosition(double boardX, double boardY, double cellSize, int position) {
    final centerX = cellSize / 2;
    final centerY = cellSize / 2;

    if (position < 13) {
      return Offset(boardX + position * cellSize + centerX, boardY + centerY);
    } else if (position < 26) {
      final row = position - 13;
      return Offset(boardX + cellSize * 3 + centerX, boardY + row * cellSize + centerY);
    } else if (position < 39) {
      final col = position - 26;
      return Offset(boardX + cellSize * 3 - col * cellSize + centerX, boardY + cellSize * 3 + centerY);
    } else {
      final row = position - 39;
      return Offset(boardX + centerX, boardY + cellSize * 3 - row * cellSize + centerY);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final points = <Offset>[];
    const int pointsCount = 5;
    for (int i = 0; i < pointsCount * 2; i++) {
      final angle = (i * math.pi) / pointsCount;
      final radius = i % 2 == 0 ? size : size * 0.4;
      points.add(Offset(
        center.dx + radius * math.cos(1.5707963267948966 - angle),
        center.dy - radius * math.sin(1.5707963267948966 - angle),
      ));
    }

    final path = Path()..addPolygon(points, true);
    canvas.drawPath(path, paint);
  }

  void _drawPawn(Canvas canvas, Offset position, double radius, LudoColor color) {
    // Gölge
    canvas.drawCircle(
      position.translate(1, 1),
      radius,
      Paint()..color = Colors.black.withValues(alpha: 0.15),
    );

    // Ana daire
    canvas.drawCircle(position, radius, Paint()..color = color.value);

    // İç çember
    canvas.drawCircle(
      position,
      radius * 0.7,
      Paint()..color = color.value.withValues(alpha: 0.5),
    );

    // Parlama
    canvas.drawCircle(
      position.translate(-radius * 0.25, -radius * 0.25),
      radius * 0.3,
      Paint()..color = Colors.white.withValues(alpha: 0.3),
    );
  }

  @override
  bool shouldRepaint(BoardPainter oldDelegate) => true;
}
