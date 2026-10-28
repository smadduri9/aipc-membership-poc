import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aipc_poc/screens/member/register_screen.dart';
import 'package:provider/provider.dart';

import 'package:aipc_poc/data/mock_repository.dart';
import 'package:aipc_poc/router.dart';
import 'package:aipc_poc/state/app_state.dart';

void main() {
  testWidgets('first sign-in with the demo number opens the application form', (
    tester,
  ) async {
    // Landing is covered in landing_test.dart; this flow starts at language.
    final router = buildRouter()..go('/language');
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

    // Language: Hindi is default; switch to English and back.
    expect(find.text('अपनी भाषा चुनें'), findsOneWidget);
    await tester.tap(find.text('English'));
    await tester.pump();
    expect(find.text('Choose your language'), findsOneWidget);
    await tester.tap(find.text('हिन्दी'));
    await tester.pump();
    await tester.tap(find.text('आगे बढ़ें'));
    await tester.pump(const Duration(milliseconds: 300));

    // Role: choose member.
    await tester.tap(find.text('सदस्य'));
    await tester.pump(const Duration(milliseconds: 300));

    // Phone: the DEMO badge fills the demo number and consent.
    await tester.tap(find.text('DEMO'));
    await tester.pump();
    expect(find.text('9876543210'), findsOneWidget);
    await tester.tap(find.text('OTP भेजें'));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(milliseconds: 300));

    // OTP: a wrong code shows an error; the demo code opens home.
    final boxes = find.byType(CupertinoTextField);
    for (var i = 0; i < 6; i++) {
      await tester.enterText(boxes.at(i), '1');
      await tester.pump();
    }
    await tester.tap(find.text('सत्यापित करें'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();
    expect(find.text('गलत कोड। फिर से प्रयास करें।'), findsOneWidget);

    // Pasting the whole code into the first box fills every box, as iOS SMS autofill does.
    await tester.enterText(find.byType(CupertinoTextField).first, '123456');
    await tester.pump();
    await tester.tap(find.text('सत्यापित करें'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();
    // A first sign-in goes straight to the application form.
    expect(find.byType(RegisterScreen), findsOneWidget);
  });
}
