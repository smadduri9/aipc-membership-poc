import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../config.dart';

/// Shows the Manmohan Singh Fellowship application inside the app. The member submits it on that site.
class FellowshipWebScreen extends StatefulWidget {
  const FellowshipWebScreen({super.key});

  @override
  State<FellowshipWebScreen> createState() => _FellowshipWebScreenState();
}

class _FellowshipWebScreenState extends State<FellowshipWebScreen> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => setState(() => _loading = false),
          onWebResourceError: (_) => setState(() {
            _loading = false;
            _failed = true;
          }),
        ),
      )
      ..loadRequest(Uri.parse(kManmohanSinghUrl));
  }

  void _retry() {
    setState(() {
      _failed = false;
      _loading = true;
    });
    _controller.loadRequest(Uri.parse(kManmohanSinghUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Manmohan Singh Fellowship'),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Done')),
        ],
      ),
      body: Stack(
        children: [
          if (!_failed) WebViewWidget(controller: _controller),
          if (_loading && !_failed)
            const Center(child: CupertinoActivityIndicator()),
          if (_failed)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('The page could not be opened.'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _retry,
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
