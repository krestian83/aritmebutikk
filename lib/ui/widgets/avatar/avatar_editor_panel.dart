import 'package:flutter/material.dart';
import 'package:fluttermoji/fluttermojiCircleAvatar.dart';
import 'package:fluttermoji/fluttermojiCustomizer.dart';

import '../../../app/theme/app_colors.dart';

/// Avatar editor content designed to be shown in a [Dialog].
///
/// Shows a live fluttermoji preview and the full customizer
/// with tabs for hair, eyes, skin, clothes, accessories, etc.
class AvatarEditorPanel extends StatelessWidget {
  final String playerName;
  final VoidCallback onClose;

  const AvatarEditorPanel({
    super.key,
    required this.playerName,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          FluttermojiCircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey.shade200,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 320,
            child: FluttermojiCustomizer(autosave: true, scaffoldHeight: 320),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Text(
          'Avatar',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.cardGradientStart,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onClose,
          child: const Icon(
            Icons.close,
            size: 24,
            color: AppColors.cardGradientStart,
          ),
        ),
      ],
    );
  }
}
