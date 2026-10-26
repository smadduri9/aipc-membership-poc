import 'package:flutter_test/flutter_test.dart';

import 'package:aipc_poc/data/mock_repository.dart';
import 'package:aipc_poc/models/application.dart';

Application _draft() => Application()
  ..name = 'Test Member'
  ..phone = '9876543210'
  ..state = 'PB'
  ..type = MembershipType.ordinary
  ..amount = 1000;

void main() {
  test('submit assigns the first reference number after the seed data', () async {
    final repo = MockRepository();
    final app = await repo.submit(_draft());
    expect(app.referenceNo, 'AIPC-PB-26-000101');
  });

  test('verifyOtp accepts only the demo code', () async {
    final repo = MockRepository();
    expect(await repo.verifyOtp('9876543210', '000000'), isFalse);
    expect(await repo.verifyOtp('9876543210', '123456'), isTrue);
  });

  test('approve sets validity two years ahead for ordinary members', () async {
    final repo = MockRepository();
    final app = await repo.submit(_draft());
    await repo.fakePay(app.referenceNo, success: true);
    await repo.approve(app.referenceNo, 'admin@aipc.demo');
    expect(app.status, AppStatus.approved);
    expect(app.validUntil!.difference(app.approvedAt!), const Duration(days: 730));
  });
}
