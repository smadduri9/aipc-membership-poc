import 'package:flutter_test/flutter_test.dart';

import 'package:aipc_poc/data/mock_repository.dart';
import 'package:aipc_poc/models/application.dart';

void main() {
  test('approved member chooses a plan, pays, and gets an active membership with notices', () async {
    final repo = MockRepository();
    final app = repo.applications.firstWhere(
      (a) => a.status == AppStatus.submitted,
    );
    await repo.approve(app.referenceNo, 'pb@aipc.demo');
    expect(
      repo.notificationsFor(app.phone).first.title,
      'Application approved',
    );

    await repo.chooseMembership(app.referenceNo, MembershipType.patron, 50000);
    expect(app.status, AppStatus.awaitingPayment);
    expect(app.amount, 50000);

    await repo.fakePay(app.referenceNo, success: true);
    expect(app.status, AppStatus.active);
    expect(app.paymentId, isNotNull);
    expect(repo.notificationsFor(app.phone).first.title, 'Membership active');
    expect(repo.unreadCount(app.phone), greaterThan(0));
    repo.markAllRead(app.phone);
    expect(repo.unreadCount(app.phone), 0);
  });

  test('AICP membership costs 1000 and is valid for two years', () async {
    final repo = MockRepository();
    final app = repo.applications.firstWhere(
      (a) => a.status == AppStatus.submitted,
    );
    await repo.approve(app.referenceNo, 'pb@aipc.demo');
    await repo.chooseMembership(
      app.referenceNo,
      MembershipType.aicpMember,
      999999,
    );
    expect(app.amount, 1000);
    await repo.fakePay(app.referenceNo, success: true);
    expect(
      app.validUntil!.difference(DateTime.now()).inDays,
      greaterThanOrEqualTo(729),
    );
  });
}
