import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import 'dart_game_settings.dart';
import 'dart_game_settings_screen.dart';

enum DartGameMode { practice, vsComputer, vsPlayer }

class DartGameScreen extends StatefulWidget {
  final DartGameMode mode;
  const DartGameScreen({super.key, this.mode = DartGameMode.practice});

  @override
  State<DartGameScreen> createState() => _DartGameScreenState();
}

class _DartGameScreenState extends State<DartGameScreen>
    with TickerProviderStateMixin {
  // Oyun Ayarları
  late DartGameSettings gameSettings;

  // Skorlar
  int player1Score = 501;
  int player2Score = 501;
  int currentPlayer = 1;
  List<Offset> thrownDarts = [];
  List<int> dartScores = [];
  int dartsThrown = 0;
  int roundScore = 0;
  int lastScore = 0;
  String? specialText;

  // Animasyonlar
  late AnimationController _verticalController;
  late AnimationController _horizontalController;
  late AnimationController _dartFlyController;
  late AnimationController _zoomController;
  late AnimationController _celebrationController;
  late AnimationController _dartSwayController;

  bool isVerticalPhase = true;
  bool isDartFlying = false;
  bool isComputerTurn = false;
  bool isWaitingForNextThrow = false;
  double lockedVertical = 0.0;

  Offset? dartStart;
  Offset? dartEnd;
  Offset? lastHitPoint;

  double screenWidth = 0;
  double screenHeight = 0;
  double boardSize = 0;
  Offset boardCenter = Offset.zero;

  List<StarParticle> stars = [];

  Color _lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  @override
  void initState() {
    super.initState();

    // Oyun ayarlarını yükle
    gameSettings = DartGameSettings();

    _verticalController = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    )..repeat(reverse: true);

    _horizontalController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);

    _dartFlyController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _dartFlyController.addStatusListener((s) {
      if (s == AnimationStatus.completed) _onDartHit();
    });

    _zoomController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _dartSwayController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    _dartFlyController.dispose();
    _zoomController.dispose();
    _celebrationController.dispose();
    _dartSwayController.dispose();
    super.dispose();
  }

  void _onTap() {
    if (isDartFlying || isWaitingForNextThrow || isComputerTurn) return;

    if (isVerticalPhase) {
      setState(() {
        lockedVertical = _verticalController.value * 2 - 1;
        isVerticalPhase = false;
      });
    } else {
      _throwDart();
    }
  }

  void _throwDart() {
    double horz = _horizontalController.value * 2 - 1;
    double moveRange = boardSize * 0.42;

    double targetX = boardCenter.dx + horz * moveRange;
    double targetY = boardCenter.dy + lockedVertical * moveRange;

    setState(() {
      isDartFlying = true;
      // Dart konumu mesafe ayarına göre
      double dartStartY = gameSettings.getDartStartOffsetY(screenHeight);
      dartStart = Offset(screenWidth / 2, dartStartY);
      dartEnd = Offset(targetX, targetY);
    });

    _zoomController.forward();
    _dartFlyController.reset();
    _dartFlyController.forward();
  }

  void _onDartHit() {
    if (dartEnd == null) return;

    int score = _calculateScore(dartEnd!);

    setState(() {
      isDartFlying = false;
      thrownDarts.add(dartEnd!);
      dartScores.add(score);
      roundScore += score;
      lastScore = score;
      dartsThrown++;
      lastHitPoint = dartEnd;

      // Özel atış kontrolü - Perfect 12 (Triple 20 = 60)
      if (score == 60) {
        specialText = "PERFECT 12! 🎯";
        _showPerfectCelebration();
      } else if (score == 50) {
        specialText = "BULLSEYE!";
        _showCelebration();
      } else if (score >= 36) {
        specialText = "TRIPLE!";
        _showCelebration();
      } else if (score >= 30) {
        specialText = "DOUBLE!";
        _showCelebration();
      } else {
        specialText = null;
      }

      if (currentPlayer == 1) {
        player1Score = math.max(0, player1Score - score);
      } else {
        player2Score = math.max(0, player2Score - score);
      }

      isVerticalPhase = true;
      isWaitingForNextThrow = true;
    });

    _zoomController.reverse();

    if (dartsThrown >= 3) {
      Timer(const Duration(milliseconds: 1500), _nextPlayer);
    } else {
      Timer(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => isWaitingForNextThrow = false);
      });
    }
  }

  void _showCelebration() {
    final r = math.Random();
    stars = List.generate(
      20,
      (i) => StarParticle(
        angle: i * math.pi / 10 + r.nextDouble() * 0.3,
        distance: 60 + r.nextDouble() * 150,
        size: 16 + r.nextDouble() * 20,
        color: [
          Colors.amber,
          Colors.yellow,
          Colors.orange,
          Colors.white,
        ][r.nextInt(4)],
        rotationSpeed: (r.nextDouble() - 0.5) * 4,
      ),
    );
    lastHitPoint = dartEnd ?? lastHitPoint;
    _celebrationController.reset();
    _celebrationController.forward();
  }

  void _showPerfectCelebration() {
    final r = math.Random();
    // Çok daha fazla partikül - balonlar, konfeti vb
    stars = List.generate(
      80,
      (i) => StarParticle(
        angle: (i % 8) * math.pi / 4 + r.nextDouble() * 0.4,
        distance: 40 + r.nextDouble() * 280,
        size: 12 + r.nextDouble() * 32,
        color: [
          Colors.redAccent,
          Colors.blueAccent,
          Colors.greenAccent,
          Colors.purpleAccent,
          Colors.yellowAccent,
          Colors.cyanAccent,
          Colors.pinkAccent,
          Colors.white,
        ][r.nextInt(8)],
        rotationSpeed: (r.nextDouble() - 0.5) * 8,
        isConfetti: true,
      ),
    );
    lastHitPoint = dartEnd ?? lastHitPoint;
    _celebrationController.reset();
    _celebrationController.forward();
  }

  void _nextPlayer() {
    setState(() {
      dartsThrown = 0;
      roundScore = 0;
      thrownDarts.clear();
      dartScores.clear();
      isVerticalPhase = true;
      isWaitingForNextThrow = false;
      specialText = null;

      if (widget.mode != DartGameMode.practice) {
        currentPlayer = currentPlayer == 1 ? 2 : 1;
        if (widget.mode == DartGameMode.vsComputer && currentPlayer == 2) {
          isComputerTurn = true;
          _computerThrow();
        }
      }
    });
  }

  void _computerThrow() {
    Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      final r = math.Random();
      double accuracy = 0.5 + r.nextDouble() * 0.35;
      double v = (r.nextDouble() - 0.5) * 2 * (1 - accuracy);
      double h = (r.nextDouble() - 0.5) * 2 * (1 - accuracy);
      double moveRange = boardSize * 0.42;

      setState(() {
        isDartFlying = true;
        double dartStartY = gameSettings.getDartStartOffsetY(screenHeight);
        dartStart = Offset(screenWidth / 2, dartStartY);
        dartEnd = Offset(
          boardCenter.dx + h * moveRange,
          boardCenter.dy + v * moveRange,
        );
      });

      _zoomController.forward();
      _dartFlyController.reset();
      _dartFlyController.forward().then((_) {
        if (dartsThrown < 3 && mounted) {
          Timer(const Duration(milliseconds: 700), () {
            if (mounted && isComputerTurn) _computerThrow();
          });
        } else {
          setState(() => isComputerTurn = false);
        }
      });
    });
  }

  int _calculateScore(Offset hit) {
    double dx = hit.dx - boardCenter.dx;
    double dy = hit.dy - boardCenter.dy;
    double dist = math.sqrt(dx * dx + dy * dy);
    double r = boardSize / 2;

    if (dist > r) return 0;
    if (dist < r * 0.025) return 50; // Inner bull
    if (dist < r * 0.065) return 25; // Outer bull

    double angle = math.atan2(dy, dx) + math.pi / 2;
    if (angle < 0) angle += 2 * math.pi;

    int seg = (angle / (2 * math.pi) * 20).floor() % 20;
    List<int> segs = [
      20,
      1,
      18,
      4,
      13,
      6,
      10,
      15,
      2,
      17,
      3,
      19,
      7,
      16,
      8,
      11,
      14,
      9,
      12,
      5,
    ];
    int base = segs[seg];

    if (dist > r * 0.35 && dist < r * 0.42) return base * 3; // Triple
    if (dist > r * 0.88 && dist < r * 0.98) return base * 2; // Double

    return base;
  }

  void _reset() {
    setState(() {
      player1Score = 501;
      player2Score = 501;
      currentPlayer = 1;
      dartsThrown = 0;
      roundScore = 0;
      thrownDarts.clear();
      dartScores.clear();
      isVerticalPhase = true;
      isComputerTurn = false;
      isWaitingForNextThrow = false;
      specialText = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          screenWidth = constraints.maxWidth;
          screenHeight = constraints.maxHeight;

          // Mobil ve desktop için farklı boyutlar
          bool isMobile = screenWidth < 600;
          double boardRatio = isMobile ? 0.75 : 0.85;
          double boardHeightRatio = isMobile ? 0.55 : 0.58;

          boardSize = math.min(
            screenWidth * boardRatio,
            screenHeight * boardHeightRatio,
          );
          boardCenter = Offset(
            screenWidth / 2,
            screenHeight * (isMobile ? 0.38 : 0.42),
          );

          return GestureDetector(
            onTap: _onTap,
            child: Stack(
              children: [
                // Zoomlanabilir oyun alanı
                AnimatedBuilder(
                  animation: _zoomController,
                  builder: (context, child) {
                    // Atış anında ekrana zoom yap - mesafeye göre ayarla
                    double zoomProgress = Curves.easeOutCubic.transform(
                      _zoomController.value,
                    );
                    double targetZoom = gameSettings.getZoomMultiplier();
                    double zoom =
                      1.0 +
                      zoomProgress *
                        (targetZoom - 1.0); // Mesafeye göre zoom

                    // Hedef noktaya doğru translate et (zoom ile birlikte)
                    double offsetX = 0;
                    double offsetY = 0;
                    if (dartEnd != null && zoomProgress > 0) {
                      // Dart vuruşunu tam merkeze sabitlemek için ölçeğe göre kaydır
                      // T = (center - point) * (zoom - 1)
                      final dx = screenWidth / 2 - dartEnd!.dx;
                      final dy = screenHeight / 2 - dartEnd!.dy;
                      offsetX = (dx * (zoom - 1)).roundToDouble();
                      offsetY = (dy * (zoom - 1)).roundToDouble();
                    }

                    return Transform.translate(
                      offset: Offset(offsetX, offsetY),
                      child: Transform.scale(
                        scale: zoom,
                        alignment: Alignment.center,
                        child: Stack(
                          children: [
                            // Ahşap arka plan
                            _buildWoodBackground(),

                            // Skor tablosu
                            _buildScoreBoard(),

                            // Dart tahtası
                            Positioned(
                              left: boardCenter.dx - boardSize / 2,
                              top: boardCenter.dy - boardSize / 2,
                              child: _buildDartboard(),
                            ),

                            // Dikey güç barı (sol)
                            if (!isComputerTurn &&
                                isVerticalPhase &&
                                !isDartFlying)
                              _buildVerticalPowerBar(),

                            // Yatay güç barı (alt)
                            if (!isComputerTurn &&
                                !isVerticalPhase &&
                                !isDartFlying)
                              _buildHorizontalPowerBar(),

                            // Nişan göstergesi
                            if (!isDartFlying && !isComputerTurn)
                              _buildAimIndicator(),

                            // Atılmış dartlar (skorsuz)
                            ...thrownDarts.map(
                              (pos) => Positioned(
                                left: pos.dx - 8,
                                top: pos.dy - 6,
                                child: _buildStuckDart(),
                              ),
                            ),

                            // Bekleyen dart
                            if (!isDartFlying &&
                                !isComputerTurn &&
                                dartsThrown < 3)
                              _buildWaitingDartArea(),

                            // Özel atış yazısı
                            if (specialText != null) _buildSpecialText(),

                            // Kutlama yıldızları
                            if (_celebrationController.isAnimating)
                              _buildStars(),

                            // Yardım butonu
                            _buildHelpButton(),

                            // Ayarlar butonu
                            _buildSettingsButton(),

                            // Uçan dart - 3D perspektif ile gerçekçi atış animasyonu (en üstte çizilsin)
                            if (isDartFlying &&
                                dartStart != null &&
                                dartEnd != null)
                              AnimatedBuilder(
                                animation: _dartFlyController,
                                builder: (ctx, _) {
                                  // Eğri animasyon - easeOutExpo ile hızlı başla, yavaşla
                                  double t = Curves.easeOutExpo.transform(
                                    _dartFlyController.value,
                                  );

                                  // 3D Perspektif: Dart uzaklaştıkça küçülür ve yukarı doğru gider
                                  // Z ekseni simülasyonu
                                  double zProgress =
                                      t; // 0 = yakın, 1 = uzak (tahtada)

                                  // X pozisyonu - hedefe TAM DÜZGÜN git
                                  double x =
                                      dartStart!.dx +
                                      (dartEnd!.dx - dartStart!.dx) * t;

                                  // Y pozisyonu - TAM DÜZ çizgi, hiç yay yok
                                  double y =
                                      dartStart!.dy +
                                      (dartEnd!.dy - dartStart!.dy) * t;
                                  
                                  // Renkli duman izi efekti
                                  final trail = <Widget>[];
                                  for (int i = 0; i < 10; i++) {
                                    final trailT = (t - i * 0.06).clamp(0.0, 1.0);
                                    if (trailT > 0) {
                                      final trailX = dartStart!.dx + (dartEnd!.dx - dartStart!.dx) * trailT;
                                      final trailY = dartStart!.dy + (dartEnd!.dy - dartStart!.dy) * trailT;
                                      final opacity = (1.0 - i / 10.0) * 0.7;
                                      final size = (12 - i * 1.0).clamp(3.0, 12.0);
                                      trail.add(
                                        Positioned(
                                          left: trailX - size / 2,
                                          top: trailY - size / 2,
                                          child: Container(
                                            width: size,
                                            height: size,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: RadialGradient(
                                                colors: [
                                                  gameSettings.dartColor.withOpacity(opacity),
                                                  gameSettings.dartColor.withOpacity(opacity * 0.3),
                                                ],
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: gameSettings.dartColor.withOpacity(opacity * 0.5),
                                                  blurRadius: 6,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  }

                                  // Mesafeye göre dinamik boyutlandırma - AYARLARDAN AL
                                  bool isMobile = screenWidth < 600;
                                  
                                  // Ayarlardaki mesafe scale'ini kullan
                                  double settingsScale = gameSettings.getDartStartScale();
                                  
                                  // Başlangıç ve bitiş scale - ayarlara göre
                                  double startScale = isMobile
                                      ? settingsScale * 2.0
                                      : settingsScale * 2.5;
                                  double endScale = isMobile ? 0.30 : 0.40;
                                  double scale =
                                      startScale -
                                      (startScale - endScale) * zProgress;

                                  // Dart boyutları
                                  double dartWidth = isMobile ? 50 : 70;
                                  double dartHeight = isMobile ? 100 : 140;

                                  // Hassas piksel hizalama - titreşimi önle
                                  double finalWidth = dartWidth * scale;
                                  double finalHeight = dartHeight * scale;
                                  
                                  // Ok'un pozisyonu - sivri uç her zaman yukarıda (dikey)
                                  double leftPos = (x - finalWidth / 2)
                                      .roundToDouble();
                                  double topPos = (y - finalHeight / 2)
                                      .roundToDouble();

                                  return Stack(
                                    children: [
                                      ...trail,
                                      Positioned(
                                        left: leftPos,
                                        top: topPos,
                                        child: SizedBox(
                                          width: finalWidth,
                                          height: finalHeight,
                                          child: CustomPaint(
                                            painter: Flying3DDartPainter(
                                              progress: zProgress,
                                              baseColor: gameSettings.dartColor,
                                            ),
                                            isComplex: true,
                                            willChange: true,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Sol alt köşede skor gösterimi (zoom dışında)
                if (dartScores.isNotEmpty) _buildThrowScores(),

                // Atış yönü göstergesi (sağ üst)
                if (!isDartFlying && !isComputerTurn && dartsThrown < 3)
                  _buildPhaseIndicator(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWoodBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFD4A574),
            const Color(0xFFC4956A),
            const Color(0xFFB8865C),
          ],
        ),
      ),
      child: CustomPaint(
        size: Size(screenWidth, screenHeight),
        painter: WoodGrainPainter(),
      ),
    );
  }

  Widget _buildScoreBoard() {
    String difficulty = widget.mode == DartGameMode.vsComputer
        ? "HARD"
        : widget.mode == DartGameMode.vsPlayer
        ? "VS"
        : "PRACTICE";

    bool isMobile = screenWidth < 600;
    double scoreFontSize = isMobile ? 18 : 24;
    double labelFontSize = isMobile ? 9 : 11;
    double buttonSize = isMobile ? 40 : 48;
    double horizontalPadding = isMobile ? 12 : 20;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 8 : 16,
          vertical: 8,
        ),
        child: Row(
          children: [
            // Geri butonu
            _buildCircleButton(
              Icons.chevron_left,
              () => Navigator.pop(context),
              buttonSize,
            ),

            const Spacer(),

            // Skor kartı
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF5D4E4E),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'YOU',
                        style: TextStyle(
                          color: currentPlayer == 1
                              ? Colors.red.shade300
                              : Colors.grey,
                          fontSize: labelFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$player1Score',
                        style: TextStyle(
                          color: currentPlayer == 1
                              ? Colors.red.shade300
                              : Colors.white70,
                          fontSize: scoreFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 10 : 16,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          difficulty,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: isMobile ? 8 : 9,
                          ),
                        ),
                        Text(
                          'VS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 12 : 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.mode != DartGameMode.practice)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'BOT',
                          style: TextStyle(
                            color: currentPlayer == 2
                                ? Colors.cyan
                                : Colors.grey,
                            fontSize: labelFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$player2Score',
                          style: TextStyle(
                            color: currentPlayer == 2
                                ? Colors.cyan
                                : Colors.white70,
                            fontSize: scoreFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            const Spacer(),

            // Yenile butonu
            _buildCircleButton(Icons.refresh, _reset, buttonSize),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton(
    IconData icon,
    VoidCallback onTap, [
    double size = 48,
  ]) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF8B5A5A), size: size * 0.58),
      ),
    );
  }

  Widget _buildDartboard() {
    return Container(
      width: boardSize,
      height: boardSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: CustomPaint(
        size: Size(boardSize, boardSize),
        painter: ProfessionalDartboardPainter(
          primaryColor: gameSettings.boardPrimaryColor,
          secondaryColor: gameSettings.boardSecondaryColor,
          accentColor: gameSettings.dartColor,
        ),
      ),
    );
  }

  Widget _buildVerticalPowerBar() {
    bool isMobile = screenWidth < 600;
    double barWidth = isMobile ? 10 : 12;
    double leftPosition = isMobile ? 12 : 25;

    return Positioned(
      left: leftPosition,
      top: boardCenter.dy - boardSize * 0.45,
      child: AnimatedBuilder(
        animation: _verticalController,
        builder: (ctx, _) {
          double pos = _verticalController.value;
          double barHeight = boardSize * 0.9;

          return Container(
            width: 12,
            height: barHeight,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white30, width: 1),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 1,
                  top: pos * (barHeight - 24) + 2,
                  child: Container(
                    width: 8,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHorizontalPowerBar() {
    bool isMobile = screenWidth < 600;
    double horizontalMargin = isMobile ? 0.08 : 0.15;

    return Positioned(
      left: screenWidth * horizontalMargin,
      right: screenWidth * horizontalMargin,
      top: boardCenter.dy + boardSize / 2 + (isMobile ? 15 : 30),
      child: AnimatedBuilder(
        animation: _horizontalController,
        builder: (ctx, _) {
          double pos = _horizontalController.value;

          return Container(
            height: 12,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white30, width: 1),
            ),
            child: LayoutBuilder(
              builder: (ctx, cons) {
                return Stack(
                  children: [
                    Positioned(
                      left: pos * (cons.maxWidth - 24) + 2,
                      top: 1,
                      child: Container(
                        width: 20,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildAimIndicator() {
    return AnimatedBuilder(
      animation: Listenable.merge([_verticalController, _horizontalController]),
      builder: (ctx, _) {
        double moveRange = boardSize * 0.42;
        double v = isVerticalPhase
            ? (_verticalController.value * 2 - 1)
            : lockedVertical;
        double h = isVerticalPhase ? 0 : (_horizontalController.value * 2 - 1);

        double x = boardCenter.dx + h * moveRange;
        double y = boardCenter.dy + v * moveRange;

        return Positioned(
          left: x - 8,
          top: y - 8,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isVerticalPhase ? Colors.white : Colors.cyan,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isVerticalPhase ? Colors.white : Colors.cyan)
                      .withOpacity(0.5),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: isVerticalPhase ? Colors.white : Colors.cyan,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Atış yönü göstergesi (sağ üst köşe)
  Widget _buildPhaseIndicator() {
    bool isMobile = screenWidth < 600;

    return Positioned(
      right: isMobile ? 12 : 20,
      top: isMobile ? 60 : 80,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 10 : 14,
          vertical: isMobile ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isVerticalPhase ? Colors.orange : Colors.cyan,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isVerticalPhase ? Colors.orange : Colors.cyan)
                  .withOpacity(0.3),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isVerticalPhase ? Icons.swap_vert : Icons.swap_horiz,
              color: isVerticalPhase ? Colors.orange : Colors.cyan,
              size: isMobile ? 16 : 20,
            ),
            SizedBox(width: isMobile ? 4 : 6),
            Text(
              isVerticalPhase ? 'Dikey' : 'Yatay',
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 11 : 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sadece dart gösteren widget (skorsuz)
  Widget _buildStuckDart() {
    return SizedBox(
      width: 16,
      height: 28,
      child: CustomPaint(
        painter: StuckDartPainter(
          baseColor: gameSettings.dartColor,
          style: gameSettings.arrowStyle,
        ),
      ),
    );
  }

  // Sol alt köşede atış skorlarını göster
  Widget _buildThrowScores() {
    bool isMobile = screenWidth < 600;

    return Positioned(
      left: isMobile ? 12 : 20,
      bottom: isMobile ? 100 : 120,
      child: Container(
        padding: EdgeInsets.all(isMobile ? 8 : 12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.75),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.withOpacity(0.5), width: 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 8),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Atışlar',
              style: TextStyle(
                color: Colors.amber,
                fontSize: isMobile ? 10 : 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            ...dartScores.asMap().entries.map((e) {
              int score = e.value;
              Color scoreColor = score >= 50
                  ? Colors.amber
                  : score >= 36
                  ? Colors.cyan
                  : score >= 20
                  ? Colors.green
                  : Colors.white;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: isMobile ? 16 : 20,
                      height: isMobile ? 16 : 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: scoreColor.withOpacity(0.2),
                        border: Border.all(color: scoreColor, width: 1),
                      ),
                      child: Center(
                        child: Text(
                          '${e.key + 1}',
                          style: TextStyle(
                            color: scoreColor,
                            fontSize: isMobile ? 9 : 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$score',
                      style: TextStyle(
                        color: scoreColor,
                        fontSize: isMobile ? 14 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (dartScores.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Toplam: ${dartScores.fold(0, (a, b) => a + b)}',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: isMobile ? 11 : 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStuckDartWithScore(int score) {
    Color scoreColor = score >= 50
        ? Colors.amber
        : score >= 36
        ? Colors.cyan
        : score >= 20
        ? Colors.green
        : Colors.white;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Skor etiketi
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: scoreColor, width: 1.5),
            boxShadow: [
              BoxShadow(color: scoreColor.withOpacity(0.5), blurRadius: 6),
            ],
          ),
          child: Text(
            '$score',
            style: TextStyle(
              color: scoreColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 2),
        // Dart
        SizedBox(
          width: 16,
          height: 28,
          child: CustomPaint(
            painter: StuckDartPainter(
              baseColor: gameSettings.dartColor,
              style: gameSettings.arrowStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFlyingDart() {
    bool isMobile = screenWidth < 600;
    double dartWidth = isMobile ? 50 : 70;
    double dartHeight = isMobile ? 100 : 140;

    CustomPainter painter;
    switch (gameSettings.arrowStyle) {
      case ArrowStyle.classic:
        painter = FlyingDartPainter(
          baseColor: gameSettings.dartColor,
          style: ArrowStyle.classic,
        );
        break;
      case ArrowStyle.modern:
        painter = Flying3DDartPainter(
          progress: _dartFlyController.value,
          baseColor: gameSettings.dartColor,
        );
        break;
      case ArrowStyle.minimal:
        painter = FlyingDartPainter(
          baseColor: gameSettings.dartColor,
          style: ArrowStyle.minimal,
        );
        break;
    }

    return SizedBox(
      width: dartWidth,
      height: dartHeight,
      child: CustomPaint(painter: painter),
    );
  }

  Widget _buildWaitingDartArea() {
    bool isMobile = screenWidth < 600;
    double dartWidth = isMobile ? 60 : 80;
    double dartHeight = isMobile ? 120 : 160;

    // Sadece dart göster - sağa sola sallanarak
    return AnimatedBuilder(
      animation: _dartSwayController,
      builder: (context, child) {
        // -1'den 1'e gidip gelen değer
        double swayValue = (_dartSwayController.value * 2 - 1);
        // Daha fazla sallanım (±16 piksel)
        double swayOffset = swayValue * (isMobile ? 12 : 16);

        return Positioned(
          left: screenWidth / 2 - dartWidth / 2 + swayOffset,
          bottom: isMobile ? 20 : 35,
          child: SizedBox(
            width: dartWidth,
            height: dartHeight,
            child: CustomPaint(
              painter: WaitingDartPainter(
                baseColor: gameSettings.dartColor,
                style: gameSettings.arrowStyle,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpecialText() {
    bool isMobile = screenWidth < 600;
    double fontSize = isMobile ? 28 : 42;
    bool isPerfect = specialText == "PERFECT 12! 🎯";

    return Positioned(
      left: 0,
      right: 0,
      top: boardCenter.dy - boardSize / 2 - (isMobile ? 40 : 60),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 500),
        builder: (ctx, val, _) {
          return Opacity(
            opacity: val,
            child: Transform.scale(
              scale: 0.8 + val * 0.2,
              child: Text(
                specialText!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isPerfect ? fontSize * 1.4 : fontSize,
                  fontWeight: FontWeight.bold,
                  color: isPerfect
                      ? Colors.red.shade400
                      : specialText == "BULLSEYE!"
                      ? Colors.amber
                      : specialText == "TRIPLE!"
                      ? Colors.cyan
                      : Colors.green,
                  shadows: [
                    Shadow(
                      color: isPerfect
                          ? Colors.red.withOpacity(0.8)
                          : Colors.black.withOpacity(0.5),
                      blurRadius: isPerfect ? 20 : 10,
                      offset: const Offset(2, 2),
                    ),
                    if (isPerfect)
                      Shadow(
                        color: Colors.yellow.withOpacity(0.6),
                        blurRadius: 15,
                        offset: const Offset(-2, -2),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStars() {
    return AnimatedBuilder(
      animation: _celebrationController,
      builder: (ctx, _) {
        double t = _celebrationController.value;
        final origin = lastHitPoint ?? boardCenter;
        return Stack(
          children: stars.map((star) {
            // Patlama efekti - hızlı başla, yavaşla
            double easeT = Curves.easeOutCubic.transform(t);
            double x =
                origin.dx + math.cos(star.angle) * star.distance * easeT;
            double y =
                origin.dy +
                math.sin(star.angle) * star.distance * easeT -
                (star.isConfetti ? 50 : 30) * easeT; // Confetti daha yüksek çık
            double opacity = 1 - t * 0.8;
            double scale = 1 + t * 0.5;
            double rotation = star.rotationSpeed * t * math.pi;

            return Positioned(
              left: x - star.size / 2,
              top: y - star.size / 2,
              child: Transform.rotate(
                angle: rotation,
                child: Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity.clamp(0.0, 1.0),
                    child: star.isConfetti
                        ? Container(
                            width: star.size,
                            height: star.size,
                            decoration: BoxDecoration(
                              color: star.color,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(2),
                              boxShadow: [
                                BoxShadow(
                                  color: star.color.withOpacity(0.8),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          )
                        : Icon(
                            Icons.star,
                            color: star.color,
                            size: star.size,
                            shadows: [
                              Shadow(
                                color: star.color.withOpacity(0.8),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildHelpButton() {
    bool isMobile = screenWidth < 600;
    double buttonSize = isMobile ? 32 : 40;

    return Positioned(
      left: isMobile ? 10 : 20,
      bottom: isMobile ? 20 : 40,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: Colors.brown.withOpacity(0.6),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '?',
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsButton() {
    bool isMobile = screenWidth < 600;
    double buttonSize = isMobile ? 40 : 48;

    return Positioned(
      right: isMobile ? 10 : 20,
      bottom: isMobile ? 20 : 40,
      child: GestureDetector(
        onTap: () async {
          // Settings screen'i aç
          final newSettings = await Navigator.of(context)
              .push<DartGameSettings>(
                MaterialPageRoute(
                  builder: (context) => DartGameSettingsScreen(
                    settings: gameSettings,
                    onSettingsChanged: (updatedSettings) {
                      setState(() {
                        gameSettings = updatedSettings;
                      });
                    },
                  ),
                ),
              );

          if (newSettings != null) {
            setState(() {
              gameSettings = newSettings;
              // Oyunu reset et - yeni ayarları uygula
              _reset();
            });
          }
        },
        child: Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            color: Colors.amber,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(
            Icons.settings,
            color: Colors.brown.shade700,
            size: isMobile ? 20 : 24,
          ),
        ),
      ),
    );
  }
}

// Yıldız parçacığı
class StarParticle {
  final double angle;
  final double distance;
  final double size;
  final Color color;
  final double rotationSpeed;
  final bool isConfetti;

  StarParticle({
    required this.angle,
    required this.distance,
    required this.size,
    this.color = Colors.amber,
    this.rotationSpeed = 0,
    this.isConfetti = false,
  });
}

// Ahşap desen çizici
class WoodGrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    double stripeWidth = size.width / 12;

    for (int i = 0; i < 13; i++) {
      paint.color = i % 2 == 0
          ? const Color(0xFFD4A574).withOpacity(0.3)
          : const Color(0xFFC08050).withOpacity(0.2);
      canvas.drawRect(
        Rect.fromLTWH(i * stripeWidth, 0, stripeWidth, size.height),
        paint,
      );
    }

    // Zemin tahtası
    paint.color = const Color(0xFF8B6914).withOpacity(0.3);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.88, size.width, size.height * 0.12),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Profesyonel dart tahtası
class ProfessionalDartboardPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;

  const ProfessionalDartboardPainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
  });

  static const segments = [
    20,
    1,
    18,
    4,
    13,
    6,
    10,
    15,
    2,
    17,
    3,
    19,
    7,
    16,
    8,
    11,
    14,
    9,
    12,
    5,
  ];

  Color _shift(Color color, double delta) {
    final hsl = HSLColor.fromColor(color);
    final l = (hsl.lightness + delta).clamp(0.0, 1.0);
    return hsl.withLightness(l).toColor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    final light = primaryColor;
    final dark = secondaryColor;
    final accentLight = _shift(accentColor, 0.10);
    final accentDark = _shift(accentColor, -0.12);

    // Siyah çerçeve
    canvas.drawCircle(c, r, Paint()..color = dark.withOpacity(0.9));

    final angle = math.pi * 2 / 20;

    for (int i = 0; i < 20; i++) {
      final start = -math.pi / 2 + i * angle - angle / 2;
      bool even = i % 2 == 0;

      // Double ring
      _drawSeg(
        canvas,
        c,
        r,
        start,
        angle,
        0.88,
        0.98,
        even ? accentDark : accentLight,
      );
      // Outer single
      _drawSeg(
        canvas,
        c,
        r,
        start,
        angle,
        0.42,
        0.88,
        even ? dark : light,
      );
      // Triple ring
      _drawSeg(
        canvas,
        c,
        r,
        start,
        angle,
        0.35,
        0.42,
        even ? accentDark : accentLight,
      );
      // Inner single
      _drawSeg(
        canvas,
        c,
        r,
        start,
        angle,
        0.065,
        0.35,
        even ? dark : light,
      );
    }

    // Outer bull
    canvas.drawCircle(c, r * 0.065, Paint()..color = accentDark);
    // Inner bull
    canvas.drawCircle(c, r * 0.025, Paint()..color = accentLight);

    // Teller
    final wire = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(c, r * 0.98, wire);
    canvas.drawCircle(c, r * 0.88, wire);
    canvas.drawCircle(c, r * 0.42, wire);
    canvas.drawCircle(c, r * 0.35, wire);
    canvas.drawCircle(c, r * 0.065, wire);
    canvas.drawCircle(c, r * 0.025, wire);

    for (int i = 0; i < 20; i++) {
      final a = -math.pi / 2 + i * angle - angle / 2;
      canvas.drawLine(
        Offset(c.dx + math.cos(a) * r * 0.065, c.dy + math.sin(a) * r * 0.065),
        Offset(c.dx + math.cos(a) * r * 0.98, c.dy + math.sin(a) * r * 0.98),
        wire..strokeWidth = 1,
      );
    }

    // Sayılar
    for (int i = 0; i < 20; i++) {
      final a = -math.pi / 2 + i * angle;
      final tp = TextPainter(
        text: TextSpan(
          text: '${segments[i]}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      final pos = Offset(
        c.dx + math.cos(a) * r * 0.80 - tp.width / 2,
        c.dy + math.sin(a) * r * 0.80 - tp.height / 2,
      );
      tp.paint(canvas, pos);
    }
  }

  void _drawSeg(
    Canvas canvas,
    Offset c,
    double r,
    double start,
    double sweep,
    double inner,
    double outer,
    Color color,
  ) {
    final path = Path()
      ..moveTo(
        c.dx + math.cos(start) * r * inner,
        c.dy + math.sin(start) * r * inner,
      )
      ..lineTo(
        c.dx + math.cos(start) * r * outer,
        c.dy + math.sin(start) * r * outer,
      )
      ..arcTo(
        Rect.fromCircle(center: c, radius: r * outer),
        start,
        sweep,
        false,
      )
      ..lineTo(
        c.dx + math.cos(start + sweep) * r * inner,
        c.dy + math.sin(start + sweep) * r * inner,
      )
      ..arcTo(
        Rect.fromCircle(center: c, radius: r * inner),
        start + sweep,
        -sweep,
        false,
      )
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant ProfessionalDartboardPainter oldDelegate) {
    return oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.accentColor != accentColor;
  }
}

// Tahtaya saplanmış dart çizici (çok küçük)
class StuckDartPainter extends CustomPainter {
  final Color baseColor;
  final ArrowStyle style;

  StuckDartPainter({required this.baseColor, required this.style});

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

    // CANLI PROFESYONEL RENKLER
    final bright = _shift(baseColor, 0.45);
    final mid = _shift(baseColor, 0.20);
    final dark = _shift(baseColor, -0.35);

    // PROFESYONEL DART - FOTOĞRAFTAKI GİBİ
    
    // 1. BÜYÜK X KANATLAR - gerçekçi 3D görünüm
    final wingLength = w * 0.42;
    final wingWidth = w * 0.14;
    
    // Kanat gölgeleri (dış çerçeve)
    final wingShadow = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = wingWidth + 3
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    
    // Sol-üst → Sağ-alt gölge
    canvas.drawLine(
      Offset(cx - wingLength, cy - wingLength * 0.9),
      Offset(cx + wingLength, cy + wingLength * 0.9),
      wingShadow,
    );
    // Sağ-üst → Sol-alt gölge
    canvas.drawLine(
      Offset(cx + wingLength, cy - wingLength * 0.9),
      Offset(cx - wingLength, cy + wingLength * 0.9),
      wingShadow,
    );
    
    // Kanat ana renk (koyu)
    final wingMain = Paint()
      ..color = dark
      ..style = PaintingStyle.stroke
      ..strokeWidth = wingWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    
    canvas.drawLine(
      Offset(cx - wingLength, cy - wingLength * 0.9),
      Offset(cx + wingLength, cy + wingLength * 0.9),
      wingMain,
    );
    canvas.drawLine(
      Offset(cx + wingLength, cy - wingLength * 0.9),
      Offset(cx - wingLength, cy + wingLength * 0.9),
      wingMain,
    );
    
    // Kanat highlight (parlak şerit)
    final wingHighlight = Paint()
      ..color = mid.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = wingWidth * 0.35
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    
    canvas.drawLine(
      Offset(cx - wingLength * 0.9, cy - wingLength * 0.8),
      Offset(cx + wingLength * 0.9, cy + wingLength * 0.8),
      wingHighlight,
    );
    canvas.drawLine(
      Offset(cx + wingLength * 0.9, cy - wingLength * 0.8),
      Offset(cx - wingLength * 0.9, cy + wingLength * 0.8),
      wingHighlight,
    );

    // 2. ORTADA PROFESYONEL GÖVDE - halka şeklinde
    final bodyRadius = w * 0.16;
    
    // Gölge
    canvas.drawCircle(
      Offset(cx + 1, cy + 1),
      bodyRadius + 2,
      Paint()
        ..color = Colors.black.withOpacity(0.4)
        ..isAntiAlias = true,
    );
    
    // Siyah dış çerçeve
    canvas.drawCircle(
      Offset(cx, cy),
      bodyRadius + 2,
      Paint()
        ..color = Colors.black
        ..isAntiAlias = true,
    );
    
    // Koyu renkli dış halka
    canvas.drawCircle(
      Offset(cx, cy),
      bodyRadius,
      Paint()
        ..color = dark
        ..isAntiAlias = true,
    );
    
    // Ana renkli orta halka
    canvas.drawCircle(
      Offset(cx, cy),
      bodyRadius * 0.70,
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
      bodyRadius * 0.20,
      Paint()
        ..color = Colors.white
        ..isAntiAlias = true,
    );
    
    // Parlama efekti
    canvas.drawCircle(
      Offset(cx - bodyRadius * 0.2, cy - bodyRadius * 0.2),
      bodyRadius * 0.08,
      Paint()
        ..color = Colors.white.withOpacity(0.6)
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(covariant StuckDartPainter oldDelegate) {
    return oldDelegate.baseColor != baseColor || oldDelegate.style != style;
  }
}

// Uçan dart çizici - çapraz kanatlı profesyonel tasarım
class FlyingDartPainter extends CustomPainter {
  final Color baseColor;
  final ArrowStyle style;

  FlyingDartPainter({required this.baseColor, required this.style});

  Color _shift(Color color, double delta) {
    final hsl = HSLColor.fromColor(color);
    final l = (hsl.lightness + delta).clamp(0.0, 1.0);
    return hsl.withLightness(l).toColor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final h = size.height;
    final w = size.width;

    final bright = _shift(baseColor, 0.16);
    final mid = _shift(baseColor, 0.04);
    final dark = _shift(baseColor, -0.14);

    // Sivri metal uç
    final tipPath = Path()
      ..moveTo(cx, 0)
      ..lineTo(cx - 5, h * 0.15)
      ..lineTo(cx + 5, h * 0.15)
      ..close();
    canvas.drawPath(
      tipPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.grey.shade300, Colors.grey.shade600],
        ).createShader(Rect.fromLTWH(cx - 5, 0, 10, h * 0.15)),
    );

    // Metal highlight
    canvas.drawLine(
      Offset(cx - 1.5, 3),
      Offset(cx - 1.5, h * 0.12),
      Paint()
        ..color = Colors.white.withOpacity(0.7)
        ..strokeWidth = 2,
    );

    // Barrel (siyah metal gövde)
    final barrelRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 7, h * 0.15, 14, h * 0.18),
      const Radius.circular(3),
    );
    canvas.drawRRect(
      barrelRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: style == ArrowStyle.minimal
              ? [Colors.grey.shade600, Colors.grey.shade700]
              : [
                  Colors.grey.shade700,
                  Colors.grey.shade500,
                  Colors.grey.shade700,
                ],
        ).createShader(Rect.fromLTWH(cx - 7, h * 0.15, 14, h * 0.18)),
    );

    // Barrel grip çizgileri
    for (int i = 0; i < 4; i++) {
      double y = h * 0.17 + i * (h * 0.035);
      canvas.drawLine(
        Offset(cx - 5, y),
        Offset(cx + 5, y),
        Paint()
          ..color = Colors.black.withOpacity(style == ArrowStyle.minimal ? 0.25 : 0.5)
          ..strokeWidth = style == ArrowStyle.minimal ? 0.8 : 1.2,
      );
    }

    // Shaft (renkli sap)
    final shaftRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 5, h * 0.33, 10, h * 0.15),
      const Radius.circular(2),
    );
    canvas.drawRRect(
      shaftRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: style == ArrowStyle.minimal
              ? [baseColor, baseColor]
              : [bright, mid, dark],
        ).createShader(Rect.fromLTWH(cx - 5, h * 0.33, 10, h * 0.15)),
    );

    // Shaft çizgileri
    for (int i = 0; i < 3; i++) {
      double y = h * 0.35 + i * (h * 0.035);
      canvas.drawLine(
        Offset(cx - 3.5, y),
        Offset(cx + 3.5, y),
        Paint()
          ..color = Colors.black.withOpacity(style == ArrowStyle.minimal ? 0.18 : 0.3)
          ..strokeWidth = style == ArrowStyle.minimal ? 0.6 : 0.8,
      );
    }

    // Kanatlar
    final wingPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: style == ArrowStyle.minimal
            ? [baseColor, baseColor]
            : [bright, dark],
      ).createShader(Rect.fromLTWH(0, h * 0.48, w, h * 0.52));

    final wingStroke = Paint()
      ..color = style == ArrowStyle.minimal ? dark.withOpacity(0.6) : dark
      ..style = PaintingStyle.stroke
      ..strokeWidth = style == ArrowStyle.minimal ? 1.0 : 1.5;

    // Sol üst kanat
    final leftTopWing = Path()
      ..moveTo(cx - 4, h * 0.48)
      ..lineTo(cx - w * 0.42, h * 0.43)
      ..lineTo(cx - w * 0.38, h * 0.55)
      ..lineTo(cx - 4, h * 0.56)
      ..close();
    canvas.drawPath(leftTopWing, wingPaint);
    canvas.drawPath(leftTopWing, wingStroke);

    // Sağ üst kanat
    final rightTopWing = Path()
      ..moveTo(cx + 4, h * 0.48)
      ..lineTo(cx + w * 0.42, h * 0.43)
      ..lineTo(cx + w * 0.38, h * 0.55)
      ..lineTo(cx + 4, h * 0.56)
      ..close();
    canvas.drawPath(rightTopWing, wingPaint);
    canvas.drawPath(rightTopWing, wingStroke);

    // Sol alt kanat
    final leftBottomWing = Path()
      ..moveTo(cx - 4, h * 0.60)
      ..lineTo(cx - w * 0.38, h * 0.65)
      ..lineTo(cx - w * 0.42, h * 0.80)
      ..lineTo(cx - 4, h * 0.72)
      ..close();
    canvas.drawPath(leftBottomWing, wingPaint);
    canvas.drawPath(leftBottomWing, wingStroke);

    // Sağ alt kanat
    final rightBottomWing = Path()
      ..moveTo(cx + 4, h * 0.60)
      ..lineTo(cx + w * 0.38, h * 0.65)
      ..lineTo(cx + w * 0.42, h * 0.80)
      ..lineTo(cx + 4, h * 0.72)
      ..close();
    canvas.drawPath(rightBottomWing, wingPaint);
    canvas.drawPath(rightBottomWing, wingStroke);
  }

  @override
  bool shouldRepaint(covariant FlyingDartPainter oldDelegate) {
    return oldDelegate.baseColor != baseColor || oldDelegate.style != style;
  }
}

// 3D Perspektif Dart Çizici - Uçuş sırasında dik görünüm
class Flying3DDartPainter extends CustomPainter {
  final double progress; // 0 = yakın, 1 = uzak
  final Color baseColor;

  Flying3DDartPainter({required this.progress, required this.baseColor});

  Color _shift(Color color, double delta) {
    final hsl = HSLColor.fromColor(color);
    final l = (hsl.lightness + delta).clamp(0.0, 1.0);
    return hsl.withLightness(l).toColor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // CANLI RENKLER
    final bright = _shift(baseColor, 0.35);
    final mid = _shift(baseColor, 0.15);
    final dark = _shift(baseColor, -0.25);

    // ARKADAN BAKIŞ - OK BİZE DOĞRU GELİYOR, SİVRİ UÇ ÖNDE
    // SADECE X KANATLAR VE ORTADA KÜÇÜK GÖVDE GÖZÜKÜYOR
    
    // KOCAMAN X ŞEKLİNDE KANATLAR
    final wingSize = size.width * 0.45;
    
    final wingPaint = Paint()
      ..color = dark
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.12
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    
    final wingOutline = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.14
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    // Sol-üst → Sağ-alt
    canvas.drawLine(
      Offset(cx - wingSize, cy - wingSize),
      Offset(cx + wingSize, cy + wingSize),
      wingOutline,
    );
    canvas.drawLine(
      Offset(cx - wingSize, cy - wingSize),
      Offset(cx + wingSize, cy + wingSize),
      wingPaint,
    );
    
    // Sağ-üst → Sol-alt
    canvas.drawLine(
      Offset(cx + wingSize, cy - wingSize),
      Offset(cx - wingSize, cy + wingSize),
      wingOutline,
    );
    canvas.drawLine(
      Offset(cx + wingSize, cy - wingSize),
      Offset(cx - wingSize, cy + wingSize),
      wingPaint,
    );

    // ORTADA CANLI RENKLI GÖVDE
    final bodyRadius = size.width * 0.16;
    
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
    
    // İç parlak
    canvas.drawCircle(
      Offset(cx, cy),
      bodyRadius * 0.4,
      Paint()
        ..color = bright
        ..isAntiAlias = true,
    );
    
    // Merkez beyaz nokta - sivri uç burada ama görünmüyor
    canvas.drawCircle(
      Offset(cx, cy),
      bodyRadius * 0.15,
      Paint()
        ..color = Colors.white.withOpacity(0.9)
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(covariant Flying3DDartPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.baseColor != baseColor;
}

// Eski DartPainter - artık kullanılmıyor
class DartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;

    // Sivri uç
    final tipPath = Path()
      ..moveTo(cx, 0)
      ..lineTo(cx - 3, 15)
      ..lineTo(cx + 3, 15)
      ..close();
    canvas.drawPath(tipPath, Paint()..color = Colors.grey.shade400);

    // Gövde
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 6, 15, 12, 35),
      const Radius.circular(3),
    );
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
        ).createShader(Rect.fromLTWH(cx - 6, 15, 12, 35)),
    );

    // Çizgiler
    for (int i = 0; i < 4; i++) {
      canvas.drawLine(
        Offset(cx - 5, 20 + i * 8.0),
        Offset(cx + 5, 20 + i * 8.0),
        Paint()
          ..color = Colors.black.withOpacity(0.3)
          ..strokeWidth = 1,
      );
    }

    // Kanatlar
    final wingPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFE53935), Color(0xFF8B0000)],
      ).createShader(Rect.fromLTWH(0, 50, 30, 30));

    // Sol kanat
    final leftWing = Path()
      ..moveTo(cx - 4, 50)
      ..lineTo(cx - 20, 75)
      ..lineTo(cx - 4, 70)
      ..close();
    canvas.drawPath(leftWing, wingPaint);
    canvas.drawPath(
      leftWing,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Sağ kanat
    final rightWing = Path()
      ..moveTo(cx + 4, 50)
      ..lineTo(cx + 20, 75)
      ..lineTo(cx + 4, 70)
      ..close();
    canvas.drawPath(rightWing, wingPaint);
    canvas.drawPath(
      rightWing,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Bekleyen dart çizici - referans gibi çapraz kanatlar
class WaitingDartPainter extends CustomPainter {
  final Color baseColor;
  final ArrowStyle style;

  WaitingDartPainter({required this.baseColor, required this.style});

  Color _shift(Color color, double delta) {
    final hsl = HSLColor.fromColor(color);
    final l = (hsl.lightness + delta).clamp(0.0, 1.0);
    return hsl.withLightness(l).toColor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final h = size.height;
    final w = size.width;

    final bright = _shift(baseColor, 0.12);
    final mid = _shift(baseColor, 0.02);
    final dark = _shift(baseColor, -0.14);

    // Sivri metal uç
    final tipPath = Path()
      ..moveTo(cx, cy - h * 0.35)
      ..lineTo(cx - 4, cy - h * 0.22)
      ..lineTo(cx + 4, cy - h * 0.22)
      ..close();
    canvas.drawPath(
      tipPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.grey.shade300, Colors.grey.shade500],
        ).createShader(Rect.fromLTWH(cx - 4, cy - h * 0.35, 8, h * 0.13)),
    );

    // Metal highlight
    canvas.drawLine(
      Offset(cx - 1, cy - h * 0.33),
      Offset(cx - 1, cy - h * 0.24),
      Paint()
        ..color = Colors.white.withOpacity(0.7)
        ..strokeWidth = 1.5,
    );

    // Barrel (metal gövde)
    final barrelRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 6, cy - h * 0.22, 12, h * 0.18),
      const Radius.circular(3),
    );
    canvas.drawRRect(
      barrelRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: style == ArrowStyle.minimal
              ? [Colors.grey.shade600, Colors.grey.shade700]
              : [
                  Colors.grey.shade700,
                  Colors.grey.shade500,
                  Colors.grey.shade700,
                ],
        ).createShader(Rect.fromLTWH(cx - 6, cy - h * 0.22, 12, h * 0.18)),
    );

    // Barrel grip çizgileri
    for (int i = 0; i < 4; i++) {
      double y = cy - h * 0.20 + i * (h * 0.035);
      canvas.drawLine(
        Offset(cx - 4, y),
        Offset(cx + 4, y),
        Paint()
          ..color = Colors.black.withOpacity(style == ArrowStyle.minimal ? 0.25 : 0.5)
          ..strokeWidth = style == ArrowStyle.minimal ? 0.8 : 1,
      );
    }

    // Shaft (renkli sap)
    final shaftRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 5, cy - h * 0.04, 10, h * 0.15),
      const Radius.circular(2),
    );
    canvas.drawRRect(
      shaftRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: style == ArrowStyle.minimal
              ? [baseColor, baseColor]
              : [bright, mid, dark],
        ).createShader(Rect.fromLTWH(cx - 5, cy - h * 0.04, 10, h * 0.15)),
    );

    // Shaft çizgileri
    for (int i = 0; i < 3; i++) {
      double y = cy + i * (h * 0.035);
      canvas.drawLine(
        Offset(cx - 3.5, y),
        Offset(cx + 3.5, y),
        Paint()
          ..color = Colors.black.withOpacity(style == ArrowStyle.minimal ? 0.18 : 0.3)
          ..strokeWidth = style == ArrowStyle.minimal ? 0.6 : 0.8,
      );
    }

    // Çapraz kanatlar (X şeklinde) - referans gibi
    final wingPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: style == ArrowStyle.minimal
            ? [baseColor, baseColor]
            : [bright, dark],
      ).createShader(Rect.fromLTWH(0, cy + h * 0.1, w, h * 0.3));

    final wingStroke = Paint()
      ..color = style == ArrowStyle.minimal ? dark.withOpacity(0.6) : dark
      ..style = PaintingStyle.stroke
      ..strokeWidth = style == ArrowStyle.minimal ? 1.2 : 2;

    // Sol üst kanat
    final leftTopWing = Path()
      ..moveTo(cx - 4, cy + h * 0.11)
      ..lineTo(cx - w * 0.4, cy + h * 0.05)
      ..lineTo(cx - w * 0.35, cy + h * 0.15)
      ..lineTo(cx - 4, cy + h * 0.18)
      ..close();
    canvas.drawPath(leftTopWing, wingPaint);
    canvas.drawPath(leftTopWing, wingStroke);

    // Sağ üst kanat
    final rightTopWing = Path()
      ..moveTo(cx + 4, cy + h * 0.11)
      ..lineTo(cx + w * 0.4, cy + h * 0.05)
      ..lineTo(cx + w * 0.35, cy + h * 0.15)
      ..lineTo(cx + 4, cy + h * 0.18)
      ..close();
    canvas.drawPath(rightTopWing, wingPaint);
    canvas.drawPath(rightTopWing, wingStroke);

    // Sol alt kanat
    final leftBottomWing = Path()
      ..moveTo(cx - 4, cy + h * 0.22)
      ..lineTo(cx - w * 0.35, cy + h * 0.28)
      ..lineTo(cx - w * 0.4, cy + h * 0.38)
      ..lineTo(cx - 4, cy + h * 0.32)
      ..close();
    canvas.drawPath(leftBottomWing, wingPaint);
    canvas.drawPath(leftBottomWing, wingStroke);

    // Sağ alt kanat
    final rightBottomWing = Path()
      ..moveTo(cx + 4, cy + h * 0.22)
      ..lineTo(cx + w * 0.35, cy + h * 0.28)
      ..lineTo(cx + w * 0.4, cy + h * 0.38)
      ..lineTo(cx + 4, cy + h * 0.32)
      ..close();
    canvas.drawPath(rightBottomWing, wingPaint);
    canvas.drawPath(rightBottomWing, wingStroke);
  }

  @override
  bool shouldRepaint(covariant WaitingDartPainter oldDelegate) {
    return oldDelegate.baseColor != baseColor || oldDelegate.style != style;
  }
}

// El ile dart tutan çizici - profesyonel görünüm
class HandWithDartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final h = size.height;
    final w = size.width;

    // El (ten rengi)
    final handPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFFE8C4A0), const Color(0xFFD4A574)],
      ).createShader(Rect.fromLTWH(0, h * 0.5, w, h * 0.5));

    // El şekli
    final handPath = Path()
      ..moveTo(cx - 25, h)
      ..quadraticBezierTo(cx - 30, h * 0.75, cx - 20, h * 0.55)
      ..lineTo(cx - 8, h * 0.52)
      ..lineTo(cx + 8, h * 0.52)
      ..lineTo(cx + 20, h * 0.55)
      ..quadraticBezierTo(cx + 30, h * 0.75, cx + 25, h)
      ..close();
    canvas.drawPath(handPath, handPaint);

    // El kenarı
    canvas.drawPath(
      handPath,
      Paint()
        ..color = const Color(0xFFC4956A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Parmaklar (dart'ı tutuyor)
    final fingerPaint = Paint()..color = const Color(0xFFE8C4A0);

    // Sol parmak
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 12, h * 0.42, 8, 25),
        const Radius.circular(4),
      ),
      fingerPaint,
    );

    // Sağ parmak
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + 4, h * 0.42, 8, 25),
        const Radius.circular(4),
      ),
      fingerPaint,
    );

    // Dart ucu (metal - yukarıya bakıyor)
    final tipPath = Path()
      ..moveTo(cx, 0)
      ..lineTo(cx - 4, h * 0.12)
      ..lineTo(cx + 4, h * 0.12)
      ..close();
    canvas.drawPath(
      tipPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.grey.shade300, Colors.grey.shade600],
        ).createShader(Rect.fromLTWH(cx - 4, 0, 8, h * 0.12)),
    );

    // Uç highlight
    canvas.drawLine(
      Offset(cx - 1, 3),
      Offset(cx - 1, h * 0.10),
      Paint()
        ..color = Colors.white.withOpacity(0.7)
        ..strokeWidth = 1.5,
    );

    // Barrel (siyah metal)
    final barrelRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 6, h * 0.12, 12, h * 0.15),
      const Radius.circular(3),
    );
    canvas.drawRRect(
      barrelRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.grey.shade700,
            Colors.grey.shade500,
            Colors.grey.shade700,
          ],
        ).createShader(Rect.fromLTWH(cx - 6, h * 0.12, 12, h * 0.15)),
    );

    // Grip çizgileri
    for (int i = 0; i < 4; i++) {
      double y = h * 0.14 + i * (h * 0.03);
      canvas.drawLine(
        Offset(cx - 4, y),
        Offset(cx + 4, y),
        Paint()
          ..color = Colors.black.withOpacity(0.5)
          ..strokeWidth = 1,
      );
    }

    // Shaft (kırmızı)
    final shaftRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 5, h * 0.27, 10, h * 0.18),
      const Radius.circular(2),
    );
    canvas.drawRRect(
      shaftRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFE53935), Color(0xFFB71C1C), Color(0xFFE53935)],
        ).createShader(Rect.fromLTWH(cx - 5, h * 0.27, 10, h * 0.18)),
    );

    // Kanatlar (X şeklinde)
    final wingPaint2 = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
      ).createShader(Rect.fromLTWH(0, h * 0.45, w, h * 0.15));

    final wingStroke2 = Paint()
      ..color = const Color(0xFF8B0000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Sol üst kanat
    final leftTopW = Path()
      ..moveTo(cx - 4, h * 0.45)
      ..lineTo(cx - 35, h * 0.40)
      ..lineTo(cx - 30, h * 0.48)
      ..lineTo(cx - 4, h * 0.50)
      ..close();
    canvas.drawPath(leftTopW, wingPaint2);
    canvas.drawPath(leftTopW, wingStroke2);

    // Sağ üst kanat
    final rightTopW = Path()
      ..moveTo(cx + 4, h * 0.45)
      ..lineTo(cx + 35, h * 0.40)
      ..lineTo(cx + 30, h * 0.48)
      ..lineTo(cx + 4, h * 0.50)
      ..close();
    canvas.drawPath(rightTopW, wingPaint2);
    canvas.drawPath(rightTopW, wingStroke2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
