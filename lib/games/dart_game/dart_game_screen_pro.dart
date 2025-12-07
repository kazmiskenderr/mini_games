import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import 'effects/zoom_effect.dart';
import 'effects/impact_effect.dart';
import 'effects/star_particles.dart';
import 'effects/dart_flight.dart';
import 'effects/hit_text.dart';

enum DartGameMode { practice, vsComputer, vsPlayer }

class DartGameScreen extends StatefulWidget {
  final DartGameMode mode;
  const DartGameScreen({super.key, this.mode = DartGameMode.practice});

  @override
  State<DartGameScreen> createState() => _DartGameScreenState();
}

class _DartGameScreenState extends State<DartGameScreen> with TickerProviderStateMixin {
  // Skorlar
  int player1Score = 501;
  int player2Score = 501;
  int currentPlayer = 1;
  List<Offset> thrownDarts = [];
  List<int> dartScores = [];
  int dartsThrown = 0;
  int roundScore = 0;
  int lastScore = 0;
  
  // Animasyon kontrolleri
  late AnimationController _verticalController;
  late AnimationController _horizontalController;
  
  // Profesyonel efekt kontrolleri
  late ZoomEffectController _zoomEffect;
  late ImpactEffectController _impactEffect;
  late StarParticlesController _starParticles;
  late DartFlightController _dartFlight;
  late HitTextController _hitText;
  
  bool isVerticalPhase = true;
  bool isDartFlying = false;
  bool isComputerTurn = false;
  bool isWaitingForNextThrow = false;
  double lockedVertical = 0.0;
  
  Offset? dartEnd;
  
  double screenWidth = 0;
  double screenHeight = 0;
  double boardSize = 0;
  Offset boardCenter = Offset.zero;
  
  // Impact efekti için
  bool showGlow = false;
  Offset? glowPosition;

