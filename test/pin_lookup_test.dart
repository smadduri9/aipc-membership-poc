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

  test('state comes from the PIN prefix for any valid PIN', () {
    expect(stateForPin('500042'), 'TS');
    expect(stateForPin('110001'), 'DL');
    expect(stateForPin('160017'), 'CH');
    expect(stateForPin('403001'), 'GA');
    expect(stateForPin('834001'), 'JH');
    expect(stateForPin('248001'), 'UK');
    expect(stateForPin('781001'), 'AS');
    expect(stateForPin('600001'), 'TN');
    expect(stateForPin('012345'), isNull);
  });
}
