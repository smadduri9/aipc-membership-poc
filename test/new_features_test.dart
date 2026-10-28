import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:aipc_poc/data/mock_data.dart';
import 'package:aipc_poc/data/mock_repository.dart';
import 'package:aipc_poc/models/application.dart';
import 'package:aipc_poc/screens/member/home_screen.dart';
import 'package:aipc_poc/state/app_state.dart';
import 'package:aipc_poc/theme.dart';
import 'package:aipc_poc/utils/pdf_documents.dart';

void main() {
  test('new applications are tracked per state and clear when seen', () async {
    final repo = MockRepository();
    final rep = adminUsers.firstWhere((u) => u.email == 'pb@aipc.demo');
    final since = DateTime.now();
    expect(repo.newApplications(rep, since, {}), isEmpty);

    final draft = Application()
      ..firstName = 'Asha'
      ..lastName = 'Verma'
      ..phone = '9812345678'
      ..state = 'PB';
    final app = await repo.submit(draft);
    expect(repo.newApplications(rep, since, {}).single.name, 'Asha Verma');
    expect(repo.newApplications(rep, since, {app.referenceNo}), isEmpty);

    final other = adminUsers.firstWhere((u) => u.email == 'dl@aipc.demo');
    expect(repo.newApplications(other, since, {}), isEmpty);
  });

  testWidgets('receipt and card PDFs are built', (tester) async {
    final app = Application()
      ..firstName = 'Asha'
      ..lastName = 'Verma'
      ..referenceNo = 'AICP-PB-26-000101'
      ..state = 'PB'
      ..amount = 1000
      ..paymentId = 'pay_Demo123'
      ..status = AppStatus.active;
    final receipt = await tester.runAsync(() => buildReceiptPdf(app));
    final card = await tester.runAsync(() => buildCardPdf(app));
    expect(receipt!.length, greaterThan(1000));
    expect(card!.length, greaterThan(1000));
  });

  testWidgets('approved member sees the approval and a pay button', (
    tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MockRepository()),
          ChangeNotifierProvider(
            create: (_) => AppState()
              ..setPhone(MockRepository.approvedDemoPhone)
              ..setLang('en'),
          ),
        ],
        child: MaterialApp(theme: buildTheme(), home: const HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text("You're approved"), findsOneWidget);
    expect(find.text('Choose membership and pay'), findsOneWidget);
  });
}
