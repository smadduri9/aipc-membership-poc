import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/mock_data.dart';
import '../../data/mock_repository.dart';
import '../../models/application.dart';
import '../../state/app_state.dart';
import '../../theme.dart';
import '../../widgets/avatar.dart';

const _softColors = [
  (Color(0xFFFFE3CF), Color(0xFF9A4A12)),
  (Color(0xFFDDF0E3), Color(0xFF1E6B34)),
  (Color(0xFFE6EEFB), Color(0xFF1F2A5A)),
];

/// Pale circle with initials. Quieter than the solid avatar used elsewhere.
class SoftAvatar extends StatelessWidget {
  const SoftAvatar({super.key, required this.name, this.size = 40});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _softColors[name.hashCode.abs() % _softColors.length];
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Text(
        initialsOf(name),
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w600,
          fontSize: size * 0.34,
        ),
      ),
    );
  }
}

/// The people waiting for the state representative: new ones first, then older ones.
/// Tick approves straight away; tapping a card opens the full details first.
class AdminReviewScreen extends StatelessWidget {
  const AdminReviewScreen({super.key, this.stateCode});

  /// Set when the master opens one state; null shows everything in the admin's scope.
  final String? stateCode;

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<MockRepository>();
    final state = context.watch<AppState>();
    final admin = state.admin;
    if (admin == null) return const Scaffold(body: SizedBox());
    final waiting = repo.search(
      state: stateCode,
      status: AppStatus.submitted,
      viewer: admin,
    );
    return Scaffold(
      backgroundColor: AppColors.grouped,
      appBar: AppBar(title: const Text('New applications')),
      body: SafeArea(
        child: waiting.isEmpty
            ? const Center(
                child: Text(
                  'All caught up.',
                  style: TextStyle(color: AppColors.grey, fontSize: 16),
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  for (final app in waiting)
                    _PersonCard(
                      app: app,
                      showState: admin.isMaster,
                      onOpen: () {
                        state.markSeen([app.referenceNo]);
                        context.push(
                          '/admin/dashboard/detail/${app.referenceNo}',
                        );
                      },
                      onApprove: () async {
                        final name = app.name;
                        await repo.approve(app.referenceNo, state.adminEmail);
                        state.markSeen([app.referenceNo]);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(content: Text('$name approved')),
                          );
                      },
                    ),
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Center(
                      child: Text(
                        'Tap a person to see their details',
                        style: TextStyle(color: AppColors.grey),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _PersonCard extends StatelessWidget {
  const _PersonCard({
    required this.app,
    required this.showState,
    required this.onOpen,
    required this.onApprove,
  });

  final Application app;
  final bool showState;
  final VoidCallback onOpen;
  final VoidCallback onApprove;

  @override
  Widget build(BuildContext context) {
    final place = [
      if (app.district.isNotEmpty) app.districtOther ?? app.district,
      if (showState) stateNames[app.state] ?? '',
    ].where((e) => e.isNotEmpty).join(' · ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                SoftAvatar(name: app.name),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          place,
                          app.professionalDomain,
                        ].where((e) => e.isNotEmpty).join(' · '),
                        style: const TextStyle(color: AppColors.grey),
                      ),
                    ],
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Approve ${app.name}',
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onApprove,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEAF4EA),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.checkmark_alt,
                        color: Color(0xFF1E8B3E),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shown after approving from the details screen: a short confirmation, then on to the next person.
class AdminApprovedScreen extends StatelessWidget {
  const AdminApprovedScreen({super.key, required this.referenceNo});

  final String referenceNo;

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<MockRepository>();
    final admin = context.watch<AppState>().admin;
    final app = repo.findByRef(referenceNo);
    final first = app?.firstName ?? 'The member';
    final next = admin == null
        ? null
        : repo
              .search(status: AppStatus.submitted, viewer: admin)
              .where((a) => a.referenceNo != referenceNo)
              .firstOrNull;
    return Scaffold(
      backgroundColor: AppColors.grouped,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEAF4EA),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.checkmark_alt,
                    size: 36,
                    color: Color(0xFF1E8B3E),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '$first is approved',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "They'll see it in their app and can pay for their membership.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.grey),
              ),
              const Spacer(),
              if (next != null)
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    minimumSize: const Size.fromHeight(52),
                  ),
                  onPressed: () =>
                      context.go('/admin/dashboard/detail/${next.referenceNo}'),
                  child: Text('Next: ${next.name}'),
                ),
              TextButton(
                onPressed: () => context.go('/admin/dashboard'),
                child: const Text('Back to dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
