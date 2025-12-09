import 'package:flutter/material.dart';
import 'dart:math' as math;

class Dice3DCube extends StatefulWidget {
  final int value; // 1-6 final value
  final bool isRolling;
  final bool isActive;
  final VoidCallback? onTap;

  const Dice3DCube({
    Key? key,
    required this.value,
    this.isRolling = false,
    this.isActive = false,
    this.onTap,
  }) : super(key: key);

  @override
  State<Dice3DCube> createState() => _Dice3DCubeState();
}

class _Dice3DCubeState extends State<Dice3DCube> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  double _rx = 0, _ry = 0, _rz = 0;
  double _scale = 1.0;
  final _rand = math.Random();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);

    _ctrl.addListener(() {
      setState(() {});
    });

    _ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        // stay at final orientation
      }
    });
  }

  @override
  void didUpdateWidget(covariant Dice3DCube oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRolling && !_ctrl.isAnimating) {
      // start an animation to a random spin then land on face for widget.value
      _startSpinToValue(widget.value);
    }
  }

  void _startSpinToValue(int finalValue) {
    // choose random extra rotations
    final extraX = (1 + _rand.nextDouble() * 2) * math.pi; // 1pi .. 3pi
    final extraY = (1 + _rand.nextDouble() * 2) * math.pi;
    final extraZ = (0 + _rand.nextDouble() * 2) * math.pi;

    // target orientations so that a specific face is front
    final target = _orientationForFace(finalValue);

    final startRx = _rx;
    final startRy = _ry;
    final startRz = _rz;

    final endRx = target[0] + extraX;
    final endRy = target[1] + extraY;
    final endRz = target[2] + extraZ;

    // make the spin faster: halve the previous duration for ~2x speed
    _ctrl.duration = const Duration(milliseconds: 500);
    _ctrl.reset();

    // animate by updating rx/ry/rz each frame based on _anim.value
    _anim.removeListener(_onTick);
    _anim.addListener(_onTick);

    // store start/end for use in tick
    _tickStart = [startRx, startRy, startRz];
    _tickEnd = [endRx, endRy, endRz];

    _ctrl.forward(from: 0).whenComplete(() {
      // set final exact orientation (mod 2pi)
      _rx = target[0] % (math.pi * 2);
      _ry = target[1] % (math.pi * 2);
      _rz = target[2] % (math.pi * 2);
      _anim.removeListener(_onTick);
      setState(() {});
    });
  }

  late List<double> _tickStart;
  late List<double> _tickEnd;

  void _onTick() {
    final t = _anim.value;
    _rx = _lerp(_tickStart[0], _tickEnd[0], t);
    _ry = _lerp(_tickStart[1], _tickEnd[1], t);
    _rz = _lerp(_tickStart[2], _tickEnd[2], t);
    // Keep scale fixed while animating (no pulsing)
    _scale = 1.0;
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  List<double> _orientationForFace(int face) {
    // Return orientation (rx, ry, rz) so that the requested face is facing camera (front)
    // We'll define: 1 -> front, 2 -> right, 3 -> back, 4 -> left, 5 -> top, 6 -> bottom
    switch (face) {
      case 1:
        return [0, 0, 0];
      case 2:
        return [0, -math.pi / 2, 0];
      case 3:
        return [0, math.pi, 0];
      case 4:
        return [0, math.pi / 2, 0];
      case 5:
        return [-math.pi / 2, 0, 0];
      case 6:
        return [math.pi / 2, 0, 0];
      default:
        return [0, 0, 0];
    }
  }

  @override
  void dispose() {
    _anim.removeListener(_onTick);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Slightly smaller dice so they fit better on screen
    final size = 52.0;
    final perspective = 0.0032; // slightly stronger perspective
    return GestureDetector(
      onTap: widget.onTap,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()..setEntry(3, 2, perspective)..scale(_scale)..rotateX(_rx)..rotateY(_ry)..rotateZ(_rz),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // faces: front, right, back, left, top, bottom
            _buildFace(size, 1, faceTransform: Matrix4.identity()..translate(0.0, 0.0, size / 2)),
            _buildFace(size, 2, faceTransform: Matrix4.identity()..rotateY(-math.pi / 2)..translate(0.0, 0.0, size / 2)),
            _buildFace(size, 3, faceTransform: Matrix4.identity()..rotateY(math.pi)..translate(0.0, 0.0, size / 2)),
            _buildFace(size, 4, faceTransform: Matrix4.identity()..rotateY(math.pi / 2)..translate(0.0, 0.0, size / 2)),
            _buildFace(size, 5, faceTransform: Matrix4.identity()..rotateX(-math.pi / 2)..translate(0.0, 0.0, size / 2)),
            _buildFace(size, 6, faceTransform: Matrix4.identity()..rotateX(math.pi / 2)..translate(0.0, 0.0, size / 2)),
          ],
        ),
      ),
    );
  }

  Widget _buildFace(double size, int faceValue, {required Matrix4 faceTransform}) {
    return Transform(
      alignment: Alignment.center,
      transform: faceTransform,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // no outer fill - keep frame clean (avoid shadow blobs when rotating)
            SizedBox(width: size, height: size),
            // draw entire face (frame + inner face + pips) with a single painter
            CustomPaint(
              size: Size(size, size),
              painter: _DiceFacePainter(faceValue),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper painter for a face (draws pip dots)
class _DiceFacePainter extends CustomPainter {
  final int value;
  _DiceFacePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    // Simple, non-glossy face: solid black frame, white inner face, black pips.
    // Görseldeki gibi: kalın koyu gri çerçeve, kareye yakın köşe, büyük siyah pipler
    // Tuned to match the small thumbnail exactly: solid black frame, white inner face, pure black pips
    // Draw a fully opaque white face with a pure black border (no transparency, no gloss)
    final strokeW = size.width * 0.08; // border thickness
    final radius = size.width * 0.06; // small corner radius

    final faceRect = Rect.fromLTWH(0, 0, size.width, size.height);
    // white filled face (completely opaque)
    canvas.drawRRect(RRect.fromRectAndRadius(faceRect, Radius.circular(radius)), Paint()..color = Colors.white);
    // black border (stroke) around the white face
    canvas.drawRRect(
      RRect.fromRectAndRadius(faceRect.deflate(strokeW / 2), Radius.circular(radius)),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.black
        ..strokeWidth = strokeW,
    );

    // compute inner area where pips should be placed (inset by border)
    final innerRect = Rect.fromLTWH(strokeW, strokeW, size.width - strokeW * 2, size.height - strokeW * 2);

    // Pip ayarları (büyük, tam siyah, konumlar görsele göre)
    // Pip parameters: reduce pip radius and increase spacing so 6-face dots don't overlap
    final pipR = innerRect.width * 0.12;
    final cx = innerRect.left + innerRect.width / 2;
    final cy = innerRect.top + innerRect.height / 2;
    final off = innerRect.width * 0.30;

    List<Offset> positions = [];
    switch (value) {
      case 1:
        positions = [Offset(cx, cy)];
        break;
      case 2:
        positions = [Offset(cx - off, cy - off), Offset(cx + off, cy + off)];
        break;
      case 3:
        positions = [Offset(cx - off, cy - off), Offset(cx, cy), Offset(cx + off, cy + off)];
        break;
      case 4:
        positions = [Offset(cx - off, cy - off), Offset(cx + off, cy - off), Offset(cx - off, cy + off), Offset(cx + off, cy + off)];
        break;
      case 5:
        positions = [Offset(cx - off, cy - off), Offset(cx + off, cy - off), Offset(cx, cy), Offset(cx - off, cy + off), Offset(cx + off, cy + off)];
        break;
      case 6:
        positions = [Offset(cx - off, cy - off), Offset(cx + off, cy - off), Offset(cx - off, cy), Offset(cx + off, cy), Offset(cx - off, cy + off), Offset(cx + off, cy + off)];
        break;
      default:
        positions = [Offset(cx, cy)];
    }

    // pip color: pure black to match thumbnail
    final pipPaint = Paint()..color = Colors.black;
    for (final p in positions) {
      canvas.drawCircle(p, pipR, pipPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DiceFacePainter oldDelegate) => oldDelegate.value != value;
}
