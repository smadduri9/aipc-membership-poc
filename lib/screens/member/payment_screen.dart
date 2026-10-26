import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/mock_repository.dart';
import '../../state/app_state.dart';
import '../../theme.dart';
import '../../utils/format.dart';
import '../../widgets/demo_badge.dart';

/// Fake Razorpay-style checkout. The sheet is English only, as a real gateway would be.
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  static const _upi = ['Google Pay', 'PhonePe', 'Paytm', 'BHIM'];
  static const _rows = ['Cards', 'Netbanking', 'Wallet'];
  String? _selected;
  bool _processing = false;

  Future<void> _pay({required bool success}) async {
    final draft = context.read<AppState>().draft;
    setState(() => _processing = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    await context.read<MockRepository>().fakePay(draft.referenceNo, success: success);
    if (!mounted) return;
    setState(() => _processing = false);
    context.go('/home/payment-result?success=$success');
  }

  Widget _option(String label) {
    final selected = _selected == label;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => setState(() => _selected = label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: selected ? Colors.blue : Colors.grey.shade300, width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final draft = context.watch<AppState>().draft;
    final ready = _selected != null && !_processing;
    return Scaffold(
      backgroundColor: AppColors.sheet,
      appBar: AppBar(
        leadingWidth: 80,
        leading: TextButton(
          onPressed: _processing ? null : () => context.go('/home'),
          child: const Text('Cancel'),
        ),
        title: const Text('Payment'),
        actions: const [Padding(padding: EdgeInsets.only(right: 12), child: Center(child: DemoBadge()))],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: ListView(
                        children: [
                          const Text('Payment Options', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(formatRupees(draft.amount), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.navy)),
                          Text('Ref: ${draft.referenceNo}', style: const TextStyle(color: AppColors.grey)),
                          const SizedBox(height: 16),
                          const Text('UPI', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 3.2,
                            children: [for (final u in _upi) _option(u)],
                          ),
                          const SizedBox(height: 12),
                          for (final r in _rows) Padding(padding: const EdgeInsets.only(bottom: 8), child: _option(r)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _actionButton('Simulate failure', AppColors.red, ready ? () => _pay(success: false) : null)),
                      const SizedBox(width: 12),
                      Expanded(child: _actionButton('Simulate success', AppColors.green, ready ? () => _pay(success: true) : null)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Demo only. No money is charged.', style: TextStyle(color: AppColors.grey)),
                ],
              ),
            ),
          ),
          if (_processing)
            Container(
              color: Colors.black45,
              alignment: Alignment.center,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoActivityIndicator(color: Colors.white, radius: 14),
                  SizedBox(height: 12),
                  Text('Processing…', style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback? onPressed) {
    return FilledButton(
      style: FilledButton.styleFrom(backgroundColor: color, minimumSize: const Size.fromHeight(52)),
      onPressed: onPressed,
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
