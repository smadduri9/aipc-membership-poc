import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/mock_data.dart';
import '../../data/mock_repository.dart';
import '../../models/application.dart';
import '../../state/app_state.dart';
import '../../theme.dart';
import '../../utils/format.dart';
import '../../widgets/nav_actions.dart';
import '../../widgets/primary_button.dart';

/// Read-only summary of everything the member entered, with the chosen plan. Continues to payment.
class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final phone = context.watch<AppState>().phone ?? '';
    final app = context.watch<MockRepository>().findByPhone(phone);
    return Scaffold(
      backgroundColor: AppColors.grouped,
      appBar: AppBar(
        title: const Text('Review details'),
        actions: const [NavActions(showLanguage: false)],
      ),
      body: SafeArea(
        child: app == null
            ? const Center(child: Text('No application found'))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _Section(
                    title: 'Personal',
                    rows: [
                      ('Name', app.name),
                      ('Mobile', app.phone),
                      ('Aadhaar', app.aadhaarMasked),
                      (
                        'Professional domain',
                        app.professionalDomainOther ?? app.professionalDomain,
                      ),
                    ],
                  ),
                  _Section(
                    title: 'Location',
                    rows: [
                      (
                        'State or UT',
                        stateNames[app.state] ?? app.stateOther ?? '',
                      ),
                      ('District', app.districtOther ?? app.district),
                      ('Tehsil', app.tehsil ?? '—'),
                      ('Block', app.block ?? '—'),
                      ('City or village', app.cityVillage),
                      ('PIN code', app.pinCode),
                    ],
                  ),
                  _Section(
                    title: 'Online',
                    rows: [
                      ('Instagram', app.instagramUrl ?? '—'),
                      ('LinkedIn', app.linkedinUrl ?? '—'),
                      ('Facebook', app.facebookUrl ?? '—'),
                    ],
                  ),
                  _Section(
                    title: 'Membership',
                    rows: [
                      (
                        'Plan',
                        app.type == MembershipType.patron
                            ? 'Patron'
                            : 'AICP Member',
                      ),
                      ('Amount', formatRupees(app.amount)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  PrimaryButton(
                    label: 'Continue to payment',
                    onPressed: () => context.go('/home/payment'),
                  ),
                ],
              ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.rows});

  final String title;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.sectionTitle),
          const SizedBox(height: 8),
          for (final (label, value) in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 130,
                    child: Text(
                      label,
                      style: const TextStyle(color: AppColors.grey),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      value,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
