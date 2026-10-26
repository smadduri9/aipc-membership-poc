import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../theme.dart';

/// Progress bar with "Step X of 4" and the current step title.
class StepProgress extends StatelessWidget {
  const StepProgress({super.key, required this.current, required this.title});

  final int current;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t(context, 'step_of', params: {'x': '${current + 1}'}), style: const TextStyle(color: AppColors.grey)),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (current + 1) / 4,
            minHeight: 6,
            color: AppColors.saffron,
            backgroundColor: AppColors.sheet,
          ),
        ),
        const SizedBox(height: 12),
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.navy)),
      ],
    );
  }
}
