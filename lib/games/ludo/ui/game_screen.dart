import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../models/game_mode.dart';
import 'ludo_board_renderer.dart';
import 'dice_3d_widget.dart';

class GameScreen extends StatefulWidget {
  final GameMode gameMode;
  final AIDifficulty? aiDifficulty;

  const GameScreen({
    super.key,
    required this.gameMode,
    this.aiDifficulty,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  int _playerDiceValue = 6;
  int _botDiceValue = 6;
  bool _isPlayerTurn = true;
  bool _isRolling = false;
  late AnimationController _diceController;
  late Animation<double> _rotationX;
  late Animation<double> _rotationY;
  late Animation<double> _rotationZ;
  late Animation<double> _scaleAnim;
  double _targetRotX = 0;
  double _targetRotY = 0;
  double _targetRotZ = 0;

  @override
  void initState() {
    super.initState();
    _diceController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _rotationX = Tween<double>(begin: 0, end: 0).animate(_diceController);
    _rotationY = Tween<double>(begin: 0, end: 0).animate(_diceController);
    _rotationZ = Tween<double>(begin: 0, end: 0).animate(_diceController);
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.0).animate(_diceController);
  }

  @override
  void dispose() {
    _diceController.dispose();
    super.dispose();
  }

  void _rollDice(bool isPlayer) {
    if (_isRolling) return;
    if (isPlayer != _isPlayerTurn) return;
    setState(() => _isRolling = true);
    // Her atışta rastgele bir açıya dönsün
    _targetRotX = math.pi * (1.5 + math.Random().nextDouble() * 2.5);
    _targetRotY = math.pi * (1.5 + math.Random().nextDouble() * 2.5);
    _targetRotZ = math.pi * (math.Random().nextDouble() * 2.0);
    _rotationX = Tween<double>(begin: 0, end: _targetRotX).animate(
      CurvedAnimation(parent: _diceController, curve: Curves.easeInOut)
    );
    _rotationY = Tween<double>(begin: 0, end: _targetRotY).animate(
      CurvedAnimation(parent: _diceController, curve: Curves.easeInOut)
    );
    _rotationZ = Tween<double>(begin: 0, end: _targetRotZ).animate(
      CurvedAnimation(parent: _diceController, curve: Curves.easeInOut)
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _diceController, curve: Curves.easeInOut)
    );
    _diceController.forward(from: 0);
    int rollCount = 0;
    void animateValue() {
      if (rollCount < 12) {
        setState(() {
          if (isPlayer) {
            _playerDiceValue = math.Random().nextInt(6) + 1;
          } else {
            _botDiceValue = math.Random().nextInt(6) + 1;
          }
        });
        rollCount++;
        Future.delayed(Duration(milliseconds: 50 + rollCount * 5), animateValue);
      } else {
        final finalValue = math.Random().nextInt(6) + 1;
        setState(() {
          if (isPlayer) {
            _playerDiceValue = finalValue;
          } else {
            _botDiceValue = finalValue;
          }
          _isRolling = false;
          if (finalValue != 6) {
            _isPlayerTurn = !_isPlayerTurn;
          }
        });
        if (!_isPlayerTurn) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted && !_isPlayerTurn) {
              _rollDice(false);
            }
          });
        }
      }
    }
    animateValue();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF87CEEB),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCircleButton(Icons.arrow_back, () => Navigator.pop(context)),
                  _buildScorePanel(),
                  _buildCircleButton(Icons.refresh, () {
                    setState(() {
                      _playerDiceValue = 1;
                      _botDiceValue = 1;
                      _isPlayerTurn = true;
                      _isRolling = false;
                    });
                  }),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  // Oyun tahtası
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: CustomPaint(
                          painter: LudoBoardRenderer(),
                          size: Size.infinite,
                        ),
                      ),
                    ),
                  ),
                  // Sol alt zar (Oyuncu)
                  Positioned(
                    left: 16,
                    bottom: 56, // bir tık yukarı
                    child: _buildDiceArea(
                      isPlayer: true,
                      value: _playerDiceValue,
                      isActive: _isPlayerTurn,
                    ),
                  ),
                  // Sağ üst zar (Bot)
                  Positioned(
                    right: 16,
                    top: 56, // bir tık aşağı
                    child: _buildDiceArea(
                      isPlayer: false,
                      value: _botDiceValue,
                      isActive: !_isPlayerTurn,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiceArea({
    required bool isPlayer,
    required int value,
    required bool isActive,
  }) {
    final isThisDiceRolling = _isRolling && (isPlayer == _isPlayerTurn);
    int displayValue = value;
    if (isThisDiceRolling) {
      // Animasyon sırasında her frame'de rastgele bir yüz göster
      displayValue = math.Random().nextInt(6) + 1;
    }
    return GestureDetector(
      onTap: isActive && !_isRolling ? () => _rollDice(isPlayer) : null,
      child: AnimatedBuilder(
        animation: _diceController,
        builder: (context, child) {
          final rotX = isThisDiceRolling ? _rotationX.value : 0.0;
          final rotY = isThisDiceRolling ? _rotationY.value : 0.0;
          final rotZ = isThisDiceRolling ? _rotationZ.value : 0.0;
          final scale = isThisDiceRolling ? _scaleAnim.value : 1.0;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.002)
              ..rotateX(rotX)
              ..rotateY(rotY)
              ..rotateZ(rotZ)
              ..scale(scale),
            child: child,
          );
        },
        child: Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFFFFF),
                Color(0xFFF5F5F5),
                Color(0xFFE8E8E8),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isActive 
                ? (isPlayer ? Colors.red : Colors.cyan)
                : Colors.grey.shade300,
              width: isActive ? 3 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(2, 4),
              ),
              if (isActive)
                BoxShadow(
                  color: (isPlayer ? Colors.red : Colors.cyan).withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: Dice3DCube(
            value: displayValue,
            isRolling: isThisDiceRolling,
            isActive: isActive,
            onTap: isActive && !_isRolling ? () => _rollDice(isPlayer) : null,
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFFE91E63), size: 24),
      ),
    );
  }

  Widget _buildScorePanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF455A64),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            children: [
              Text('YOU', style: TextStyle(color: Colors.red[400], fontSize: 12, fontWeight: FontWeight.bold)),
              Text('0', style: TextStyle(color: Colors.red[400], fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Text(
                  widget.aiDifficulty?.name.toUpperCase() ?? 'HARD',
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
                const Text('VS', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Column(
            children: [
              Text('BOT', style: TextStyle(color: Colors.cyan[300], fontSize: 12, fontWeight: FontWeight.bold)),
              Text('0', style: TextStyle(color: Colors.cyan[300], fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

// 3D Zar Painter - Modern görünüm
class Dice3DPainter extends CustomPainter {
  final int value;
  
  Dice3DPainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final offset = size.width * 0.26;
    final dotRadius = size.width * 0.095;

    final positions = <Offset>[];
    
    switch (value) {
      case 1:
        positions.add(center);
        break;
      case 2:
        positions.add(Offset(center.dx - offset, center.dy - offset));
        positions.add(Offset(center.dx + offset, center.dy + offset));
        break;
      case 3:
        positions.add(Offset(center.dx - offset, center.dy - offset));
        positions.add(center);
        positions.add(Offset(center.dx + offset, center.dy + offset));
        break;
      case 4:
        positions.add(Offset(center.dx - offset, center.dy - offset));
        positions.add(Offset(center.dx + offset, center.dy - offset));
        positions.add(Offset(center.dx - offset, center.dy + offset));
        positions.add(Offset(center.dx + offset, center.dy + offset));
        break;
      case 5:
        positions.add(Offset(center.dx - offset, center.dy - offset));
        positions.add(Offset(center.dx + offset, center.dy - offset));
        positions.add(center);
        positions.add(Offset(center.dx - offset, center.dy + offset));
        positions.add(Offset(center.dx + offset, center.dy + offset));
        break;
      case 6:
        positions.add(Offset(center.dx - offset, center.dy - offset));
        positions.add(Offset(center.dx + offset, center.dy - offset));
        positions.add(Offset(center.dx - offset, center.dy));
        positions.add(Offset(center.dx + offset, center.dy));
        positions.add(Offset(center.dx - offset, center.dy + offset));
        positions.add(Offset(center.dx + offset, center.dy + offset));
        break;
    }

    for (final pos in positions) {
      // Nokta gölgesi
      canvas.drawCircle(
        Offset(pos.dx + 1.5, pos.dy + 1.5),
        dotRadius,
        Paint()..color = Colors.black.withValues(alpha: 0.3),
      );
      
      // Ana nokta - gradient
      final dotGradient = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: [
          const Color(0xFF444444),
          const Color(0xFF1a1a1a),
          Colors.black,
        ],
        stops: const [0.0, 0.5, 1.0],
      );
      
      canvas.drawCircle(
        pos,
        dotRadius,
        Paint()..shader = dotGradient.createShader(
          Rect.fromCircle(center: pos, radius: dotRadius),
        ),
      );
      
      // Nokta üst parlama
      canvas.drawCircle(
        Offset(pos.dx - dotRadius * 0.25, pos.dy - dotRadius * 0.25),
        dotRadius * 0.35,
        Paint()..color = Colors.white.withValues(alpha: 0.4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant Dice3DPainter oldDelegate) => oldDelegate.value != value;
}
