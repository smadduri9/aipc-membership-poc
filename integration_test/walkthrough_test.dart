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

  // Fixed-time pumps: pumpAndSettle can wait for minutes when a spinner keeps animating.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
  }

  /// Pumps until the finder matches (up to 15 seconds), so taps follow the animations in each screen.
  Future<void> waitFor(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 60 && finder.evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }
  }

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
    await waitFor(tester, find.text('आगे'));
    await tester.tap(find.text('आगे'));
    await settle(tester);
    await waitFor(tester, find.text('English'));
    await tester.tap(find.text('English'));
    await settle(tester);
    await waitFor(tester, find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await settle(tester);
    await waitFor(tester, find.text('Member'));
    await tester.tap(find.text('Member'));
    await settle(tester);

    // Phone and OTP (demo code 123456).
    await tester.enterText(find.byType(CupertinoTextField).first, '9812345678');
    await waitFor(tester, find.byType(CupertinoSwitch).first);
    await tester.tap(find.byType(CupertinoSwitch).first);
    await settle(tester);
    await waitFor(tester, find.text('Send OTP'));
    await tester.tap(find.text('Send OTP'));
    await settle(tester);
    for (var i = 0; i < 6; i++) {
      await waitFor(tester, find.byType(CupertinoTextField).at(i));
      await tester.enterText(find.byType(CupertinoTextField).at(i), '${i + 1}');
      await tester.pump();
    }
    await waitFor(tester, find.text('Verify'));
    await tester.tap(find.text('Verify'));
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump();
    await waitFor(tester, find.text('Become a Member'));
    await tester.tap(find.text('Become a Member'));
    await settle(tester);

    // Step 1: identity and domain.
    await waitFor(tester, find.widgetWithText(TextField, 'First name'));
    await tester.enterText(
      find.widgetWithText(TextField, 'First name'),
      'Asha',
    );
    await waitFor(tester, find.widgetWithText(TextField, 'Last name'));
    await tester.enterText(
      find.widgetWithText(TextField, 'Last name'),
      'Verma',
    );
    await waitFor(tester, find.widgetWithText(TextField, 'Aadhaar number'));
    await tester.enterText(
      find.widgetWithText(TextField, 'Aadhaar number'),
      '2345 6789 0124',
    );
    await tester.scrollUntilVisible(
      find.text('Choose your domain'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await waitFor(tester, find.text('Choose your domain'));
    await tester.tap(find.text('Choose your domain'));
    await settle(tester);
    await waitFor(tester, find.text('Academia'));
    await tester.tap(find.text('Academia'));
    await settle(tester);
    await waitFor(tester, find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await settle(tester);

    // Step 2: location from PIN code.
    await waitFor(tester, find.widgetWithText(TextField, 'PIN code'));
    await tester.enterText(
      find.widgetWithText(TextField, 'PIN code'),
      '142026',
    );
    await settle(tester);
    await reveal(tester, find.widgetWithText(TextField, 'City / Village'));
    await waitFor(tester, find.widgetWithText(TextField, 'City / Village'));
    await tester.enterText(
      find.widgetWithText(TextField, 'City / Village'),
      'Ludhiana',
    );
    await waitFor(tester, find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await settle(tester);

    // Step 3: photo (demo capture on the simulator), one social link, consent.
    await tester.pump(const Duration(seconds: 2));
    await waitFor(tester, find.textContaining('Take photo').first);
    await tester.tap(find.textContaining('Take photo').first);
    await settle(tester);
    await reveal(tester, find.widgetWithText(TextField, 'Instagram'));
    await waitFor(tester, find.widgetWithText(TextField, 'Instagram'));
    await tester.enterText(
      find.widgetWithText(TextField, 'Instagram'),
      'https://www.instagram.com/ashaverma',
    );
    await reveal(tester, find.byType(CupertinoSwitch));
    await waitFor(tester, find.byType(CupertinoSwitch));
    await tester.tap(find.byType(CupertinoSwitch));
    await settle(tester);
    await waitFor(tester, find.text('Submit application'));
    await tester.tap(find.text('Submit application'));
    await settle(tester);
    await waitFor(tester, find.text('Application received'));
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
    await waitFor(tester, find.text('Track application'));
    await tester.tap(find.text('Track application'));
    await settle(tester);
    await waitFor(tester, find.text('Choose membership'));
    await tester.tap(find.text('Choose membership'));
    await settle(tester);
    await waitFor(tester, find.text('AICP Member'));
    await tester.tap(find.text('AICP Member'));
    await settle(tester);
    await waitFor(tester, find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await settle(tester);
    expect(application.status, AppStatus.awaitingPayment);
    await waitFor(tester, find.text('Continue to payment'));
    await tester.tap(find.text('Continue to payment'));
    await settle(tester);
    await waitFor(tester, find.text('Simulate success'));
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
