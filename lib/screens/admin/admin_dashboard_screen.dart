import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/mock_data.dart';
import '../../data/mock_repository.dart';
import '../../models/application.dart';
import '../../state/app_state.dart';
import '../../theme.dart';
import '../../utils/format.dart';
import '../../widgets/demo_badge.dart';
import '../../widgets/primary_button.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<MockRepository>();
    final all = repo.search();
    final awaiting = all.where((a) => a.status == AppStatus.submitted).length;
    final approved = all.where((a) => a.status == AppStatus.approved).length;
    final collected = all
        .where(
          (a) =>
              a.status == AppStatus.submitted || a.status == AppStatus.approved,
        )
        .fold<int>(0, (sum, a) => sum + a.amount);
    final byState = {
      for (final code in stateNames.keys)
        code: all.where((a) => a.state == code).length,
    };
    return Scaffold(
      backgroundColor: AppColors.grouped,
      appBar: AppBar(
        title: const Text('Dashboard'),
        leading: IconButton(
          tooltip: 'Back to member app',
          icon: const Icon(Icons.close),
          onPressed: () {
            final signedIn =
                context.read<AppState>().phone?.isNotEmpty ?? false;
            context.go(signedIn ? '/home' : '/phone');
          },
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: DemoBadge()),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                _StatTile(label: 'Total applications', value: '${all.length}'),
                _StatTile(label: 'Awaiting approval', value: '$awaiting'),
                _StatTile(label: 'Approved', value: '$approved'),
                _StatTile(
                  label: 'Amount collected',
                  value: formatRupees(collected),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.only(left: 16, bottom: 6),
              child: Text('BY STATE', style: AppText.sectionHeader),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  for (final entry in byState.entries)
                    ListTile(
                      title: Text(stateNames[entry.key]!),
                      trailing: Text(
                        '${entry.value}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Applications',
              onPressed: () => context.push('/admin/dashboard/list'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.push('/admin/dashboard/audit'),
              child: const Text('Audit log'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                context.read<AppState>().adminSignOut();
                context.go('/admin');
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.red),
              child: const Text('Log out'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppColors.grey)),
        ],
      ),
    );
  }
}
