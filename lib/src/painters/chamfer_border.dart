import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// The signature Auris corner geometry: an **asymmetric** 45° chamfer that cuts
/// **only the top-left and bottom-right** corners, leaving the top-right and
/// bottom-left square (§spec:design-tokens "Shape", §spec:theme-layer).
///
/// This is the single place the corner rule lives. Flutter's
/// [BeveledRectangleBorder] cannot express it because it bevels all four
/// corners equally; [AurisChamferBorder] owns the notched-panel silhouette so
/// "which corners are cut" is one edit, not a sweep across every theme.
///
/// The outer path is a six-vertex polygon. Starting on the top edge a [cut]
/// before the top-left corner, it slants down-left to the left edge ([cut]
/// below the corner), runs to the square top-right corner, down to the
/// bottom-right where it slants in by [cut] on both edges, along the bottom to
/// the square bottom-left corner, and back up to the start.
class AurisChamferBorder extends OutlinedBorder {
  /// Creates a chamfered border whose top-left and bottom-right corners are cut
  /// by [cut] (the length of each 45° leg, in logical pixels).
  const AurisChamferBorder({
    this.cut = 0,
    super.side = BorderSide.none,
  });

  /// The length of each 45° cut leg, in logical pixels. Clamped per-rect so it
  /// never exceeds half the shorter side.
  final double cut;

  /// The effective cut for [rect]: [cut] clamped to half the shorter side so a
  /// large bevel on a small rect degrades gracefully instead of self-crossing.
  double _effectiveCut(Rect rect) {
    final double limit = rect.shortestSide / 2;
    final double c = cut.clamp(0.0, limit);
    return c;
  }

  /// The notched polygon for [rect], inset on all edges by [inset] (used to
  /// derive the inner path from the outer one).
  Path _buildPath(Rect rect, {double inset = 0}) {
    final Rect r = inset == 0 ? rect : rect.deflate(inset);
    final double c = _effectiveCut(r);
    if (c <= 0) {
      return Path()..addRect(r);
    }
    return Path()
      // Top edge, a cut before the top-left corner.
      ..moveTo(r.left + c, r.top)
      // Slant down-left to the left edge (top-left corner cut).
      ..lineTo(r.left, r.top + c)
      // Down the left edge to the square bottom-left corner.
      ..lineTo(r.left, r.bottom)
      // Along the bottom to a cut before the bottom-right corner.
      ..lineTo(r.right - c, r.bottom)
      // Slant up-right to the right edge (bottom-right corner cut).
      ..lineTo(r.right, r.bottom - c)
      // Up the right edge to the square top-right corner, then back to start.
      ..lineTo(r.right, r.top)
      ..close();
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      _buildPath(rect);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      _buildPath(rect, inset: side.width);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none || side.width == 0) {
      return;
    }
    final Path path = getOuterPath(rect, textDirection: textDirection);
    canvas.drawPath(path, side.toPaint());
  }

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.strokeInset);

  @override
  AurisChamferBorder copyWith({BorderSide? side, double? cut}) {
    return AurisChamferBorder(
      cut: cut ?? this.cut,
      side: side ?? this.side,
    );
  }

  @override
  AurisChamferBorder scale(double t) {
    return AurisChamferBorder(
      cut: cut * t,
      side: side.scale(t),
    );
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is AurisChamferBorder) {
      return AurisChamferBorder(
        cut: lerpDouble(a.cut, cut, t)!,
        side: BorderSide.lerp(a.side, side, t),
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is AurisChamferBorder) {
      return AurisChamferBorder(
        cut: lerpDouble(cut, b.cut, t)!,
        side: BorderSide.lerp(side, b.side, t),
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is AurisChamferBorder &&
        other.cut == cut &&
        other.side == side;
  }

  @override
  int get hashCode => Object.hash(cut, side);

  @override
  String toString() => 'AurisChamferBorder(cut: $cut, side: $side)';
}

/// The text-field counterpart of [AurisChamferBorder].
///
/// [InputDecorationTheme] requires an [InputBorder] rather than a
/// [ShapeBorder], so this paints the identical top-left + bottom-right cut
/// silhouette while satisfying the [InputBorder] contract (and respecting the
/// active [borderSide] supplied by `InputDecorator` for enabled / focus /
/// error states).
class AurisChamferInputBorder extends InputBorder {
  /// Creates a chamfered input border cutting the top-left and bottom-right
  /// corners by [cut].
  const AurisChamferInputBorder({
    this.cut = 0,
    super.borderSide = const BorderSide(),
  });

  /// The length of each 45° cut leg, in logical pixels.
  final double cut;

  double _effectiveCut(Rect rect) => cut.clamp(0.0, rect.shortestSide / 2);

  Path _buildPath(Rect rect, {double inset = 0}) {
    final Rect r = inset == 0 ? rect : rect.deflate(inset);
    final double c = _effectiveCut(r);
    if (c <= 0) {
      return Path()..addRect(r);
    }
    return Path()
      ..moveTo(r.left + c, r.top)
      ..lineTo(r.left, r.top + c)
      ..lineTo(r.left, r.bottom)
      ..lineTo(r.right - c, r.bottom)
      ..lineTo(r.right, r.bottom - c)
      ..lineTo(r.right, r.top)
      ..close();
  }

  @override
  bool get isOutline => true;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(borderSide.strokeInset);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      _buildPath(rect);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      _buildPath(rect, inset: borderSide.width);

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    double? gapStart,
    double gapExtent = 0.0,
    double gapPercentage = 0.0,
    TextDirection? textDirection,
  }) {
    if (borderSide.style == BorderStyle.none || borderSide.width == 0) {
      return;
    }
    canvas.drawPath(
      getOuterPath(rect, textDirection: textDirection),
      borderSide.toPaint(),
    );
  }

  @override
  AurisChamferInputBorder copyWith({BorderSide? borderSide, double? cut}) {
    return AurisChamferInputBorder(
      cut: cut ?? this.cut,
      borderSide: borderSide ?? this.borderSide,
    );
  }

  @override
  AurisChamferInputBorder scale(double t) {
    return AurisChamferInputBorder(
      cut: cut * t,
      borderSide: borderSide.scale(t),
    );
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is AurisChamferInputBorder) {
      return AurisChamferInputBorder(
        cut: lerpDouble(a.cut, cut, t)!,
        borderSide: BorderSide.lerp(a.borderSide, borderSide, t),
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is AurisChamferInputBorder) {
      return AurisChamferInputBorder(
        cut: lerpDouble(cut, b.cut, t)!,
        borderSide: BorderSide.lerp(borderSide, b.borderSide, t),
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is AurisChamferInputBorder &&
        other.cut == cut &&
        other.borderSide == borderSide;
  }

  @override
  int get hashCode => Object.hash(cut, borderSide);

  @override
  String toString() =>
      'AurisChamferInputBorder(cut: $cut, borderSide: $borderSide)';
}
