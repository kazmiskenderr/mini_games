import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart_game_screen.dart';

/// Dart oyunu mod seçim ekranı
class DartGamePreviewScreen extends StatelessWidget {
  const DartGamePreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          children: [
            // Üst bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Dart Oyunu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Dart tahtası önizleme
                    Center(
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.red.shade900,
                              Colors.green.shade900,
                              Colors.black,
                            ],
                            stops: const [0.1, 0.3, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withValues(alpha: 0.3),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: CustomPaint(
                          painter: _MiniDartboardPainter(),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    const Text(
                      'Oyun Modu Seçin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Practice modu
                    _buildModeCard(
                      context,
                      icon: Icons.sports_esports,
                      title: 'Pratik',
                      subtitle: 'Kendi başınıza antrenman yapın',
                      color: Colors.blue,
                      onTap: () => _startGame(context, DartGameMode.practice),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // VS Computer modu
                    _buildModeCard(
                      context,
                      icon: Icons.computer,
                      title: 'Bilgisayara Karşı',
                      subtitle: 'Yapay zeka ile yarışın',
                      color: Colors.orange,
                      onTap: () => _startGame(context, DartGameMode.vsComputer),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // VS Player modu
                    _buildModeCard(
                      context,
                      icon: Icons.people,
                      title: '2 Oyuncu',
                      subtitle: 'Arkadaşınızla oynayın',
                      color: Colors.purple,
                      onTap: () => _startGame(context, DartGameMode.vsPlayer),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Kurallar
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.white.withValues(alpha: 0.7),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                              '501 Kuralları',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• 501 puandan 0\'a düşürün\n'
                          '• Her turda 3 dart atarsınız\n'
                          '• Double ve Triple bölgeler ekstra puan\n'
                          '• Soldan dikey, alttan yatay nişan alın',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildModeCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.3),
                color.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _startGame(BuildContext context, DartGameMode mode) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DartGameScreen(mode: mode),
      ),
    );
  }
}

/// Mini dart tahtası çizici
class _MiniDartboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Segment numaraları
    const List<int> segments = [20, 1, 18, 4, 13, 6, 10, 15, 2, 17, 3, 19, 7, 16, 8, 11, 14, 9, 12, 5];
    final segmentAngle = math.pi * 2 / 20;
    
    // Tel çerçeveler
    final wirePaint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    canvas.drawCircle(center, radius * 0.9, wirePaint);
    canvas.drawCircle(center, radius * 0.43, wirePaint);
    canvas.drawCircle(center, radius * 0.36, wirePaint);
    canvas.drawCircle(center, radius * 0.08, wirePaint);
    
    // Bulls eye
    final bullPaint = Paint()
      ..color = Colors.green.shade700
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.08, bullPaint);
    
    final innerBullPaint = Paint()
      ..color = Colors.red.shade700
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.03, innerBullPaint);
    
    // Numaralar
    for (int i = 0; i < 20; i++) {
      final angle = -math.pi / 2 + i * segmentAngle;
      final textRadius = radius * 0.75;
      final textCenter = Offset(
        center.dx + math.cos(angle) * textRadius,
        center.dy + math.sin(angle) * textRadius,
      );
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${segments[i]}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          textCenter.dx - textPainter.width / 2,
          textCenter.dy - textPainter.height / 2,
        ),
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
