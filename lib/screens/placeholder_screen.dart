import 'package:flutter/material.dart';
import '../widgets/demo_badge.dart';

/// Temporary screen used until a feature PR replaces it.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: const [Padding(padding: EdgeInsets.only(right: 12), child: Center(child: DemoBadge()))]),
      body: SafeArea(child: Center(child: Text(title))),
    );
  }
}
