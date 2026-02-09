import 'package:flutter/material.dart';

import '../../../game/services/avatar_service.dart';
import 'avatar_widget.dart';

/// Self-loading avatar icon that loads the player's fluttermoji
/// from [AvatarService] before displaying.
///
/// Renders as an empty [SizedBox] if the player has no saved
/// avatar, so screens don't need to check separately.
class AvatarIcon extends StatefulWidget {
  final String playerName;
  final double size;

  const AvatarIcon({
    super.key,
    required this.playerName,
    this.size = 40,
  });

  @override
  State<AvatarIcon> createState() => _AvatarIconState();
}

class _AvatarIconState extends State<AvatarIcon> {
  final _service = AvatarService();
  bool _loaded = false;
  bool _hasAvatar = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(AvatarIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playerName != widget.playerName) {
      _loaded = false;
      _hasAvatar = false;
      _load();
    }
  }

  Future<void> _load() async {
    final exists = await _service.hasAvatar(widget.playerName);
    if (!exists) {
      if (!mounted) return;
      setState(() {
        _loaded = true;
        _hasAvatar = false;
      });
      return;
    }
    await _service.loadPlayer(widget.playerName);
    if (!mounted) return;
    setState(() {
      _loaded = true;
      _hasAvatar = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || !_hasAvatar) {
      return const SizedBox.shrink();
    }
    return AvatarWidget(size: widget.size);
  }
}
