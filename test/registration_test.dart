import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:aipc_poc/data/mock_repository.dart';
import 'package:aipc_poc/screens/member/register_screen.dart';
import 'package:aipc_poc/state/app_state.dart';
import 'package:aipc_poc/theme.dart';

Widget _app() => MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => MockRepository()),
    ChangeNotifierProvider(
      create: (_) => AppState()
        ..setPhone('9876543210')
        ..setLang('en'),
    ),
  ],
  child: MaterialApp(theme: buildTheme(), home: const RegisterScreen()),
);

void main() {
  testWidgets('domain grid lists the client domains and picks one', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose your domain'));
    await tester.pumpAndSettle();
    expect(find.text('Academia'), findsOneWidget);
    await tester.tap(find.text('Academia'));
    await tester.pumpAndSettle();
    expect(find.text('Academia'), findsOneWidget);
    expect(find.text('Choose your domain'), findsNothing);
  });

  testWidgets('domain grid ends with Other', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose your domain'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Other'),
      200,
      scrollable: find.descendant(
        of: find.byType(GridView),
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.text('Other'), findsOneWidget);
  });

  testWidgets('identity step rejects an invalid Aadhaar number', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'First name'),
      'Asha',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Last name'),
      'Verma',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Aadhaar number'),
      '1234 5678 9012',
    );
    await tester.tap(find.text('Choose your domain'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Academia'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid 12-digit Aadhaar number'), findsOneWidget);
  });
}
