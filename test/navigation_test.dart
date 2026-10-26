import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:aipc_poc/data/mock_repository.dart';
import 'package:aipc_poc/router.dart';
import 'package:aipc_poc/state/app_state.dart';

void main() {
  // Every screen reached with `go` must still have a parent to return to.
  for (final location in [
    '/home/status',
    '/home/status/card',
    '/home/payment',
    '/language/phone',
    '/language/phone/otp',
    '/admin/dashboard/list',
  ]) {
    testWidgets('$location can navigate back', (tester) async {
      final router = buildRouter();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => MockRepository()),
            ChangeNotifierProvider(
              create: (_) => AppState()..setPhone('9876543210'),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pump(
        const Duration(seconds: 2),
      ); // let the splash timer fire
      router.go(location);
      await tester.pump(const Duration(milliseconds: 500));
      expect(router.canPop(), isTrue);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 2));
    });
  }
}
