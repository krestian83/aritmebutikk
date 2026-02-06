import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';

/// Displays the countdown timer in a rounded purple pill.
///
/// Pulses and turns red when time is running low (<=10s).
class TimerPill extends StatefulWidget {
  final ValueNotifier<int> secondsLeft;

  const TimerPill({super.key, required this.secondsLeft});

  @override
  State<TimerPill> createState() => _TimerPillState();
}

class _TimerPillState extends State<TimerPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    widget.secondsLeft.addListener(_onTimerChanged);
  }

  void _onTimerChanged() {
    if (widget.secondsLeft.value <= 10 && widget.secondsLeft.value > 0) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    widget.secondsLeft.removeListener(_onTimerChanged);
    _pulseController.dispose();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    if (totalSeconds >= 60) {
      final m = totalSeconds ~/ 60;
      final s = totalSeconds % 60;
      return '${m.toString().padLeft(2, '0')}:'
          '${s.toString().padLeft(2, '0')}';
    }
    return '${totalSeconds}s';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: widget.secondsLeft,
      builder: (context, seconds, _) {
        final isWarning = seconds <= 10 && seconds > 0;
        return ScaleTransition(
          scale: _pulseAnimation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isWarning
                    ? [AppColors.timerRed, const Color(0xFFFF8A80)]
                    : [AppColors.pillPurple, const Color(0xFF9B7FE8)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: (isWarning ? AppColors.timerRed : AppColors.pillPurple)
                      .withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '\u23F0',
                  style: TextStyle(
                    fontSize: 18,
                    color: isWarning ? AppColors.white : AppColors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Text(_formatTime(seconds), style: AppTheme.pillStyle),
              ],
            ),
          ),
        );
      },
    );
  }
}
