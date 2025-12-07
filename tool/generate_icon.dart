import 'dart:io';
import 'package:image/image.dart' as img;

int _color(int r, int g, int b) => img.getColor(r, g, b);

int _lerp(int a, int b, double t) => (a + (b - a) * t).round();

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
  img.fillRect(
    icon,
    dartTipX - 70,
    dartTipY + 50,
    dartTipX - 10,
    dartTipY + 95,
    _color(237, 68, 66),
  );

  // Right wing
  img.fillRect(
    icon,
    dartTipX + 10,
    dartTipY + 50,
    dartTipX + 70,
    dartTipY + 95,
    _color(237, 68, 66),
  );

  // Wing outlines
  img.drawRect(
    icon,
    dartTipX - 70,
    dartTipY + 50,
    dartTipX - 10,
    dartTipY + 95,
    _color(200, 40, 40),
  );
  img.drawRect(
    icon,
    dartTipX + 10,
    dartTipY + 50,
    dartTipX + 70,
    dartTipY + 95,
    _color(200, 40, 40),
  );

  // Top wings (smaller)
  img.fillRect(
    icon,
    dartTipX - 50,
    dartTipY + 60,
    dartTipX - 10,
    dartTipY + 85,
    _color(200, 40, 40),
  );

  img.fillRect(
    icon,
    dartTipX + 10,
    dartTipY + 60,
    dartTipX + 50,
    dartTipY + 85,
    _color(200, 40, 40),
  );

  // Shadow under dart - simple dark lines
  for (int i = 0; i < 10; i++) {
    final y = centerY + 300 + i;
    final opacity = (10 - i) / 10;
    final shade = (30 * opacity).round();
    final shadowColor = _color(shade, shade, shade);
    final shadowWidth = (80 * (1 - i / 15)).round();
    img.drawLine(
      icon,
      centerX - shadowWidth,
      y,
      centerX + shadowWidth,
      y,
      shadowColor,
    );
  }

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
