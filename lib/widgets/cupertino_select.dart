import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../theme.dart';

/// Tappable form field that opens a native list sheet: tap a row to choose it. Long lists get a search field.
class CupertinoSelect extends StatelessWidget {
  const CupertinoSelect({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.enabled = true,
    this.error,
    this.display,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final String? error;

  /// Converts a stored value into the label shown to the user, e.g. a translation.
  final String Function(String value)? display;

  String _label(String value) => display?.call(value) ?? value;

  Future<void> _open(BuildContext context) async {
    if (!enabled || items.isEmpty) return;
    final picked = await showCupertinoModalPopup<String>(
      context: context,
      builder: (_) => _SelectSheet(
        title: label,
        items: items,
        current: value,
        display: _label,
      ),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = value.isNotEmpty;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: enabled ? () => _open(context) : null,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            errorText: error,
            suffixIcon: const Icon(CupertinoIcons.chevron_down, size: 18),
          ),
          child: Text(
            hasValue ? _label(value) : t(context, 'select'),
            style: TextStyle(color: hasValue ? Colors.black : AppColors.grey),
          ),
        ),
      ),
    );
  }
}

class _SelectSheet extends StatefulWidget {
  const _SelectSheet({
    required this.title,
    required this.items,
    required this.current,
    required this.display,
  });

  final String title;
  final List<String> items;
  final String current;
  final String Function(String value) display;

  @override
  State<_SelectSheet> createState() => _SelectSheetState();
}

class _SelectSheetState extends State<_SelectSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final searchable = widget.items.length > 8;
    final shown = [
      for (final item in widget.items)
        if (widget.display(item).toLowerCase().contains(_query.toLowerCase()))
          item,
    ];
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.85,
      child: CupertinoPageScaffold(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        navigationBar: CupertinoNavigationBar(
          middle: Text(widget.title),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t(context, 'cancel')),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              if (searchable)
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
                        for (final item in shown)
                          CupertinoListTile(
                            title: Text(widget.display(item)),
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
