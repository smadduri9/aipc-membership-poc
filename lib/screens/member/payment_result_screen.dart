import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/mock_repository.dart';
import '../../models/application.dart';
import '../../l10n/strings.dart';
import '../../state/app_state.dart';
import '../../theme.dart';
import '../../widgets/nav_actions.dart';
import '../../widgets/primary_button.dart';

import 'package:flutter/cupertino.dart';

import '../../utils/format.dart';
import '../../utils/pdf_documents.dart';

class PaymentResultScreen extends StatelessWidget {
  const PaymentResultScreen({super.key, required this.success});

  final bool success;

  @override
  Widget build(BuildContext context) {
    final draft = _currentApplication(context);
    final app = context.watch<MockRepository>().findByRef(draft.referenceNo);
    final color = success ? AppColors.green : AppColors.red;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: const [NavActions()],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(
                success ? Icons.check_circle : Icons.cancel,
                color: color,
                size: 96,
              ),
              const SizedBox(height: 16),
              Text(
                success
                    ? t(context, 'payment_received')
                    : t(context, 'payment_failed'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              if (success) ...[
                Text(
                  '${t(context, 'reference_no')}: ${draft.referenceNo}',
                  textAlign: TextAlign.center,
                ),
                if (app?.paymentId != null)
                  Text(
                    '${t(context, 'payment_id')}: ${app!.paymentId}',
                    textAlign: TextAlign.center,
                  ),
                if (app != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    '${t(context, 'amount')}: ${formatRupees(app.amount)}',
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    formatDate(DateTime.now()),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.grey),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: OutlinedButton.icon(
                      icon: const Icon(CupertinoIcons.arrow_down_doc),
                      label: Text(t(context, 'download_receipt')),
                      onPressed: () => shareReceipt(app),
                    ),
                  ),
                ],
              ] else
                Text(
                  t(context, 'no_money_deducted'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.grey),
                ),
              const Spacer(),
              if (success)
                PrimaryButton(
                  label: t(context, 'back'),
                  onPressed: () => context.go('/home'),
                )
              else ...[
                PrimaryButton(
                  label: t(context, 'retry_payment'),
                  onPressed: () => context.go('/home/payment'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/home'),
                  child: Text(t(context, 'go_home')),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The member's own application, found by phone. Falls back to the draft when none exists yet.
Application _currentApplication(BuildContext context) {
  final phone = context.read<AppState>().phone ?? '';
  return context.read<MockRepository>().findByPhone(phone) ??
      context.read<AppState>().draft;
}
