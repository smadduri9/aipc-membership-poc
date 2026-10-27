import 'package:flutter_test/flutter_test.dart';

import 'package:aipc_poc/data/pincode_lookup.dart';

void main() {
  testWidgets('sample PIN directory loads and finds a Punjab office', (
    tester,
  ) async {
    final index = await tester.runAsync(() => PinIndex.load());
    final offices = index!.forPin('142026');
    expect(offices, isNotEmpty);
    expect(offices.first.state, 'PB');
    expect(offices.first.district, 'Ludhiana');
  });
}
