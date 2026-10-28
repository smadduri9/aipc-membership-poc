import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/mock_repository.dart';
import '../../state/app_state.dart';
import '../../theme.dart';
import '../../widgets/demo_badge.dart';
import '../../widgets/primary_button.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _failed = false;
  late final VoidCallback _unregisterDemo;

  @override
  void initState() {
    super.initState();
    _unregisterDemo = DemoFill.register(_pickDemoAccount);
  }

  /// Demo badge: pick a role, and the login is filled and submitted.
  Future<void> _pickDemoAccount() async {
    final email = await showCupertinoModalPopup<String>(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        title: const Text('Sign in as'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(sheetContext).pop('pb@aipc.demo'),
            child: const Text('State representative · Punjab'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(sheetContext).pop('master@aipc.demo'),
            child: const Text('Master · all states and UTs'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(sheetContext).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );
    if (email == null || !mounted) return;
    setState(() {
      _email.text = email;
      _password.text = 'demo1234';
    });
    await _login();
  }

  @override
  void dispose() {
    _unregisterDemo();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    final ok = await context.read<MockRepository>().adminLogin(
      _email.text.trim(),
      _password.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok != null) {
      context.read<AppState>().adminSignIn(ok);
      context.go('/admin/dashboard');
    } else {
      setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin login'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: DemoBadge()),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              if (_failed)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Wrong email or password',
                    style: TextStyle(color: AppColors.red),
                  ),
                ),
              const SizedBox(height: 8),
              const Text(
                'Demo: master@aipc.demo or pb@aipc.demo / demo1234',
                style: TextStyle(color: AppColors.grey),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Log in',
                loading: _loading,
                onPressed: _loading ? null : _login,
              ),
              TextButton(
                onPressed: () {
                  final signedIn =
                      context.read<AppState>().phone?.isNotEmpty ?? false;
                  context.go(signedIn ? '/home' : '/phone');
                },
                child: const Text('Back to member app'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
