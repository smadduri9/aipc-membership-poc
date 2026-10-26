import 'package:flutter/material.dart';
import 'router.dart';
import 'theme.dart';

void main() => runApp(const AipcApp());

class AipcApp extends StatelessWidget {
  const AipcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AIPC',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      routerConfig: buildRouter(),
    );
  }
}
