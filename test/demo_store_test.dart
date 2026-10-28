import 'package:flutter_test/flutter_test.dart';

import 'package:aipc_poc/data/demo_store.dart';
import 'package:aipc_poc/data/mock_repository.dart';
import 'package:aipc_poc/models/application.dart';

void main() {
  test(
    'demo data survives a restart: application, approval and notice',
    () async {
      String? saved;
      final repo = MockRepository(onSave: (json) => saved = json);
      final draft = Application()
        ..firstName = 'Asha'
        ..lastName = 'Verma'
        ..phone = '9876543210'
        ..state = 'PB'
        ..district = 'Ludhiana'
        ..cityVillage = 'Jagraon HO'
        ..pinCode = '142026';
      final app = await repo.submit(draft);
      await repo.approve(app.referenceNo, 'pb@aipc.demo');

      final restored = MockRepository(restore: DemoSnapshot.decode(saved));
      final again = restored.findByPhone('9876543210');
      expect(again?.name, 'Asha Verma');
      expect(again?.status, AppStatus.approved);
      expect(restored.unreadCount('9876543210'), 1);
      expect(restored.applications.length, repo.applications.length);
    },
  );

  test('reset puts the seed data back', () async {
    final repo = MockRepository();
    final seeded = repo.applications.length;
    await repo.submit(
      Application()
        ..phone = '9876543210'
        ..state = 'PB',
    );
    await repo.resetDemo();
    expect(repo.applications.length, seeded);
    expect(repo.findByPhone('9876543210'), isNull);
  });

  test('unreadable saved data falls back to fresh seed data', () {
    expect(DemoSnapshot.decode('not json'), isNull);
    expect(DemoSnapshot.decode(null), isNull);
  });
}
