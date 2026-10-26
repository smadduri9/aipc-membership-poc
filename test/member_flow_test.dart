import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aipc_poc/main.dart';

void main() {
  testWidgets('member can log in with demo credentials and reach home', (tester) async {
    await tester.pumpWidget(const AipcApp());
    await tester.pump(const Duration(milliseconds: 1600));

    // Language: Hindi is default; switch to English and back.
    expect(find.text('अपनी भाषा चुनें'), findsOneWidget);
    await tester.tap(find.text('English'));
    await tester.pump();
    expect(find.text('Choose your language'), findsOneWidget);
    await tester.tap(find.text('हिन्दी'));
    await tester.pump();
    await tester.tap(find.text('आगे बढ़ें'));
    await tester.pump(const Duration(milliseconds: 300));

    // Phone: send button stays disabled until number and consent are given.
    await tester.enterText(find.byType(CupertinoTextField).first, '9876543210');
    await tester.pump();
    await tester.tap(find.byType(CupertinoSwitch));
    await tester.pump();
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

    final fresh = find.byType(CupertinoTextField);
    for (final (i, digit) in '123456'.split('').indexed) {
      await tester.enterText(fresh.at(i), digit);
      await tester.pump();
    }
    await tester.tap(find.text('सत्यापित करें'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();
    expect(find.textContaining('नमस्ते'), findsOneWidget);
    expect(find.text('सदस्य बनें'), findsOneWidget);
  });
}
