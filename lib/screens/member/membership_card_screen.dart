import 'dart:math';

import 'package:flutter/material.dart';
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
import '../../utils/pdf_documents.dart';

class MembershipCardScreen extends StatelessWidget {
  const MembershipCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final phone = context.watch<AppState>().phone ?? '';
    final repo = context.watch<MockRepository>();
    final app = repo.findByPhone(phone);
    return Scaffold(
      appBar: AppBar(title: const Text('AICP'), actions: const [NavActions()]),
      body: SafeArea(
        child: app == null
            ? const Center(child: Text('—'))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _CardFace(app: app),
                  const SizedBox(height: 20),
                  Center(child: _FakeQr(seed: app.referenceNo)),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: t(context, 'download_card'),
                    onPressed: () => shareCard(app),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => shareReceipt(app),
                    child: Text(t(context, 'download_receipt')),
                  ),
                ],
              ),
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace({required this.app});

  final Application app;

  @override
  Widget build(BuildContext context) {
    final validity = app.validUntil == null
        ? t(context, 'duration_tbd')
        : '${t(context, 'valid_till')} ${formatDate(app.validUntil!)}';
    return AspectRatio(
      aspectRatio: 16 / 10,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.navy, Color(0xFF3A4B8C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AICP',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              t(context, 'app_subtitle'),
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const Spacer(),
            Row(
              children: [
                Avatar(
                  index: app.selfieIndex ?? 0,
                  initials: initialsOf(app.name),
                  size: 52,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    app.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${t(context, 'membership_no')} ${app.referenceNo}',
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              '${t(context, app.type == MembershipType.patron ? 'patron' : 'ordinary')} · ${optionLabel(context.read<AppState>().lang, stateNames[app.state] ?? '')}',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(validity, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

/// Decorative grid derived from the reference number. It does not encode real data.
class _FakeQr extends StatelessWidget {
  const _FakeQr({required this.seed});

  final String seed;

  @override
  Widget build(BuildContext context) {
    final random = Random(seed.hashCode);
    const size = 21;
    final cells = List.generate(size * size, (_) => random.nextBool());
    return SizedBox(
      width: 160,
      height: 160,
      child: GridView.count(
        crossAxisCount: size,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (final filled in cells)
            Container(color: filled ? Colors.black : Colors.white),
        ],
      ),
    );
  }
}
