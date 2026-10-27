import 'package:flutter_test/flutter_test.dart';

import 'package:aipc_poc/data/mock_data.dart';
import 'package:aipc_poc/data/mock_repository.dart';
import 'package:aipc_poc/data/reference_data.dart';
import 'package:aipc_poc/models/application.dart';

void main() {
  test(
    '36 states and UTs, 24 domains, one representative each plus master',
    () {
      expect(regions.length, 36);
      expect(professionalDomains.length, 24);
      expect(adminUsers.where((u) => u.isMaster).length, 1);
      expect(adminUsers.where((u) => !u.isMaster).length, 36);
    },
  );

  test('seed covers at least 10 states and UTs with applications', () {
    final repo = MockRepository();
    final states = repo.applications.map((a) => a.state).toSet();
    expect(states.length, greaterThanOrEqualTo(10));
  });

  test('state representative only sees their own state', () async {
    final repo = MockRepository();
    final punjab = adminUsers.firstWhere((u) => u.stateCode == 'PB');
    final apps = repo.search(viewer: punjab);
    expect(apps, isNotEmpty);
    expect(apps.every((a) => a.state == 'PB'), isTrue);
  });

  test('dashboard money counts only active memberships', () {
    final repo = MockRepository();
    final stats = repo.dashboardStats();
    expect(
      stats.money,
      repo.applications
          .where((a) => a.status == AppStatus.active)
          .fold<int>(0, (sum, a) => sum + a.amount),
    );
  });
}
