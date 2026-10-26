import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/mock_data.dart';
import '../../l10n/strings.dart';
import '../../models/application.dart';
import '../../state/app_state.dart';
import '../../theme.dart';
import '../../utils/indian_phone.dart';
import '../../widgets/avatar.dart';
import '../../widgets/cupertino_select.dart';
import '../../widgets/demo_badge.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/step_progress.dart';

final _voterPattern = RegExp(r'^[A-Z]{3}\d{7}$');
final _pinPattern = RegExp(r'^\d{6}$');
const _patronMinimum = 50000;

/// Four-step membership form. Values are written straight into [AppState.draft],
/// so they survive Back/Next and the Edit links on the review screen.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.initialStep = 0, this.editing = false});

  final int initialStep;
  final bool editing;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late int _step = widget.initialStep.clamp(0, 3);
  late final PageController _pages = PageController(initialPage: _step);
  final Map<String, String> _errors = {};

  late final TextEditingController _name;
  late final TextEditingController _voter;
  late final TextEditingController _pin;
  late final TextEditingController _referrer;
  late final TextEditingController _amount;

  @override
  void initState() {
    super.initState();
    final d = context.read<AppState>().draft;
    _name = TextEditingController(text: d.name);
    _voter = TextEditingController(text: d.voterId ?? '');
    _pin = TextEditingController(text: d.pinCode);
    _referrer = TextEditingController(text: d.referrerPhone ?? '');
    _amount = TextEditingController(text: d.type == MembershipType.patron ? '${d.amount}' : '');
  }

  Application get _draft => context.read<AppState>().draft;

  @override
  void dispose() {
    _pages.dispose();
    _name.dispose();
    _voter.dispose();
    _pin.dispose();
    _referrer.dispose();
    _amount.dispose();
    super.dispose();
  }

  bool _validate(int step) {
    final d = _draft;
    _errors.clear();
    switch (step) {
      case 0:
        if (d.name.trim().length < 3) _errors['name'] = 'err_name';
        if (d.voterId != null && d.voterId!.isNotEmpty && !_voterPattern.hasMatch(d.voterId!)) {
          _errors['voter'] = 'err_voter';
        }
        if (d.domain.isEmpty) _errors['domain'] = 'err_select';
      case 1:
        if (d.state.isEmpty) _errors['state'] = 'err_select';
        if (d.parliamentary.isEmpty) _errors['pc'] = 'err_select';
        if (d.assembly.isEmpty) _errors['ac'] = 'err_select';
        if (!_pinPattern.hasMatch(d.pinCode)) _errors['pin'] = 'err_pin';
        final referrer = d.referrerPhone ?? '';
        if (referrer.isNotEmpty && !isValidMobile(referrer)) _errors['referrer'] = 'err_referrer';
      case 2:
        if (d.selfieIndex == null) _errors['selfie'] = 'err_selfie';
      case 3:
        if (d.type == MembershipType.patron && d.amount < _patronMinimum) _errors['amount'] = 'err_amount';
    }
    return _errors.isEmpty;
  }

  void _goToStep(int step) {
    setState(() => _step = step);
    _pages.animateToPage(step, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  void _back() {
    if (_step == 0 || widget.editing) {
      context.pop();
    } else {
      setState(() => _errors.clear());
      _goToStep(_step - 1);
    }
  }

  void _next() {
    if (!_validate(_step)) {
      setState(() {});
      return;
    }
    if (widget.editing) {
      context.pop();
    } else if (_step < 3) {
      _goToStep(_step + 1);
    } else {
      context.push('/home/review');
    }
  }

  String? _err(BuildContext context, String key) {
    final code = _errors[key];
    return code == null ? null : t(context, code);
  }

  @override
  Widget build(BuildContext context) {
    final titles = [
      t(context, 'step_personal'),
      t(context, 'step_location'),
      t(context, 'step_selfie'),
      t(context, 'step_membership'),
    ];
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: _back),
        actions: const [Padding(padding: EdgeInsets.only(right: 12), child: Center(child: DemoBadge()))],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: StepProgress(current: _step, title: titles[_step]),
            ),
            Expanded(
              child: PageView(
                controller: _pages,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _personalStep(context),
                  _locationStep(context),
                  _selfieStep(context),
                  _membershipStep(context),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_step > 0 || widget.editing)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _back,
                        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                        child: Text(t(context, 'back')),
                      ),
                    ),
                  if (_step > 0 || widget.editing) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(label: t(context, 'next'), onPressed: _next),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _padded(List<Widget> children) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
      );

  Widget _personalStep(BuildContext context) {
    final d = _draft;
    return _padded([
      TextField(
        controller: _name,
        decoration: InputDecoration(labelText: '${t(context, 'name')} *', errorText: _err(context, 'name'), border: const OutlineInputBorder()),
        onChanged: (v) => d.name = v,
      ),
      const SizedBox(height: 16),
      TextField(
        enabled: false,
        controller: TextEditingController(text: d.phone),
        decoration: InputDecoration(labelText: t(context, 'phone'), border: const OutlineInputBorder()),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _voter,
        textCapitalization: TextCapitalization.characters,
        decoration: InputDecoration(labelText: t(context, 'voter_id'), errorText: _err(context, 'voter'), border: const OutlineInputBorder()),
        onChanged: (v) {
          d.voterId = v.toUpperCase();
          if (_voter.text != d.voterId) _voter.value = _voter.value.copyWith(text: d.voterId);
        },
      ),
      const SizedBox(height: 16),
      CupertinoSelect(
        label: '${t(context, 'domain')} *',
        value: d.domain,
        items: professionalDomains,
        error: _err(context, 'domain'),
        onChanged: (v) => setState(() => d.domain = v),
      ),
    ]);
  }

  Widget _locationStep(BuildContext context) {
    final d = _draft;
    final pcs = d.state.isEmpty ? <String>[] : (constituencies[d.state]?.keys.toList() ?? <String>[]);
    final acs = d.parliamentary.isEmpty ? <String>[] : (constituencies[d.state]?[d.parliamentary] ?? <String>[]);
    return _padded([
      CupertinoSelect(
        label: '${t(context, 'state')} *',
        value: d.state.isEmpty ? '' : stateNames[d.state]!,
        items: stateNames.values.toList(),
        error: _err(context, 'state'),
        onChanged: (name) => setState(() {
          d.state = stateNames.entries.firstWhere((e) => e.value == name).key;
          d.parliamentary = '';
          d.assembly = '';
        }),
      ),
      const SizedBox(height: 16),
      CupertinoSelect(
        label: '${t(context, 'parliamentary')} *',
        value: d.parliamentary,
        items: pcs,
        enabled: d.state.isNotEmpty,
        error: _err(context, 'pc'),
        onChanged: (v) => setState(() {
          d.parliamentary = v;
          d.assembly = '';
        }),
      ),
      const SizedBox(height: 16),
      CupertinoSelect(
        label: '${t(context, 'assembly')} *',
        value: d.assembly,
        items: acs,
        enabled: d.parliamentary.isNotEmpty,
        error: _err(context, 'ac'),
        onChanged: (v) => setState(() => d.assembly = v),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _pin,
        keyboardType: TextInputType.number,
        maxLength: 6,
        decoration: InputDecoration(labelText: '${t(context, 'pin_code')} *', errorText: _err(context, 'pin'), border: const OutlineInputBorder()),
        onChanged: (v) => d.pinCode = v,
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _referrer,
        keyboardType: TextInputType.number,
        maxLength: 10,
        decoration: InputDecoration(labelText: t(context, 'referrer'), errorText: _err(context, 'referrer'), border: const OutlineInputBorder()),
        onChanged: (v) => d.referrerPhone = v.isEmpty ? null : v,
      ),
    ]);
  }

  Widget _selfieStep(BuildContext context) {
    final d = _draft;
    final chosen = d.selfieIndex;
    return _padded([
      const SizedBox(height: 16),
      Center(
        child: GestureDetector(
          onTap: () => _pickSelfie(context),
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.sheet, border: Border.all(color: Colors.grey.shade300)),
            alignment: Alignment.center,
            child: chosen == null
                ? const Icon(CupertinoIcons.camera, size: 48, color: AppColors.grey)
                : Avatar(index: chosen, initials: initialsOf(d.name), size: 160),
          ),
        ),
      ),
      const SizedBox(height: 16),
      Center(
        child: TextButton(
          onPressed: () => _pickSelfie(context),
          child: Text(t(context, chosen == null ? 'take_selfie' : 'retake')),
        ),
      ),
      if (_errors.containsKey('selfie'))
        Center(child: Text(_err(context, 'selfie')!, style: const TextStyle(color: AppColors.red))),
    ]);
  }

  Future<void> _pickSelfie(BuildContext context) async {
    final doneLabel = tRead(context, 'done');
    final initials = initialsOf(_draft.name);
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetContext) => Container(
        color: CupertinoColors.systemBackground.resolveFrom(sheetContext),
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (var i = 0; i < 3; i++)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _draft.selfieIndex = i;
                      _errors.remove('selfie');
                    });
                    Navigator.of(sheetContext).pop();
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Avatar(index: i, initials: initials, size: 80),
                      const SizedBox(height: 6),
                      Text(doneLabel, style: const TextStyle(color: AppColors.grey)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _membershipStep(BuildContext context) {
    final d = _draft;
    final isPatron = d.type == MembershipType.patron;
    return _padded([
      _TypeCard(
        selected: !isPatron,
        title: t(context, 'ordinary'),
        subtitle: t(context, 'ordinary_price'),
        onTap: () => setState(() {
          d.type = MembershipType.ordinary;
          d.amount = 1000;
          _amount.clear();
        }),
      ),
      const SizedBox(height: 12),
      _TypeCard(
        selected: isPatron,
        title: t(context, 'patron'),
        subtitle: t(context, 'patron_from'),
        onTap: () => setState(() {
          d.type = MembershipType.patron;
          if (d.amount < _patronMinimum) d.amount = _patronMinimum;
          _amount.text = '${d.amount}';
        }),
      ),
      if (isPatron) ...[
        const SizedBox(height: 16),
        TextField(
          controller: _amount,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: '${t(context, 'amount')} *', errorText: _err(context, 'amount'), border: const OutlineInputBorder()),
          onChanged: (v) => d.amount = int.tryParse(v) ?? 0,
        ),
        const SizedBox(height: 8),
        Text(t(context, 'duration_tbc'), style: const TextStyle(color: AppColors.grey)),
      ],
    ]);
  }
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({required this.selected, required this.title, required this.subtitle, required this.onTap});

  final bool selected;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: selected ? AppColors.navy : Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: AppColors.grey)),
                ],
              ),
            ),
            if (selected) const Icon(Icons.check_circle, color: AppColors.green),
          ],
        ),
      ),
    );
  }
}
