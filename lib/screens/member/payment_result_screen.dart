import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/mock_repository.dart';
import '../../l10n/strings.dart';
import '../../state/app_state.dart';
import '../../theme.dart';
import '../../widgets/demo_badge.dart';
import '../../widgets/primary_button.dart';

class PaymentResultScreen extends StatelessWidget {
  const PaymentResultScreen({super.key, required this.success});

  final bool success;

  @override
  Widget build(BuildContext context) {
    final draft = context.watch<AppState>().draft;
    final app = context.watch<MockRepository>().findByRef(draft.referenceNo);
    final color = success ? AppColors.green : AppColors.red;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: const [Padding(padding: EdgeInsets.only(right: 12), child: Center(child: DemoBadge()))],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(success ? Icons.check_circle : Icons.cancel, color: color, size: 96),
              const SizedBox(height: 16),
              Text(
                success ? t(context, 'payment_received') : t(context, 'payment_failed'),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(height: 12),
              if (success) ...[
                Text('${t(context, 'reference_no')}: ${draft.referenceNo}', textAlign: TextAlign.center),
                if (app?.paymentId != null) Text('${t(context, 'payment_id')}: ${app!.paymentId}', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text(t(context, 'awaiting_approval_msg'), textAlign: TextAlign.center, style: const TextStyle(color: AppColors.grey)),
              ] else
                Text(t(context, 'no_money_deducted'), textAlign: TextAlign.center, style: const TextStyle(color: AppColors.grey)),
              const Spacer(),
              if (success)
                PrimaryButton(label: t(context, 'track_status'), onPressed: () => context.go('/status'))
              else ...[
                PrimaryButton(label: t(context, 'retry_payment'), onPressed: () => context.go('/payment')),
                const SizedBox(height: 12),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
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
