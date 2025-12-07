import 'dart:io';
import 'package:image/image.dart' as img;

int _color(int r, int g, int b) => img.getColor(r, g, b);

int _lerp(int a, int b, double t) => (a + (b - a) * t).round();

void _drawFilledTriangle(
  img.Image image,
  int x1,
  int y1,
  int x2,
  int y2,
  int x3,
  int y3,
  int color,
) {
  // Simple triangle rasterization
  final minX = [x1, x2, x3].reduce((a, b) => a < b ? a : b);
  final maxX = [x1, x2, x3].reduce((a, b) => a > b ? a : b);
  final minY = [y1, y2, y3].reduce((a, b) => a < b ? a : b);
  final maxY = [y1, y2, y3].reduce((a, b) => a > b ? a : b);

  for (int y = minY; y <= maxY; y++) {
    for (int x = minX; x <= maxX; x++) {
      // Barycentric coordinates
      final denom = (y2 - y3) * (x1 - x3) + (x3 - x2) * (y1 - y3);
      if (denom == 0) continue;

      final a = ((y2 - y3) * (x - x3) + (x3 - x2) * (y - y3)) / denom;
      final b = ((y3 - y1) * (x - x3) + (x1 - x3) * (y - y3)) / denom;
      final c = 1 - a - b;

      if (a >= 0 && b >= 0 && c >= 0) {
        image.setPixel(x, y, color);
      }
    }
  }
}

void main() {
  const size = 1024;
  final icon = img.Image(size, size);

  // Wood gradient background
  const woodLight = [210, 180, 140];
  const woodDark = [120, 80, 50];

  for (int y = 0; y < size; y++) {
    final t = y / (size - 1);
    final r = _lerp(woodDark[0], woodLight[0], t);
    final g = _lerp(woodDark[1], woodLight[1], t);
    final b = _lerp(woodDark[2], woodLight[2], t);
    final color = _color(r, g, b);
    for (int x = 0; x < size; x++) {
      icon.setPixel(x, y, color);
    }
  }

  final centerX = size ~/ 2;
  final centerY = size ~/ 2;

  // Main dartboard
  final boardRadius = 320;

  // Outer black ring
  img.fillCircle(icon, centerX, centerY, boardRadius, _color(40, 40, 40));

  // Dartboard rings
  final ringRadii = [305, 270, 235, 200, 165, 130, 95, 60, 30];
  final ringColors = [
    _color(245, 245, 245), // White
    _color(237, 68, 66), // Red
    _color(245, 245, 245), // White
    _color(237, 68, 66), // Red
    _color(245, 245, 245), // White
    _color(66, 186, 146), // Green
    _color(237, 68, 66), // Red
    _color(66, 186, 146), // Green
    _color(255, 200, 0), // Gold center
  ];

  for (int i = 0; i < ringRadii.length; i++) {
    img.fillCircle(icon, centerX, centerY, ringRadii[i], ringColors[i]);
  }

  // Bullseye center
  img.fillCircle(icon, centerX, centerY, 28, _color(245, 245, 245));
  img.fillCircle(icon, centerX, centerY, 18, _color(237, 68, 66));
  img.fillCircle(icon, centerX, centerY, 8, _color(66, 186, 146));

  // Flying dart coming from top
  final dartTipX = centerX;
  final dartTipY = centerY - 380;

  // Dart tip - metal
  img.fillCircle(icon, dartTipX, dartTipY, 18, _color(200, 200, 200));
  img.fillCircle(icon, dartTipX, dartTipY + 8, 16, _color(220, 220, 220));

  // Dart shaft - dark
  img.fillRect(
    icon,
    dartTipX - 10,
    dartTipY + 15,
    dartTipX + 10,
    dartTipY + 100,
    _color(50, 50, 50),
  );

  // Dart shaft shine
  img.drawLine(
    icon,
    dartTipX - 8,
    dartTipY + 20,
    dartTipX - 8,
    dartTipY + 90,
    _color(100, 100, 100),
  );

  // Left wing
  _drawFilledTriangle(
    icon,
    dartTipX - 10,
    dartTipY + 50,
    dartTipX - 70,
    dartTipY + 55,
    dartTipX - 10,
    dartTipY + 95,
    _color(237, 68, 66),
  );

  // Right wing
  _drawFilledTriangle(
    icon,
    dartTipX + 10,
    dartTipY + 50,
    dartTipX + 70,
    dartTipY + 55,
    dartTipX + 10,
    dartTipY + 95,
    _color(237, 68, 66),
  );

  // Wing outlines
  img.drawLine(
    icon,
    dartTipX - 10,
    dartTipY + 50,
    dartTipX - 70,
    dartTipY + 55,
    _color(200, 40, 40),
  );
  img.drawLine(
    icon,
    dartTipX - 70,
    dartTipY + 55,
    dartTipX - 10,
    dartTipY + 95,
    _color(200, 40, 40),
  );
  img.drawLine(
    icon,
    dartTipX + 10,
    dartTipY + 50,
    dartTipX + 70,
    dartTipY + 55,
    _color(200, 40, 40),
  );
  img.drawLine(
    icon,
    dartTipX + 70,
    dartTipY + 55,
    dartTipX + 10,
    dartTipY + 95,
    _color(200, 40, 40),
  );

  // Top wings (smaller)
  _drawFilledTriangle(
    icon,
    dartTipX - 10,
    dartTipY + 60,
    dartTipX - 50,
    dartTipY + 62,
    dartTipX - 10,
    dartTipY + 85,
    _color(200, 40, 40),
  );

  _drawFilledTriangle(
    icon,
    dartTipX + 10,
    dartTipY + 60,
    dartTipX + 50,
    dartTipY + 62,
    dartTipX + 10,
    dartTipY + 85,
    _color(200, 40, 40),
  );

  // Shadow under dart
  img.drawEllipse(
    icon,
    centerX,
    centerY + 310,
    80,
    20,
    _color(0, 0, 0),
    antialias: true,
    thickness: 0,
  );

  // Title banner at bottom
  const titleText = 'DART MASTER';
  img.drawString(
    icon,
    img.arial_48,
    centerX - 150,
    size - 120,
    titleText,
    color: _color(255, 220, 100),
  );

  File('assets/icons/dart_icon.png')
    ..createSync(recursive: true)
    ..writeAsBytesSync(img.encodePng(icon));

  print('✅ Dart icon generated: assets/icons/dart_icon.png');
}
