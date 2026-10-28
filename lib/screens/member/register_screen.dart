import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/mock_repository.dart';
import '../../data/pincode_lookup.dart';
import '../../data/reference_data.dart';
import '../../l10n/strings.dart';
import '../../models/application.dart';
import '../../state/app_state.dart';
import '../../theme.dart';
import '../../utils/aadhaar.dart';
import '../../utils/social_link.dart';
import '../../widgets/cupertino_select.dart';
import '../../widgets/demo_badge.dart';
import '../../widgets/nav_actions.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/selfie_capture.dart';
import '../../widgets/step_progress.dart';

/// Three-step membership application. Steps: identity and domain, location, then selfie and social links.
/// Values are written into [AppState.draft] as the member goes, so Back keeps them.
/// Payment and membership type come later, after approval.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.initialStep = 0});

  final int initialStep;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late int _step = widget.initialStep.clamp(0, 2);
  final Map<String, String> _errors = {};

  // Identity
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _aadhaar = TextEditingController();
  final _domainOther = TextEditingController();

  // Location
  final _pin = TextEditingController();
  final _stateOther = TextEditingController();
  final _districtOther = TextEditingController();
  final _tehsil = TextEditingController();
  final _block = TextEditingController();
  final _city = TextEditingController();
  final _pc = TextEditingController();
  final _ac = TextEditingController();

  // Social
  final _instagram = TextEditingController();
  final _linkedin = TextEditingController();
  final _facebook = TextEditingController();

  PinIndex? _pinIndex;
  List<PinRecord> _pinOffices = const [];
  _PinResult _pinResult = _PinResult.none;
  bool _prefilled = false;
  late final VoidCallback _unregisterDemo;
  bool _consent = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final d = context.read<AppState>().draft;
    _first.text = d.firstName;
    _last.text = d.lastName;
    _domainOther.text = d.professionalDomainOther ?? '';
    _pin.text = d.pinCode;
    _stateOther.text = d.stateOther ?? '';
    _districtOther.text = d.districtOther ?? '';
    _tehsil.text = d.tehsil ?? '';
    _block.text = d.block ?? '';
    _city.text = d.cityVillage;
    _pc.text = d.parliamentary;
    _ac.text = d.assembly;
    _instagram.text = d.instagramUrl ?? '';
    _linkedin.text = d.linkedinUrl ?? '';
    _facebook.text = d.facebookUrl ?? '';
    _unregisterDemo = DemoFill.register(_onDemoTap);
    PinIndex.load().then((index) {
      if (!mounted) return;
      _pinIndex = index;
      if (_pin.text.length == 6) {
        _onPinChanged(_pin.text, keepEdits: true);
      } else {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _unregisterDemo();
    for (final c in [
      _first,
      _last,
      _aadhaar,
      _domainOther,
      _pin,
      _stateOther,
      _districtOther,
      _tehsil,
      _block,
      _city,
      _pc,
      _ac,
      _instagram,
      _linkedin,
      _facebook,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Application get _draft => context.read<AppState>().draft;

  String? _err(String key) =>
      _errors[key] == null ? null : tRead(context, _errors[key]!);

  /// Demo badge: fills every step at once, so the presenter only taps Continue.
  void _onDemoTap() {
    _fillDemo(_draft);
    _errors.clear();
    _onPinChanged(_pin.text);
  }

  void _fillDemo(Application d) {
    _first.text = d.firstName = 'Asha';
    _last.text = d.lastName = 'Verma';
    _aadhaar.text = '2345 6789 0124';
    d.professionalDomain = 'Academia';
    _pin.text = d.pinCode = '142026';
    _tehsil.text = 'Jagraon';
    _pc.text = 'Ludhiana';
    _ac.text = 'Jagraon';
    d.selfiePath = demoSelfie;
    _instagram.text = 'https://www.instagram.com/ashaverma';
    _consent = true;
  }

  /// Looks up the PIN. A known post office fills state, district, block and city.
  /// An unknown PIN still fills the state from its prefix, and the member picks the district.
  /// [keepEdits] restores the office list without overwriting what the member already typed.
  void _onPinChanged(String value, {bool keepEdits = false}) {
    final d = _draft;
    d.pinCode = value;
    _errors.remove('pin');
    _pinOffices = const [];
    _pinResult = _PinResult.none;
    if (value.length == 6 && _pinIndex != null) {
      final offices = _pinIndex!.forPin(value);
      final state = stateForPin(value);
      if (offices.isNotEmpty) {
        _pinOffices = offices;
        _pinResult = _PinResult.found;
        final current = offices.where((o) => o.office == _city.text);
        if (!keepEdits || current.isEmpty) {
          _applyOffice(current.isEmpty ? offices.first : current.first);
        }
      } else if (state != null) {
        _pinResult = _PinResult.stateOnly;
        if (!keepEdits || d.state != state) {
          d.state = state;
          d.stateOther = null;
          _stateOther.clear();
          d.district = '';
          d.districtOther = null;
          _districtOther.clear();
        }
      } else {
        _pinResult = _PinResult.unknown;
      }
      _errors.remove('state');
      _errors.remove('district');
    }
    setState(() {});
  }

  void _applyOffice(PinRecord r) {
    final d = _draft;
    d.state = r.state;
    d.stateOther = null;
    _stateOther.clear();
    d.district = r.district;
    d.districtOther = null;
    _districtOther.clear();
    d.block = r.block;
    _block.text = r.block;
    d.cityVillage = r.office;
    _city.text = r.office;
    _errors.remove('city');
  }

  /// Demo only: pretends to read the address from Aadhaar, then runs the normal PIN lookup.
  void _prefillFromAadhaar() {
    if (!isValidAadhaar(_aadhaar.text)) return;
    final address = context.read<MockRepository>().lookupAadhaarAddress(
      _aadhaar.text,
    );
    _pin.text = address.pin;
    _prefilled = true;
    _onPinChanged(address.pin);
  }

  /// Districts for a state: the reference list plus every district in the PIN table, sorted, then Other.
  List<String> _districtsFor(String code) {
    final all = <String>{
      ...?regionByCode(code)?.districts,
      ...?_pinIndex?.districtsIn(code),
      if (_draft.district.isNotEmpty && _draft.district != otherOption)
        _draft.district,
    }.toList()..sort();
    return [...all, otherOption];
  }

  bool _validate() {
    final d = _draft;
    _errors.clear();
    switch (_step) {
      case 0:
        if (_first.text.trim().isEmpty) _errors['first'] = 'err_required';
        if (_last.text.trim().isEmpty) _errors['last'] = 'err_required';
        if (!isValidAadhaar(_aadhaar.text)) _errors['aadhaar'] = 'err_aadhaar';
        if (d.professionalDomain.isEmpty) _errors['domain'] = 'err_select';
        if (d.professionalDomain == otherOption &&
            _domainOther.text.trim().length < 2) {
          _errors['domainOther'] = 'err_required';
        }
      case 1:
        if (!RegExp(r'^[1-9]\d{5}$').hasMatch(_pin.text)) {
          _errors['pin'] = 'err_pin';
        }
        if (d.state.isEmpty && _stateOther.text.trim().isEmpty) {
          _errors['state'] = 'err_select';
        }
        if (d.state == 'OT' && _stateOther.text.trim().length < 2) {
          _errors['state'] = 'err_required';
        }
        if (d.state == 'OT' || d.district == otherOption) {
          if (_districtOther.text.trim().length < 2) {
            _errors['district'] = 'err_required';
          }
        } else if (d.district.isEmpty) {
          _errors['district'] = 'err_select';
        }
        if (_city.text.trim().length < 2) _errors['city'] = 'err_required';
      case 2:
        if (d.selfiePath == null) _errors['selfie'] = 'err_selfie';
        final links = {
          SocialPlatform.instagram: _instagram.text,
          SocialPlatform.linkedin: _linkedin.text,
          SocialPlatform.facebook: _facebook.text,
        };
        for (final entry in links.entries) {
          final message = validateSocialLink(entry.key, entry.value);
          if (entry.value.trim().isNotEmpty && message != null) {
            _errors[entry.key.name] = 'err_social';
          }
        }
        if (_instagram.text.trim().isEmpty &&
            _linkedin.text.trim().isEmpty &&
            _facebook.text.trim().isEmpty) {
          _errors['social'] = 'err_social_required';
        }
        if (!_consent) _errors['consent'] = 'err_consent';
    }
    return _errors.isEmpty;
  }

  /// Copies the text fields into the draft. Full Aadhaar is never stored, only the masked form.
  void _saveStep() {
    final d = _draft;
    switch (_step) {
      case 0:
        d.firstName = _first.text.trim();
        d.lastName = _last.text.trim();
        d.aadhaarMasked = maskAadhaar(_aadhaar.text);
        d.professionalDomainOther = d.professionalDomain == otherOption
            ? _domainOther.text.trim()
            : null;
      case 1:
        d.pinCode = _pin.text;
        d.stateOther = d.state == 'OT' ? _stateOther.text.trim() : null;
        if (d.state == 'OT') d.district = otherOption;
        d.districtOther = d.district == otherOption
            ? _districtOther.text.trim()
            : null;
        d.tehsil = _tehsil.text.trim().isEmpty ? null : _tehsil.text.trim();
        d.block = _block.text.trim().isEmpty ? null : _block.text.trim();
        d.cityVillage = _city.text.trim();
        d.parliamentary = _pc.text.trim();
        d.assembly = _ac.text.trim();
      case 2:
        d.instagramUrl = _instagram.text.trim().isEmpty
            ? null
            : _instagram.text.trim();
        d.linkedinUrl = _linkedin.text.trim().isEmpty
            ? null
            : _linkedin.text.trim();
        d.facebookUrl = _facebook.text.trim().isEmpty
            ? null
            : _facebook.text.trim();
    }
  }

  Future<void> _next() async {
    if (!_validate()) {
      setState(() {});
      return;
    }
    _saveStep();
    if (_step < 2) {
      setState(() {
        _step++;
        _errors.clear();
      });
      return;
    }
    setState(() => _submitting = true);
    final repo = context.read<MockRepository>();
    final app = await repo.submit(_draft);
    if (!mounted) return;
    setState(() => _submitting = false);
    context.read<AppState>().resetDraft();
    context.go('/home/submitted', extra: app.referenceNo);
  }

  void _back() {
    if (_step == 0) {
      context.pop();
    } else {
      setState(() {
        _step--;
        _errors.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final titles = [
      t(context, 'reg_identity'),
      t(context, 'reg_location'),
      t(context, 'reg_selfie'),
    ];
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(CupertinoIcons.chevron_back),
            onPressed: _back,
          ),
          actions: const [NavActions(showLanguage: false)],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: StepProgress(current: _step, title: titles[_step]),
              ),
              Expanded(
                child: ListView(
                  // A new key per step starts each step at the top instead of keeping the previous scroll position.
                  key: ValueKey(_step),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    ...switch (_step) {
                      0 => _identity(),
                      1 => _location(),
                      _ => _selfieAndSocial(),
                    },
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: PrimaryButton(
                  label: _step == 2
                      ? t(context, 'submit_application')
                      : t(context, 'continue'),
                  loading: _submitting,
                  onPressed: _next,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _identity() {
    final d = _draft;
    final phone = context.read<AppState>().phone ?? '';
    return [
      _field(t(context, 'first_name'), _first, errorKey: 'first'),
      _field(t(context, 'last_name'), _last, errorKey: 'last'),
      _readOnly(t(context, 'phone'), phone),
      _field(
        t(context, 'aadhaar'),
        _aadhaar,
        keyboard: TextInputType.number,
        hint: t(context, 'aadhaar_hint'),
        errorKey: 'aadhaar',
        formatter: true,
        onEditingComplete: _prefillFromAadhaar,
      ),
      const SizedBox(height: 8),
      Text(t(context, 'professional_domain'), style: AppText.sectionTitle),
      const SizedBox(height: 8),
      _DomainTile(
        label: d.professionalDomain.isEmpty
            ? t(context, 'choose_domain')
            : d.professionalDomain,
        error: _err('domain'),
        onTap: _pickDomain,
      ),
      if (d.professionalDomain == otherOption)
        _field(
          t(context, 'domain_other'),
          _domainOther,
          errorKey: 'domainOther',
        ),
    ];
  }

  Future<void> _pickDomain() async {
    final picked = await showCupertinoModalPopup<String>(
      context: context,
      builder: (_) => _DomainSheet(current: _draft.professionalDomain),
    );
    if (picked == null) return;
    setState(() {
      _draft.professionalDomain = picked;
      if (picked != otherOption) _domainOther.clear();
    });
  }

  List<Widget> _location() {
    final d = _draft;
    final region = regionByCode(d.state);
    final other = t(context, 'other');
    final stateNames = [for (final r in regions) r.name, other];
    final currentStateName = d.state == 'OT' ? other : (region?.name ?? '');
    return [
      if (_prefilled)
        _Notice(
          icon: CupertinoIcons.checkmark_seal_fill,
          text: t(context, 'prefilled_demo'),
        ),
      _field(
        t(context, 'pin_code'),
        _pin,
        keyboard: TextInputType.number,
        errorKey: 'pin',
        maxLength: 6,
        onChanged: _onPinChanged,
      ),
      if (_pinResult == _PinResult.found)
        _Notice(
          icon: CupertinoIcons.location_solid,
          text:
              '${t(context, 'pin_found')}: ${_city.text}, ${d.district}, ${region?.name ?? ''}',
        ),
      if (_pinResult == _PinResult.stateOnly)
        _Notice(
          icon: CupertinoIcons.location,
          text: '${region?.name ?? ''}. ${t(context, 'pin_state_only')}',
        ),
      if (_pinResult == _PinResult.unknown)
        _Notice(
          icon: CupertinoIcons.exclamationmark_circle,
          text: t(context, 'pin_unknown'),
          warning: true,
        ),
      if (_pinOffices.length > 1)
        _gap(
          CupertinoSelect(
            label: t(context, 'pin_pick_office'),
            value: _city.text,
            items: [for (final o in _pinOffices) o.office],
            onChanged: (v) => setState(
              () => _applyOffice(_pinOffices.firstWhere((o) => o.office == v)),
            ),
          ),
        ),
      const SizedBox(height: 4),
      Text(t(context, 'address_section'), style: AppText.sectionTitle),
      const SizedBox(height: 8),
      _gap(
        CupertinoSelect(
          label: t(context, 'state_ut'),
          value: currentStateName,
          items: stateNames,
          error: _err('state'),
          onChanged: (v) => setState(() {
            final code = v == other
                ? 'OT'
                : regions.firstWhere((r) => r.name == v).code;
            if (code == d.state) return;
            d.state = code;
            d.district = '';
            d.districtOther = null;
            _districtOther.clear();
            _errors.remove('state');
          }),
        ),
      ),
      if (d.state == 'OT')
        _field(t(context, 'state_other'), _stateOther, errorKey: 'state'),
      if (d.state.isNotEmpty && d.state != 'OT')
        _gap(
          CupertinoSelect(
            label: t(context, 'district'),
            value: d.district,
            items: _districtsFor(d.state),
            error: _err('district'),
            onChanged: (v) => setState(() {
              d.district = v;
              if (v != otherOption) {
                d.districtOther = null;
                _districtOther.clear();
              }
              _errors.remove('district');
            }),
          ),
        ),
      if (d.state == 'OT' || d.district == otherOption)
        _field(
          t(context, 'district_other'),
          _districtOther,
          errorKey: 'district',
        ),
      _field(t(context, 'city_village'), _city, errorKey: 'city'),
      const SizedBox(height: 4),
      Text(t(context, 'more_details'), style: AppText.sectionTitle),
      const SizedBox(height: 8),
      _field(t(context, 'tehsil'), _tehsil),
      _field(t(context, 'block'), _block),
      _field(t(context, 'parliamentary'), _pc),
      _field(t(context, 'assembly'), _ac),
    ];
  }

  Widget _gap(Widget child) =>
      Padding(padding: const EdgeInsets.only(bottom: 14), child: child);

  List<Widget> _selfieAndSocial() {
    final d = _draft;
    return [
      Text(t(context, 'selfie_title'), style: AppText.sectionTitle),
      const SizedBox(height: 8),
      SelfieCapture(
        value: d.selfiePath,
        onChanged: (v) => setState(() {
          d.selfiePath = v;
          if (v == null) _errors.remove('selfie');
        }),
      ),
      if (_err('selfie') != null) ErrorText(_err('selfie')!),
      const SizedBox(height: 20),
      Text(t(context, 'social_title'), style: AppText.sectionTitle),
      const SizedBox(height: 4),
      Text(
        t(context, 'social_hint'),
        style: const TextStyle(color: AppColors.grey),
      ),
      const SizedBox(height: 8),
      _field(
        'Instagram',
        _instagram,
        keyboard: TextInputType.url,
        errorKey: 'instagram',
      ),
      _field(
        'LinkedIn',
        _linkedin,
        keyboard: TextInputType.url,
        errorKey: 'linkedin',
      ),
      _field(
        'Facebook',
        _facebook,
        keyboard: TextInputType.url,
        errorKey: 'facebook',
      ),
      if (_err('social') != null) ErrorText(_err('social')!),
      if (_err('instagram') != null ||
          _err('linkedin') != null ||
          _err('facebook') != null)
        ErrorText(t(context, 'err_social')),
      const SizedBox(height: 12),
      Row(
        children: [
          CupertinoSwitch(
            value: _consent,
            onChanged: (v) => setState(() => _consent = v),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(t(context, 'consent_text'))),
        ],
      ),
      if (_err('consent') != null) ErrorText(_err('consent')!),
    ];
  }

  Widget _readOnly(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      child: Text(value),
    ),
  );

  Widget _field(
    String label,
    TextEditingController controller, {
    String? errorKey,
    String? hint,
    String? helper,
    bool optional = false,
    TextInputType? keyboard,
    int? maxLength,
    bool formatter = false,
    ValueChanged<String>? onChanged,
    VoidCallback? onEditingComplete,
  }) {
    final error = errorKey == null ? null : _err(errorKey);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        maxLength: maxLength,
        onChanged:
            onChanged ??
            (_) {
              if (errorKey != null) setState(() => _errors.remove(errorKey));
            },
        onEditingComplete: onEditingComplete,
        inputFormatters: formatter ? [_AadhaarFormatter()] : null,
        decoration: InputDecoration(
          labelText: optional ? '$label (${t(context, 'optional')})' : label,
          hintText: hint,
          helperText: helper,
          errorText: error,
          counterText: '',
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

/// Shows the Aadhaar number in groups of four digits while typing.
class _AadhaarFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 12 ? digits.substring(0, 12) : digits;
    final buffer = StringBuffer();
    for (var i = 0; i < limited.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(limited[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class _DomainTile extends StatelessWidget {
  const _DomainTile({required this.label, required this.onTap, this.error});

  final String label;
  final VoidCallback onTap;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F7FD),
          border: Border.all(
            color: error == null ? const Color(0xFFCFE0F5) : AppColors.red,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_down,
              color: AppColors.navy,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

/// Native grouped list of the 24 domains plus Other, with search and a checkmark on the current choice.
class _DomainSheet extends StatefulWidget {
  const _DomainSheet({required this.current});

  final String current;

  @override
  State<_DomainSheet> createState() => _DomainSheetState();
}

class _DomainSheetState extends State<_DomainSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final items = [
      for (final d in [...professionalDomains, otherOption])
        if (d.toLowerCase().contains(_query.toLowerCase())) d,
    ];
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.85,
      child: CupertinoPageScaffold(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        navigationBar: CupertinoNavigationBar(
          middle: Text(t(context, 'professional_domain')),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t(context, 'cancel')),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: CupertinoSearchTextField(
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    CupertinoListSection.insetGrouped(
                      children: [
                        for (final item in items)
                          CupertinoListTile(
                            title: Text(item),
                            trailing: item == widget.current
                                ? const Icon(
                                    CupertinoIcons.checkmark_alt,
                                    color: AppColors.navy,
                                  )
                                : null,
                            onTap: () => Navigator.of(context).pop(item),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _PinResult { none, found, stateOnly, unknown }

/// Soft coloured note above or below a field, for example the PIN lookup result.
class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.text, this.warning = false});

  final IconData icon;
  final String text;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final color = warning ? const Color(0xFF9A5B00) : const Color(0xFF1E6B34);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: warning ? const Color(0xFFFFF4E0) : const Color(0xFFEAF4EA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: color)),
          ),
        ],
      ),
    );
  }
}

class ErrorText extends StatelessWidget {
  const ErrorText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 4, bottom: 8),
    child: Text(
      text,
      style: const TextStyle(color: AppColors.red, fontSize: 13),
    ),
  );
}
