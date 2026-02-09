import 'package:flutter/material.dart';

import '../../../game/services/avatar_service.dart';
import 'avatar_widget.dart';

/// Self-loading avatar icon that loads the player's fluttermoji
/// from [AvatarService] before displaying.
class AvatarIcon extends StatefulWidget {
  final String playerName;
  final double size;

  const AvatarIcon({super.key, required this.playerName, this.size = 40});

  @override
  State<AvatarIcon> createState() => _AvatarIconState();
}

class _AvatarIconState extends State<AvatarIcon> {
  final _service = AvatarService();
  bool _loaded = false;

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
      _load();
    }
  }

  Future<void> _load() async {
    await _service.loadPlayer(widget.playerName);
    if (!mounted) return;
    setState(() => _loaded = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return SizedBox(width: widget.size, height: widget.size);
    }
    return AvatarWidget(size: widget.size);
  }
}
