import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../game/services/avatar_service.dart';
import '../../game/services/credit_service.dart';
import '../../game/services/sound_service.dart';
import '../widgets/avatar/avatar_editor_panel.dart';
import '../widgets/avatar/avatar_icon.dart';
import '../widgets/background/animated_background.dart';
import '../widgets/hud/mute_button.dart';
import '../widgets/dialogs/pin_dialog.dart';
import 'category_screen.dart';
import 'store_editor_screen.dart';
import 'store_screen.dart';

/// Main menu with name entry, credit balance, and navigation.
class MainMenuScreen extends StatefulWidget {
  final String? initialName;

  const MainMenuScreen({super.key, this.initialName});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _focusNode = FocusNode();
  final _creditService = CreditService();
  late final AnimationController _wiggleCtrl;
  int? _balance;

  @override
  void initState() {
    super.initState();
    _wiggleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
    if (widget.initialName != null) {
      _nameController.text = widget.initialName!;
      _loadBalance(widget.initialName!);
    }
    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _wiggleCtrl.dispose();
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      _loadBalance(name);
    } else {
      setState(() => _balance = null);
    }
  }

  Future<void> _loadBalance(String name) async {
    final balance = await _creditService.getBalance(name);
    if (!mounted) return;
    setState(() => _balance = balance);
  }

  void _startGame() {
    SoundService.instance.play('press');
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _focusNode.requestFocus();
      return;
    }
    Navigator.of(context)
        .push(
          MaterialPageRoute(builder: (_) => CategoryScreen(playerName: name)),
        )
        .then((_) => _loadBalance(name));
  }

  void _openStore() {
    SoundService.instance.play('press');
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _focusNode.requestFocus();
      return;
    }
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => StoreScreen(playerName: name)))
        .then((_) => _loadBalance(name));
  }

  void _openAvatarEditor() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    SoundService.instance.play('press');
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: AvatarEditorPanel(
          playerName: name,
          onClose: () => Navigator.of(dialogContext).pop(),
        ),
      ),
    ).then((_) {
      AvatarService().savePlayer(name);
    });
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
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '\u2795\u2796\u2716\u2797',
                        style: TextStyle(fontSize: 48),
                      ),
                      const SizedBox(height: 12),
                      Stack(
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
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                AnimatedBuilder(
                                  animation: _wiggleCtrl,
                                  builder: (_, child) {
                                    final t = _wiggleCtrl.value;
                                    final dy = math.sin(t * 2 * math.pi) * 3;
                                    final angle =
                                        math.sin(t * 2 * math.pi) * 0.06;
                                    return Transform.translate(
                                      offset: Offset(0, dy),
                                      child: Transform.rotate(
                                        angle: angle,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Text(
                                    '(bu)',
                                    style: TextStyle(
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.cardGradientEnd
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      _buildNameField(),
                      if (_balance != null) ...[
                        const SizedBox(height: 16),
                        _buildBalanceChip(),
                      ],
                      const SizedBox(height: 24),
                      _buildPlayButton(),
                      const SizedBox(height: 16),
                      _buildStoreButton(),
                      const SizedBox(height: 16),
                      _buildParentButton(),
                    ],
                  ),
                ),
              ),
              const MuteButton(),
              if (_nameController.text.trim().isNotEmpty)
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: _openAvatarEditor,
                    child: AvatarIcon(
                      playerName: _nameController.text.trim(),
                      size: 48,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardGradientStart.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _nameController,
        focusNode: _focusNode,
        textAlign: TextAlign.center,
        textCapitalization: TextCapitalization.words,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.cardGradientStart,
        ),
        decoration: InputDecoration(
          hintText: 'Skriv inn navnet ditt',
          hintStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: AppColors.cardGradientStart.withValues(alpha: 0.4),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
        ),
        onSubmitted: (_) => _startGame(),
      ),
    );
  }

  Widget _buildBalanceChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.cardGradientStart, AppColors.cardGradientEnd],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('\u2B50', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(
            '$_balance poeng',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
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
          side: BorderSide(color: AppColors.outline, width: 1),
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
          side: BorderSide(color: AppColors.outline, width: 1),
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
          side: BorderSide(color: AppColors.outline, width: 1),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
