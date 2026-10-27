import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:aipc_poc/data/mock_repository.dart';
import 'package:aipc_poc/router.dart';
import 'package:aipc_poc/state/app_state.dart';

void main() {
  testWidgets('landing stays until Next is tapped, then opens language', (
    tester,
  ) async {
    final router = buildRouter();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MockRepository()),
          ChangeNotifierProvider(create: (_) => AppState()),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('AICP'), findsOneWidget);

    // No auto-advance.
    await tester.pump(const Duration(seconds: 10));
    expect(router.routeInformationProvider.value.uri.path, '/');

    // Tapping Next leaves the landing page.
    await tester.tap(find.text('आगे'));
    await tester.pumpAndSettle();
    expect(find.text('अपनी भाषा चुनें'), findsOneWidget);
  });
}
