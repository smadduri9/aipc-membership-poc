import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppColors {
  static const navy = Color(0xFF1F2A5A);
  static const saffron = Color(0xFFF39C12);
  static const green = Color(0xFF1E8E3E);
  static const red = Color(0xFFC62828);
  static const grey = Color(0xFF6B7280);
  static const sheet = Color(0xFFF3F4F6);

  /// iOS system grouped background and field fill (systemGroupedBackground / tertiarySystemFill).
  static const grouped = Color(0xFFF2F2F7);
  static const separator = Color(0x1F000000);
}

/// Text sizes from Apple's Human Interface Guidelines type scale.
class AppText {
  static const largeTitle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: AppColors.navy,
    height: 1.2,
  );
  static const headline = TextStyle(fontSize: 17, fontWeight: FontWeight.w600);
  static const body = TextStyle(fontSize: 17);
  static const footnote = TextStyle(fontSize: 13, color: AppColors.grey);
  static const sectionHeader = TextStyle(
    fontSize: 13,
    color: AppColors.grey,
    letterSpacing: 0.2,
  );
}

ThemeData buildTheme() {
  const fieldRadius = BorderRadius.all(Radius.circular(10));
  return ThemeData(
    useMaterial3: true,
    platform: TargetPlatform.iOS,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.navy,
      primary: AppColors.navy,
    ),
    scaffoldBackgroundColor: Colors.white,
    // iOS has highlight feedback rather than Material ink ripples.
    splashFactory: NoSplash.splashFactory,
    highlightColor: const Color(0x14000000),
    // iOS-style navigation bar: white, flat, centred 17pt semibold title, hairline divider.
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.navy,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      shape: Border(bottom: BorderSide(color: AppColors.separator, width: 0.5)),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    // iOS text fields: filled, borderless, 10pt corners; focus and error shown with a thin outline.
    // iOS text fields: filled, borderless, 10pt corners, label kept inside the field.
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: AppColors.grouped,
      contentPadding: EdgeInsets.fromLTRB(14, 10, 14, 10),
      border: UnderlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide.none,
      ),
      enabledBorder: UnderlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide.none,
      ),
      disabledBorder: UnderlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide.none,
      ),
      focusedBorder: UnderlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide(color: AppColors.navy, width: 2),
      ),
      errorBorder: UnderlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide(color: AppColors.red, width: 1.5),
      ),
      focusedErrorBorder: UnderlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide(color: AppColors.red, width: 2),
      ),
      floatingLabelStyle: TextStyle(color: AppColors.navy),
      counterStyle: TextStyle(height: 0, fontSize: 0),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.navy,
        textStyle: const TextStyle(fontSize: 17),
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {TargetPlatform.iOS: CupertinoPageTransitionsBuilder()},
    ),
  );
}
