import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models/application.dart';
import '../theme.dart';

/// Colour-coded label for an application status.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final AppStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      AppStatus.draft => (AppColors.grey, 'Draft'),
      AppStatus.paymentPending => (AppColors.grey, t(context, 'st_payment')),
      AppStatus.paymentFailed => (AppColors.red, t(context, 'payment_failed')),
      AppStatus.paymentVerified => (AppColors.saffron, t(context, 'st_verified')),
      AppStatus.approvalPending => (AppColors.saffron, t(context, 'st_awaiting')),
      AppStatus.approved => (AppColors.green, t(context, 'st_approved')),
      AppStatus.rejected => (AppColors.red, t(context, 'st_rejected')),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
