import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../game/services/audio_state.dart';
import '../../../game/services/music_service.dart';

/// Small bottom-right button cycling: all on → music off → all off.
class MuteButton extends StatelessWidget {
  const MuteButton({super.key});

  void _onTap() {
    AudioState.instance.cycle();
    MusicService.instance.applyMuteState();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 16,
      child: ValueListenableBuilder<MuteMode>(
        valueListenable: AudioState.instance.notifier,
        builder: (context, mode, _) {
          final (icon, tooltip) = switch (mode) {
            MuteMode.allOn => (Icons.volume_up_rounded, 'Demp musikk'),
            MuteMode.musicOff => (
              Icons.music_off_rounded,
              'Demp alt',
            ),
            MuteMode.allOff => (
              Icons.volume_off_rounded,
              'Sl\u00E5 p\u00E5 lyd',
            ),
          };

          return GestureDetector(
            onTap: _onTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.outline),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Tooltip(
                message: tooltip,
                child: Icon(
                  icon,
                  size: 20,
                  color: mode == MuteMode.allOn
                      ? AppColors.cardGradientStart
                      : Colors.grey.shade500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
