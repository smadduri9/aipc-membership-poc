import 'package:flutter_test/flutter_test.dart';
import 'package:aipc_poc/main.dart';

void main() {
  testWidgets('app starts and shows AIPC', (tester) async {
    await tester.pumpWidget(const AipcApp());
    expect(find.text('AIPC'), findsWidgets);
  });
}
