import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppColors {
  static const navy = Color(0xFF1F2A5A);
  static const saffron = Color(0xFFF39C12);
  static const green = Color(0xFF1E8E3E);
  static const red = Color(0xFFC62828);
  static const grey = Color(0xFF6B7280);
  static const sheet = Color(0xFFF3F4F6);
}

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    platform: TargetPlatform.iOS,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.navy),
    scaffoldBackgroundColor: Colors.white,
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    }),
  );
}
