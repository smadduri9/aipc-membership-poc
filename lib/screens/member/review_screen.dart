import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/mock_data.dart';
import '../../data/mock_repository.dart';
import '../../l10n/strings.dart';
import '../../models/application.dart';
import '../../state/app_state.dart';
import '../../theme.dart';
import '../../utils/format.dart';
import '../../widgets/avatar.dart';
import '../../widgets/nav_actions.dart';
import '../../widgets/primary_button.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  bool _confirmed = false;
  bool _submitting = false;

  Future<void> _submit(Application draft) async {
    setState(() => _submitting = true);
    await context.read<MockRepository>().submit(draft);
    if (!mounted) return;
    context.go('/home/payment');
  }

  @override
  Widget build(BuildContext context) {
    final d = context.watch<AppState>().draft;
    return Scaffold(
      backgroundColor: AppColors.grouped,
      appBar: AppBar(
        title: Text(t(context, 'review')),
        actions: const [NavActions()],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _Section(
                    title: t(context, 'step_personal'),
                    step: 0,
                    rows: [
                      (t(context, 'name'), d.name),
                      (t(context, 'phone'), d.phone),
                      (t(context, 'voter_id'), d.voterId ?? '—'),
                      (
                        t(context, 'domain'),
                        optionLabel(context.read<AppState>().lang, d.domain),
                      ),
                    ],
                  ),
                  _Section(
                    title: t(context, 'step_location'),
                    step: 1,
                    rows: [
                      (
                        t(context, 'state'),
                        optionLabel(
                          context.read<AppState>().lang,
                          stateNames[d.state] ?? '',
                        ),
                      ),
                      (t(context, 'parliamentary'), d.parliamentary),
                      (t(context, 'assembly'), d.assembly),
                      (t(context, 'pin_code'), d.pinCode),
                      (t(context, 'referrer'), d.referrerPhone ?? '—'),
                    ],
                  ),
                  _SelfieSection(draft: d),
                  _Section(
                    title: t(context, 'step_membership'),
                    step: 3,
                    rows: [
                      (
                        t(
                          context,
                          d.type == MembershipType.patron
                              ? 'patron'
                              : 'ordinary',
                        ),
                        formatRupees(d.amount),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      CupertinoSwitch(
                        value: _confirmed,
                        onChanged: (v) => setState(() => _confirmed = v),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(t(context, 'confirm_details'))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label:
                        '${t(context, 'submit_pay')} ${formatRupees(d.amount)}',
                    loading: _submitting,
                    onPressed: _confirmed && !_submitting
                        ? () => _submit(d)
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.step, required this.rows});

  final String title;
  final int step;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy,
                  ),
                ),
              ),
              TextButton(
                onPressed: () =>
                    context.push('/home/register?step=$step&edit=1'),
                child: Text(t(context, 'edit')),
              ),
            ],
          ),
          for (final (label, value) in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
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
                  Expanded(child: Text(value.isEmpty ? '—' : value)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SelfieSection extends StatelessWidget {
  const _SelfieSection({required this.draft});

  final Application draft;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Avatar(
            index: draft.selfieIndex ?? 0,
            initials: initialsOf(draft.name),
            size: 56,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              t(context, 'step_selfie'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
              ),
            ),
          ),
          TextButton(
            onPressed: () => context.push('/home/register?step=2&edit=1'),
            child: Text(t(context, 'edit')),
          ),
        ],
      ),
    );
  }
}
