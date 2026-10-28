import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/demo_store.dart';
import 'data/mock_repository.dart';
import 'router.dart';
import 'state/app_state.dart';
import 'theme.dart';
import 'widgets/admin_live_pill.dart';

const _demoKey = 'aipc_demo_v1';

/// Loads the saved demo data so applications and approvals survive an app restart.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences? prefs;
  try {
    prefs = await SharedPreferences.getInstance();
  } catch (_) {
    // No storage (for example in some test hosts): run with fresh seed data.
  }
  final repo = MockRepository(
    restore: DemoSnapshot.decode(prefs?.getString(_demoKey)),
    onSave: prefs == null ? null : (json) => prefs!.setString(_demoKey, json),
  );
  runApp(AipcApp(repository: repo));
}

class AipcApp extends StatefulWidget {
  const AipcApp({super.key, this.repository});

  /// Defaults to fresh seed data, which is what widget tests use.
  final MockRepository? repository;

  @override
  State<AipcApp> createState() => _AipcAppState();
}

class _AipcAppState extends State<AipcApp> {
  final _router = buildRouter();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => widget.repository ?? MockRepository(),
        ),
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: MaterialApp.router(
        title: 'AICP',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        routerConfig: _router,
        builder: (context, child) =>
            AdminLivePill(router: _router, child: child ?? const SizedBox()),
      ),
    );
  }
}
