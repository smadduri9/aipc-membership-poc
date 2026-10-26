import 'package:flutter/material.dart';

import '../theme.dart';

/// Marks every screen as sample-data demo output.
class DemoBadge extends StatelessWidget {
  const DemoBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.saffron,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'DEMO • Sample data',
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
