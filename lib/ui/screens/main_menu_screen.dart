import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/l10n/strings.dart';
import '../../app/theme/app_colors.dart';
import '../../game/services/avatar_service.dart';
import '../../game/services/credit_service.dart';
import '../../game/services/sound_service.dart';
import '../widgets/avatar/avatar_icon.dart';
import '../widgets/dialogs/pin_dialog.dart';
import '../widgets/hud/mute_button.dart';
import '../widgets/logo/math_market_logo.dart';
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
      body: Stack(
        children: [
          _WarmBackground(
            child: SafeArea(
              child: Stack(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 48),
                              _buildTitle(),
                              const SizedBox(height: 4),
                              const MathMarketLogo(size: 120),
                              const SizedBox(height: 24),
                              _buildProfileCard(),
                              const SizedBox(height: 32),
                              _buildPlayButton(),
                              const SizedBox(height: 14),
                              _buildStoreButton(),
                              const SizedBox(height: 14),
                              _buildParentButton(),
                              const SizedBox(height: 48),
                            ],
                          ),
                        ),
                      );
                    },
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
                        color: AppColors.menuTextBrown,
                      ),
                    ),
                  ),
                  const MuteButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        S.current.appName,
        maxLines: 1,
        style: GoogleFonts.fredoka(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          color: AppColors.menuTextDark,
          letterSpacing: -1,
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
        width: 200,
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
          boxShadow: [
            BoxShadow(
              color: AppColors.menuTextBrown.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: AppColors.menuTextBrown.withValues(alpha: 0.04),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_hasAvatar) ...[
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF5E6D8), Color(0xFFE8D5C4)],
                  ),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.menuTextBrown.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: AvatarIcon(playerName: widget.playerName, size: 67),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              widget.playerName,
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.menuTextDark,
              ),
            ),
            if (_balance != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.menuTeal, AppColors.menuTealDark],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.menuTeal.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('\u2B50', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      S.current.pointsAmount(_balance!),
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.3,
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
      child: _MenuButton(
        onPressed: _startGame,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.menuTeal, AppColors.menuTealLight],
        ),
        shadowColor: AppColors.menuTeal.withValues(alpha: 0.35),
        child: Text(
          S.current.play,
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildStoreButton() {
    return SizedBox(
      width: double.infinity,
      child: _MenuButton(
        onPressed: _openStore,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.menuOrange, AppColors.menuOrangeLight],
        ),
        shadowColor: AppColors.menuOrange.withValues(alpha: 0.35),
        child: Text(
          S.current.store,
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildParentButton() {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: _openParentMenu,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.menuTextBrown.withValues(alpha: 0.15),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 18,
                color: AppColors.menuTextBrown,
              ),
              const SizedBox(width: 8),
              Text(
                S.current.parentMenu,
                style: GoogleFonts.nunito(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.menuTextBrown,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Gradient button with press-scale feedback.
class _MenuButton extends StatefulWidget {
  final VoidCallback onPressed;
  final LinearGradient gradient;
  final Color shadowColor;
  final Widget child;

  const _MenuButton({
    required this.onPressed,
    required this.gradient,
    required this.shadowColor,
    required this.child,
  });

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.shadowColor,
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Warm peach gradient with decorative circles.
class _WarmBackground extends StatelessWidget {
  final Widget child;

  const _WarmBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.35, 0.65, 1.0],
          colors: [
            AppColors.menuBgTop,
            AppColors.menuBgMid,
            AppColors.menuBgLow,
            AppColors.menuBgBottom,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles.
          Positioned(
            top: 60,
            right: -30,
            child: _Circle(120, AppColors.menuTeal.withValues(alpha: 0.08)),
          ),
          Positioned(
            top: 280,
            left: -40,
            child: _Circle(100, AppColors.menuOrange.withValues(alpha: 0.10)),
          ),
          Positioned(
            bottom: 200,
            right: -20,
            child: _Circle(80, AppColors.menuTeal.withValues(alpha: 0.06)),
          ),
          Positioned(
            bottom: 80,
            left: 30,
            child: _Circle(50, AppColors.menuOrange.withValues(alpha: 0.08)),
          ),
          child,
        ],
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  final double diameter;
  final Color color;

  const _Circle(this.diameter, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
