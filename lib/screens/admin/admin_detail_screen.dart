import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/mock_data.dart';
import '../../data/mock_repository.dart';
import '../../models/application.dart';
import '../../state/app_state.dart';
import '../../theme.dart';
import '../../utils/format.dart';
import '../../widgets/avatar.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/status_timeline.dart';

class AdminDetailScreen extends StatelessWidget {
  const AdminDetailScreen({super.key, required this.referenceNo});

  final String referenceNo;

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<MockRepository>();
    final viewer = context.watch<AppState>().admin;
    final found = repo.findByRef(referenceNo);
    final inScope =
        viewer == null || viewer.isMaster || found?.state == viewer.stateCode;
    final app = inScope ? found : null;
    return Scaffold(
      backgroundColor: AppColors.grouped,
      appBar: AppBar(title: Text(referenceNo)),
      // Primary actions stay pinned above the home indicator instead of scrolling off screen.
      bottomNavigationBar: app != null && app.status == AppStatus.submitted
          ? Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: SafeArea(top: false, child: _Actions(app: app)),
            )
          : null,
      body: SafeArea(
        child: app == null
            ? const Center(child: Text('Application not found'))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      Avatar(
                        index: app.selfieIndex ?? 0,
                        initials: initialsOf(app.name),
                        size: 64,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          app.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      StatusChip(status: app.status, english: true),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _Field('Phone', app.phone),
                        _Field('Aadhaar', app.aadhaarMasked),
                        _Field(
                          'Domain',
                          app.professionalDomainOther ?? app.professionalDomain,
                        ),
                        _Field(
                          'Place',
                          [
                            app.cityVillage,
                            app.districtOther ?? app.district,
                            stateNames[app.state] ?? app.stateOther ?? '',
                          ].where((e) => e.isNotEmpty).join(', '),
                        ),
                        _Field('PIN code', app.pinCode),
                        if (app.parliamentary.isNotEmpty)
                          _Field('Parliamentary', app.parliamentary),
                        if (app.assembly.isNotEmpty)
                          _Field('Assembly', app.assembly),
                        if (app.instagramUrl != null)
                          _Field('Instagram', app.instagramUrl!),
                        if (app.linkedinUrl != null)
                          _Field('LinkedIn', app.linkedinUrl!),
                        if (app.facebookUrl != null)
                          _Field('Facebook', app.facebookUrl!),
                        // Plan and payment only matter once the member has chosen a plan.
                        if (app.status != AppStatus.submitted) ...[
                          _Field(
                            'Plan',
                            app.type == MembershipType.patron
                                ? 'Patron'
                                : 'AICP Member',
                          ),
                          _Field('Amount', formatRupees(app.amount)),
                          _Field('Payment ID', app.paymentId ?? '—'),
                        ],
                        _Field('Applied', formatDateTime(app.createdAt)),
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
                    child: StatusTimeline(app: app, english: true),
                  ),
                ],
              ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: AppColors.grey)),
          ),
          Expanded(child: Text(value.isEmpty ? '—' : value)),
        ],
      ),
    );
  }
}

const _declineReasons = [
  'Photo unclear',
  'Wrong state',
  'Link not working',
  'Other',
];

class _Actions extends StatelessWidget {
  const _Actions({required this.app});

  final Application app;

  Future<void> _approve(BuildContext context) async {
    final actor = context.read<AppState>().adminEmail;
    final state = context.read<AppState>();
    await context.read<MockRepository>().approve(app.referenceNo, actor);
    state.markSeen([app.referenceNo]);
    if (context.mounted) {
      context.go('/admin/dashboard/approved/${app.referenceNo}');
    }
  }

  Future<void> _decline(BuildContext context) async {
    final reason = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => const _DeclineSheet(),
    );
    if (reason == null || !context.mounted) return;
    final actor = context.read<AppState>().adminEmail;
    await context.read<MockRepository>().reject(app.referenceNo, actor, reason);
    if (!context.mounted) return;
    context.read<AppState>().markSeen([app.referenceNo]);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('${app.firstName} was declined')));
    context.go('/admin/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.red,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => _decline(context),
            child: const Text('Decline'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.navy,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => _approve(context),
            child: const Text(
              'Approve',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}

class _DeclineSheet extends StatefulWidget {
  const _DeclineSheet();

  @override
  State<_DeclineSheet> createState() => _DeclineSheetState();
}

class _DeclineSheetState extends State<_DeclineSheet> {
  String? _reason;
  final _other = TextEditingController();

  @override
  void dispose() {
    _other.dispose();
    super.dispose();
  }

  String? get _final {
    if (_reason == null) return null;
    if (_reason == 'Other') {
      final text = _other.text.trim();
      return text.isEmpty ? null : text;
    }
    return _reason;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Decline application?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            const Text(
              'They can fix this and apply again.',
              style: TextStyle(color: AppColors.grey),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final r in _declineReasons)
                  ChoiceChip(
                    label: Text(r),
                    selected: _reason == r,
                    onSelected: (_) => setState(() => _reason = r),
                  ),
              ],
            ),
            if (_reason == 'Other') ...[
              const SizedBox(height: 12),
              TextField(
                controller: _other,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Reason for declining',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.red,
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: _final == null
                  ? null
                  : () => Navigator.of(context).pop(_final),
              child: const Text('Decline'),
            ),
          ],
        ),
      ),
    );
  }
}
