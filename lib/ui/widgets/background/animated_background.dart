import 'dart:math';

import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

/// A floating shape for the background animation.
class _FloatingShape {
  double x;
  double y;
  double size;
  double speed;
  double angle;
  double rotationSpeed;
  double rotation;
  Color color;
  bool isTriangle;

  _FloatingShape({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.angle,
    required this.rotationSpeed,
    required this.rotation,
    required this.color,
    required this.isTriangle,
  });
}

/// Animated pastel gradient background with floating shapes.
class AnimatedBackground extends StatefulWidget {
  final Widget child;

  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_FloatingShape> _shapes;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();

    _shapes = List.generate(8, (_) => _createShape());
  }

  _FloatingShape _createShape() {
    final colors = [
      AppColors.shapeCyan.withValues(alpha: 0.4),
      AppColors.shapeOrange.withValues(alpha: 0.3),
      AppColors.shapeBlue.withValues(alpha: 0.35),
      AppColors.neonCyan.withValues(alpha: 0.2),
      AppColors.orange.withValues(alpha: 0.25),
    ];
    return _FloatingShape(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      size: 12 + _random.nextDouble() * 30,
      speed: 0.02 + _random.nextDouble() * 0.04,
      angle: _random.nextDouble() * 2 * pi,
      rotationSpeed: 0.5 + _random.nextDouble() * 2,
      rotation: _random.nextDouble() * 2 * pi,
      color: colors[_random.nextInt(colors.length)],
      isTriangle: _random.nextBool(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _BackgroundPainter(
            shapes: _shapes,
            progress: _controller.value,
          ),
          child: child,
        );
      },
      child: RepaintBoundary(child: widget.child),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final List<_FloatingShape> shapes;
  final double progress;

  _BackgroundPainter({required this.shapes, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Pastel gradient background.
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.bgTop, AppColors.bgMiddle, AppColors.bgBottom],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bgPaint);

    // Draw floating shapes.
    for (final shape in shapes) {
      final t = progress * 2 * pi;
      final dx = sin(t * shape.speed * 10 + shape.angle) * 30;
      final dy = cos(t * shape.speed * 8 + shape.angle) * 20;
      final cx = shape.x * size.width + dx;
      final cy = shape.y * size.height + dy;
      final rot = shape.rotation + t * shape.rotationSpeed;

      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(rot);

      final paint = Paint()..color = shape.color;

      if (shape.isTriangle) {
        final path = Path()
          ..moveTo(0, -shape.size * 0.6)
          ..lineTo(shape.size * 0.5, shape.size * 0.4)
          ..lineTo(-shape.size * 0.5, shape.size * 0.4)
          ..close();
        canvas.drawPath(path, paint);
      } else {
        canvas.drawCircle(Offset.zero, shape.size * 0.5, paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_BackgroundPainter old) => true;
}
