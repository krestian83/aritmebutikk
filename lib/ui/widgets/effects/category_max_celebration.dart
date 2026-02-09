import 'dart:math';

import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../game/models/game_category.dart';

/// Full-screen celebration overlay shown when a player maxes
/// out all available credits in a category.
class CategoryMaxCelebration extends StatefulWidget {
  final GameCategory category;
  final VoidCallback onComplete;

  const CategoryMaxCelebration({
    super.key,
    required this.category,
    required this.onComplete,
  });

  @override
  State<CategoryMaxCelebration> createState() => _CategoryMaxCelebrationState();
}

class _CategoryMaxCelebrationState extends State<CategoryMaxCelebration>
    with SingleTickerProviderStateMixin {
  static const _messages = [
    'Fantastisk! Du har mestret',
    'Utrolig! Full pott i',
    'Kjempebra! Du klarte alle poeng i',
    'Wow! Alle poeng samlet i',
    'Strålende! Du er mester i',
    'Helt rett! Maks poeng i',
    'Imponerende! Du knuste',
    'Superstjerne! Du fullførte',
  ];

  late final AnimationController _controller;
  late final List<_Particle> _particles;
  late final String _message;
  final Random _random = Random();

  static const _colors = [
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
    Color(0xFFFFE66D),
    Color(0xFF95E1D3),
    Color(0xFFF38181),
    Color(0xFFAA96DA),
    Color(0xFF6EC6E8),
    Color(0xFFFF9A9E),
  ];

  @override
  void initState() {
    super.initState();
    _message = _messages[_random.nextInt(_messages.length)];

    _controller =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 7000),
          )
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              widget.onComplete();
            }
          })
          ..forward();

    _particles = List.generate(60, (_) {
      return _Particle(
        x: _random.nextDouble(),
        y: -0.05 - _random.nextDouble() * 0.1,
        vx: (_random.nextDouble() - 0.5) * 0.3,
        vy: 0.3 + _random.nextDouble() * 0.5,
        rotation: _random.nextDouble() * 2 * pi,
        rotationSpeed: (_random.nextDouble() - 0.5) * 6,
        size: 5 + _random.nextDouble() * 9,
        color: _colors[_random.nextInt(_colors.length)],
        wobblePhase: _random.nextDouble() * 2 * pi,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onComplete,
      child: Stack(
        children: [
          // Dark backdrop.
          Positioned.fill(
            child: ColoredBox(color: Colors.black.withValues(alpha: 0.55)),
          ),

          // Confetti rain.
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _RainPainter(
                    particles: _particles,
                    progress: _controller.value,
                  ),
                  size: Size.infinite,
                );
              },
            ),
          ),

          // Message.
          Center(
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: _controller,
                curve: const Interval(0.0, 0.2, curve: Curves.elasticOut),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('\u2B50', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    Text(
                      _message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.category.icon} '
                      '${widget.category.label} '
                      '${widget.category.icon}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.starGold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Trykk for å fortsette',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -- Confetti rain particles --------------------------------------------------

class _Particle {
  final double x;
  final double y;
  final double vx;
  final double vy;
  final double rotation;
  final double rotationSpeed;
  final double size;
  final Color color;
  final double wobblePhase;

  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.rotation,
    required this.rotationSpeed,
    required this.size,
    required this.color,
    required this.wobblePhase,
  });
}

class _RainPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _RainPainter({required this.particles, required this.progress});

  final Paint _paint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    // Fade out during the last 30 %.
    final opacity = progress < 0.7
        ? 1.0
        : ((1.0 - progress) / 0.3).clamp(0.0, 1.0);
    if (opacity <= 0) return;

    for (final p in particles) {
      final t = progress;
      final wobble = sin(t * 4 * pi + p.wobblePhase) * 0.02;
      final x = (p.x + p.vx * t + wobble) * size.width;
      final y = (p.y + p.vy * t + 0.3 * t * t) * size.height;
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
  bool shouldRepaint(_RainPainter old) => old.progress != progress;
}
