import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
import '../../utils/pdf_documents.dart';
import '../../utils/format.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final repo = context.watch<MockRepository>();
    final phone = appState.phone;
    final app = (phone == null || phone.isEmpty)
        ? null
        : repo.findByPhone(phone);
    // The member's own name once they have applied; a generic greeting before that.
    final name = (app?.name.isNotEmpty ?? false)
        ? app!.name
        : t(context, 'member');
    final unread = repo.unreadCount(phone ?? '');
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('${t(context, 'namaste')}, $name'),
        actions: [
          IconButton(
            tooltip: t(context, 'notifications'),
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text('$unread'),
              child: const Icon(CupertinoIcons.bell),
            ),
            onPressed: () => context.push('/home/notifications'),
          ),
          const NavActions(),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              if (app == null)
                _BecomeMemberCard(
                  onTap: () {
                    final state = context.read<AppState>();
                    state.resetDraft();
                    state.draft.phone = state.phone ?? '';
                    context.push('/home/register?step=0');
                  },
                )
              else
                _StatusCard(app: app),
              const SizedBox(height: 24),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: AppColors.red),
                onPressed: () {
                  context.read<AppState>()
                    ..setPhone('')
                    ..resetDraft();
                  context.go('/');
                },
                child: Text(t(context, 'logout')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BecomeMemberCard extends StatelessWidget {
  const _BecomeMemberCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.navy,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t(context, 'become_member'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    t(context, 'become_member_sub'),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

/// What the member sees once they have an application. It changes with the status so the
/// next step is always on this one screen: wait, pay, fix and resubmit, or use the card.
class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.app});

  final Application app;

  @override
  Widget build(BuildContext context) {
    switch (app.status) {
      case AppStatus.approved:
      case AppStatus.awaitingPayment:
        return _ApprovedCard(app: app);
      case AppStatus.active:
        return _ActiveCard(app: app);
      default:
        return _WaitingCard(app: app);
    }
  }
}

class _WaitingCard extends StatelessWidget {
  const _WaitingCard({required this.app});

  final Application app;

  @override
  Widget build(BuildContext context) {
    final rejected = app.status == AppStatus.rejected;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                app.referenceNo,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              StatusChip(status: app.status),
              if (rejected && app.rejectReason != null) ...[
                const SizedBox(height: 8),
                Text(app.rejectReason!),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          label: rejected ? 'Edit and resubmit' : t(context, 'view_status'),
          onPressed: () {
            if (rejected) {
              context.read<AppState>().draft = app;
              context.push('/home/register?step=0');
            } else {
              context.push('/home/status');
            }
          },
        ),
      ],
    );
  }
}

class _ApprovedCard extends StatelessWidget {
  const _ApprovedCard({required this.app});

  final Application app;

  @override
  Widget build(BuildContext context) {
    final chosen = app.status == AppStatus.awaitingPayment;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF4EA),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    CupertinoIcons.checkmark_circle_fill,
                    color: Color(0xFF1E6B34),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t(context, 'approved_title'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      color: Color(0xFF1E6B34),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                t(context, 'approved_body'),
                style: const TextStyle(color: Color(0xFF1E6B34)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          label: chosen ? t(context, 'pay_now_cta') : t(context, 'pay_cta'),
          onPressed: () =>
              context.push(chosen ? '/home/review' : '/home/membership'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => context.push('/home/status'),
          child: Text(t(context, 'view_status')),
        ),
      ],
    );
  }
}

class _ActiveCard extends StatelessWidget {
  const _ActiveCard({required this.app});

  final Application app;

  @override
  Widget build(BuildContext context) {
    final plan = app.type == MembershipType.patron ? 'Patron' : 'AICP Member';
    final until = app.validUntil == null
        ? 'Lifetime'
        : 'Valid till ${formatDate(app.validUntil!)}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t(context, 'active_member'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$plan · $until',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: StatusTimeline(app: app),
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          label: t(context, 'view_card'),
          onPressed: () => context.push('/home/status/card'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(CupertinoIcons.arrow_down_doc),
          label: Text(t(context, 'download_card')),
          onPressed: () => shareCard(app),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(CupertinoIcons.doc_text),
          label: Text(t(context, 'download_receipt')),
          onPressed: () => shareReceipt(app),
        ),
      ],
    );
  }
}
