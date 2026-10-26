import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models/application.dart';
import '../theme.dart';
import '../utils/format.dart';

enum _RowState { done, current, future, failed }

/// Vertical timeline of an application's progress. Built from the application's status and history.
class StatusTimeline extends StatelessWidget {
  const StatusTimeline({super.key, required this.app});

  final Application app;

  DateTime? _timeOf(AppStatus status) {
    for (final event in app.history) {
      if (event.status == status) return event.at;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final s = app.status;
    final paymentFailed = s == AppStatus.paymentFailed;
    final paymentDone = s == AppStatus.paymentVerified ||
        s == AppStatus.approvalPending ||
        s == AppStatus.approved ||
        s == AppStatus.rejected;
    final verifiedDone = paymentDone;
    final awaitingDone = s == AppStatus.approved || s == AppStatus.rejected;

    final rows = <_Row>[
      _Row(t(context, 'st_submitted'), s == AppStatus.draft ? _RowState.future : _RowState.done, app.createdAt),
      _Row(
        t(context, 'st_payment'),
        paymentFailed
            ? _RowState.failed
            : paymentDone
                ? _RowState.done
                : s == AppStatus.paymentPending
                    ? _RowState.current
                    : _RowState.future,
        _timeOf(AppStatus.paymentVerified) ?? _timeOf(AppStatus.paymentFailed),
      ),
      _Row(
        t(context, 'st_verified'),
        verifiedDone ? _RowState.done : _RowState.future,
        _timeOf(AppStatus.paymentVerified),
      ),
      _Row(
        t(context, 'st_awaiting'),
        awaitingDone
            ? _RowState.done
            : s == AppStatus.approvalPending
                ? _RowState.current
                : _RowState.future,
        _timeOf(AppStatus.approvalPending),
      ),
      if (s == AppStatus.rejected)
        _Row(t(context, 'st_rejected'), _RowState.failed, _timeOf(AppStatus.rejected), note: app.rejectReason)
      else
        _Row(
          t(context, 'st_approved'),
          s == AppStatus.approved ? _RowState.done : _RowState.future,
          _timeOf(AppStatus.approved),
        ),
    ];

    return Column(
      children: [
        for (var i = 0; i < rows.length; i++)
          _TimelineRow(row: rows[i], isLast: i == rows.length - 1),
      ],
    );
  }
}

class _Row {
  const _Row(this.label, this.state, this.time, {this.note});

  final String label;
  final _RowState state;
  final DateTime? time;
  final String? note;
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.row, required this.isLast});

  final _Row row;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = switch (row.state) {
      _RowState.done => AppColors.green,
      _RowState.current => AppColors.saffron,
      _RowState.failed => AppColors.red,
      _RowState.future => Colors.grey.shade400,
    };
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(width: 14, height: 14, margin: const EdgeInsets.only(top: 4), decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                if (!isLast) Expanded(child: Container(width: 2, color: Colors.grey.shade300)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(row.label, style: TextStyle(fontWeight: FontWeight.w600, color: row.state == _RowState.future ? AppColors.grey : Colors.black)),
                  if (row.time != null && row.state != _RowState.future)
                    Text(formatDateTime(row.time!), style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                  if (row.note != null && row.note!.isNotEmpty)
                    Text(row.note!, style: const TextStyle(color: AppColors.red)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
