import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/mock_repository.dart';
import '../../l10n/strings.dart';
import '../../models/application.dart';
import '../../state/app_state.dart';
import '../../theme.dart';
import '../../widgets/nav_actions.dart';
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
      backgroundColor: AppColors.grouped,
      appBar: AppBar(
        title: Text(t(context, 'status_title')),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: Badge(
              isLabelVisible: repo.unreadCount(phone) > 0,
              label: Text('${repo.unreadCount(phone)}'),
              child: const Icon(CupertinoIcons.bell),
            ),
            onPressed: () => context.push('/home/notifications'),
          ),
          const NavActions(),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ReferenceRow(referenceNo: app.referenceNo),
                  StatusChip(status: app.status),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: StatusTimeline(app: app),
            ),
            const SizedBox(height: 16),
            if (app.status == AppStatus.approved)
              PrimaryButton(
                label: 'Choose membership',
                onPressed: () => context.push('/home/membership'),
              ),
            if (app.status == AppStatus.awaitingPayment)
              PrimaryButton(
                label: 'Review and pay',
                onPressed: () => context.push('/home/review'),
              ),
            if (app.status == AppStatus.paymentFailed)
              PrimaryButton(
                label: t(context, 'retry_payment'),
                onPressed: () => context.go('/home/payment'),
              ),
            if (app.status == AppStatus.rejected)
              PrimaryButton(
                label: 'Edit and resubmit',
                onPressed: () {
                  context.read<AppState>().draft = app;
                  context.go('/home/register?step=0');
                },
              ),
            if (app.status == AppStatus.active)
              PrimaryButton(
                label: t(context, 'view_card'),
                onPressed: () => context.push('/home/status/card'),
              ),
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
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: referenceNo));
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(t(context, 'copied'))));
          },
        ),
      ],
    );
  }
}
