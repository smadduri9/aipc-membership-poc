import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../l10n/strings.dart';
import '../../state/app_state.dart';
import '../../theme.dart';
import '../../widgets/demo_badge.dart';
import '../../widgets/primary_button.dart';

const _languages = [
  ('hi', 'हिन्दी'),
  ('en', 'English'),
  ('pa', 'ਪੰਜਾਬੀ'),
  ('or', 'ଓଡ଼ିଆ'),
];

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(actions: const [Padding(padding: EdgeInsets.only(right: 12), child: Center(child: DemoBadge()))]),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(t(context, 'choose_language'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.navy)),
              const SizedBox(height: 24),
              for (final (code, label) in _languages)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => context.read<AppState>().setLang(code),
                    child: Container(
                      height: 64,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: state.lang == code ? AppColors.navy : Colors.grey.shade300, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: Text(label, style: const TextStyle(fontSize: 20))),
                          if (state.lang == code) const Icon(Icons.check_circle, color: AppColors.green),
                        ],
                      ),
                    ),
                  ),
                ),
              const Spacer(),
              PrimaryButton(label: t(context, 'continue'), onPressed: () => context.push('/language/phone')),
            ],
          ),
        ),
      ),
    );
  }
}
