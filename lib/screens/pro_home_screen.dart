import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../router/game_router.dart';
import '../router/color_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _floatController;
  late AnimationController _pulseController;
  
  final List<FloatingParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    // Partiküller oluştur
    for (int i = 0; i < 30; i++) {
      _particles.add(FloatingParticle(
        x: Random().nextDouble(),
        y: Random().nextDouble(),
        size: 2 + Random().nextDouble() * 4,
        speed: 0.1 + Random().nextDouble() * 0.3,
        opacity: 0.3 + Random().nextDouble() * 0.5,
      ));
    }
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final games = [
      GameInfo(
        title: 'Color Tube Sort',
        description: 'Renkleri sırala, rahatla!',
        icon: Icons.science_rounded,
        colors: [const Color(0xFF6C63FF), const Color(0xFF7DD3FC)],
        route: ColorRoutes.colorTubeMenu,
        isAvailable: true,
        imageAsset: 'tube',
      ),
      GameInfo(
        title: 'Zıpla & Koş',
        description: 'Engelleri aş, rekor kır!',
        icon: Icons.rocket_launch_rounded,
        colors: [const Color(0xFF667eea), const Color(0xFF764ba2)],
        route: GameRoutes.jumpGamePreview,
        isAvailable: true,
        imageAsset: 'jump',
      ),
      GameInfo(
        title: 'Dart',
        description: 'Hedefi vur, şampiyon ol!',
        icon: Icons.track_changes_rounded,
        colors: [const Color(0xFFe53935), const Color(0xFFff7043)],
        route: GameRoutes.dartGamePreview,
        isAvailable: true,
        imageAsset: 'dart',
      ),
      GameInfo(
        title: 'Kızma Birader',
        description: 'Klasik Ludo macerası!',
        icon: Icons.casino_rounded,
        colors: [const Color(0xFFf093fb), const Color(0xFFf5576c)],
        route: GameRoutes.ludoHome,
        isAvailable: true,
        imageAsset: 'ludo',
      ),
      GameInfo(
        title: 'Yılan Oyunu',
        description: 'Klasik yılan macerası',
        icon: Icons.pets_rounded,
        colors: [const Color(0xFF11998e), const Color(0xFF38ef7d)],
        route: null,
        isAvailable: false,
        imageAsset: 'snake',
      ),
      GameInfo(
        title: 'Uzay Savaşı',
        description: 'Galaksiyi koru!',
        icon: Icons.rocket_rounded,
        colors: [const Color(0xFFf093fb), const Color(0xFFf5576c)],
        route: null,
        isAvailable: false,
        imageAsset: 'space',
      ),
    ];

    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(
                    const Color(0xFF1a1a2e),
                    const Color(0xFF16213e),
                    (sin(_backgroundController.value * pi * 2) + 1) / 2,
                  )!,
                  const Color(0xFF0f0f23),
                  Color.lerp(
                    const Color(0xFF1a1a2e),
                    const Color(0xFF0f3460),
                    (cos(_backgroundController.value * pi * 2) + 1) / 2,
                  )!,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Partiküller
                ..._particles.map((p) => _buildParticle(p)),
                
                // Ana içerik
                SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      
                      // Logo ve başlık
                      _buildHeader(),
                      
                      const SizedBox(height: 40),
                      
                      // Oyun listesi
                      Expanded(
                        child: _buildGameGrid(games),
                      ),
                      
                      // Alt bilgi
                      _buildFooter(),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildParticle(FloatingParticle p) {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        final y = (p.y + _backgroundController.value * p.speed) % 1.0;
        return Positioned(
          left: p.x * MediaQuery.of(context).size.width,
          top: y * MediaQuery.of(context).size.height,
          child: Container(
            width: p.size,
            height: p.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: p.opacity),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: p.opacity * 0.5),
                  blurRadius: p.size,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, sin(_floatController.value * pi * 2) * 5),
          child: Column(
            children: [
              // Logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667eea).withValues(alpha: 0.5),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.gamepad_rounded,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 25),
              
              // Başlık
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFFf093fb), Color(0xFF764ba2)],
                ).createShader(bounds),
                child: Text(
                  'MiniGames',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              
              const SizedBox(height: 10),
              
              Text(
                'Eğlencenin başladığı yer',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white60,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGameGrid(List<GameInfo> games) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: games.length,
      itemBuilder: (context, index) {
        return _buildGameCard(games[index], index);
      },
    );
  }

  Widget _buildGameCard(GameInfo game, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + index * 100),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: game.isAvailable && game.route != null
            ? () => Navigator.pushNamed(context, game.route!)
            : null,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final glowOpacity = game.isAvailable 
                ? 0.3 + _pulseController.value * 0.2 
                : 0.1;
            
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: game.isAvailable 
                      ? game.colors
                      : [Colors.grey.shade800, Colors.grey.shade900],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (game.isAvailable ? game.colors[0] : Colors.grey)
                        .withValues(alpha: glowOpacity),
                    blurRadius: 15,
                    spreadRadius: 1,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Oyun görseli (özel çizim)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: _buildGameVisual(game),
                    ),
                  ),
                  
                  // Gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                          stops: const [0.4, 1.0],
                        ),
                      ),
                    ),
                  ),
                  
                  // İçerik
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // İkon badge
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            game.icon,
                            size: 22,
                            color: Colors.white,
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // Başlık
                        Text(
                          game.title,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        
                        // Durum
                        const SizedBox(height: 4),
                        if (game.isAvailable)
                          _buildPlayButton()
                        else
                          _buildComingSoon(),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildGameVisual(GameInfo game) {
    return CustomPaint(
      painter: GameVisualPainter(
        gameType: game.imageAsset,
        colors: game.colors,
        isAvailable: game.isAvailable,
      ),
    );
  }

  Widget _buildPlayButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 4),
          Text(
            'OYNA',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoon() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            color: Colors.white54,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            'YAKINDA',
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome,
                color: Colors.amber.shade400,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Daha fazla oyun yakında!',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class GameInfo {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> colors;
  final String? route;
  final bool isAvailable;
  final String imageAsset;

  GameInfo({
    required this.title,
    required this.description,
    required this.icon,
    required this.colors,
    required this.route,
    required this.isAvailable,
    required this.imageAsset,
  });
}

