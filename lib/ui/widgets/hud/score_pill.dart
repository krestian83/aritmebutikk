import 'package:flutter/material.dart';

import '../../../app/l10n/strings.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';

/// Displays the current score in a rounded purple pill with a
/// count-up animation when the value changes.
class ScorePill extends StatefulWidget {
  final ValueNotifier<int> score;

  const ScorePill({super.key, required this.score});

  @override
  State<ScorePill> createState() => _ScorePillState();
}

class _ScorePillState extends State<ScorePill> {
  int _previous = 0;

  @override
  void initState() {
    super.initState();
    _previous = widget.score.value;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: widget.score,
      builder: (context, value, _) {
        final from = _previous;
        _previous = value;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.pillBlue, Color(0xFF2070E8)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.outline, width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.pillBlue.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('\u2B50', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              TweenAnimationBuilder<int>(
                key: ValueKey(value),
                tween: IntTween(begin: from, end: value),
                duration: const Duration(milliseconds: 300),
                builder: (context, val, _) {
                  return Text(
                    '${S.current.pointsColon} $val',
                    style: AppTheme.pillStyle,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
