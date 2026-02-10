import 'dart:math';

import 'package:flutter/material.dart';

/// Shared confetti color palette.
const confettiColors = [
  Color(0xFFFF6B6B),
  Color(0xFF4ECDC4),
  Color(0xFFFFE66D),
  Color(0xFF95E1D3),
  Color(0xFFF38181),
  Color(0xFFAA96DA),
  Color(0xFF6EC6E8),
  Color(0xFFFF9A9E),
];

/// A single confetti particle with position, velocity, and spin.
class ConfettiParticle {
  final double x;
  final double y;
  final double vx;
  final double vy;
  final double rotation;
  final double rotationSpeed;
  final double size;
  final Color color;
  final double wobblePhase;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.rotation,
    required this.rotationSpeed,
    required this.size,
    required this.color,
    this.wobblePhase = 0,
  });
}

/// Paints confetti rectangles that move, rotate, and fade.
///
/// [gravity] scales the `t^2` vertical acceleration.
/// [fadeStart] is the progress value (0-1) after which opacity
/// fades linearly to 0. Set to 0 for a full linear fade.
/// When [wobble] is true, particles sway horizontally using
/// their [wobblePhase].
class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;
  final double gravity;
  final double fadeStart;
  final bool wobble;

  ConfettiPainter({
    required this.particles,
    required this.progress,
    this.gravity = 2.0,
    this.fadeStart = 0.0,
    this.wobble = false,
  });

  final Paint _paint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final double opacity;
    if (fadeStart <= 0) {
      opacity = (1.0 - progress).clamp(0.0, 1.0);
    } else {
      opacity = progress < fadeStart
          ? 1.0
          : ((1.0 - progress) / (1.0 - fadeStart)).clamp(0.0, 1.0);
    }
    if (opacity <= 0) return;

    for (final p in particles) {
      final t = progress;
      final w = wobble ? sin(t * 4 * pi + p.wobblePhase) * 0.02 : 0.0;
      final x = (p.x + p.vx * t + w) * size.width;
      final y = (p.y + p.vy * t + gravity * t * t) * size.height;
      final rot = p.rotation + p.rotationSpeed * t;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rot);

      _paint.color = p.color.withValues(alpha: opacity);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: p.size,
          height: p.size * 0.6,
        ),
        _paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter old) => old.progress != progress;
}
