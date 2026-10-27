import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/mock_repository.dart';
import '../../models/application.dart';
import '../../state/app_state.dart';
import '../../theme.dart';
import '../../utils/format.dart';
import '../../widgets/nav_actions.dart';
import '../../widgets/primary_button.dart';

const _patronMinimum = 50000;
const _patronChips = [50000, 100000, 200000];

/// Membership options shown after approval. Patron amount is any value from 50,000 up.
/// The Manmohan Singh Fellowship opens in an in-app page, where the member applies on that site.
class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  MembershipType? _type;
  final _amount = TextEditingController();
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final repo = context.read<MockRepository>();
    final phone = context.read<AppState>().phone ?? '';
    final app = repo.findByPhone(phone);
    if (app == null || _type == null) return;
    var amount = 1000;
    if (_type == MembershipType.patron) {
      amount = int.tryParse(_amount.text.replaceAll(',', '')) ?? 0;
      if (amount < _patronMinimum) {
        setState(() => _error = 'Minimum amount is ₹50,000');
        return;
      }
    }
    setState(() {
      _error = null;
      _saving = true;
    });
    await repo.chooseMembership(app.referenceNo, _type!, amount);
    if (!mounted) return;
    setState(() => _saving = false);
    context.go('/home/review');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grouped,
      appBar: AppBar(
        title: const Text('Choose membership'),
        actions: const [NavActions(showLanguage: false)],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _OptionCard(
              selected: _type == MembershipType.aicpMember,
              title: 'AICP Member',
              price: '₹1,000 for 2 years',
              onTap: () => setState(() {
                _type = MembershipType.aicpMember;
                _error = null;
              }),
            ),
            _OptionCard(
              selected: _type == MembershipType.patron,
              title: 'Patron',
              price: 'From ₹50,000, any amount above',
              onTap: () => setState(() {
                _type = MembershipType.patron;
                _error = null;
              }),
              child: _type != MembershipType.patron
                  ? null
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: [
                            for (final v in _patronChips)
                              ActionChip(
                                label: Text(formatRupees(v)),
                                onPressed: () => setState(() {
                                  _amount.text = '$v';
                                  _error = null;
                                }),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _amount,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Amount (₹)',
                            errorText: _error,
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (_) => setState(() => _error = null),
                        ),
                      ],
                    ),
            ),
            _OptionCard(
              selected: false,
              title: 'Manmohan Singh Fellowship',
              price: 'Apply on the fellowship website',
              onTap: () => context.push('/home/membership/fellowship'),
              trailing: const Icon(CupertinoIcons.arrow_up_right_square),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Continue',
              loading: _saving,
              onPressed: _type == null ? null : _continue,
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.selected,
    required this.title,
    required this.price,
    required this.onTap,
    this.child,
    this.trailing,
  });

  final bool selected;
  final String title;
  final String price;
  final VoidCallback onTap;
  final Widget? child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.navy : const Color(0xFFCFE0F5),
              width: selected ? 2 : 1,
            ),
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
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                  ),
                  trailing ??
                      Icon(
                        selected
                            ? CupertinoIcons.checkmark_circle_fill
                            : CupertinoIcons.circle,
                        color: selected ? AppColors.navy : AppColors.grey,
                      ),
                ],
              ),
              const SizedBox(height: 4),
              Text(price, style: const TextStyle(color: AppColors.grey)),
              ?child,
            ],
          ),
        ),
      ),
    );
  }
}
