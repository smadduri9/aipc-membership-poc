import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/mock_repository.dart';
import 'router.dart';
import 'state/app_state.dart';
import 'theme.dart';

void main() => runApp(const AipcApp());

class AipcApp extends StatelessWidget {
  const AipcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MockRepository()),
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: MaterialApp.router(
        title: 'AIPC',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        routerConfig: buildRouter(),
      ),
    );
  }
}
