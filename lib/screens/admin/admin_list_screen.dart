import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/mock_data.dart';
import '../../data/mock_repository.dart';
import '../../models/application.dart';
import '../../utils/format.dart';
import '../../widgets/avatar.dart';
import '../../widgets/status_chip.dart';

const _statusFilters = <(String, AppStatus?)>[
  ('All', null),
  ('Awaiting approval', AppStatus.submitted),
  ('Approved', AppStatus.approved),
  ('Rejected', AppStatus.rejected),
  ('Payment failed', AppStatus.paymentFailed),
  ('Payment pending', AppStatus.submitted),
];

class AdminListScreen extends StatefulWidget {
  const AdminListScreen({super.key});

  @override
  State<AdminListScreen> createState() => _AdminListScreenState();
}

class _AdminListScreenState extends State<AdminListScreen> {
  final _query = TextEditingController();
  AppStatus? _status;
  String? _stateCode;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _showCsv(BuildContext context, String csv) {
    showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Export CSV'),
        content: Container(
          height: 240,
          margin: const EdgeInsets.only(top: 12),
          child: SingleChildScrollView(
            child: Text(
              csv,
              style: const TextStyle(fontSize: 11, fontFamily: 'Courier'),
            ),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: csv));
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Copy'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<MockRepository>();
    final results = repo.search(
      state: _stateCode,
      status: _status,
      query: _query.text,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Applications'),
        actions: [
          TextButton(
            onPressed: () => _showCsv(context, repo.exportCsv()),
            child: const Text('Export CSV'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: CupertinoSearchTextField(
                controller: _query,
                placeholder: 'Reference, phone or name',
                onChanged: (_) => setState(() {}),
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  for (final (label, status) in _statusFilters)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(label),
                        selected: _status == status,
                        onSelected: (_) => setState(() => _status = status),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(
                        _stateCode == null
                            ? 'State: All'
                            : 'State: ${stateNames[_stateCode]}',
                      ),
                      onPressed: () => _pickState(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: results.isEmpty
                  ? const Center(
                      child: Text('No applications match these filters.'),
                    )
                  : ListView.separated(
                      itemCount: results.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, i) =>
                          _ApplicationRow(app: results[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickState(BuildContext context) {
    final codes = [null, ...stateNames.keys];
    var chosen = 0;
    showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetContext) => Container(
        height: 300,
        color: CupertinoColors.systemBackground.resolveFrom(sheetContext),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: CupertinoButton(
                child: const Text('Done'),
                onPressed: () {
                  setState(() => _stateCode = codes[chosen]);
                  Navigator.of(sheetContext).pop();
                },
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 36,
                onSelectedItemChanged: (index) => chosen = index,
                children: [
                  for (final code in codes)
                    Center(
                      child: Text(
                        code == null ? 'All states' : stateNames[code]!,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApplicationRow extends StatelessWidget {
  const _ApplicationRow({required this.app});

  final Application app;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => context.push('/admin/dashboard/detail/${app.referenceNo}'),
      leading: Avatar(
        index: app.selfieIndex ?? 0,
        initials: initialsOf(app.name),
        size: 44,
      ),
      title: Text(
        app.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${app.referenceNo} · ${app.state} · ${formatDate(app.createdAt)}',
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          StatusChip(status: app.status, english: true),
          const SizedBox(height: 4),
          Text(formatRupees(app.amount), style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
