import 'package:flutter/material.dart';

import '../theme.dart';

const _avatarColors = [AppColors.navy, AppColors.saffron, AppColors.green];

/// Placeholder selfie: a coloured circle with initials. Used instead of a camera.
class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.index, required this.initials, this.size = 56});

  final int index;
  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: _avatarColors[index % _avatarColors.length],
      child: Text(
        initials.isEmpty ? '?' : initials,
        style: TextStyle(color: Colors.white, fontSize: size / 3, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// First letters of the first two words of [name].
String initialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  return parts.take(2).map((p) => p[0].toUpperCase()).join();
}
