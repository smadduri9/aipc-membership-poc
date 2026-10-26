import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/strings.dart';
import '../../theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) context.go('/language');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('AIPC', style: TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(t(context, 'app_subtitle'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 32),
              const CupertinoActivityIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
