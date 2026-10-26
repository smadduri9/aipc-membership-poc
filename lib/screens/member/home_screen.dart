import 'package:flutter/material.dart';
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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final repo = context.watch<MockRepository>();
    final phone = appState.phone;
    final app = (phone == null || phone.isEmpty) ? null : repo.findByPhone(phone);
    final name = app?.name ?? t(context, 'member');
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('${t(context, 'namaste')}, $name'),
        actions: const [Padding(padding: EdgeInsets.only(right: 12), child: Center(child: DemoBadge()))],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (app == null)
                _BecomeMemberCard(onTap: () {
                  final state = context.read<AppState>();
                  state.resetDraft();
                  state.draft.phone = state.phone ?? '';
                  context.push('/register?step=0');
                })
              else
                _StatusCard(app: app),
              const Spacer(),
              TextButton(onPressed: () => context.push('/admin'), child: const Text('Admin login (demo)')),
              const SizedBox(height: 4),
              PrimaryButton(
                label: t(context, 'logout'),
                color: AppColors.grey,
                onPressed: () {
                  context.read<AppState>().setPhone('');
                  context.go('/phone');
                },
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
        decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t(context, 'become_member'), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(t(context, 'become_member_sub'), style: const TextStyle(color: Colors.white70)),
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

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.app});

  final Application app;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(app.referenceNo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          StatusChip(status: app.status),
          const SizedBox(height: 16),
          PrimaryButton(label: t(context, 'view_status'), onPressed: () => context.push('/status')),
        ],
      ),
    );
  }
}
