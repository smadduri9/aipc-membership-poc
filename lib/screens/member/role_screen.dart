import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/strings.dart';
import '../../theme.dart';
import '../../widgets/nav_actions.dart';

/// Asks whether the person is a member applying or an administrator.
class RoleScreen extends StatelessWidget {
  const RoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: const [NavActions()]),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(t(context, 'role_title'), style: AppText.largeTitle),
              const SizedBox(height: 24),
              _RoleCard(
                icon: CupertinoIcons.person_crop_circle,
                title: t(context, 'role_member_title'),
                subtitle: t(context, 'role_member_sub'),
                onTap: () => context.push('/phone'),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                icon: CupertinoIcons.shield_lefthalf_fill,
                title: t(context, 'role_admin_title'),
                subtitle: t(context, 'role_admin_sub'),
                onTap: () => context.push('/admin'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F7FD),
          border: Border.all(color: const Color(0xFFCFE0F5)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: AppColors.navy),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: AppColors.grey)),
                ],
              ),
            ),
            const Icon(CupertinoIcons.chevron_right, color: AppColors.grey),
          ],
        ),
      ),
    );
  }
}
