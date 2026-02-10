import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:fluttermoji/fluttermojiCircleAvatar.dart';
import 'package:fluttermoji/fluttermojiCustomizer.dart';

import '../../app/l10n/locale_service.dart';
import '../../app/l10n/strings.dart';
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
  final bool showBack;

  const NewPlayerScreen({super.key, this.editName, this.showBack = true});

  @override
  State<NewPlayerScreen> createState() => _NewPlayerScreenState();
}

class _NewPlayerScreenState extends State<NewPlayerScreen> {
  final _profileService = ProfileService.instance;
  final _avatarService = AvatarService.instance;
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
      setState(() => _errorText = S.current.enterAName);
      return false;
    }

    final added = await _profileService.addProfile(name);
    if (!added) {
      setState(() => _errorText = S.current.nameAlreadyTaken);
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
                    canGoBack: widget.showBack,
                    onBack: () => Navigator.of(context).pop(),
                  ),
          ),
        ),
      ),
    );
  }
}

class _NameStep extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? errorText;
  final VoidCallback onFinish;
  final VoidCallback onCreateAvatar;
  final bool canGoBack;
  final VoidCallback onBack;

  const _NameStep({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.errorText,
    required this.onFinish,
    required this.onCreateAvatar,
    required this.canGoBack,
    required this.onBack,
  });

  @override
  State<_NameStep> createState() => _NameStepState();
}

class _NameStepState extends State<_NameStep> {
  void _setLocale(AppLocale locale) {
    SoundService.instance.play('press');
    LocaleService.instance.setLocale(locale);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final current = LocaleService.instance.locale.value;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _FlagButton(
                  countryCode: 'GB',
                  selected: current == AppLocale.en,
                  onTap: () => _setLocale(AppLocale.en),
                ),
                const SizedBox(width: 8),
                _FlagButton(
                  countryCode: 'NO',
                  selected: current == AppLocale.nb,
                  onTap: () => _setLocale(AppLocale.nb),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Icon(Icons.person_add, size: 64, color: AppColors.menuTeal),
            const SizedBox(height: 16),
            Text(
              S.current.whatsYourName,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.menuTeal,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.menuTextBrown.withValues(alpha: 0.15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.menuTeal.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                autofocus: true,
                textAlign: TextAlign.center,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.menuTeal,
                ),
                decoration: InputDecoration(
                  hintText: S.current.enterYourName,
                  hintStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: AppColors.menuTeal.withValues(alpha: 0.4),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
                onSubmitted: (_) => widget.onFinish(),
              ),
            ),
            if (widget.errorText != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.errorText!,
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
                onPressed: widget.onFinish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  side: BorderSide(
                    color: AppColors.menuTextBrown.withValues(alpha: 0.15),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  S.current.done,
                  style: const TextStyle(
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
                onPressed: widget.onCreateAvatar,
                icon: const Icon(Icons.face, size: 20),
                label: Text(
                  S.current.createAvatar,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.menuTeal,
                  side: BorderSide(
                    color: AppColors.menuTextBrown.withValues(alpha: 0.15),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            if (widget.canGoBack) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: widget.onBack,
                child: Text(
                  S.current.back,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FlagButton extends StatelessWidget {
  final String countryCode;
  final bool selected;
  final VoidCallback onTap;

  const _FlagButton({
    required this.countryCode,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const size = 27.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? AppColors.menuTeal
                : AppColors.menuTextBrown.withValues(alpha: 0.15),
            width: selected ? 2.5 : 1,
          ),
        ),
        child: ClipOval(
          child: SizedBox(
            width: size,
            height: size,
            child: FittedBox(
              fit: BoxFit.cover,
              child: CountryFlag.fromCountryCode(countryCode),
            ),
          ),
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
            Text(
              S.current.createYourAvatar,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.menuTeal,
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
              child: FluttermojiCustomizer(
                autosave: true,
                scaffoldHeight: 320,
                attributeTitles: S.current.avatarAttributeTitles,
              ),
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
                  side: BorderSide(
                    color: AppColors.menuTextBrown.withValues(alpha: 0.15),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  S.current.done,
                  style: const TextStyle(
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
