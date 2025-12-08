import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart_game_mode.dart';

Color _alpha(Color color, double opacity) =>
  color.withAlpha((opacity.clamp(0.0, 1.0) * 255).round());

class ModernDartScreen extends StatefulWidget {
  final DartGameMode mode;
  const ModernDartScreen({super.key, this.mode = DartGameMode.practice});

  @override
  State<ModernDartScreen> createState() => _ModernDartScreenState();
}

class _ModernDartScreenState extends State<ModernDartScreen>
    with TickerProviderStateMixin {
  int player1Score = 501;
  int player2Score = 501;
  int currentPlayer = 1;
  List<int> currentRound = [];
  List<DartLanding> landings = [];
  Color boardMainColor = const Color(0xFF0F141C);
  Color dartMainColor = const Color(0xFFE53935);
  Color accentColor = Colors.amber;
  Color accentSecondary = const Color(0xFF4CAF50);

  late AnimationController _aimController;
  late AnimationController _throwController;
  late AnimationController _impactController;
  late AnimationController _celebrationController;

  bool _isThrown = false;
  Offset? _targetPoint;
  Offset? _landedPoint;
  String? _celebrationText;
  List<Particle> _particles = [];

  final List<_ThemePalette> _palettes = const [
    _ThemePalette(
      name: 'Gece',
      board: Color(0xFF0F141C),
      dart: Color(0xFFE53935),
      accent: Color(0xFFFFC107),
      accent2: Color(0xFF4CAF50),
    ),
    _ThemePalette(
      name: 'Deniz',
      board: Color(0xFF0C1B29),
      dart: Color(0xFF00B4D8),
      accent: Color(0xFF48CAE4),
      accent2: Color(0xFF90E0EF),
    ),
    _ThemePalette(
      name: 'Gün Batımı',
      board: Color(0xFF1B0B19),
      dart: Color(0xFFFF6B6B),
      accent: Color(0xFFFFB347),
      accent2: Color(0xFFFFD166),
    ),
  ];

  late Offset boardCenter;
  late double boardRadius;
  Offset _aimPos = Offset.zero;

  @override
  void initState() {
    super.initState();

    _aimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    _throwController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _onDartLanded();
        }
      });

    _impactController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
  }

  @override
  void dispose() {
    _aimController.dispose();
    _throwController.dispose();
    _impactController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  void _onScreenTap(Offset pos) {
    if (_isThrown) return;

    _targetPoint = pos;
    _isThrown = true;
    HapticFeedback.mediumImpact();
    _throwController.forward(from: 0);
    setState(() {});
  }

  void _onDartLanded() {
    if (_targetPoint == null) return;

    final score = _calculateScore(_targetPoint!);
    final multiplier = _getMultiplier(_targetPoint!);
    final finalScore = score * multiplier;

    setState(() {
      _landedPoint = _targetPoint;
      currentRound.add(finalScore);
      landings.add(DartLanding(_targetPoint!, finalScore, multiplier));
    });

    _impactController.forward(from: 0);
    HapticFeedback.heavyImpact();

    if (multiplier == 3) {
      _showCelebration('TRIPLE ×3', Colors.amber[300]!);
    } else if (multiplier == 2) {
      _showCelebration('DOUBLE ×2', Colors.orange[300]!);
    } else if (score == 50) {
      _showCelebration('BULLSEYE', Colors.red[300]!);
    }

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        _updateScore(finalScore);
      }
    });
  }

  void _showCelebration(String text, Color color) {
    setState(() {
      _celebrationText = text;
      _particles = List.generate(28, (i) {
        final angle = (i / 28) * math.pi * 2;
        final speed = 180 + math.Random().nextDouble() * 160;
        return Particle(
          position: _landedPoint ?? boardCenter,
          velocity: Offset(
            math.cos(angle) * speed,
            math.sin(angle) * speed,
          ),
          color: color,
          size: 3 + math.Random().nextDouble() * 3,
        );
      });
    });

    _celebrationController.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      setState(() {
        _celebrationText = null;
        _particles.clear();
      });
    });
  }

  void _openThemePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _alpha(boardMainColor, 0.95),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tema seç', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white)),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _palettes.map((p) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        boardMainColor = p.board;
                        dartMainColor = p.dart;
                        accentColor = p.accent;
                        accentSecondary = p.accent2;
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 120,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _alpha(p.board, 0.9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                        boxShadow: [
                          BoxShadow(color: _alpha(Colors.black, 0.25), blurRadius: 10, offset: const Offset(0, 6)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _colorDot(p.board),
                              _colorDot(p.dart),
                              _colorDot(p.accent),
                              _colorDot(p.accent2),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _colorDot(Color color) {
    return Container(
      width: 22,
      height: 22,
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.4),
      ),
    );
  }

  void _updateScore(int score) {
    if (!mounted) return;
    setState(() {
      if (currentPlayer == 1) {
        player1Score = (player1Score - score).clamp(0, 501);
      } else {
        player2Score = (player2Score - score).clamp(0, 501);
      }

      if (currentRound.length >= 3) {
        currentPlayer = currentPlayer == 1 ? 2 : 1;
        currentRound.clear();
      }

      _isThrown = false;
      _targetPoint = null;
      _landedPoint = null;
    });
  }

  int _calculateScore(Offset pos) {
    final dx = pos.dx - boardCenter.dx;
    final dy = pos.dy - boardCenter.dy;
    final distance = math.sqrt(dx * dx + dy * dy) / boardRadius;
    final angle = (math.atan2(dy, dx) + math.pi) / (math.pi * 2);

    if (distance < 0.04) return 50;
    if (distance < 0.09) return 25;
    if (distance > 1.02) return 0;

    const sectors = [
      20, 1, 18, 4, 13, 6, 10, 15, 2, 17,
      3, 19, 7, 16, 8, 11, 14, 9, 12, 5
    ];
    final sectorIndex = ((angle + 1 / 40) * 20).floor() % 20;
    return sectors[sectorIndex];
  }

  int _getMultiplier(Offset pos) {
    final dx = pos.dx - boardCenter.dx;
    final dy = pos.dy - boardCenter.dy;
    final dist = math.sqrt(dx * dx + dy * dy) / boardRadius;

    if (dist >= 0.56 && dist <= 0.63) return 3;
    if (dist >= 0.95 && dist <= 1.02) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    boardRadius = math.min(size.width, size.height - 140) * 0.42;
    boardCenter = Offset(size.width / 2, (size.height + padding.top) / 2);

    if (!_isThrown) {
      final aimAngle = _aimController.value * math.pi * 2;
      final aimRadius = boardRadius * 0.7;
      _aimPos = Offset(
        boardCenter.dx + math.cos(aimAngle) * aimRadius,
        boardCenter.dy + math.sin(aimAngle) * aimRadius,
      );
    }

    return Scaffold(
      backgroundColor: boardMainColor,
      body: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) => _onScreenTap(details.localPosition),
              child: CustomPaint(
                painter: GameBoardPainter(
                  boardCenter: boardCenter,
                  boardRadius: boardRadius,
                  landings: landings,
                  mainColor: boardMainColor,
                  accentColor: accentColor,
                  accentSecondary: accentSecondary,
                  dartColor: dartMainColor,
                ),
                child: const SizedBox.expand(),
              ),
            ),

            if (!_isThrown) _buildAimReticle(),

            if (_isThrown) _buildDartFlight(size),

            if (_particles.isNotEmpty)
              CustomPaint(
                painter: ParticlePainter(
                  particles: _particles,
                  progress: _celebrationController.value,
                ),
                child: const SizedBox.expand(),
              ),

            if (_celebrationText != null) _buildCelebrationText(),

            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: _buildScorePanel(),
            ),

            Positioned(
              bottom: 18,
              left: 16,
              child: _buildShotsCard(),
            ),
            Positioned(
              top: 16,
              right: 18,
              child: IconButton(
                icon: const Icon(Icons.palette_rounded, color: Colors.white, size: 28),
                tooltip: 'Tema seç',
                onPressed: _openThemePicker,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAimReticle() {
    return Positioned(
      left: _aimPos.dx - 30,
      top: _aimPos.dy - 30,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: accentColor, width: 2.4),
          boxShadow: [
            BoxShadow(
              color: _alpha(accentColor, 0.45),
              blurRadius: 12,
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDartFlight(Size size) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _throwController,
        _impactController,
      ]),
      builder: (context, child) {
        final t = Curves.easeOutQuad.transform(_throwController.value);
        final startPos = Offset(size.width / 2, size.height + 60);
        final target = _targetPoint ?? boardCenter;
        final flightPos = Offset.lerp(startPos, target, t) ?? startPos;

        double wobbleX = 0;
        if (_impactController.isAnimating) {
          wobbleX = math.sin(_impactController.value * math.pi * 6) * 3;
        }

        return Positioned(
          left: flightPos.dx - 13 + wobbleX,
          top: flightPos.dy - 90,
          child: DartWidget(color: dartMainColor),
        );
      },
    );
  }

  Widget _buildCelebrationText() {
    return Center(
      child: AnimatedBuilder(
        animation: _celebrationController,
        builder: (context, child) {
          final scale = 1 + (_celebrationController.value * 0.35);
          final opacity = 1 - _celebrationController.value;
          return Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: Text(
                _celebrationText ?? '',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.amber[300],
                  shadows: [
                    BoxShadow(
                      color: _alpha(Colors.black, 0.7),
                      blurRadius: 14,
                      spreadRadius: 4,
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

  Widget _buildScorePanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _alpha(const Color(0xFF1A202C), 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: _alpha(Colors.black, 0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _playerScoreTile('P1', player1Score, currentPlayer == 1),
          const SizedBox(width: 12),
          _roundSummary(),
          const SizedBox(width: 12),
          _playerScoreTile(
            widget.mode == DartGameMode.practice ? 'GHOST' : 'P2',
            player2Score,
            currentPlayer == 2,
          ),
        ],
      ),
    );
  }

  Widget _playerScoreTile(String label, int score, bool isActive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.amber : Colors.white70,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          score.toString(),
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white70,
            fontSize: 34,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }

  Widget _roundSummary() {
    final total = currentRound.fold<int>(0, (a, b) => a + b);
    return Column(
      children: [
        Text(
          'Round ${currentRound.length}/3',
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '+$total',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildShotsCard() {
    final total = currentRound.fold<int>(0, (a, b) => a + b);
    return Container(
      width: 170,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _alpha(const Color(0xFF1F1A19), 0.9),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _alpha(Colors.black, 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Throws',
            style: TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(3, (i) {
            final has = i < currentRound.length;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: has ? Colors.white24 : Colors.white10,
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    has ? currentRound[i].toString() : '-',
                    style: TextStyle(
                      color: has ? Colors.white : Colors.white38,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Total: $total',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// DRAWING
// ============================================================================

class GameBoardPainter extends CustomPainter {
  final Offset boardCenter;
  final double boardRadius;
  final List<DartLanding> landings;
  final Color mainColor;
  final Color accentColor;
  final Color accentSecondary;
  final Color dartColor;

  GameBoardPainter({
    required this.boardCenter,
    required this.boardRadius,
    required this.landings,
    required this.mainColor,
    required this.accentColor,
    required this.accentSecondary,
    required this.dartColor,
  });

  static const double doubleOuterR = 1.02;
  static const double doubleInnerR = 0.95;
  static const double tripleOuterR = 0.63;
  static const double tripleInnerR = 0.56;
  static const double outerBullR = 0.09;
  static const double innerBullR = 0.04;

  @override
  void paint(Canvas canvas, Size size) {
    const sectors = [20, 1, 18, 4, 13, 6, 10, 15, 2, 17, 3, 19, 7, 16, 8, 11, 14, 9, 12, 5];
    final segmentAngle = math.pi * 2 / 20;

    canvas.drawRect(Offset.zero & size, Paint()..color = mainColor);

    canvas.drawCircle(
      boardCenter,
      boardRadius * 1.08,
      Paint()
        ..color = _alpha(mainColor, 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    canvas.drawCircle(boardCenter, boardRadius * 1.02, Paint()..color = mainColor);
    canvas.drawCircle(
      boardCenter,
      boardRadius * 1.02,
      Paint()
        ..color = _alpha(accentColor, 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    for (var i = 0; i < 20; i++) {
      final start = (i - 0.5) * segmentAngle - math.pi / 2;
      final isDark = i.isEven;
      final baseColor = isDark
          ? _shift(mainColor, -0.28)
          : Color.lerp(mainColor, Colors.white, 0.82) ?? Colors.white;
      _drawBand(canvas, start, segmentAngle, 0, tripleInnerR, baseColor);
    }

    for (var i = 0; i < 20; i++) {
      final start = (i - 0.5) * segmentAngle - math.pi / 2;
      final isRed = i.isEven;
      final color = isRed ? accentColor : accentSecondary;
      _drawBand(canvas, start, segmentAngle, tripleInnerR, tripleOuterR, color);
    }

    for (var i = 0; i < 20; i++) {
      final start = (i - 0.5) * segmentAngle - math.pi / 2;
      final isDark = i.isEven;
      final baseColor = isDark
          ? _shift(mainColor, -0.28)
          : Color.lerp(mainColor, Colors.white, 0.82) ?? Colors.white;
      _drawBand(canvas, start, segmentAngle, tripleOuterR, doubleInnerR, baseColor);
    }

    for (var i = 0; i < 20; i++) {
      final start = (i - 0.5) * segmentAngle - math.pi / 2;
      final isRed = i.isEven;
      final color = isRed ? accentColor : accentSecondary;
      _drawBand(canvas, start, segmentAngle, doubleInnerR, doubleOuterR, color);
    }

    final wire = Paint()
      ..color = _alpha(Colors.black, 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    for (var i = 0; i < 20; i++) {
      final angle = (i - 0.5) * segmentAngle - math.pi / 2;
      canvas.drawLine(
        Offset(
          boardCenter.dx + math.cos(angle) * boardRadius * 0.04,
          boardCenter.dy + math.sin(angle) * boardRadius * 0.04,
        ),
        Offset(
          boardCenter.dx + math.cos(angle) * boardRadius * doubleOuterR,
          boardCenter.dy + math.sin(angle) * boardRadius * doubleOuterR,
        ),
        wire,
      );
    }
    canvas.drawCircle(boardCenter, boardRadius * tripleInnerR, wire);
    canvas.drawCircle(boardCenter, boardRadius * tripleOuterR, wire);
    canvas.drawCircle(boardCenter, boardRadius * doubleInnerR, wire);
    canvas.drawCircle(boardCenter, boardRadius * doubleOuterR, wire);

    canvas.drawCircle(
      boardCenter,
      boardRadius * outerBullR,
      Paint()..color = accentSecondary,
    );
    canvas.drawCircle(
      boardCenter,
      boardRadius * innerBullR,
      Paint()..color = accentColor,
    );
    canvas.drawCircle(boardCenter, boardRadius * innerBullR, wire);
    canvas.drawCircle(boardCenter, boardRadius * outerBullR, wire..color = _alpha(Colors.black, 0.35));

    for (var i = 0; i < 20; i++) {
      final angle = i * segmentAngle - math.pi / 2;
      final pos = Offset(
        boardCenter.dx + math.cos(angle) * boardRadius * 1.08,
        boardCenter.dy + math.sin(angle) * boardRadius * 1.08,
      );
      _drawText(
        canvas,
        sectors[i].toString(),
        pos,
        TextStyle(
          color: Color.lerp(accentColor, Colors.white, 0.85),
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.6,
        ),
      );
    }

    for (final landing in landings) {
      _drawLandedDart(canvas, landing.position);
    }
  }

  void _drawBand(Canvas canvas, double start, double sweep, double innerR, double outerR, Color color) {
    final path = Path()
      ..arcTo(
        Rect.fromCircle(center: boardCenter, radius: boardRadius * outerR),
        start,
        sweep,
        true,
      )
      ..arcTo(
        Rect.fromCircle(center: boardCenter, radius: boardRadius * innerR),
        start + sweep,
        -sweep,
        false,
      )
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawLandedDart(Canvas canvas, Offset pos) {
    final paint = Paint()..strokeCap = StrokeCap.round;

    paint.color = dartColor;
    paint.strokeWidth = 3;
    canvas.drawLine(
      Offset(pos.dx, pos.dy - 32),
      pos,
      paint,
    );

    paint.color = _alpha(Colors.white, 0.25);
    paint.strokeWidth = 1.1;
    canvas.drawLine(
      Offset(pos.dx - 1, pos.dy - 28),
      Offset(pos.dx - 1, pos.dy - 10),
      paint,
    );

    paint.color = accentColor;
    canvas.drawPath(
      Path()
        ..moveTo(pos.dx, pos.dy - 24)
        ..lineTo(pos.dx - 7, pos.dy - 16)
        ..lineTo(pos.dx, pos.dy - 18)
        ..close(),
      paint,
    );
    paint.color = accentSecondary;
    canvas.drawPath(
      Path()
        ..moveTo(pos.dx, pos.dy - 24)
        ..lineTo(pos.dx + 7, pos.dy - 16)
        ..lineTo(pos.dx, pos.dy - 18)
        ..close(),
      paint,
    );

    paint.color = Color.lerp(accentColor, Colors.white, 0.4) ?? accentColor;
    canvas.drawPath(
      Path()
        ..moveTo(pos.dx, pos.dy - 32)
        ..lineTo(pos.dx - 2, pos.dy - 28)
        ..lineTo(pos.dx + 2, pos.dy - 28)
        ..close(),
      paint,
    );

    canvas.drawCircle(pos, 2.2, Paint()..color = _alpha(Colors.white, 0.8));
  }

  void _drawText(Canvas canvas, String text, Offset pos, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  Color _shift(Color color, double delta) {
    final hsl = HSLColor.fromColor(color);
    final l = (hsl.lightness + delta).clamp(0.0, 1.0);
    return hsl.withLightness(l).toColor();
  }

  @override
  bool shouldRepaint(GameBoardPainter oldDelegate) =>
      oldDelegate.landings.length != landings.length ||
      oldDelegate.mainColor != mainColor ||
      oldDelegate.accentColor != accentColor ||
      oldDelegate.accentSecondary != accentSecondary ||
      oldDelegate.dartColor != dartColor;
}

class DartWidget extends StatelessWidget {
  final Color color;
  const DartWidget({super.key, this.color = const Color(0xFFE53935)});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DartPainter(color: color),
      size: const Size(26, 118),
    );
  }
}

class _DartPainter extends CustomPainter {
  final Color color;
  _DartPainter({this.color = const Color(0xFFE53935)});
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final paint = Paint()..strokeCap = StrokeCap.round;

    paint.color = color;
    paint.strokeWidth = 3.2;
    canvas.drawLine(
      Offset(centerX, size.height * 0.12),
      Offset(centerX, size.height * 0.92),
      paint,
    );

    paint.color = _alpha(Colors.white, 0.25);
    paint.strokeWidth = 1.2;
    canvas.drawLine(
      Offset(centerX - 1, size.height * 0.2),
      Offset(centerX - 1, size.height * 0.7),
      paint,
    );

    paint.color = Colors.white;
    paint.strokeWidth = 1;
    canvas.drawCircle(Offset(centerX, size.height * 0.5), 3, paint);

    paint.color = const Color(0xFF1976D2);
    canvas.drawPath(
      Path()
        ..moveTo(centerX, size.height * 0.76)
        ..lineTo(centerX - 7, size.height * 0.88)
        ..lineTo(centerX, size.height * 0.83)
        ..close(),
      paint,
    );
    paint.color = const Color(0xFFFDD835);
    canvas.drawPath(
      Path()
        ..moveTo(centerX, size.height * 0.76)
        ..lineTo(centerX + 7, size.height * 0.88)
        ..lineTo(centerX, size.height * 0.83)
        ..close(),
      paint,
    );

    paint.color = const Color(0xFFFFC107);
    canvas.drawPath(
      Path()
        ..moveTo(centerX, 0)
        ..lineTo(centerX - 2, size.height * 0.10)
        ..lineTo(centerX + 2, size.height * 0.10)
        ..close(),
      paint,
    );
    paint.color = const Color(0xFFB8860B);
    canvas.drawPath(
      Path()
        ..moveTo(centerX + 2, size.height * 0.10)
        ..lineTo(centerX + 1, size.height * 0.14)
        ..lineTo(centerX, size.height * 0.12)
        ..close(),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;

  ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const gravity = 500.0;

    for (final p in particles) {
      final pos = Offset(
        p.position.dx + p.velocity.dx * progress,
        p.position.dy +
            p.velocity.dy * progress +
            0.5 * gravity * progress * progress,
      );

      final opacity = ((1 - progress).clamp(0, 1) as double);
      final paint = Paint()..color = _alpha(p.color, opacity);

      canvas.drawCircle(pos, p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DartLanding {
  final Offset position;
  final int score;
  final int multiplier;

  DartLanding(this.position, this.score, this.multiplier);
}

class Particle {
  final Offset position;
  final Offset velocity;
  final Color color;
  final double size;

  Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
  });
}

class _ThemePalette {
  final String name;
  final Color board;
  final Color dart;
  final Color accent;
  final Color accent2;

  const _ThemePalette({
    required this.name,
    required this.board,
    required this.dart,
    required this.accent,
    required this.accent2,
  });
}
