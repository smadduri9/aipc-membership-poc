import 'package:flutter/material.dart';

/// Congress flag image (Wikimedia Commons, "Indian National Congress Flag.svg", rendered to PNG).
const congressFlagAsset = 'assets/images/congress_flag.png';

/// Small faint Congress flag in the centre of the screen, drawn over [child] but ignoring touches,
/// so sign-in screens with little content don't look empty.
class FlagWatermark extends StatelessWidget {
  const FlagWatermark({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: Align(
              alignment: const Alignment(0, 0.45),
              child: Opacity(
                opacity: 0.12,
                // Soft round fade so the flag has no hard edges over the screen behind it.
                child: ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (rect) => const RadialGradient(
                    radius: 0.62,
                    colors: [Colors.black, Colors.black, Colors.transparent],
                    stops: [0, 0.55, 1],
                  ).createShader(rect),
                  child: Image.asset(
                    congressFlagAsset,
                    width: size.width * 0.4,
                    fit: BoxFit.contain,
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
