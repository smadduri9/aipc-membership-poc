import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models/application.dart';
import '../theme.dart';

/// Colour-coded label for an application status.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status, this.english = false});

  final AppStatus status;

  /// Admin screens are English only, regardless of the member's language.
  final bool english;

  String _label(BuildContext context, String key) =>
      english ? translate('en', key) : t(context, key);

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      AppStatus.draft => (AppColors.grey, 'Draft'),
      AppStatus.paymentPending => (
        AppColors.grey,
        _label(context, 'payment_pending'),
      ),
      AppStatus.paymentFailed => (
        AppColors.red,
        _label(context, 'payment_failed'),
      ),
      AppStatus.paymentVerified => (
        AppColors.saffron,
        _label(context, 'st_verified'),
      ),
      AppStatus.approvalPending => (
        AppColors.saffron,
        _label(context, 'st_awaiting'),
      ),
      AppStatus.approved => (AppColors.green, _label(context, 'st_approved')),
      AppStatus.rejected => (AppColors.red, _label(context, 'st_rejected')),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
