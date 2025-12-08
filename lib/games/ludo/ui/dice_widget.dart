import 'package:flutter/material.dart';
import 'dart:math' as math;

class DiceWidget extends StatefulWidget {
  final int value;
  final bool isRolling;
  final VoidCallback? onTap;

  const DiceWidget({
    super.key,
    required this.value,
    this.isRolling = false,
    this.onTap,
  });

  @override
  State<DiceWidget> createState() => _DiceWidgetState();
}

class _DiceWidgetState extends State<DiceWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(DiceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRolling && !oldWidget.isRolling) {
      _controller.repeat();
    } else if (!widget.isRolling && oldWidget.isRolling) {
      _controller.stop();
      _controller.animateTo(1.0).then((_) => _controller.reset());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: widget.isRolling ? _rotationAnimation.value : 0,
            child: Transform.scale(
              scale: widget.isRolling ? _scaleAnimation.value : 1.0,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2C3E50), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CustomPaint(
                  painter: DiceDotsPainter(value: widget.value),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class DiceDotsPainter extends CustomPainter {
  final int value;

  DiceDotsPainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = const Color(0xFF2C3E50)
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = size.width * 0.08;
    final offset = size.width * 0.25;

    switch (value) {
      case 1:
        canvas.drawCircle(Offset(cx, cy), radius, dotPaint);
        break;
      case 2:
        canvas.drawCircle(Offset(cx - offset, cy - offset), radius, dotPaint);
        canvas.drawCircle(Offset(cx + offset, cy + offset), radius, dotPaint);
        break;
      case 3:
        canvas.drawCircle(Offset(cx - offset, cy - offset), radius, dotPaint);
        canvas.drawCircle(Offset(cx, cy), radius, dotPaint);
        canvas.drawCircle(Offset(cx + offset, cy + offset), radius, dotPaint);
        break;
      case 4:
        canvas.drawCircle(Offset(cx - offset, cy - offset), radius, dotPaint);
        canvas.drawCircle(Offset(cx + offset, cy - offset), radius, dotPaint);
        canvas.drawCircle(Offset(cx - offset, cy + offset), radius, dotPaint);
        canvas.drawCircle(Offset(cx + offset, cy + offset), radius, dotPaint);
        break;
      case 5:
        canvas.drawCircle(Offset(cx - offset, cy - offset), radius, dotPaint);
        canvas.drawCircle(Offset(cx + offset, cy - offset), radius, dotPaint);
        canvas.drawCircle(Offset(cx, cy), radius, dotPaint);
        canvas.drawCircle(Offset(cx - offset, cy + offset), radius, dotPaint);
        canvas.drawCircle(Offset(cx + offset, cy + offset), radius, dotPaint);
        break;
      case 6:
        canvas.drawCircle(Offset(cx - offset, cy - offset), radius, dotPaint);
        canvas.drawCircle(Offset(cx + offset, cy - offset), radius, dotPaint);
        canvas.drawCircle(Offset(cx - offset, cy), radius, dotPaint);
        canvas.drawCircle(Offset(cx + offset, cy), radius, dotPaint);
        canvas.drawCircle(Offset(cx - offset, cy + offset), radius, dotPaint);
        canvas.drawCircle(Offset(cx + offset, cy + offset), radius, dotPaint);
        break;
    }
  }

  @override
  bool shouldRepaint(DiceDotsPainter oldDelegate) => oldDelegate.value != value;
}
