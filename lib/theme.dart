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
    // iOS-style navigation bar: white, flat, centred 17pt semibold title, hairline divider.
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.navy,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black),
      shape: Border(bottom: BorderSide(color: Color(0x1F000000), width: 0.5)),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    }),
  );
}
