import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/mock_repository.dart';
import '../../l10n/strings.dart';
import '../../models/application.dart';
import '../../state/app_state.dart';
import '../../theme.dart';
import '../../widgets/demo_badge.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/status_timeline.dart';

class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final phone = context.watch<AppState>().phone ?? '';
    final repo = context.watch<MockRepository>();
    final app = repo.findByPhone(phone) ?? context.watch<AppState>().draft;
    return Scaffold(
      appBar: AppBar(
        title: Text(t(context, 'status_title')),
        actions: const [Padding(padding: EdgeInsets.only(right: 12), child: Center(child: DemoBadge()))],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _ReferenceRow(referenceNo: app.referenceNo),
            const SizedBox(height: 12),
            Align(alignment: Alignment.centerLeft, child: StatusChip(status: app.status)),
            const SizedBox(height: 20),
            StatusTimeline(app: app),
            if (app.status == AppStatus.paymentFailed)
              PrimaryButton(label: t(context, 'retry_payment'), onPressed: () => context.go('/home/payment')),
            if (app.status == AppStatus.approved) ...[
              const SizedBox(height: 8),
              PrimaryButton(label: t(context, 'view_card'), onPressed: () => context.push('/home/status/card')),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReferenceRow extends StatelessWidget {
  const _ReferenceRow({required this.referenceNo});

  final String referenceNo;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            referenceNo.isEmpty ? '—' : referenceNo,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.navy),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: referenceNo));
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t(context, 'copied'))));
          },
        ),
      ],
    );
  }
}
