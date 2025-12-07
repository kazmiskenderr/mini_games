import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final sourceFile = File('assets/icons/multi_games_icon.png');
  if (!sourceFile.existsSync()) {
    print('❌ Source icon not found: ${sourceFile.path}');
    return;
  }

  final sourceImage = img.decodePng(sourceFile.readAsBytesSync());
  if (sourceImage == null) {
    print('❌ Failed to decode source image');
    return;
  }

  final iosIconDir = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';

  final iconSizes = {
    'Icon-App-20x20@1x.png': 20,
    'Icon-App-20x20@2x.png': 40,
    'Icon-App-20x20@3x.png': 60,
    'Icon-App-29x29@1x.png': 29,
    'Icon-App-29x29@2x.png': 58,
    'Icon-App-29x29@3x.png': 87,
    'Icon-App-40x40@1x.png': 40,
    'Icon-App-40x40@2x.png': 80,
    'Icon-App-40x40@3x.png': 120,
    'Icon-App-60x60@2x.png': 120,
    'Icon-App-60x60@3x.png': 180,
    'Icon-App-76x76@1x.png': 76,
    'Icon-App-76x76@2x.png': 152,
    'Icon-App-83.5x83.5@2x.png': 167,
    'Icon-App-1024x1024@1x.png': 1024,
  };

  for (final entry in iconSizes.entries) {
    final fileName = entry.key;
    final size = entry.value;

    final resized = img.copyResize(sourceImage, width: size, height: size);
    final outputFile = File('$iosIconDir/$fileName');
    outputFile.writeAsBytesSync(img.encodePng(resized));
    print('✅ Generated: $fileName ($size x $size)');
  }

  print('\n🎉 All iOS icons updated successfully!');
}
