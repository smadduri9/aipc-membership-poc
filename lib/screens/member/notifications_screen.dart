import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/mock_repository.dart';
import '../../state/app_state.dart';
import '../../theme.dart';
import '../../utils/format.dart';
import '../../widgets/nav_actions.dart';

/// In-app inbox. Shows decisions on the application and payment results, newest first.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MockRepository>().markAllRead(
        context.read<AppState>().phone ?? '',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final phone = context.watch<AppState>().phone ?? '';
    final items = context.watch<MockRepository>().notificationsFor(phone);
    return Scaffold(
      backgroundColor: AppColors.grouped,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: const [NavActions(showLanguage: false)],
      ),
      body: SafeArea(
        child: items.isEmpty
            ? const Center(
                child: Text(
                  'No notifications yet',
                  style: TextStyle(color: AppColors.grey),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final n = items[i];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: n.read ? null : Border.all(color: AppColors.navy),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          n.title,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(n.body),
                        const SizedBox(height: 6),
                        Text(
                          formatDateTime(n.at),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
