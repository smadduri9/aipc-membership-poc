import 'package:flutter/cupertino.dart';
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
import 'admin_review_screen.dart';

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
    final state = context.watch<AppState>();
    final admin = state.admin;
    final fresh = admin == null
        ? <Application>[]
        : repo.newApplications(
            admin,
            state.adminSignedInAt,
            state.seenRefs,
            stateCode: stateCode,
          );
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
                tooltip: 'Log out',
                icon: const Icon(CupertinoIcons.square_arrow_left),
                onPressed: () {
                  context.read<AppState>().adminSignOut();
                  context.go('/');
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
            Text(
              _greeting(),
              style: const TextStyle(color: AppColors.grey, fontSize: 15),
            ),
            const SizedBox(height: 2),
            Text(
              name,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
            if (asMaster)
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Text(
                  'Viewing as Master',
                  style: TextStyle(color: AppColors.grey),
                ),
              ),
            const SizedBox(height: 16),
            _NewCard(
              fresh: fresh,
              waiting: stats.pending,
              onReview: () {
                if (admin != null) {
                  context.read<AppState>().markSeen(
                    fresh.map((a) => a.referenceNo),
                  );
                }
                context.push('/admin/dashboard/review?state=$stateCode');
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _MiniStat('Approved', '${stats.approved}')),
                const SizedBox(width: 12),
                Expanded(child: _MiniStat('Active', '${stats.active}')),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniStat('Collected', formatRupees(stats.money)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Text('All applications'),
                trailing: const Icon(CupertinoIcons.chevron_right, size: 18),
                onTap: () => context.push('/admin/dashboard/list'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    return h < 12
        ? 'Good morning'
        : h < 17
        ? 'Good afternoon'
        : 'Good evening';
  }
}

/// Navy card: how many new applications, their faces, and one Review button.
class _NewCard extends StatelessWidget {
  const _NewCard({
    required this.fresh,
    required this.waiting,
    required this.onReview,
  });

  final List<Application> fresh;
  final int waiting;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final count = fresh.isEmpty ? waiting : fresh.length;
    final label = fresh.isEmpty
        ? (waiting == 0 ? 'nothing waiting' : 'waiting for review')
        : (fresh.length == 1 ? 'new application' : 'new applications');
    final faces = (fresh.isEmpty ? <Application>[] : fresh).take(4).toList();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white70)),
          if (faces.isNotEmpty) ...[
            const SizedBox(height: 14),
            SizedBox(
              height: 36,
              child: Stack(
                children: [
                  for (var i = 0; i < faces.length; i++)
                    Positioned(
                      left: i * 26.0,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.navy, width: 2),
                        ),
                        child: SoftAvatar(name: faces[i].name, size: 32),
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.navy,
              minimumSize: const Size.fromHeight(46),
            ),
            onPressed: onReview,
            child: const Text(
              'Review',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.grey)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
          ),
        ],
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
          tooltip: 'Log out',
          icon: const Icon(CupertinoIcons.square_arrow_left),
          onPressed: () {
            context.read<AppState>().adminSignOut();
            context.go('/');
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
