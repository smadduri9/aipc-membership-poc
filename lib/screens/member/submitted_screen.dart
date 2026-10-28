import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/strings.dart';
import '../../theme.dart';
import '../../widgets/nav_actions.dart';
import '../../widgets/primary_button.dart';

/// Confirmation after submitting. The state representative reviews the application next.
class SubmittedScreen extends StatelessWidget {
  const SubmittedScreen({super.key, required this.referenceNo});

  final String referenceNo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: const [NavActions(showLanguage: false)]),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(
                CupertinoIcons.checkmark_seal_fill,
                size: 88,
                color: AppColors.green,
              ),
              const SizedBox(height: 24),
              Text(
                t(context, 'application_received'),
                textAlign: TextAlign.center,
                style: AppText.largeTitle,
              ),
              const SizedBox(height: 12),
              Text(
                t(context, 'application_received_body'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: AppColors.grey),
              ),
              const SizedBox(height: 20),
              Text(
                '${t(context, 'reference_no')}: $referenceNo',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.navy,
                ),
              ),
              const Spacer(),
              PrimaryButton(
                label: t(context, 'back'),
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
