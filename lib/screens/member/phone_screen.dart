import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/mock_repository.dart';
import '../../l10n/strings.dart';
import '../../state/app_state.dart';
import '../../theme.dart';
import '../../utils/indian_phone.dart';
import '../../widgets/demo_badge.dart';
import '../../widgets/primary_button.dart';

class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final _controller = TextEditingController();
  bool _consent = false;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _controller.text;
    setState(() => _sending = true);
    await context.read<MockRepository>().sendOtp(phone);
    if (!mounted) return;
    context.read<AppState>().setPhone(phone);
    setState(() => _sending = false);
    context.go('/otp');
  }

  @override
  Widget build(BuildContext context) {
    final text = _controller.text;
    final showError = text.length == 10 && !isValidMobile(text);
    final canSend = isValidMobile(text) && _consent;
    return Scaffold(
      appBar: AppBar(actions: const [Padding(padding: EdgeInsets.only(right: 12), child: Center(child: DemoBadge()))]),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(t(context, 'enter_phone'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.navy)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(color: AppColors.sheet, borderRadius: BorderRadius.circular(12)),
                    child: const Text('+91', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CupertinoTextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      placeholder: '9XXXXXXXXX',
                      padding: const EdgeInsets.all(14),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
              if (showError)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(t(context, 'err_phone'), style: const TextStyle(color: AppColors.red)),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CupertinoSwitch(value: _consent, onChanged: (v) => setState(() => _consent = v)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(t(context, 'consent_text'))),
                ],
              ),
              const SizedBox(height: 8),
              Text(t(context, 'demo_phone_hint'), style: const TextStyle(color: AppColors.grey)),
              const Spacer(),
              PrimaryButton(
                label: t(context, 'send_otp'),
                loading: _sending,
                onPressed: canSend ? _sendOtp : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
