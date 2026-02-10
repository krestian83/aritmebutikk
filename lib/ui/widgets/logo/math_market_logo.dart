import 'dart:math';

import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

/// Animated shopping-cart logo with bouncing number balls.
class MathMarketLogo extends StatefulWidget {
  final double size;

  const MathMarketLogo({super.key, this.size = 120});

  @override
  State<MathMarketLogo> createState() => _MathMarketLogoState();
}

class _MathMarketLogoState extends State<MathMarketLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        return CustomPaint(
          size: Size(widget.size, widget.size * 0.83),
          painter: _LogoPainter(progress: _ctrl.value),
        );
      },
    );
  }
}

class _LogoPainter extends CustomPainter {
  final double progress;

  _LogoPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 120;
    final t = progress * 2 * pi;

    // Cart tremble offset (integer freqs for seamless loop).
    final trembleX = sin(t * 2) * 0.6 * s;
    final trembleY = cos(t * 3) * 0.4 * s;

    canvas.save();
    canvas.translate(trembleX, trembleY);

    _drawCart(canvas, s);
    _drawWheels(canvas, s, t);

    canvas.restore();

    // Each ball uses two integer freqs (dx, dy) for seamless loop.
    _drawBall(canvas, s, t, 54, 48, 13, AppColors.menuTeal, '7', 3, 2);
    _drawBall(canvas, s, t, 78, 44, 13, AppColors.menuOrange, '3', 2, 3);
    _drawBall(
      canvas, s, t, 66, 62, 11, AppColors.menuTeal, '\u00D7', 4, 3,
      opacity: 0.7,
    );

    _drawSparkles(canvas, s, t);
    _drawStar(canvas, s, t);
  }

  void _drawCart(Canvas canvas, double s) {
    final paint = Paint()
      ..color = AppColors.menuTeal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(22 * s, 30 * s)
      ..lineTo(30 * s, 30 * s)
      ..lineTo(42 * s, 72 * s)
      ..lineTo(88 * s, 72 * s)
      ..lineTo(98 * s, 42 * s)
      ..lineTo(38 * s, 42 * s);

    canvas.drawPath(path, paint);
  }

  void _drawWheels(Canvas canvas, double s, double t) {
    final dx = sin(t * 2) * 0.5 * s;
    final paint = Paint()..color = AppColors.menuOrange;
    canvas.drawCircle(Offset(48 * s + dx, 84 * s), 7 * s, paint);
    canvas.drawCircle(Offset(82 * s + dx, 84 * s), 7 * s, paint);
  }

  void _drawBall(
    Canvas canvas,
    double s,
    double t,
    double cx,
    double cy,
    double r,
    Color color,
    String label,
    int freqX,
    int freqY, {
    double opacity = 0.9,
  }) {
    final dx = sin(t * freqX) * 1.0 * s;
    final dy = cos(t * freqY) * 2.5 * s;

    final x = cx * s + dx;
    final y = cy * s + dy;
    final rs = r * s;

    final paint = Paint()..color = color.withValues(alpha: opacity);
    canvas.drawCircle(Offset(x, y), rs, paint);

    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 16 * s,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  void _drawSparkles(Canvas canvas, double s, double t) {
    void sparkle(double cx, double cy, double r, Color c, int freq) {
      final v = 0.5 + 0.5 * sin(t * freq);
      final a = 0.2 + 0.3 * v;
      final sc = 0.7 + 0.3 * v;
      final paint = Paint()..color = c.withValues(alpha: a);
      canvas.drawCircle(Offset(cx * s, cy * s), r * s * sc, paint);
    }

    sparkle(100, 28, 3, AppColors.menuOrange, 3);
    sparkle(16, 60, 2.5, AppColors.menuTeal, 2);
    sparkle(106, 52, 2, AppColors.menuTeal, 4);
  }

  void _drawStar(Canvas canvas, double s, double t) {
    final a = 0.2 + 0.3 * (0.5 + 0.5 * sin(t * 2));
    final paint = Paint()..color = AppColors.menuOrange.withValues(alpha: a);

    final path = Path()
      ..moveTo(94 * s, 18 * s)
      ..lineTo(96 * s, 12 * s)
      ..lineTo(98 * s, 18 * s)
      ..lineTo(104 * s, 20 * s)
      ..lineTo(98 * s, 22 * s)
      ..lineTo(96 * s, 28 * s)
      ..lineTo(94 * s, 22 * s)
      ..lineTo(88 * s, 20 * s)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_LogoPainter old) => old.progress != progress;
}