  @override
  void initState() {
    super.initState();
    
    // Temel animasyonlar
    _verticalController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _horizontalController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    
    // Profesyonel efektler
    _zoomEffect = ZoomEffectController()..initialize(this);
    _impactEffect = ImpactEffectController()..initialize(this);
    _starParticles = StarParticlesController()..initialize(this);
    _dartFlight = DartFlightController()..initialize(this);
    _hitText = HitTextController()..initialize(this);
    
    // Dart uçuş tamamlandığında
    _dartFlight.controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onDartHit();
      }
    });
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    _zoomEffect.dispose();
    _impactEffect.dispose();
    _starParticles.dispose();
    _dartFlight.dispose();
    _hitText.dispose();
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
      dartEnd = Offset(targetX, targetY);
    });
    
    // Zoom efekti başlat
    _zoomEffect.zoomIn();
    
    // Dart uçuşunu başlat
    _dartFlight.fly(
      start: Offset(screenWidth / 2, screenHeight + 50),
      end: dartEnd!,
    );
  }
  
  void _onDartHit() async {
    if (dartEnd == null) return;
    
    int score = _calculateScore(dartEnd!);
    
    // Zoom geri al
    await _zoomEffect.zoomOut();
    
    // Impact efektleri
    _impactEffect.playImpact();
    _starParticles.emit(dartEnd!);
    
    setState(() {
      showGlow = true;
      glowPosition = dartEnd;
      isDartFlying = false;
      thrownDarts.add(dartEnd!);
      dartScores.add(score);
      roundScore += score;
      lastScore = score;
      dartsThrown++;
      
      if (currentPlayer == 1) {
        player1Score = math.max(0, player1Score - score);
      } else {
        player2Score = math.max(0, player2Score - score);
      }
      
      isVerticalPhase = true;
      isWaitingForNextThrow = true;
    });
    
    // Özel atış kontrolü ve metin animasyonu
    if (score == 50) {
      _hitText.show("BULLSEYE!", HitType.bullseye);
    } else if (score == 25) {
      _hitText.show("BULL!", HitType.bull);
    } else if (score >= 36) {
      _hitText.show("TRIPLE!", HitType.triple);
    } else if (score >= 30) {
      _hitText.show("DOUBLE!", HitType.double);
    }
    
    // Glow efektini gizle
    Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => showGlow = false);
    });
    
    // Sonraki atış veya tur değişimi
    if (dartsThrown >= 3) {
      Timer(const Duration(milliseconds: 1000), _nextPlayer);
    } else {
      Timer(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => isWaitingForNextThrow = false);
      });
    }
  }
  
  void _nextPlayer() {
    setState(() {
      dartsThrown = 0;
      roundScore = 0;
      thrownDarts.clear();
      dartScores.clear();
      isVerticalPhase = true;
      isWaitingForNextThrow = false;
      
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
        dartEnd = Offset(
          boardCenter.dx + h * moveRange,
          boardCenter.dy + v * moveRange,
        );
      });
      
      _zoomEffect.zoomIn();
      _dartFlight.fly(
        start: Offset(screenWidth / 2, screenHeight + 50),
        end: dartEnd!,
      ).then((_) {
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
    List<int> segs = [20, 1, 18, 4, 13, 6, 10, 15, 2, 17, 3, 19, 7, 16, 8, 11, 14, 9, 12, 5];
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          screenWidth = constraints.maxWidth;
          screenHeight = constraints.maxHeight;
          
          bool isMobile = screenWidth < 600;
          double boardRatio = isMobile ? 0.78 : 0.85;
          double boardHeightRatio = isMobile ? 0.40 : 0.42;
          
          boardSize = math.min(screenWidth * boardRatio, screenHeight * boardHeightRatio);
          boardCenter = Offset(screenWidth / 2, screenHeight * (isMobile ? 0.38 : 0.40));
          
          return GestureDetector(
            onTap: _onTap,
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _zoomEffect.controller,
                _impactEffect.shakeController,
              ]),
              builder: (context, child) {
                double zoom = _zoomEffect.zoomAnimation.value;
                double uiOffset = _zoomEffect.uiOffsetAnimation.value;
                double shakeOffset = _impactEffect.shakeOffset;
                
                return Transform.translate(
                  offset: Offset(shakeOffset, uiOffset),
                  child: Transform.scale(
                    scale: zoom,
                    alignment: Alignment.center,
                    child: Stack(
                      children: [
                        // Parallax arka plan
                        _buildParallaxBackground(),
                        
                        // UI elementleri (yukarı kayar)
                        Transform.translate(
                          offset: Offset(0, uiOffset * 0.5),
                          child: _buildScoreBoard(),
                        ),
                        
                        // Dart tahtası
                        Positioned(
                          left: boardCenter.dx - boardSize / 2,
                          top: boardCenter.dy - boardSize / 2,
                          child: AnimatedBuilder(
                            animation: _impactEffect.bounceController,
                            builder: (ctx, child) {
                              return Transform.scale(
                                scale: _impactEffect.bounceScale,
                                child: _buildDartboard(),
                              );
                            },
                          ),
                        ),
                        
                        // Dikey güç barı
                        if (!isComputerTurn && isVerticalPhase && !isDartFlying)
                          _buildVerticalPowerBar(),
                        
                        // Yatay güç barı
                        if (!isComputerTurn && !isVerticalPhase && !isDartFlying)
                          _buildHorizontalPowerBar(),
                        
                        // Nişan göstergesi
                        if (!isDartFlying && !isComputerTurn)
                          _buildAimIndicator(),
                        
                        // Dart gölgeleri
                        ...thrownDarts.map((pos) => DartShadowEffect(position: pos)),
                        
                        // Atılmış dartlar ve skorları
                        ...thrownDarts.asMap().entries.map((e) => Positioned(
                          left: e.value.dx - 20,
                          top: e.value.dy - 30,
                          child: _buildStuckDartWithScore(dartScores[e.key]),
                        )),
                        
                        // Glow efekti
                        if (showGlow && glowPosition != null)
                          DartGlowEffect(
                            animation: _impactEffect.glowController,
                            position: glowPosition!,
                          ),
                        
                        // Uçan dart (motion blur ile)
                        if (isDartFlying)
                          _dartFlight.buildDartWithTrail(
                            dartWidget: _buildFlyingDart(),
                          ),
                        
                        // Yıldız partikülleri
                        _starParticles.buildParticles(),
                        
                        // Bekleyen dart
                        if (!isDartFlying && !isComputerTurn && dartsThrown < 3)
                          _buildWaitingDartArea(),
                        
                        // İsabet metni
                        Positioned(
                          left: 0,
                          right: 0,
                          top: boardCenter.dy - boardSize / 2 - 80,
                          child: _hitText.buildText(),
                        ),
                        
                        // Yardım butonu
                        _buildHelpButton(),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildParallaxBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFB8D4E8), // Pastel mavi üst
            Color(0xFFA8C8DC), // Orta
            Color(0xFF98BCD0), // Alt
          ],
        ),
      ),
      child: CustomPaint(
        size: Size(screenWidth, screenHeight),
        painter: ParallaxLinesPainter(),
      ),
    );
  }
  
  Widget _buildScoreBoard() {
    bool isMobile = screenWidth < 600;
    double scoreFontSize = isMobile ? 22 : 28;
    double labelFontSize = isMobile ? 10 : 12;
    double buttonSize = isMobile ? 44 : 52;
    
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: 10),
        child: Row(
          children: [
            // Geri butonu
            _buildCircleButton(Icons.chevron_left, () => Navigator.pop(context), buttonSize),
            
            const Spacer(),
            
            // Skor kartı
            Container(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF2D3436).withOpacity(0.85),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // YOU skoru
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('YOU', style: TextStyle(
                        color: currentPlayer == 1 
                            ? const Color(0xFFE8504E) 
                            : Colors.grey.shade400,
                        fontSize: labelFontSize, 
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      )),
                      const SizedBox(height: 2),
                      Text('$player1Score', style: TextStyle(
                        color: currentPlayer == 1 
                            ? const Color(0xFFE8504E) 
                            : Colors.white70,
                        fontSize: scoreFontSize, 
                        fontWeight: FontWeight.bold,
                      )),
                    ],
                  ),
                  
                  // Zorluk etiketi
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 20),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade700,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.mode == DartGameMode.vsComputer ? 'HARD' : 
                      widget.mode == DartGameMode.vsPlayer ? 'VS' : 'SOLO',
                      style: TextStyle(
                        color: Colors.grey.shade300,
                        fontSize: isMobile ? 9 : 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  
                  // BOT skoru
                  if (widget.mode != DartGameMode.practice)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('BOT', style: TextStyle(
                          color: currentPlayer == 2 
                              ? const Color(0xFF00A2FF) 
                              : Colors.grey.shade400,
                          fontSize: labelFontSize, 
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        )),
                        const SizedBox(height: 2),
                        Text('$player2Score', style: TextStyle(
                          color: currentPlayer == 2 
                              ? const Color(0xFF00A2FF) 
                              : Colors.white70,
                          fontSize: scoreFontSize, 
                          fontWeight: FontWeight.bold,
                        )),
                      ],
                    ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Restart butonu
            _buildCircleButton(Icons.refresh, _reset, buttonSize),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCircleButton(IconData icon, VoidCallback onTap, [double size = 48]) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF2D3436), size: size * 0.55),
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
            color: Colors.black.withOpacity(0.35),
            blurRadius: 25,
            spreadRadius: 8,
          ),
        ],
      ),
      child: CustomPaint(
        size: Size(boardSize, boardSize),
        painter: ProfessionalDartboardPainter(),
        isComplex: true,
        willChange: false,
      ),
    );
  }
  
  Widget _buildVerticalPowerBar() {
    bool isMobile = screenWidth < 600;
    double barWidth = isMobile ? 10 : 14;
    double leftPosition = isMobile ? 14 : 28;
    
    return Positioned(
      left: leftPosition,
      top: boardCenter.dy - boardSize * 0.45,
      child: AnimatedBuilder(
        animation: _verticalController,
        builder: (ctx, _) {
          double pos = _verticalController.value;
          double barHeight = boardSize * 0.9;
          
          return Container(
            width: barWidth,
            height: barHeight,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(barWidth / 2),
              border: Border.all(color: Colors.white24, width: 1),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 2,
                  top: pos * (barHeight - 24) + 2,
                  child: Container(
                    width: barWidth - 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular((barWidth - 4) / 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.6),
                          blurRadius: 6,
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
    double horizontalMargin = isMobile ? 0.10 : 0.15;
    
    return Positioned(
      left: screenWidth * horizontalMargin,
      right: screenWidth * horizontalMargin,
      top: boardCenter.dy + boardSize / 2 + (isMobile ? 18 : 35),
      child: AnimatedBuilder(
        animation: _horizontalController,
        builder: (ctx, _) {
          double pos = _horizontalController.value;
          
          return Container(
            height: 14,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: Colors.white24, width: 1),
            ),
            child: LayoutBuilder(
              builder: (ctx, cons) {
                return Stack(
                  children: [
                    Positioned(
                      left: pos * (cons.maxWidth - 24) + 2,
                      top: 2,
                      child: Container(
                        width: 20,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.6),
                              blurRadius: 6,
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
        double v = isVerticalPhase ? (_verticalController.value * 2 - 1) : lockedVertical;
        double h = isVerticalPhase ? 0 : (_horizontalController.value * 2 - 1);
        
        double x = boardCenter.dx + h * moveRange;
        double y = boardCenter.dy + v * moveRange;
        
        Color indicatorColor = isVerticalPhase 
            ? const Color(0xFFE8504E) 
            : const Color(0xFF00A2FF);
        
        return Positioned(
          left: x - 10,
          top: y - 10,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: indicatorColor, width: 3),
              boxShadow: [
                BoxShadow(
                  color: indicatorColor.withOpacity(0.5),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: indicatorColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildStuckDartWithScore(int score) {
    Color scoreColor = score >= 50 ? const Color(0xFFFFD700) : 
                       score >= 36 ? const Color(0xFF00A2FF) : 
                       score >= 20 ? const Color(0xFF9B59B6) : Colors.white;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Skor etiketi
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.85),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: scoreColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: scoreColor.withOpacity(0.4),
                blurRadius: 8,
              ),
            ],
          ),
          child: Text(
            '$score',
            style: TextStyle(
              color: scoreColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 3),
        // Dart
        SizedBox(
          width: 16,
          height: 28,
          child: CustomPaint(
            painter: StuckDartPainter(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildFlyingDart() {
    bool isMobile = screenWidth < 600;
    double dartWidth = isMobile ? 50 : 70;
    double dartHeight = isMobile ? 100 : 140;
    
    return SizedBox(
      width: dartWidth,
      height: dartHeight,
      child: CustomPaint(
        painter: FlyingDartPainter(),
      ),
    );
  }
  
  Widget _buildWaitingDartArea() {
    bool isMobile = screenWidth < 600;
    double dartAreaWidth = isMobile ? 80 : 120;
    double dartAreaHeight = isMobile ? 110 : 160;
    
    return Positioned(
      left: 0,
      right: 0,
      bottom: isMobile ? 12 : 25,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Talimat yazısı
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 14 : 18, 
              vertical: isMobile ? 5 : 7,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isVerticalPhase ? 'Dikey ayarla' : 'Yatay ayarla ve at!',
              style: TextStyle(
                color: Colors.white, 
                fontSize: isMobile ? 11 : 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: isMobile ? 8 : 12),
          // Dart ve el
          SizedBox(
            width: dartAreaWidth,
            height: dartAreaHeight,
            child: CustomPaint(
              painter: HandWithDartPainter(),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHelpButton() {
    bool isMobile = screenWidth < 600;
    double buttonSize = isMobile ? 36 : 44;
    
    return Positioned(
      left: isMobile ? 12 : 24,
      bottom: isMobile ? 24 : 44,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text('?', style: TextStyle(
            color: const Color(0xFF2D3436),
            fontSize: isMobile ? 20 : 24,
            fontWeight: FontWeight.bold,
          )),
        ),
      ),
    );
  }
}

// Parallax çizgili arka plan
class ParallaxLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    // Dikey çizgiler
    double spacing = size.width / 20;
    for (int i = 0; i <= 20; i++) {
      double x = i * spacing;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    
    // Ahşap zemin
    final floorPaint = Paint()
      ..color = const Color(0xFF8B7355).withOpacity(0.3);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.88, size.width, size.height * 0.12),
      floorPaint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Profesyonel dart tahtası - anti-aliasing ile
class ProfessionalDartboardPainter extends CustomPainter {
  static const segments = [20, 1, 18, 4, 13, 6, 10, 15, 2, 17, 3, 19, 7, 16, 8, 11, 14, 9, 12, 5];
  
  @override
  void paint(Canvas canvas, Size size) {
    // Anti-aliasing aktif
    canvas.save();
    
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    
    // Siyah çerçeve
    canvas.drawCircle(c, r, Paint()
      ..color = const Color(0xFF1A1A1A)
      ..isAntiAlias = true);
    
    final angle = math.pi * 2 / 20;
    
    for (int i = 0; i < 20; i++) {
      final start = -math.pi / 2 + i * angle - angle / 2;
      bool even = i % 2 == 0;
      
      // Double ring
      _drawSeg(canvas, c, r, start, angle, 0.88, 0.98, 
        even ? const Color(0xFFE53935) : const Color(0xFF2E7D32));
      // Outer single
      _drawSeg(canvas, c, r, start, angle, 0.42, 0.88, 
        even ? const Color(0xFF1A1A1A) : const Color(0xFFF5DEB3));
      // Triple ring
      _drawSeg(canvas, c, r, start, angle, 0.35, 0.42, 
        even ? const Color(0xFFE53935) : const Color(0xFF2E7D32));
      // Inner single
      _drawSeg(canvas, c, r, start, angle, 0.065, 0.35, 
        even ? const Color(0xFF1A1A1A) : const Color(0xFFF5DEB3));
    }
    
    // Outer bull
    canvas.drawCircle(c, r * 0.065, Paint()
      ..color = const Color(0xFF2E7D32)
      ..isAntiAlias = true);
    // Inner bull
    canvas.drawCircle(c, r * 0.025, Paint()
      ..color = const Color(0xFFE53935)
      ..isAntiAlias = true);
    
    // Tel çizgiler - smooth stroke
    final wire = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..isAntiAlias = true;
    
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
    
    // Sayılar - gölgeli
    for (int i = 0; i < 20; i++) {
      final a = -math.pi / 2 + i * angle;
      final tp = TextPainter(
        text: TextSpan(
          text: '${segments[i]}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1)),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      final pos = Offset(
        c.dx + math.cos(a) * r * 0.78 - tp.width / 2,
        c.dy + math.sin(a) * r * 0.78 - tp.height / 2,
      );
      tp.paint(canvas, pos);
    }
    
    canvas.restore();
  }
  
  void _drawSeg(Canvas canvas, Offset c, double r, double start, double sweep, 
      double inner, double outer, Color color) {
    final path = Path()
      ..moveTo(c.dx + math.cos(start) * r * inner, c.dy + math.sin(start) * r * inner)
      ..lineTo(c.dx + math.cos(start) * r * outer, c.dy + math.sin(start) * r * outer)
      ..arcTo(Rect.fromCircle(center: c, radius: r * outer), start, sweep, false)
      ..lineTo(c.dx + math.cos(start + sweep) * r * inner, c.dy + math.sin(start + sweep) * r * inner)
      ..arcTo(Rect.fromCircle(center: c, radius: r * inner), start + sweep, -sweep, false)
      ..close();
    canvas.drawPath(path, Paint()
      ..color = color
      ..isAntiAlias = true);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Tahtaya saplanmış dart
class StuckDartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    
    // Sivri uç (metal)
    final tipPath = Path()
      ..moveTo(cx, 0)
      ..lineTo(cx - 1.5, 6)
      ..lineTo(cx + 1.5, 6)
      ..close();
    canvas.drawPath(tipPath, Paint()
      ..color = const Color(0xFFB0B0B0)
      ..isAntiAlias = true);
    
    // Gövde (kırmızı)
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 3, 6, 6, 12),
      const Radius.circular(1),
    );
    canvas.drawRRect(bodyRect, Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
      ).createShader(Rect.fromLTWH(cx - 3, 6, 6, 12))
      ..isAntiAlias = true);
    
    // Küçük kanatlar
    canvas.drawLine(Offset(cx - 2, 16), Offset(cx - 5, 20), 
      Paint()..color = const Color(0xFFD32F2F)..strokeWidth = 2..strokeCap = StrokeCap.round);
    canvas.drawLine(Offset(cx + 2, 16), Offset(cx + 5, 20), 
      Paint()..color = const Color(0xFFD32F2F)..strokeWidth = 2..strokeCap = StrokeCap.round);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Uçan dart
class FlyingDartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final h = size.height;
    final w = size.width;
    
    // Sivri metal uç
    final tipPath = Path()
      ..moveTo(cx, 0)
      ..lineTo(cx - 5, h * 0.15)
      ..lineTo(cx + 5, h * 0.15)
      ..close();
    canvas.drawPath(tipPath, Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.grey.shade300, Colors.grey.shade600],
      ).createShader(Rect.fromLTWH(cx - 5, 0, 10, h * 0.15))
      ..isAntiAlias = true);
    
    // Metal highlight
    canvas.drawLine(Offset(cx - 1.5, 3), Offset(cx - 1.5, h * 0.12), 
      Paint()..color = Colors.white.withOpacity(0.7)..strokeWidth = 2);
    
    // Barrel
    final barrelRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 7, h * 0.15, 14, h * 0.18),
      const Radius.circular(3),
    );
    canvas.drawRRect(barrelRect, Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Colors.grey.shade700, Colors.grey.shade500, Colors.grey.shade700],
      ).createShader(Rect.fromLTWH(cx - 7, h * 0.15, 14, h * 0.18))
      ..isAntiAlias = true);
    
    // Barrel grip çizgileri
    for (int i = 0; i < 4; i++) {
      double y = h * 0.17 + i * (h * 0.035);
      canvas.drawLine(Offset(cx - 5, y), Offset(cx + 5, y),
        Paint()..color = Colors.black.withOpacity(0.5)..strokeWidth = 1.2);
    }
    
    // Shaft
    final shaftRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 5, h * 0.33, 10, h * 0.15),
      const Radius.circular(2),
    );
    canvas.drawRRect(shaftRect, Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Color(0xFFE53935), Color(0xFFB71C1C), Color(0xFFE53935)],
      ).createShader(Rect.fromLTWH(cx - 5, h * 0.33, 10, h * 0.15))
      ..isAntiAlias = true);
    
    // Kanatlar
    final wingPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
      ).createShader(Rect.fromLTWH(0, h * 0.48, w, h * 0.52))
      ..isAntiAlias = true;
    
    final wingStroke = Paint()
      ..color = const Color(0xFF8B0000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..isAntiAlias = true;
    
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// El ile dart tutan
class HandWithDartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final h = size.height;
    final w = size.width;
    
    // El
    final handPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFFE8C4A0), const Color(0xFFD4A574)],
      ).createShader(Rect.fromLTWH(0, h * 0.5, w, h * 0.5))
      ..isAntiAlias = true;
    
    final handPath = Path()
      ..moveTo(cx - 25, h)
      ..quadraticBezierTo(cx - 30, h * 0.75, cx - 20, h * 0.55)
      ..lineTo(cx - 8, h * 0.52)
      ..lineTo(cx + 8, h * 0.52)
      ..lineTo(cx + 20, h * 0.55)
      ..quadraticBezierTo(cx + 30, h * 0.75, cx + 25, h)
      ..close();
    canvas.drawPath(handPath, handPaint);
    
    canvas.drawPath(handPath, Paint()
      ..color = const Color(0xFFC4956A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..isAntiAlias = true);
    
    // Parmaklar
    final fingerPaint = Paint()
      ..color = const Color(0xFFE8C4A0)
      ..isAntiAlias = true;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx - 12, h * 0.42, 8, 25), const Radius.circular(4)),
      fingerPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx + 4, h * 0.42, 8, 25), const Radius.circular(4)),
      fingerPaint,
    );
    
    // Dart ucu
    final tipPath = Path()
      ..moveTo(cx, 0)
      ..lineTo(cx - 4, h * 0.12)
      ..lineTo(cx + 4, h * 0.12)
      ..close();
    canvas.drawPath(tipPath, Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.grey.shade300, Colors.grey.shade600],
      ).createShader(Rect.fromLTWH(cx - 4, 0, 8, h * 0.12))
      ..isAntiAlias = true);
    
    canvas.drawLine(Offset(cx - 1, 3), Offset(cx - 1, h * 0.10), 
      Paint()..color = Colors.white.withOpacity(0.7)..strokeWidth = 1.5);
    
    // Barrel
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx - 6, h * 0.12, 12, h * 0.15), const Radius.circular(3)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Colors.grey.shade700, Colors.grey.shade500, Colors.grey.shade700],
        ).createShader(Rect.fromLTWH(cx - 6, h * 0.12, 12, h * 0.15))
        ..isAntiAlias = true,
    );
    
    for (int i = 0; i < 4; i++) {
      double y = h * 0.14 + i * (h * 0.03);
      canvas.drawLine(Offset(cx - 4, y), Offset(cx + 4, y),
        Paint()..color = Colors.black.withOpacity(0.5)..strokeWidth = 1);
    }
    
    // Shaft
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx - 5, h * 0.27, 10, h * 0.18), const Radius.circular(2)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFE53935), Color(0xFFB71C1C), Color(0xFFE53935)],
        ).createShader(Rect.fromLTWH(cx - 5, h * 0.27, 10, h * 0.18))
        ..isAntiAlias = true,
    );
    
    // Kanatlar
    final wingPaint2 = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
      ).createShader(Rect.fromLTWH(0, h * 0.45, w, h * 0.15))
      ..isAntiAlias = true;
    
    final wingStroke2 = Paint()
      ..color = const Color(0xFF8B0000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..isAntiAlias = true;
    
    final leftTopW = Path()
      ..moveTo(cx - 4, h * 0.45)
      ..lineTo(cx - 35, h * 0.40)
      ..lineTo(cx - 30, h * 0.48)
      ..lineTo(cx - 4, h * 0.50)
      ..close();
    canvas.drawPath(leftTopW, wingPaint2);
    canvas.drawPath(leftTopW, wingStroke2);
    
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
