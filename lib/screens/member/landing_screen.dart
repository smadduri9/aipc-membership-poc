import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/strings.dart';
import '../../theme.dart';
import '../../widgets/nav_actions.dart';
import '../../widgets/primary_button.dart';

/// First screen of the app. Introduces AICP and waits for the user to tap Next.
/// There is no auto-advance.
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  static const _heroAsset = 'assets/images/landing_image.jpg';
  bool _precached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_precached) {
      _precached = true;
      precacheImage(const AssetImage(_heroAsset), context);
    }
  }

  void _next() {
    HapticFeedback.lightImpact();
    context.push('/language');
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final size = MediaQuery.sizeOf(context);
    final compact = size.height < 700;
    final photoHeight = size.height * (compact ? 0.56 : 0.64);

    return Scaffold(
      backgroundColor: AppColors.sheet,
      // Expand so the card below the photo is inside the hit-test area. Without this the stack is only as tall as the photo and the Next button cannot be tapped.
      body: Stack(
        fit: StackFit.expand,
        children: [
          SizedBox(
            height: photoHeight,
            width: double.infinity,
            child: Image.asset(
              _heroAsset,
              fit: BoxFit.cover,
              alignment: const Alignment(0, -0.35),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: photoHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.7, 1.0],
                  colors: [
                    Colors.black.withValues(alpha: 0.25),
                    Colors.transparent,
                    AppColors.sheet,
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            top: 0,
            left: 16,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(top: 8),
                child: LanguagePill(),
              ),
            ),
          ),
          Positioned(
            top: photoHeight - 28,
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedContainer(
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
              decoration: const BoxDecoration(
                color: AppColors.sheet,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          t(context, 'landing_title'),
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: AppColors.navy,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          t(context, 'landing_full_name'),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const _TricolourRule(),
                        const SizedBox(height: 24),
                        PrimaryButton(
                          label: t(context, 'next'),
                          onPressed: _next,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Thin saffron, white and green rule. The white segment has a hairline border so it shows on light backgrounds.
class _TricolourRule extends StatelessWidget {
  const _TricolourRule();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _segment(AppColors.saffron),
        const SizedBox(width: 4),
        _segment(Colors.white, border: true),
        const SizedBox(width: 4),
        _segment(AppColors.green),
      ],
    );
  }

  Widget _segment(Color color, {bool border = false}) {
    return Container(
      width: 24,
      height: 3,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
        border: border ? Border.all(color: AppColors.separator) : null,
      ),
    );
  }
}
