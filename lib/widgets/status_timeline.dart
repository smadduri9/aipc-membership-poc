import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models/application.dart';
import '../theme.dart';
import '../utils/format.dart';

enum _RowState { done, current, future, failed }

/// Progress of an application: submitted, then reviewed, then payment and membership.
class StatusTimeline extends StatelessWidget {
  const StatusTimeline({super.key, required this.app, this.english = false});

  final Application app;

  /// Admin screens are English only, regardless of the member's language.
  final bool english;

  String _label(BuildContext context, String key) =>
      english ? translate('en', key) : t(context, key);

  DateTime? _timeOf(AppStatus status) {
    for (final event in app.history) {
      if (event.status == status) return event.at;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final s = app.status;
    final rejected = s == AppStatus.rejected;
    final reviewed =
        s != AppStatus.submitted &&
        s != AppStatus.underReview &&
        s != AppStatus.draft;
    final paid = s == AppStatus.active;
    final rows = <(String, _RowState, DateTime?)>[
      (
        _label(context, 'st_submitted'),
        s == AppStatus.draft ? _RowState.future : _RowState.done,
        _timeOf(AppStatus.submitted),
      ),
      (
        _label(context, 'st_awaiting'),
        reviewed ? _RowState.done : _RowState.current,
        _timeOf(AppStatus.approved) ?? _timeOf(AppStatus.rejected),
      ),
      if (rejected)
        (
          _label(context, 'st_rejected'),
          _RowState.failed,
          _timeOf(AppStatus.rejected),
        )
      else ...[
        (
          _label(context, 'st_payment'),
          s == AppStatus.paymentFailed
              ? _RowState.failed
              : paid
              ? _RowState.done
              : reviewed
              ? _RowState.current
              : _RowState.future,
          _timeOf(AppStatus.active) ?? _timeOf(AppStatus.paymentFailed),
        ),
        (
          _label(context, 'st_active'),
          paid ? _RowState.done : _RowState.future,
          _timeOf(AppStatus.active),
        ),
      ],
    ];
    return Column(
      children: [
        for (var i = 0; i < rows.length; i++)
          _Row(
            label: rows[i].$1,
            state: rows[i].$2,
            time: rows[i].$3,
            last: i == rows.length - 1,
          ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.state,
    required this.time,
    required this.last,
  });

  final String label;
  final _RowState state;
  final DateTime? time;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      _RowState.done => AppColors.green,
      _RowState.current => AppColors.saffron,
      _RowState.failed => AppColors.red,
      _RowState.future => AppColors.grey,
    };
    final icon = switch (state) {
      _RowState.done => Icons.check_circle,
      _RowState.current => Icons.radio_button_checked,
      _RowState.failed => Icons.cancel,
      _RowState.future => Icons.radio_button_unchecked,
    };
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Icon(icon, color: color, size: 22),
              if (!last)
                Expanded(
                  child: Container(width: 2, color: AppColors.separator),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: state == _RowState.future ? AppColors.grey : null,
                    ),
                  ),
                  if (time != null)
                    Text(
                      formatDateTime(time!),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
