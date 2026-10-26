import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/mock_repository.dart';
import '../../l10n/strings.dart';
import '../../state/app_state.dart';
import '../../theme.dart';
import '../../widgets/demo_badge.dart';
import '../../widgets/primary_button.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const _length = 6;
  final _controllers = List.generate(_length, (_) => TextEditingController());
  final _focusNodes = List.generate(_length, (_) => FocusNode());
  Timer? _timer;
  int _secondsLeft = 30;
  bool _verifying = false;
  bool _wrongCode = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  /// Restarts the countdown. Resending only restarts the timer; no code is actually sent.
  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _secondsLeft = _secondsLeft - 1);
      if (_secondsLeft <= 0) timer.cancel();
    });
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < _length - 1) _focusNodes[index + 1].requestFocus();
    if (value.isEmpty && index > 0) _focusNodes[index - 1].requestFocus();
    setState(() => _wrongCode = false);
  }

  Future<void> _verify() async {
    setState(() => _verifying = true);
    final ok = await context.read<MockRepository>().verifyOtp(
          context.read<AppState>().phone ?? '',
          _code,
        );
    if (!mounted) return;
    setState(() => _verifying = false);
    if (ok) {
      context.go('/home');
    } else {
      setState(() => _wrongCode = true);
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes.first.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final phone = context.watch<AppState>().phone ?? '';
    return Scaffold(
      appBar: AppBar(actions: const [Padding(padding: EdgeInsets.only(right: 12), child: Center(child: DemoBadge()))]),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(t(context, 'enter_otp'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.navy)),
              Text('+91 $phone', style: const TextStyle(fontSize: 16, color: AppColors.grey)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_length, (i) {
                  return SizedBox(
                    width: 44,
                    child: CupertinoTextField(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(fontSize: 22),
                      onChanged: (v) => _onDigitChanged(i, v),
                    ),
                  );
                }),
              ),
              if (_wrongCode)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(t(context, 'err_otp'), style: const TextStyle(color: AppColors.red)),
                ),
              const SizedBox(height: 12),
              Text(t(context, 'demo_otp_hint'), style: const TextStyle(color: AppColors.grey)),
              const SizedBox(height: 8),
              _secondsLeft > 0
                  ? Text('${t(context, 'resend_in')} $_secondsLeft s', style: const TextStyle(color: AppColors.grey))
                  : TextButton(onPressed: _startTimer, child: Text(t(context, 'resend'))),
              const Spacer(),
              PrimaryButton(
                label: t(context, 'verify'),
                loading: _verifying,
                onPressed: _code.length == _length ? _verify : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
