import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/mock_data.dart';
import '../../data/mock_repository.dart';
import '../../data/reference_data.dart';
import '../../models/application.dart';
import '../../state/app_state.dart';
import '../../theme.dart';
import '../../utils/format.dart';
import '../../widgets/demo_badge.dart';

/// Home for admins. A state representative sees their own state.
/// The master sees every state and can open any state's dashboard, which is the same screen the representative sees.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AppState>().admin;
    if (admin == null) return const Scaffold(body: SizedBox());
    if (!admin.isMaster) {
      return StateDashboardScreen(stateCode: admin.stateCode!, asMaster: false);
    }
    return const _MasterDashboard();
  }
}

/// Stats and pending applications for one state or UT.
class StateDashboardScreen extends StatelessWidget {
  const StateDashboardScreen({
    super.key,
    required this.stateCode,
    required this.asMaster,
  });

  final String stateCode;
  final bool asMaster;

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<MockRepository>();
    final stats = repo.dashboardStats(stateCode: stateCode);
    final pending = repo
        .search(state: stateCode, status: AppStatus.submitted)
        .take(5)
        .toList();
    final name = stateNames[stateCode] ?? stateCode;
    return Scaffold(
      backgroundColor: AppColors.grouped,
      appBar: AppBar(
        title: Text('$name dashboard'),
        leading: asMaster
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/admin/dashboard'),
              )
            : IconButton(
                tooltip: 'Back to member app',
                icon: const Icon(Icons.close),
                onPressed: () => context.go('/'),
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
            if (asMaster)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Viewing as Master · $name'),
              ),
            _Tiles(
              tiles: [
                ('Applications', '${stats.total}'),
                ('Pending', '${stats.pending}'),
                ('Approved', '${stats.approved}'),
                ('Active members', '${stats.active}'),
              ],
            ),
            const SizedBox(height: 12),
            _MoneyCard(amount: stats.money, label: 'Money collected in $name'),
            const SizedBox(height: 20),
            const Text('Pending approvals', style: AppText.sectionTitle),
            const SizedBox(height: 8),
            if (pending.isEmpty)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Nothing waiting for review.',
                  style: TextStyle(color: AppColors.grey),
                ),
              ),
            for (final app in pending)
              ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Text(app.name),
                subtitle: Text(
                  '${app.referenceNo} · ${formatRupees(app.amount)}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    context.push('/admin/dashboard/detail/${app.referenceNo}'),
              ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.push('/admin/dashboard/list'),
              child: const Text('See all applications'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MasterDashboard extends StatelessWidget {
  const _MasterDashboard();

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<MockRepository>();
    final all = repo.dashboardStats();
    final rows = [
      for (final r in regions)
        (
          code: r.code,
          name: r.name,
          stats: repo.dashboardStats(stateCode: r.code),
        ),
    ]..sort((a, b) => b.stats.total.compareTo(a.stats.total));
    return Scaffold(
      backgroundColor: AppColors.grouped,
      appBar: AppBar(
        title: const Text('All states and UTs'),
        leading: IconButton(
          tooltip: 'Back to member app',
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/'),
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
            _Tiles(
              tiles: [
                ('Applications', '${all.total}'),
                ('Pending', '${all.pending}'),
                ('Approved', '${all.approved}'),
                ('Active members', '${all.active}'),
              ],
            ),
            const SizedBox(height: 12),
            _MoneyCard(amount: all.money, label: 'Money collected, all states'),
            const SizedBox(height: 20),
            const Text('By state or UT', style: AppText.sectionTitle),
            const SizedBox(height: 4),
            const Text(
              'Tap a state to open its dashboard.',
              style: TextStyle(color: AppColors.grey),
            ),
            const SizedBox(height: 8),
            for (final row in rows)
              ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Text(row.name),
                subtitle: Text(
                  '${row.stats.total} applications · ${row.stats.pending} pending · '
                  '${formatRupees(row.stats.money)}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/admin/dashboard/state/${row.code}'),
              ),
          ],
        ),
      ),
    );
  }
}

class _Tiles extends StatelessWidget {
  const _Tiles({required this.tiles});

  final List<(String, String)> tiles;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        for (final (label, value) in tiles)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
                Text(label, style: const TextStyle(color: AppColors.grey)),
              ],
            ),
          ),
      ],
    );
  }
}

class _MoneyCard extends StatelessWidget {
  const _MoneyCard({required this.amount, required this.label});

  final int amount;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 4),
          Text(
            formatRupees(amount),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
