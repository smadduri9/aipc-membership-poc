import 'package:flutter_test/flutter_test.dart';

import 'package:aipc_poc/main.dart';

void main() {
  testWidgets('app opens on the landing page', (tester) async {
    await tester.pumpWidget(const AipcApp());
    await tester.pumpAndSettle();
    expect(find.text('AICP'), findsWidgets);
  });
}
