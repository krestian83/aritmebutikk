import 'dart:math' as math;

import 'package:flutter/material.dart';

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

class _MainMenuScreenState extends State<MainMenuScreen>
    with SingleTickerProviderStateMixin {
  final _creditService = CreditService.instance;
  final _avatarService = AvatarService.instance;
  late final AnimationController _wiggleCtrl;
  int? _balance;
  bool _hasAvatar = false;

  @override
  void initState() {
    super.initState();
    _wiggleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
    _loadData();
  }

  @override
  void dispose() {
    _wiggleCtrl.dispose();
    super.dispose();
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
                    const Text(
                      '\u2795\u2796\u2716\u2797',
                      style: TextStyle(fontSize: 48),
                    ),
                    const SizedBox(height: 8),
                    _buildTitle(),
                    const Spacer(flex: 2),
                    _buildProfileCard(),
                    const Spacer(),
                    _buildPlayButton(),
                    const SizedBox(height: 14),
                    _buildStoreButton(),
                    const SizedBox(height: 14),
                    _buildParentButton(),
                    const SizedBox(height: 56),
                  ],
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
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Text(
          'Aritmetikk',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: AppColors.cardGradientStart,
          ),
        ),
        Positioned(
          top: -22,
          left: 0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Opacity(
                opacity: 0,
                child: Text(
                  'Aritm',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800),
                ),
              ),
              AnimatedBuilder(
                animation: _wiggleCtrl,
                builder: (_, child) {
                  final t = _wiggleCtrl.value;
                  final dy = math.sin(t * 2 * math.pi) * 3;
                  final angle = math.sin(t * 2 * math.pi) * 0.06;
                  return Transform.translate(
                    offset: Offset(0, dy),
                    child: Transform.rotate(angle: angle, child: child),
                  );
                },
                child: Text(
                  '(bu)',
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.cardGradientEnd.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.playerName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cardGradientStart,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.swap_horiz,
                  size: 20,
                  color: AppColors.cardGradientStart
                      .withValues(alpha: 0.5),
                ),
              ],
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
                    const Text(
                      '\u2B50',
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$_balance poeng',
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
        child: const Text(
          'Spill',
          style: TextStyle(
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
        child: const Text(
          'Butikk',
          style: TextStyle(
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
        label: const Text(
          'Foreldremeny',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
