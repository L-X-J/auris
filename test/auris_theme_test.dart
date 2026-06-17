import 'dart:io';

import 'package:auris/auris.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AurisTheme.light', () {
    test('builds a light ThemeData carrying an AurisScheme extension', () {
      final ThemeData theme = AurisTheme.light();

      expect(theme.brightness, Brightness.light);

      final AurisScheme? scheme = theme.extension<AurisScheme>();
      expect(scheme, isNotNull);
      expect(scheme!.brightness, Brightness.light);
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

    test('accent override recolors the primary ramp, darkened for contrast', () {
      const Color accent = Color(0xFF00FF99);
      final ThemeData theme = AurisTheme.light(accent: accent);
      final AurisScheme scheme = theme.extension<AurisScheme>()!;

      // A raw light accent is too bright to clear AA on the light surface, so
      // the override is darkened (same hue, lower lightness) rather than used
      // verbatim — the same contrast correction the canonical amber rung gets.
      expect(scheme.primaryActive, isNot(accent));
      expect(
        scheme.primaryActive.computeLuminance(),
        lessThan(accent.computeLuminance()),
      );
      expect(
        HSLColor.fromColor(scheme.primaryActive).hue,
        closeTo(HSLColor.fromColor(accent).hue, 1.0),
      );
      // The darkened ramp clears WCAG AA (4.5:1) against the panel surface.
      expect(
        _contrast(scheme.primaryActive, scheme.surfacePanel),
        greaterThanOrEqualTo(4.5),
      );
      // The component color scheme tracks the same darkened ramp.
      expect(theme.colorScheme.primary, scheme.primaryActive);
    });
  });

  group('AurisTheme.dark', () {
    test('builds the dark (amber-on-near-black) theme', () {
      final ThemeData theme = AurisTheme.dark();
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, AurisTokens.gold);
      expect(theme.scaffoldBackgroundColor, AurisTokens.void_);
    });
  });

  group('font fallback', () {
    // The bundled fonts are the design intent, but text must still render in a
    // sensible system font if a bundled font fails to load — so every text role
    // pairs its family with a fallback chain (§spec:packaging "degrades
    // gracefully if a font is absent").
    test('every TextTheme role declares the matching fallback chain', () {
      final TextTheme text = AurisTheme.dark().textTheme;

      final List<TextStyle?> displayRoles = <TextStyle?>[
        text.displayLarge,
        text.displayMedium,
        text.displaySmall,
        text.headlineLarge,
        text.headlineMedium,
        text.headlineSmall,
        text.titleLarge,
        text.titleMedium,
        text.titleSmall,
      ];
      for (final TextStyle? style in displayRoles) {
        expect(style!.fontFamily, AurisTokens.fontDisplay);
        expect(style.fontFamilyFallback, AurisTokens.fontDisplayFallback);
      }

      final List<TextStyle?> bodyRoles = <TextStyle?>[
        text.bodyLarge,
        text.bodyMedium,
        text.bodySmall,
        text.labelLarge,
        text.labelMedium,
        text.labelSmall,
      ];
      for (final TextStyle? style in bodyRoles) {
        expect(style!.fontFamily, AurisTokens.fontBody);
        expect(style.fontFamilyFallback, AurisTokens.fontBodyFallback);
      }
    });

    test('fallback chains end in a generic CSS family the engine can map', () {
      // The last entry of each chain is a generic family Flutter's engine maps
      // to a platform font on every OS, so the chain never dead-ends in a name
      // that might be absent everywhere.
      expect(AurisTokens.fontDisplayFallback.last, 'sans-serif');
      expect(AurisTokens.fontBodyFallback.last, 'sans-serif');
      expect(AurisTokens.fontMonoFallback.last, 'monospace');
    });

    test('every bundled-font site in lib/ pairs a fallback chain', () {
      // Invariant guard: the family -> fallback pairing is fixed (display/body
      // -> sans, mono -> mono), so a `fontFamily: AurisTokens.fontX` site that
      // omits the matching `fontFamilyFallback:` would silently
      // reintroduce the tofu/blank-glyph bug — invisible to the goldens (which
      // load the real fonts) until a font asset actually fails. Scanning the
      // source keeps the ~80 hand-maintained pairs honest as new styles land.
      const Map<String, String> expected = <String, String>{
        'fontDisplay': 'fontDisplayFallback',
        'fontBody': 'fontBodyFallback',
        'fontMono': 'fontMonoFallback',
      };
      final RegExp familySite = RegExp(
        r'fontFamily: AurisTokens\.(fontDisplay|fontBody|fontMono),',
      );

      final List<String> unpaired = <String>[];
      for (final FileSystemEntity entity in Directory(
        'lib',
      ).listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        // Collapse whitespace before scanning so the pairing check survives
        // line-wrapping by `dart format` — a deeply-indented style can wrap
        // `fontFamilyFallback:` onto a separate line from its value.
        final String src = entity.readAsStringSync().replaceAll(
          RegExp(r'\s+'),
          ' ',
        );
        for (final RegExpMatch m in familySite.allMatches(src)) {
          final String wantFallback = expected[m.group(1)]!;
          final int end = m.end + 80 < src.length ? m.end + 80 : src.length;
          final String after = src.substring(m.end, end).trim();
          if (!after.startsWith(
            'fontFamilyFallback: AurisTokens.$wantFallback',
          )) {
            unpaired.add('${entity.path} -> needs $wantFallback');
          }
        }
      }
      expect(
        unpaired,
        isEmpty,
        reason:
            'Each fontFamily site must be followed by its matching '
            'fontFamilyFallback so text degrades gracefully:\n'
            '${unpaired.join('\n')}',
      );
    });
  });

  group('AurisTheme.light builds the light variant', () {
    test('is a light-brightness theme with light surfaces and dark text', () {
      final ThemeData theme = AurisTheme.light();
      final AurisScheme scheme = theme.extension<AurisScheme>()!;
      expect(theme.brightness, Brightness.light);
      expect(scheme.brightness, Brightness.light);
      // Page is light and text is dark (inverted from the dark variant).
      expect(scheme.surfacePage.computeLuminance(), greaterThan(0.5));
      expect(scheme.textBright.computeLuminance(), lessThan(0.2));
      // Depth on light is an amber glow (a brightened accent): warm, red ≥ green
      // ≫ blue, the kit's identity kept rather than swapped for another hue.
      final Color glowColor = scheme.depthActive.glow.first.color;
      expect(glowColor.r, greaterThan(glowColor.b));
      expect(glowColor.g, greaterThan(glowColor.b));
    });
  });

  group('AurisScheme.resolve', () {
    test('resolves the dark branch', () {
      final AurisScheme scheme = AurisScheme.resolve(
        brightness: Brightness.dark,
      );
      expect(scheme.brightness, Brightness.dark);
      expect(scheme.surfacePage, AurisTokens.void_);
      expect(scheme.primaryActive, AurisTokens.gold);
    });

    test('resolves the light branch', () {
      final AurisScheme scheme = AurisScheme.resolve(
        brightness: Brightness.light,
      );
      expect(scheme.brightness, Brightness.light);
      expect(scheme.surfacePage.computeLuminance(), greaterThan(0.5));
    });

    test('bevel and glow overrides scale the resolved roles', () {
      final AurisScheme scheme = AurisScheme.resolve(
        bevelScale: 2.0,
        glowScale: 2.0,
      );
      expect(scheme.bevel.md, AurisTokens.bevelMd * 2.0);
      // Glow intensity scales alpha (brighter), not blur (wider) — the blur is
      // held constant so the glow keeps hugging the element's shape.
      expect(
        scheme.depthActive.glow.first.color.a,
        (AurisTokens.glowActive.first.color.a * 2.0).clamp(0.0, 1.0),
      );
      expect(
        scheme.depthActive.glow.first.blurRadius,
        AurisTokens.glowActive.first.blurRadius,
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
              final AurisScheme scheme = Theme.of(
                context,
              ).extension<AurisScheme>()!;
              return Scaffold(body: ColoredBox(color: scheme.surfacePanel));
            },
          ),
        ),
      );

      expect(find.byType(ColoredBox), findsWidgets);
    });
  });
}

/// WCAG contrast ratio between [a] and [b], from their relative luminances.
double _contrast(Color a, Color b) {
  final double la = a.computeLuminance();
  final double lb = b.computeLuminance();
  final double hi = la > lb ? la : lb;
  final double lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}
