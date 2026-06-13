import 'package:flutter/material.dart';

import '../scheme.dart';
import '../tokens.dart';
import 'auris_container.dart';

/// The state of an [AurisStepIndicator] marker.
enum AurisStepState {
  /// Not yet reached — dim border, dim number.
  inactive,

  /// The current step — gold border + glow, gold number.
  active,

  /// Finished — solid gold fill with a check glyph.
  complete,

  /// Errored — danger border + fill with a warning glyph.
  error,
}

/// A chamfered step marker for use with `Stepper.stepIconBuilder` or standalone
/// (§spec:custom-widgets). The four [AurisStepState]s — inactive, active,
/// complete, error — are distinguished by border/fill color and glyph, all
/// resolved from the [AurisScheme]; the active marker carries the active depth
/// glow.
///
/// Built on [AurisContainer] so the marker shares the exact chamfer geometry of
/// the rest of the kit.
class AurisStepIndicator extends StatelessWidget {
  /// Creates a step marker showing [step] (1-based) in the given [state].
  const AurisStepIndicator({
    super.key,
    required this.step,
    required this.state,
    this.size = 28,
  });

  /// The 1-based step number (shown for inactive/active states).
  final int step;

  /// The marker state.
  final AurisStepState state;

  /// The square edge length of the marker.
  final double size;

  @override
  Widget build(BuildContext context) {
    final AurisScheme scheme = Theme.of(context).extension<AurisScheme>()!;

    late final Color border;
    late final Color fill;
    late final Color foreground;
    AurisDepth? depth;
    Widget content;

    switch (state) {
      case AurisStepState.inactive:
        border = scheme.borderResting;
        fill = scheme.surfaceInset;
        foreground = scheme.textMid;
        content = _label(scheme, foreground);
      case AurisStepState.active:
        border = scheme.primaryActive;
        fill = scheme.primaryActive.withValues(alpha: 0.16);
        foreground = scheme.primaryActive;
        depth = scheme.depthActive;
        content = _label(scheme, foreground);
      case AurisStepState.complete:
        border = scheme.primaryActive;
        fill = scheme.primaryActive;
        foreground = scheme.onPrimary;
        content = Icon(Icons.check, size: size * 0.55, color: foreground);
      case AurisStepState.error:
        border = scheme.dangerBright;
        fill = scheme.danger.withValues(alpha: 0.22);
        foreground = scheme.dangerBright;
        depth = scheme.depthDanger;
        content =
            Icon(Icons.priority_high, size: size * 0.6, color: foreground);
    }

    return AurisContainer(
      cut: scheme.bevel.xs,
      width: size,
      height: size,
      fill: fill,
      borderColor: border,
      depth: depth,
      alignment: Alignment.center,
      child: content,
    );
  }

  Widget _label(AurisScheme scheme, Color color) {
    return Text(
      '$step',
      style: TextStyle(
        fontFamily: AurisTokens.fontMono,
        fontSize: size * 0.42,
        height: 1.0,
        color: color,
      ),
    );
  }
}
