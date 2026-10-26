import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/strings.dart';
import '../state/app_state.dart';
import 'demo_badge.dart';

const languageOptions = [
  ('hi', 'हिन्दी'),
  ('en', 'English'),
  ('pa', 'ਪੰਜਾਬੀ'),
  ('or', 'ଓଡ଼ିଆ'),
];

/// Nav bar trailing items for member screens: a language switcher and the demo badge.
/// Lets members change language at any point in the journey without losing their progress.
class NavActions extends StatelessWidget {
  const NavActions({super.key, this.showLanguage = true});

  final bool showLanguage;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLanguage) const LanguageButton(),
        const Padding(
          padding: EdgeInsets.only(right: 12),
          child: Center(child: DemoBadge()),
        ),
      ],
    );
  }
}

class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key});

  Future<void> _choose(BuildContext context) async {
    final state = context.read<AppState>();
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        title: Text(translate(state.lang, 'choose_language')),
        actions: [
          for (final (code, label) in languageOptions)
            CupertinoActionSheetAction(
              isDefaultAction: state.lang == code,
              onPressed: () {
                state.setLang(code);
                Navigator.of(sheetContext).pop();
              },
              child: Text(state.lang == code ? '$label  ✓' : label),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(sheetContext).pop(),
          child: Text(translate(state.lang, 'cancel')),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: t(context, 'choose_language'),
      icon: const Icon(CupertinoIcons.globe),
      onPressed: () => _choose(context),
    );
  }
}
