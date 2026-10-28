import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/mock_repository.dart';
import '../state/app_state.dart';
import '../theme.dart';

/// Demo autofill for the screen on top. A screen registers its fill action in initState and
/// unregisters in dispose, so the badge always fills the screen the presenter is looking at.
class DemoFill {
  DemoFill._();

  static final _actions = <VoidCallback>[];

  /// Returns the function that removes this action again.
  static VoidCallback register(VoidCallback fill) {
    _actions.add(fill);
    return () => _actions.remove(fill);
  }

  static VoidCallback? get current => _actions.isEmpty ? null : _actions.last;
}

/// Orange DEMO badge in the nav bar. Tap it to fill the current screen with demo details.
/// On screens with nothing to fill it offers to reset the demo data.
class DemoBadge extends StatelessWidget {
  const DemoBadge({super.key});

  Future<void> _onTap(BuildContext context) async {
    HapticFeedback.selectionClick();
    final fill = DemoFill.current;
    if (fill != null) {
      fill();
      return;
    }
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        title: const Text('Demo'),
        message: const Text(
          'Clears every application made in the demo and starts again from the landing page.',
        ),
        actions: [
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.of(sheetContext).pop();
              await context.read<MockRepository>().resetDemo();
              if (!context.mounted) return;
              context.read<AppState>()
                ..setPhone('')
                ..adminSignOut()
                ..resetDraft();
              context.go('/');
            },
            child: const Text('Reset demo data'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(sheetContext).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Demo: fill in this screen',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTap(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.saffron,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CupertinoIcons.sparkles, size: 13, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'DEMO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
