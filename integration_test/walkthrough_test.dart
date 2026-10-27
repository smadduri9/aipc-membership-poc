import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'package:aipc_poc/data/mock_repository.dart';
import 'package:aipc_poc/main.dart' as app;
import 'package:aipc_poc/models/application.dart';
import 'package:aipc_poc/state/app_state.dart';

/// Member journey from landing to submitted application, then approval by the state representative
/// and payment. Runs on a simulator; English copy is selected at the start.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> settle(WidgetTester tester) =>
      tester.pumpAndSettle(const Duration(seconds: 3));

  /// Scrolls the form until the field is built, since long forms build items lazily.
  Future<void> reveal(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      150,
      scrollable: find.byType(Scrollable).first,
    );
  }

  testWidgets('member applies, is approved, chooses a plan and pays', (
    tester,
  ) async {
    app.main();
    await settle(tester);

    // Landing waits for Next; language follows; then Member.
    expect(find.text('AICP'), findsOneWidget);
    await tester.tap(find.text('आगे'));
    await settle(tester);
    await tester.tap(find.text('English'));
    await settle(tester);
    await tester.tap(find.text('Continue'));
    await settle(tester);
    await tester.tap(find.text('Member'));
    await settle(tester);

    // Phone and OTP (demo code 123456).
    await tester.enterText(find.byType(CupertinoTextField).first, '9812345678');
    await tester.tap(find.byType(CupertinoSwitch).first);
    await settle(tester);
    await tester.tap(find.text('Send OTP'));
    await settle(tester);
    for (var i = 0; i < 6; i++) {
      await tester.enterText(find.byType(CupertinoTextField).at(i), '${i + 1}');
      await tester.pump();
    }
    await tester.tap(find.text('Verify'));
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump();
    await tester.tap(find.text('Become a Member'));
    await settle(tester);

    // Step 1: identity and domain.
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
      '2345 6789 0124',
    );
    await tester.scrollUntilVisible(
      find.text('Choose your domain'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Choose your domain'));
    await settle(tester);
    await tester.tap(find.text('Academia'));
    await settle(tester);
    await tester.tap(find.text('Continue'));
    await settle(tester);

    // Step 2: location from PIN code.
    await tester.enterText(
      find.widgetWithText(TextField, 'PIN code'),
      '142026',
    );
    await settle(tester);
    await reveal(tester, find.widgetWithText(TextField, 'City / Village'));
    await tester.enterText(
      find.widgetWithText(TextField, 'City / Village'),
      'Ludhiana',
    );
    await tester.tap(find.text('Continue'));
    await settle(tester);

    // Step 3: photo (demo capture on the simulator), one social link, consent.
    await tester.pump(const Duration(seconds: 2));
    await tester.tap(find.textContaining('Take photo').first);
    await settle(tester);
    await reveal(tester, find.widgetWithText(TextField, 'Instagram'));
    await tester.enterText(
      find.widgetWithText(TextField, 'Instagram'),
      'https://www.instagram.com/ashaverma',
    );
    await reveal(tester, find.byType(CupertinoSwitch));
    await tester.tap(find.byType(CupertinoSwitch));
    await settle(tester);
    await tester.tap(find.text('Submit application'));
    await settle(tester);
    expect(find.text('Application received'), findsOneWidget);

    // State representative for Punjab approves the application.
    final repo = tester
        .element(find.byType(Scaffold).first)
        .read<MockRepository>();
    final application = repo.applications.lastWhere(
      (a) => a.phone == '9812345678',
    );
    await repo.approve(application.referenceNo, 'pb@aipc.demo');
    await settle(tester);

    // Member chooses the AICP Member plan and pays.
    await tester.tap(find.text('Track application'));
    await settle(tester);
    await tester.tap(find.text('Choose membership'));
    await settle(tester);
    await tester.tap(find.text('AICP Member'));
    await settle(tester);
    await tester.tap(find.text('Continue'));
    await settle(tester);
    expect(application.status, AppStatus.awaitingPayment);
    await tester.tap(find.text('Continue to payment'));
    await settle(tester);
    await tester.tap(find.text('Simulate success'));
    await tester.pump(const Duration(seconds: 2));
    await settle(tester);
    expect(application.status, AppStatus.active);
    expect(
      tester.element(find.byType(Scaffold).first).read<AppState>().phone,
      '9812345678',
    );
  });
}
