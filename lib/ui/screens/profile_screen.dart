import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';

import '../../app/l10n/locale_service.dart';
import '../../app/l10n/strings.dart';
import '../../app/theme/app_colors.dart';
import '../../game/services/avatar_service.dart';
import '../../game/services/credit_service.dart';
import '../../game/services/profile_service.dart';
import '../../game/services/sound_service.dart';
import '../widgets/background/animated_background.dart';
import '../widgets/profile/profile_card.dart';
import 'main_menu_screen.dart';
import 'new_player_screen.dart';

/// Lets the user pick an existing profile or create a new one.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileService = ProfileService.instance;
  final _creditService = CreditService.instance;
  final _avatarService = AvatarService.instance;

  List<String> _profiles = [];
  Map<String, int> _balances = {};
  Map<String, String?> _avatarSvgs = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profiles = await _profileService.loadProfiles();

    if (profiles.isEmpty && mounted) {
      setState(() {
        _profiles = [];
        _loading = false;
      });
      _openNewPlayer();
      return;
    }

    final balances = <String, int>{};
    final svgs = <String, String?>{};

    for (final name in profiles) {
      balances[name] = await _creditService.getBalance(name);
      svgs[name] = await _avatarService.getAvatarSvg(name);
    }

    // Restore the previously active player to avoid side effects.
    if (AvatarService.currentPlayer != null) {
      await _avatarService.loadPlayer(AvatarService.currentPlayer!);
    }

    if (!mounted) return;
    setState(() {
      _profiles = profiles;
      _balances = balances;
      _avatarSvgs = svgs;
      _loading = false;
    });
  }

  Future<void> _openNewPlayer() async {
    final name = await Navigator.of(
      context,
    ).push<String>(MaterialPageRoute(builder: (_) => const NewPlayerScreen()));
    if (name != null && mounted) {
      _selectProfile(name);
    } else {
      // Reload in case user backed out.
      _loading = true;
      _load();
    }
  }

  void _selectProfile(String name) {
    SoundService.instance.play('press');
    Navigator.of(context)
        .push(
          MaterialPageRoute(builder: (_) => MainMenuScreen(playerName: name)),
        )
        .then((_) {
          if (mounted) {
            setState(() => _loading = true);
            _load();
          }
        });
  }

  Future<void> _editAvatar(String name) async {
    SoundService.instance.play('press');
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => NewPlayerScreen(editName: name)),
    );
    if (result != null && mounted) {
      setState(() => _loading = true);
      _load();
    }
  }

  Future<void> _deleteProfile(String name) async {
    SoundService.instance.play('press');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.current.deleteProfileTitle(name)),
        content: Text(S.current.deleteProfileBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(S.current.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              S.current.delete,
              style: const TextStyle(color: AppColors.coral),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await _profileService.deleteProfile(name);
    setState(() => _loading = true);
    _load();
  }

  void _setLocale(AppLocale locale) {
    SoundService.instance.play('press');
    LocaleService.instance.setLocale(locale);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        const SizedBox(height: 24),
        _buildHeaderRow(),
        const SizedBox(height: 24),
        Expanded(child: _buildList()),
        _buildNewPlayerButton(),
        const SizedBox(height: 56),
      ],
    );
  }

  Widget _buildHeaderRow() {
    final current = LocaleService.instance.locale.value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          const SizedBox(width: 80),
          Expanded(
            child: Text(
              S.current.selectPlayer,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.cardGradientStart,
              ),
            ),
          ),
          _FlagButton(
            countryCode: 'GB',
            selected: current == AppLocale.en,
            onTap: () => _setLocale(AppLocale.en),
          ),
          const SizedBox(width: 6),
          _FlagButton(
            countryCode: 'NO',
            selected: current == AppLocale.nb,
            onTap: () => _setLocale(AppLocale.nb),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_profiles.isEmpty) {
      return Center(
        child: Text(
          S.current.createFirstPlayer,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.cardGradientStart.withValues(alpha: 0.6),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _profiles.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        final name = _profiles[index];
        return ProfileCard(
          name: name,
          balance: _balances[name] ?? 0,
          avatarSvg: _avatarSvgs[name],
          onTap: () => _selectProfile(name),
          onEdit: () => _editAvatar(name),
          onDelete: () => _deleteProfile(name),
        );
      },
    );
  }

  Widget _buildNewPlayerButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _openNewPlayer,
          icon: const Icon(Icons.add, size: 22),
          label: Text(
            S.current.newPlayer,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.cardGradientStart,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            side: const BorderSide(color: AppColors.outline),
            elevation: 4,
          ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.cardGradientStart : AppColors.outline,
            width: selected ? 2.5 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            width: 36,
            height: 24,
            child: CountryFlag.fromCountryCode(countryCode),
          ),
        ),
      ),
    );
  }
}
