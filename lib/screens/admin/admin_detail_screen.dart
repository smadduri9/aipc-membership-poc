import 'package:flutter/cupertino.dart';
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

const _rejectReasons = [
  'Incomplete details',
  'Duplicate application',
  'Not eligible',
];

class AdminDetailScreen extends StatelessWidget {
  const AdminDetailScreen({super.key, required this.referenceNo});

  final String referenceNo;

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<MockRepository>();
    final app = repo.findByRef(referenceNo);
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
                        _Field('Domain', app.professionalDomain),
                        _Field('State', stateNames[app.state] ?? ''),
                        _Field('Parliamentary', app.parliamentary),
                        _Field('Assembly', app.assembly),
                        _Field('PIN code', app.pinCode),
                        _Field(
                          'Type',
                          app.type == MembershipType.patron
                              ? 'Patron'
                              : 'Ordinary',
                        ),
                        _Field('Amount', formatRupees(app.amount)),
                        _Field('Payment ID', app.paymentId ?? '—'),
                        _Field('Created', formatDateTime(app.createdAt)),
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

class _Actions extends StatelessWidget {
  const _Actions({required this.app});

  final Application app;

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _confirmApprove(BuildContext context) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Approve membership?'),
        content: Text(app.referenceNo),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final actor = context.read<AppState>().adminEmail;
    await context.read<MockRepository>().approve(app.referenceNo, actor);
    if (context.mounted) _toast(context, 'Approved');
  }

  Future<void> _reject(BuildContext context, String reason) async {
    final actor = context.read<AppState>().adminEmail;
    await context.read<MockRepository>().reject(app.referenceNo, actor, reason);
    if (context.mounted) _toast(context, 'Rejected');
  }

  Future<void> _chooseReject(BuildContext context) async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        title: const Text('Reason for rejection'),
        actions: [
          for (final reason in _rejectReasons)
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.of(sheetContext).pop();
                _reject(context, reason);
              },
              child: Text(reason),
            ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(sheetContext).pop();
              _rejectWithText(context);
            },
            child: const Text('Other'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(sheetContext).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  Future<void> _rejectWithText(BuildContext context) async {
    final controller = TextEditingController();
    final reason = await showCupertinoDialog<String>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Reason'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(
            controller: controller,
            placeholder: 'Enter a reason',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) Navigator.of(dialogContext).pop(text);
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (reason != null && context.mounted) await _reject(context, reason);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.green,
              minimumSize: const Size.fromHeight(52),
            ),
            onPressed: () => _confirmApprove(context),
            child: const Text('Approve'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.red,
              minimumSize: const Size.fromHeight(52),
            ),
            onPressed: () => _chooseReject(context),
            child: const Text('Reject'),
          ),
        ),
      ],
    );
  }
}
