import 'package:flutter/cupertino.dart';
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
  testWidgets('domain list picks a domain', (
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

  testWidgets('domain list ends with Other and can be searched', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose your domain'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(CupertinoSearchTextField), 'oth');
    await tester.pumpAndSettle();
    expect(find.text('Other'), findsOneWidget);
    expect(find.text('Academia'), findsNothing);
  });

  testWidgets('identity step rejects an Aadhaar number that is not 12 digits', (
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
      '1234 5678 901',
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
