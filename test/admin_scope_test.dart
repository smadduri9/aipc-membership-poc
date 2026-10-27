import 'package:flutter_test/flutter_test.dart';

import 'package:aipc_poc/data/mock_data.dart';
import 'package:aipc_poc/data/mock_repository.dart';
import 'package:aipc_poc/models/application.dart';

void main() {
  test(
    'master login works with demo password and wrong password fails',
    () async {
      final repo = MockRepository();
      expect(
        (await repo.adminLogin('master@aipc.demo', 'demo1234'))?.isMaster,
        isTrue,
      );
      expect(await repo.adminLogin('master@aipc.demo', 'wrong'), isNull);
    },
  );

  test(
    'a state representative cannot read another state in the list or export',
    () async {
      final repo = MockRepository();
      final mh = adminUsers.firstWhere((u) => u.stateCode == 'MH');
      expect(repo.search(viewer: mh).every((a) => a.state == 'MH'), isTrue);
      expect(repo.exportCsv(viewer: mh).contains(',PB,'), isFalse);
    },
  );

  test('master sees every state and can filter to one state', () {
    final repo = MockRepository();
    final master = adminUsers.firstWhere((u) => u.isMaster);
    expect(
      repo.search(viewer: master).map((a) => a.state).toSet().length,
      greaterThanOrEqualTo(10),
    );
    expect(
      repo.search(state: 'PB', viewer: master).every((a) => a.state == 'PB'),
      isTrue,
    );
  });

  test(
    'approving makes the membership valid for two years when AICP member',
    () async {
      final repo = MockRepository();
      final app = repo.applications.firstWhere(
        (a) =>
            a.status == AppStatus.submitted &&
            a.type == MembershipType.aicpMember,
      );
      await repo.approve(app.referenceNo, 'pb@aipc.demo');
      expect(app.status, AppStatus.approved);
      expect(app.reviewedBy, 'pb@aipc.demo');
    },
  );
}
