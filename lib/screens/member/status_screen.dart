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
            if (repo.unreadCount(phone) > 0)
              _NewNoticeBanner(
                title: repo.notificationsFor(phone).first.title,
                body: repo.notificationsFor(phone).first.body,
                onTap: () => context.push('/home/notifications'),
              ),
            if (repo.unreadCount(phone) > 0) const SizedBox(height: 16),
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
                label: t(context, 'pay_cta'),
                onPressed: () => context.push('/home/membership'),
              ),
            if (app.status == AppStatus.awaitingPayment)
              PrimaryButton(
                label: t(context, 'pay_now_cta'),
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

/// Top banner for the newest unread notice (approval or rejection) on the status screen.
class _NewNoticeBanner extends StatelessWidget {
  const _NewNoticeBanner({
    required this.title,
    required this.body,
    required this.onTap,
  });

  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.navy,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(CupertinoIcons.bell_fill, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const Icon(CupertinoIcons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
