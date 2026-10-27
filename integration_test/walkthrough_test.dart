import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:aipc_poc/main.dart' as app;
import 'package:aipc_poc/widgets/avatar.dart';
import 'package:aipc_poc/widgets/cupertino_select.dart';

/// Walks the full member and admin journey on a simulator and screenshots every screen.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> wait(WidgetTester tester, [int ms = 800]) async {
    for (var elapsed = 0; elapsed < ms; elapsed += 100) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('full demo walkthrough', (tester) async {
    var step = 0;
    Future<void> shot(String name) async {
      step++;
      await wait(tester, 400);
      await binding.takeScreenshot('${step.toString().padLeft(2, '0')}-$name');
    }

    Future<void> pick(String label) async {
      await tester.tap(find.widgetWithText(CupertinoSelect, label));
      await wait(tester, 600);
      await tester.tap(find.text('हो गया'));
      await wait(tester, 600);
    }

    app.main();
    await wait(tester, 2500);
    await shot('language');

    await tester.tap(find.text('आगे बढ़ें'));
    await wait(tester);
    await tester.enterText(find.byType(CupertinoTextField).first, '9876543210');
    await tester.tap(find.byType(CupertinoSwitch));
    await wait(tester, 300);
    await shot('phone');

    await tester.tap(find.text('OTP भेजें'));
    await wait(tester, 1500);
    await shot('otp');

    await tester.enterText(find.byType(CupertinoTextField).first, '123456');
    await wait(tester, 300);
    await tester.tap(find.text('सत्यापित करें'));
    await wait(tester, 1500);
    await shot('home');

    await tester.tap(find.text('सदस्य बनें'));
    await wait(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'पूरा नाम *'),
      'Ravi Kumar',
    );
    await tester.tap(find.widgetWithText(CupertinoSelect, 'पेशेवर क्षेत्र *'));
    await wait(tester, 600);
    await shot('domain-picker');
    await tester.tap(find.text('हो गया'));
    await wait(tester, 600);
    await shot('register-personal');

    // Language can be changed mid-journey without losing entered data.
    await tester.tap(find.byIcon(CupertinoIcons.globe));
    await wait(tester, 600);
    await shot('language-sheet');
    await tester.tap(find.text('English'));
    await wait(tester, 600);
    await shot('register-personal-english');
    await tester.tap(find.byIcon(CupertinoIcons.globe));
    await wait(tester, 600);
    await tester.tap(find.text('हिन्दी'));
    await wait(tester, 600);

    await tester.tap(find.text('आगे'));
    await wait(tester);
    await pick('राज्य *');
    await pick('लोकसभा क्षेत्र *');
    await pick('विधानसभा क्षेत्र *');
    await tester.enterText(
      find.widgetWithText(TextField, 'पिन कोड *'),
      '141001',
    );
    await wait(tester, 300);
    await shot('register-location');

    await tester.tap(find.text('आगे'));
    await wait(tester);
    await tester.tap(find.text('सेल्फ़ी लें'));
    await wait(tester, 600);
    await shot('selfie-sheet');
    await tester.tap(find.byType(Avatar).at(1));
    await wait(tester, 600);
    await shot('register-selfie');

    await tester.tap(find.text('आगे'));
    await wait(tester);
    await shot('register-membership');

    await tester.tap(find.text('आगे'));
    await wait(tester);
    await shot('review');

    await tester.tap(find.byType(CupertinoSwitch));
    await wait(tester, 300);
    await tester.tap(find.textContaining('जमा करें'));
    await wait(tester, 1500);
    await tester.tap(find.text('PhonePe'));
    await wait(tester, 300);
    await shot('payment');

    await tester.tap(find.text('Simulate success'));
    await wait(tester, 3000);
    await shot('payment-success');

    await tester.tap(find.text('स्थिति देखें'));
    await wait(tester);
    await shot('status-awaiting');

    await tester.tap(find.byType(BackButton));
    await wait(tester);
    await shot('home-with-application');

    await tester.tap(find.text('Admin login (demo)'));
    await wait(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Email'),
      'master@aipc.demo',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      'demo1234',
    );
    await wait(tester, 300);
    await shot('admin-login');

    await tester.tap(find.text('Log in'));
    await wait(tester, 1500);
    await shot('admin-dashboard');

    await tester.tap(find.text('Applications'));
    await wait(tester);
    await shot('admin-list');

    await tester.tap(find.textContaining('000101'));
    await wait(tester);
    await shot('admin-detail');

    await tester.tap(find.text('Approve'));
    await wait(tester, 600);
    await shot('admin-approve-dialog');
    await tester.tap(find.text('Approve').last);
    await wait(tester, 1500);
    await shot('admin-approved');

    await tester.tap(find.byType(BackButton));
    await wait(tester);
    await tester.tap(find.byType(BackButton));
    await wait(tester);
    await tester.tap(find.text('Audit log'));
    await wait(tester);
    await shot('admin-audit');

    await tester.tap(find.byType(BackButton));
    await wait(tester);
    await tester.tap(find.byIcon(Icons.close));
    await wait(tester);
    await tester.tap(find.text('स्थिति देखें'));
    await wait(tester);
    await shot('status-approved');

    await tester.tap(find.text('सदस्यता कार्ड देखें'));
    await wait(tester);
    await shot('membership-card');
  });
}
