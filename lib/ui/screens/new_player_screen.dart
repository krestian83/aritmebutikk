import 'package:flutter/material.dart';
import 'package:fluttermoji/fluttermojiCircleAvatar.dart';
import 'package:fluttermoji/fluttermojiCustomizer.dart';

import '../../app/theme/app_colors.dart';
import '../../game/services/avatar_service.dart';
import '../../game/services/profile_service.dart';
import '../../game/services/sound_service.dart';
import '../widgets/background/animated_background.dart';

/// Two-step new-player flow: name entry, then avatar editor.
///
/// When [editName] is provided, skips name entry and jumps
/// straight to avatar editing for an existing player.
class NewPlayerScreen extends StatefulWidget {
  final String? editName;

  const NewPlayerScreen({super.key, this.editName});

  @override
  State<NewPlayerScreen> createState() => _NewPlayerScreenState();
}

class _NewPlayerScreenState extends State<NewPlayerScreen> {
  final _profileService = ProfileService();
  final _avatarService = AvatarService();
  final _nameController = TextEditingController();
  final _focusNode = FocusNode();

  bool _isAvatarStep = false;
  String? _errorText;
  String _playerName = '';

  bool get _isEditMode => widget.editName != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _playerName = widget.editName!;
      _isAvatarStep = true;
      _loadAvatar();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadAvatar() async {
    await _avatarService.loadPlayer(_playerName);
    if (mounted) setState(() {});
  }

  Future<bool> _validateAndSaveName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorText = 'Skriv inn et navn');
      return false;
    }

    final added = await _profileService.addProfile(name);
    if (!added) {
      setState(() => _errorText = 'Navnet er allerede i bruk');
      return false;
    }

    _playerName = name;
    return true;
  }

  Future<void> _finishWithoutAvatar() async {
    if (!await _validateAndSaveName()) return;
    SoundService.instance.play('press');
    if (!mounted) return;
    Navigator.of(context).pop(_playerName);
  }

  Future<void> _goToAvatar() async {
    if (!await _validateAndSaveName()) return;
    SoundService.instance.play('press');
    await _avatarService.loadPlayer(_playerName);
    if (!mounted) return;
    setState(() {
      _isAvatarStep = true;
      _errorText = null;
    });
  }

  Future<void> _finishWithAvatar() async {
    SoundService.instance.play('press');
    await _avatarService.savePlayer(_playerName);
    if (!mounted) return;
    Navigator.of(context).pop(_playerName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isAvatarStep
                ? _AvatarStep(
                    key: const ValueKey('avatar'),
                    playerName: _playerName,
                    onFinish: _finishWithAvatar,
                  )
                : _NameStep(
                    key: const ValueKey('name'),
                    controller: _nameController,
                    focusNode: _focusNode,
                    errorText: _errorText,
                    onFinish: _finishWithoutAvatar,
                    onCreateAvatar: _goToAvatar,
                    onBack: () => Navigator.of(context).pop(),
                  ),
          ),
        ),
      ),
    );
  }
}

class _NameStep extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? errorText;
  final VoidCallback onFinish;
  final VoidCallback onCreateAvatar;
  final VoidCallback onBack;

  const _NameStep({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.errorText,
    required this.onFinish,
    required this.onCreateAvatar,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_add,
              size: 64,
              color: AppColors.cardGradientStart,
            ),
            const SizedBox(height: 16),
            const Text(
              'Hva heter du?',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.cardGradientStart,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.outline),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cardGradientStart
                        .withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                autofocus: true,
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
                    color: AppColors.cardGradientStart
                        .withValues(alpha: 0.4),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
                onSubmitted: (_) => onFinish(),
              ),
            ),
            if (errorText != null) ...[
              const SizedBox(height: 8),
              Text(
                errorText!,
                style: const TextStyle(
                  color: AppColors.coral,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onFinish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  side: const BorderSide(
                    color: AppColors.outline,
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'Ferdig',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onCreateAvatar,
                icon: const Icon(Icons.face, size: 20),
                label: const Text(
                  'Lag avatar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.cardGradientStart,
                  side: const BorderSide(
                    color: AppColors.outline,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onBack,
              child: Text(
                'Tilbake',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarStep extends StatelessWidget {
  final String playerName;
  final VoidCallback onFinish;

  const _AvatarStep({
    super.key,
    required this.playerName,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Lag din avatar!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.cardGradientStart,
              ),
            ),
            const SizedBox(height: 16),
            FluttermojiCircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade200,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 320,
              child: FluttermojiCustomizer(autosave: true, scaffoldHeight: 320),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onFinish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  side: const BorderSide(color: AppColors.outline),
                  elevation: 4,
                ),
                child: const Text(
                  'Ferdig',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
