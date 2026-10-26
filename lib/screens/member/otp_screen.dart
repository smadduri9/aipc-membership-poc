import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/mock_repository.dart';
import '../../l10n/strings.dart';
import '../../state/app_state.dart';
import '../../theme.dart';
import '../../widgets/nav_actions.dart';
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

  /// Handles typing, pasting and iOS SMS code autofill. A multi-digit value is
  /// spread across the boxes from [index] onwards.
  void _onDigitChanged(int index, String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 1) {
      for (var i = 0; i < digits.length && index + i < _length; i++) {
        _controllers[index + i].text = digits[i];
      }
      final last = (index + digits.length - 1).clamp(0, _length - 1);
      _focusNodes[last].requestFocus();
    } else {
      if (digits != value) _controllers[index].text = digits;
      if (digits.isNotEmpty && index < _length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else if (digits.isEmpty && index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
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
      appBar: AppBar(actions: const [NavActions()]),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                t(context, 'enter_otp'),
                style: AppText.largeTitle.copyWith(fontSize: 24),
              ),
              Text(
                '+91 $phone',
                style: const TextStyle(fontSize: 16, color: AppColors.grey),
              ),
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
                      autofillHints: const [AutofillHints.oneTimeCode],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.grouped,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                      onChanged: (v) => _onDigitChanged(i, v),
                    ),
                  );
                }),
              ),
              if (_wrongCode)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    t(context, 'err_otp'),
                    style: const TextStyle(color: AppColors.red),
                  ),
                ),
              const SizedBox(height: 12),
              Text(
                t(context, 'demo_otp_hint'),
                style: const TextStyle(color: AppColors.grey),
              ),
              const SizedBox(height: 8),
              _secondsLeft > 0
                  ? Text(
                      '${t(context, 'resend_in')} $_secondsLeft s',
                      style: const TextStyle(color: AppColors.grey),
                    )
                  : TextButton(
                      onPressed: _startTimer,
                      child: Text(t(context, 'resend')),
                    ),
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
