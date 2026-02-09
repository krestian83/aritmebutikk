import 'package:flutter/material.dart';
import 'package:fluttermoji/fluttermojiCircleAvatar.dart';

/// Displays the current fluttermoji avatar at a given [size].
class AvatarWidget extends StatelessWidget {
  final double size;

  const AvatarWidget({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return FluttermojiCircleAvatar(
      radius: size / 2,
      backgroundColor: Colors.grey.shade200,
    );
  }
}
