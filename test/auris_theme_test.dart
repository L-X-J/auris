import 'package:auris/auris.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AurisTheme.light', () {
    test('builds a dark ThemeData carrying an AurisScheme extension', () {
      final ThemeData theme = AurisTheme.light();

      expect(theme.brightness, Brightness.dark);

      final AurisScheme? scheme = theme.extension<AurisScheme>();
      expect(scheme, isNotNull);
      expect(scheme!.brightness, Brightness.dark);
    });

    test('derives the ColorScheme from the resolved scheme', () {
      final ThemeData theme = AurisTheme.light();
      final AurisScheme scheme = theme.extension<AurisScheme>()!;

      expect(theme.colorScheme.primary, scheme.primaryActive);
      expect(theme.colorScheme.surface, scheme.surfacePanel);
      // Depth is glow, not shadow: shadows are transparent.
      expect(theme.colorScheme.shadow, Colors.transparent);
      expect(theme.shadowColor, Colors.transparent);
    });

    test('populates the full TextTheme from the scheme', () {
      final ThemeData theme = AurisTheme.light();
      final TextTheme text = theme.textTheme;

      expect(text.displayLarge, isNotNull);
      expect(text.bodyMedium, isNotNull);
      expect(text.labelLarge, isNotNull);
      expect(text.displayLarge!.fontFamily, AurisTokens.fontDisplay);
      expect(text.bodyLarge!.fontFamily, AurisTokens.fontBody);
    });

    test('accent override recolors the primary ramp', () {
      const Color accent = Color(0xFF00FF99);
      final ThemeData theme = AurisTheme.light(accent: accent);
      final AurisScheme scheme = theme.extension<AurisScheme>()!;

      expect(scheme.primaryActive, accent);
      expect(theme.colorScheme.primary, accent);
    });
  });

  group('AurisTheme.dark', () {
    test('throws UnimplementedError (reserved for the future variant)', () {
      expect(AurisTheme.dark, throwsUnimplementedError);
    });
  });

  group('AurisScheme.resolve', () {
    test('resolves the dark branch', () {
      final AurisScheme scheme =
          AurisScheme.resolve(brightness: Brightness.dark);
      expect(scheme.brightness, Brightness.dark);
      expect(scheme.surfacePage, AurisTokens.void_);
      expect(scheme.primaryActive, AurisTokens.gold);
    });

    test('requesting a non-dark brightness is unsupported in v0.1.0', () {
      expect(
        () => AurisScheme.resolve(brightness: Brightness.light),
        throwsUnsupportedError,
      );
    });

    test('bevel and glow overrides scale the resolved roles', () {
      final AurisScheme scheme = AurisScheme.resolve(
        bevelScale: 2.0,
        glowScale: 2.0,
      );
      expect(scheme.bevel.md, AurisTokens.bevelMd * 2.0);
      expect(
        scheme.depthActive.glow.first.blurRadius,
        AurisTokens.glowActive.first.blurRadius * 2.0,
      );
    });

    testWidgets('renders a Material widget that reads a scheme role color', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AurisTheme.light(),
          home: Builder(
            builder: (BuildContext context) {
              final AurisScheme scheme =
                  Theme.of(context).extension<AurisScheme>()!;
              return Scaffold(
                body: ColoredBox(color: scheme.surfacePanel),
              );
            },
          ),
        ),
      );

      expect(find.byType(ColoredBox), findsWidgets);
    });
  });
}
