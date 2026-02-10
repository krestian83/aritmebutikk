import 'package:flutter/material.dart';

import '../../app/l10n/locale_service.dart';
import '../../app/l10n/strings.dart';
import '../../app/theme/app_colors.dart';
import '../../game/services/avatar_service.dart';
import '../../game/services/profile_service.dart';
import '../../game/services/sound_service.dart';
import '../widgets/background/animated_background.dart';
import '../widgets/common/flag_button.dart';

/// Single-step new-player flow: name entry + emoji picker.
///
/// When [editName] is provided, shows the name (read-only) with
/// the current emoji for editing.
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
  final _emojiController = TextEditingController();
  final _emojiFocusNode = FocusNode();

  String? _errorText;
  String _playerName = '';
  String _emoji = AvatarService.defaultEmoji;

  bool get _isEditMode => widget.editName != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _playerName = widget.editName!;
      _loadEmoji();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    _emojiController.dispose();
    _emojiFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadEmoji() async {
    final emoji = await _avatarService.getEmoji(_playerName);
    if (!mounted) return;
    setState(() => _emoji = emoji);
  }

  Future<void> _finish() async {
    if (!_isEditMode) {
      final name = _nameController.text.trim();
      if (name.isEmpty) {
        setState(() => _errorText = S.current.enterAName);
        return;
      }
      final added = await _profileService.addProfile(name);
      if (!added) {
        setState(() => _errorText = S.current.nameAlreadyTaken);
        return;
      }
      _playerName = name;
    }

    SoundService.instance.play('press');
    await _avatarService.saveEmoji(_playerName, _emoji);
    if (!mounted) return;
    Navigator.of(context).pop(_playerName);
  }

  void _openEmojiInput() {
    _emojiController.clear();
    _emojiFocusNode.requestFocus();
  }

  void _onEmojiChanged(String value) {
    if (value.isEmpty) return;
    final characters = value.characters;
    if (characters.isNotEmpty) {
      setState(() => _emoji = characters.first);
    }
    _emojiController.clear();
    _emojiFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: _NewPlayerBody(
            isEditMode: _isEditMode,
            playerName: _playerName,
            nameController: _nameController,
            focusNode: _focusNode,
            errorText: _errorText,
            emoji: _emoji,
            emojiController: _emojiController,
            emojiFocusNode: _emojiFocusNode,
            onEmojiTap: _openEmojiInput,
            onEmojiChanged: _onEmojiChanged,
            onFinish: _finish,
            canGoBack: widget.showBack,
            onBack: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }
}

class _NewPlayerBody extends StatefulWidget {
  final bool isEditMode;
  final String playerName;
  final TextEditingController nameController;
  final FocusNode focusNode;
  final String? errorText;
  final String emoji;
  final TextEditingController emojiController;
  final FocusNode emojiFocusNode;
  final VoidCallback onEmojiTap;
  final ValueChanged<String> onEmojiChanged;
  final VoidCallback onFinish;
  final bool canGoBack;
  final VoidCallback onBack;

  const _NewPlayerBody({
    required this.isEditMode,
    required this.playerName,
    required this.nameController,
    required this.focusNode,
    required this.errorText,
    required this.emoji,
    required this.emojiController,
    required this.emojiFocusNode,
    required this.onEmojiTap,
    required this.onEmojiChanged,
    required this.onFinish,
    required this.canGoBack,
    required this.onBack,
  });

  @override
  State<_NewPlayerBody> createState() => _NewPlayerBodyState();
}

class _NewPlayerBodyState extends State<_NewPlayerBody> {
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
            if (!widget.isEditMode)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FlagButton(
                    countryCode: 'GB',
                    selected: current == AppLocale.en,
                    onTap: () => _setLocale(AppLocale.en),
                  ),
                  const SizedBox(width: 8),
                  FlagButton(
                    countryCode: 'NO',
                    selected: current == AppLocale.nb,
                    onTap: () => _setLocale(AppLocale.nb),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            Text(
              widget.isEditMode
                  ? S.current.chooseYourEmoji
                  : S.current.whatsYourName,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.menuTeal,
              ),
            ),
            const SizedBox(height: 24),
            _buildEmojiPicker(),
            const SizedBox(height: 24),
            if (!widget.isEditMode) ...[
              _buildNameField(),
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
            ] else ...[
              Text(
                widget.playerName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.menuTextDark,
                ),
              ),
              const SizedBox(height: 24),
            ],
            _buildDoneButton(),
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

  Widget _buildEmojiPicker() {
    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: widget.onEmojiTap,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.menuTeal.withValues(alpha: 0.3),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.menuTeal.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(widget.emoji, style: const TextStyle(fontSize: 48)),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.menuTeal,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.edit, size: 14, color: Colors.white),
          ),
        ),
        // Hidden text field for emoji keyboard input.
        Opacity(
          opacity: 0,
          child: SizedBox(
            width: 1,
            height: 1,
            child: TextField(
              controller: widget.emojiController,
              focusNode: widget.emojiFocusNode,
              onChanged: widget.onEmojiChanged,
              keyboardType: TextInputType.text,
              showCursor: false,
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return Container(
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
        controller: widget.nameController,
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
    );
  }

  Widget _buildDoneButton() {
    return SizedBox(
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
    );
  }
}
