import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/mock_repository.dart';
import '../../utils/format.dart';
import '../../widgets/demo_badge.dart';

class AdminAuditScreen extends StatelessWidget {
  const AdminAuditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = context.watch<MockRepository>().auditLog;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit log'),
        actions: const [Padding(padding: EdgeInsets.only(right: 12), child: Center(child: DemoBadge()))],
      ),
      body: SafeArea(
        child: ListView.separated(
          itemCount: entries.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final e = entries[i];
            return ListTile(
              title: Text('${e.action} · ${e.referenceNo}'),
              subtitle: Text(
                [formatDateTime(e.at), e.actor, if (e.note != null) e.note!].join('\n'),
              ),
              isThreeLine: e.note != null,
            );
          },
        ),
      ),
    );
  }
}
