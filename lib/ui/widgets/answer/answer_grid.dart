import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import 'answer_button.dart';

/// 2x2 grid of answer bubble buttons.
class AnswerGrid extends StatelessWidget {
  final List<int> choices;
  final ValueChanged<int> onChoiceSelected;
  final bool enabled;

  const AnswerGrid({
    super.key,
    required this.choices,
    required this.onChoiceSelected,
    this.enabled = true,
  });

  static const _colors = [
    AppColors.coral,
    AppColors.green,
    AppColors.cyan,
    AppColors.purple,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [_buildButton(0), _buildButton(1)],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [_buildButton(2), _buildButton(3)],
        ),
      ],
    );
  }

  Widget _buildButton(int index) {
    if (index >= choices.length) {
      return const Expanded(child: SizedBox(height: 120));
    }
    return Expanded(
      child: Center(
        child: AnswerButton(
          value: choices[index],
          color: _colors[index % _colors.length],
          enabled: enabled,
          onTap: () => onChoiceSelected(choices[index]),
        ),
      ),
    );
  }
}
