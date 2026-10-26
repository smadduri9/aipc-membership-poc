import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:aipc_poc/data/mock_repository.dart';
import 'package:aipc_poc/screens/member/register_screen.dart';
import 'package:aipc_poc/state/app_state.dart';
import 'package:aipc_poc/theme.dart';
import 'package:aipc_poc/widgets/cupertino_select.dart';

void main() {
  testWidgets('tapping the professional domain field opens the picker', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MockRepository()),
          ChangeNotifierProvider(create: (_) => AppState()),
        ],
        child: MaterialApp(
          theme: buildTheme(),
          home: const RegisterScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byType(CupertinoSelect));
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoPicker), findsOneWidget);
    await tester.tap(find.text('हो गया'));
    await tester.pumpAndSettle();
    expect(find.text('Civil Society & Policy Research'), findsOneWidget);
  });
}
