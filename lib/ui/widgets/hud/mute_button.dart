import 'package:flutter/material.dart';

import '../../../app/l10n/strings.dart';
import '../../../app/theme/app_colors.dart';
import '../../../game/services/audio_state.dart';
import '../../../game/services/music_service.dart';

/// Small top-right button cycling: soundOnly → all → muted.
class MuteButton extends StatelessWidget {
  const MuteButton({super.key});

  void _onTap() {
    AudioState.instance.cycle();
    MusicService.instance.applyMuteState();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 8,
      top: 8,
      child: ValueListenableBuilder<AudioMode>(
        valueListenable: AudioState.instance.notifier,
        builder: (context, mode, _) {
          final (icon, tooltip) = switch (mode) {
            AudioMode.soundOnly => (
              Icons.volume_up_rounded,
              S.current.enableMusic,
            ),
            AudioMode.all => (Icons.music_note_rounded, S.current.muteAll),
            AudioMode.muted => (
              Icons.volume_off_rounded,
              S.current.unmuteAudio,
            ),
          };

          return GestureDetector(
            onTap: _onTap,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.menuTextBrown.withValues(alpha: 0.15),
                ),
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
                  color: mode == AudioMode.all
                      ? AppColors.menuTeal
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
