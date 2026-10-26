import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../theme.dart';

/// Tappable form field that opens an iOS-style picker.
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
    final initial = items.contains(value) ? items.indexOf(value) : 0;
    var chosen = initial;
    final doneLabel = tRead(context, 'done');
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetContext) => Container(
        height: 300,
        color: CupertinoColors.systemBackground.resolveFrom(sheetContext),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: CupertinoButton(
                child: Text(doneLabel),
                onPressed: () {
                  onChanged(items[chosen]);
                  Navigator.of(sheetContext).pop();
                },
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 36,
                scrollController: FixedExtentScrollController(
                  initialItem: initial,
                ),
                onSelectedItemChanged: (index) => chosen = index,
                children: [
                  for (final item in items) Center(child: Text(_label(item))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
