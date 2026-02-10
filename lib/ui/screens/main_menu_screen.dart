import 'package:flutter/material.dart';

import '../../app/l10n/strings.dart';
import '../../app/theme/app_colors.dart';
import '../../game/services/avatar_service.dart';
import '../../game/services/credit_service.dart';
import '../../game/services/sound_service.dart';
import '../widgets/avatar/avatar_icon.dart';
import '../widgets/background/animated_background.dart';
import '../widgets/dialogs/pin_dialog.dart';
import '../widgets/hud/mute_button.dart';
import 'category_screen.dart';
import 'store_editor_screen.dart';
import 'store_screen.dart';

/// Main menu with credit balance and navigation.
class MainMenuScreen extends StatefulWidget {
  final String playerName;

  const MainMenuScreen({super.key, required this.playerName});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  final _creditService = CreditService.instance;
  final _avatarService = AvatarService.instance;
  int? _balance;
  bool _hasAvatar = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final balance = await _creditService.getBalance(widget.playerName);
    final hasAvatar = await _avatarService.hasAvatar(widget.playerName);
    if (!mounted) return;
    setState(() {
      _balance = balance;
      _hasAvatar = hasAvatar;
    });
  }

  void _startGame() {
    SoundService.instance.play('press');
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => CategoryScreen(playerName: widget.playerName),
          ),
        )
        .then((_) => _loadData());
  }

  void _openStore() {
    SoundService.instance.play('press');
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => StoreScreen(playerName: widget.playerName),
          ),
        )
        .then((_) => _loadData());
  }

  Future<void> _openParentMenu() async {
    SoundService.instance.play('press');
    final ok = await PinDialog.show(context);
    if (!ok || !mounted) return;
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const StoreEditorScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const SizedBox(height: 48),
                    _buildTitle(),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: const Text(
                        '\u2795\u2796\u2716\u2797',
                        maxLines: 1,
                        style: TextStyle(fontSize: 36),
                      ),
                    ),
                    const Spacer(),
                    _buildProfileCard(),
                    const Spacer(),
                    _buildPlayButton(),
                    const SizedBox(height: 14),
                    _buildStoreButton(),
                    const SizedBox(height: 14),
                    _buildParentButton(),
                    const SizedBox(height: 72),
                  ],
                ),
              ),
              Positioned(
                left: 8,
                top: 8,
                child: IconButton(
                  onPressed: () {
                    SoundService.instance.play('press');
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.cardGradientStart,
                  ),
                ),
              ),
              const MuteButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        S.current.appName,
        maxLines: 1,
        style: const TextStyle(
          fontSize: 64,
          fontWeight: FontWeight.w800,
          color: AppColors.cardGradientStart,
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return GestureDetector(
      onTap: () {
        SoundService.instance.play('press');
        Navigator.of(context).pop();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.30),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardGradientStart.withValues(alpha: 0.10),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_hasAvatar) ...[
              AvatarIcon(playerName: widget.playerName, size: 67),
              const SizedBox(height: 8),
            ],
            Text(
              widget.playerName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.cardGradientStart,
              ),
            ),
            if (_balance != null) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.cardGradientStart,
                      AppColors.cardGradientEnd,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('\u2B50', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 6),
                    Text(
                      S.current.pointsAmount(_balance!),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlayButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _startGame,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cardGradientStart,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          side: const BorderSide(color: AppColors.outline),
          elevation: 4,
        ),
        child: Text(
          S.current.play,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildStoreButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _openStore,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cardGradientStart,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          side: const BorderSide(color: AppColors.outline),
          elevation: 4,
        ),
        child: Text(
          S.current.store,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildParentButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _openParentMenu,
        icon: const Icon(Icons.lock_outline, size: 18),
        label: Text(
          S.current.parentMenu,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.grey.shade600,
          side: const BorderSide(color: AppColors.outline),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
