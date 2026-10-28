import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/mock_repository.dart';
import '../state/app_state.dart';
import '../theme.dart';

/// Small pill that drops in over any admin screen when a member in the admin's scope applies.
/// Tapping it opens the review list. It hides itself after four seconds.
class AdminLivePill extends StatefulWidget {
  const AdminLivePill({super.key, required this.child, required this.router});

  final Widget child;
  final GoRouter router;

  @override
  State<AdminLivePill> createState() => _AdminLivePillState();
}

class _AdminLivePillState extends State<AdminLivePill> {
  final Set<String> _announced = {};
  String? _text;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _show(String text) {
    _timer?.cancel();
    setState(() => _text = text);
    _timer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _text = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<MockRepository>();
    final state = context.watch<AppState>();
    final admin = state.admin;
    if (admin == null) {
      _announced.clear();
    } else {
      final fresh = repo
          .newApplications(admin, state.adminSignedInAt, state.seenRefs)
          .where((a) => !_announced.contains(a.referenceNo))
          .toList();
      if (fresh.isNotEmpty) {
        _announced.addAll(fresh.map((a) => a.referenceNo));
        final text = fresh.length == 1
            ? '${fresh.first.name} applied'
            : '${fresh.length} new applications';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _show(text);
        });
      }
    }
    return Stack(
      children: [
        widget.child,
        if (_text != null)
          Positioned(
            top: MediaQuery.paddingOf(context).top + 6,
            left: 0,
            right: 0,
            child: Center(
              child: Material(
                color: AppColors.navy,
                shape: const StadiumBorder(),
                elevation: 4,
                child: InkWell(
                  customBorder: const StadiumBorder(),
                  onTap: () {
                    setState(() => _text = null);
                    widget.router.go('/admin/dashboard/review');
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          CupertinoIcons.person_badge_plus_fill,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _text!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