class FloatingParticle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;

  FloatingParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

/// Oyun kartları için özel görsel çizici
class GameVisualPainter extends CustomPainter {
  final String gameType;
  final List<Color> colors;
  final bool isAvailable;
  
  GameVisualPainter({
    required this.gameType,
    required this.colors,
    required this.isAvailable,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (!isAvailable) {
      _paintLocked(canvas, size);
      return;
    }
    
    switch (gameType) {
      case 'jump':
        _paintJumpGame(canvas, size);
        break;
      case 'dart':
        _paintDartGame(canvas, size);
        break;
      case 'snake':
        _paintSnakeGame(canvas, size);
        break;
      case 'space':
        _paintSpaceGame(canvas, size);
        break;
    }
  }
  
  void _paintJumpGame(Canvas canvas, Size size) {
    // Gökyüzü
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF87CEEB),
          const Color(0xFF98D8C8),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);
    
    // Dağlar
    final mountainPaint = Paint()..color = const Color(0xFF4A7C59);
    final path = Path()
      ..moveTo(0, size.height * 0.6)
      ..lineTo(size.width * 0.3, size.height * 0.35)
      ..lineTo(size.width * 0.5, size.height * 0.5)
      ..lineTo(size.width * 0.7, size.height * 0.3)
      ..lineTo(size.width, size.height * 0.55)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, mountainPaint);
    
    // Zemin
    final groundPaint = Paint()..color = const Color(0xFF5D8A4A);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.75, size.width, size.height * 0.25),
      groundPaint,
    );
    
    // Karakter (küçük kutu)
    final playerPaint = Paint()..color = const Color(0xFF5C4D7D);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.2, size.height * 0.55, 20, 25),
        const Radius.circular(4),
      ),
      playerPaint,
    );
    
    // Gözler
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(size.width * 0.2 + 6, size.height * 0.55 + 8), 3, eyePaint);
    canvas.drawCircle(Offset(size.width * 0.2 + 14, size.height * 0.55 + 8), 3, eyePaint);
    
    // Engel (kırmızı üçgen)
    final obstaclePaint = Paint()..color = const Color(0xFFE53935);
    final obstaclePath = Path()
      ..moveTo(size.width * 0.7, size.height * 0.75)
      ..lineTo(size.width * 0.7 + 15, size.height * 0.75)
      ..lineTo(size.width * 0.7 + 7.5, size.height * 0.6)
      ..close();
    canvas.drawPath(obstaclePath, obstaclePaint);
  }
  
  void _paintDartGame(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.55, size.height * 0.45);
    final maxRadius = size.width * 0.22; // Küçültüldü
    
    // Dart tahtası halkaları
    final colors = [
      const Color(0xFFE53935), // Kırmızı
      const Color(0xFFFDD835), // Sarı  
      const Color(0xFF43A047), // Yeşil
      const Color(0xFF1E88E5), // Mavi
      const Color(0xFF212121), // Siyah (merkez)
    ];
    
    for (int i = 0; i < 5; i++) {
      final paint = Paint()..color = colors[i];
      final radius = maxRadius * (5 - i) / 5;
      canvas.drawCircle(center, radius, paint);
      
      // Halka kenarları
      final borderPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawCircle(center, radius, borderPaint);
    }
    
    // Bullseye (ortadaki beyaz nokta)
    canvas.drawCircle(center, 3, Paint()..color = Colors.white);
    
    // Dart oku (daha küçük ve şık)
    final dartBodyPaint = Paint()..color = const Color(0xFF37474F);
    final dartX = size.width * 0.18;
    final dartY = size.height * 0.22;
    
    // Ok gövdesi
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(dartX, dartY), width: 6, height: 28),
        const Radius.circular(2),
      ),
      dartBodyPaint,
    );
    
    // Ok ucu (metal)
    final tipPaint = Paint()..color = Colors.grey.shade300;
    final tipPath = Path()
      ..moveTo(dartX - 3, dartY - 14)
      ..lineTo(dartX, dartY - 24)
      ..lineTo(dartX + 3, dartY - 14)
      ..close();
    canvas.drawPath(tipPath, tipPaint);
    
    // Kanatlar
    final wingPaint = Paint()..color = const Color(0xFF1E88E5);
    // Sol kanat
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(dartX - 10, dartY + 6, 8, 12),
        const Radius.circular(1),
      ),
      wingPaint,
    );
    // Sağ kanat
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(dartX + 2, dartY + 6, 8, 12),
        const Radius.circular(1),
      ),
      wingPaint,
    );
  }
  
  void _paintSnakeGame(Canvas canvas, Size size) {
    // Izgara arka planı
    final bgPaint = Paint()..color = const Color(0xFF1B5E20);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);
    
    // Yılan gövdesi
    final snakePaint = Paint()..color = const Color(0xFF4CAF50);
    final segments = [
      Offset(size.width * 0.3, size.height * 0.4),
      Offset(size.width * 0.4, size.height * 0.4),
      Offset(size.width * 0.5, size.height * 0.4),
      Offset(size.width * 0.5, size.height * 0.5),
      Offset(size.width * 0.6, size.height * 0.5),
    ];
    
    for (final seg in segments) {
      canvas.drawCircle(seg, 8, snakePaint);
    }
    
    // Yılan başı
    final headPaint = Paint()..color = const Color(0xFF66BB6A);
    canvas.drawCircle(segments.last, 10, headPaint);
    
    // Yem
    final foodPaint = Paint()..color = const Color(0xFFFF5722);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.5), 6, foodPaint);
  }
  
  void _paintSpaceGame(Canvas canvas, Size size) {
    // Uzay arka planı
    final spacePaint = Paint()..color = const Color(0xFF1A1A2E);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), spacePaint);
    
    // Yıldızlar
    final starPaint = Paint()..color = Colors.white;
    final random = Random(42);
    for (int i = 0; i < 15; i++) {
      canvas.drawCircle(
        Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
        random.nextDouble() * 2,
        starPaint,
      );
    }
    
    // Uzay gemisi
    final shipPaint = Paint()..color = const Color(0xFF64B5F6);
    final shipPath = Path()
      ..moveTo(size.width * 0.3, size.height * 0.6)
      ..lineTo(size.width * 0.4, size.height * 0.45)
      ..lineTo(size.width * 0.5, size.height * 0.6)
      ..close();
    canvas.drawPath(shipPath, shipPaint);
    
    // Düşman
    final enemyPaint = Paint()..color = const Color(0xFFEF5350);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.3), 12, enemyPaint);
  }
  
  void _paintLocked(Canvas canvas, Size size) {
    // Gri arka plan
    final bgPaint = Paint()..color = Colors.grey.shade800;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);
    
    // Kilit ikonu çizimi
    final lockPaint = Paint()..color = Colors.grey.shade600;
    final lockCenter = Offset(size.width / 2, size.height / 2);
    
    // Kilit gövdesi
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: lockCenter.translate(0, 5), width: 25, height: 20),
        const Radius.circular(3),
      ),
      lockPaint,
    );
    
    // Kilit halkası
    final ringPaint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawArc(
      Rect.fromCenter(center: lockCenter.translate(0, -5), width: 18, height: 18),
      pi,
      pi,
      false,
      ringPaint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
