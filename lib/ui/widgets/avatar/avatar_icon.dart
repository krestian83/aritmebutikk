import 'package:flutter/material.dart';

import '../../../game/services/avatar_service.dart';

/// Displays the player's emoji avatar at a given [size].
///
/// Always renders (with a default fallback emoji), so screens
/// don't need to check whether an avatar exists.
class AvatarIcon extends StatefulWidget {
  final String playerName;
  final double size;

  const AvatarIcon({super.key, required this.playerName, this.size = 40});

  @override
  State<AvatarIcon> createState() => _AvatarIconState();
}

class _AvatarIconState extends State<AvatarIcon> {
  String _emoji = AvatarService.defaultEmoji;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(AvatarIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playerName != widget.playerName) {
      _load();
    }
  }

  Future<void> _load() async {
    final emoji = await AvatarService.instance.getEmoji(widget.playerName);
    if (!mounted) return;
    setState(() => _emoji = emoji);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: FittedBox(child: Text(_emoji)),
    );
  }
}
