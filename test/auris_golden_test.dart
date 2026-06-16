// Golden-image tests for the geometry- and glow-bearing custom widgets.
//
// The analyzer and behavioral unit tests do not catch visual regressions — a
// zero-height progress segment, an off-screen popup, a too-large chamfer, or a
// runaway glow all pass logic tests while looking wrong. These goldens are the
// automated counterpart to the manual showcase review, failing in CI when the
// rendered look drifts (§spec:showcase "Visual regression", §spec:custom-widgets).
//
// Determinism: every shot pins a fixed surface size, a device pixel ratio of
// 1.0, the canonical `AurisTheme.dark()` accent, and loads the bundled fonts so
// glyphs render as real type rather than Ahem blocks — so the goldens depend
// only on the widget code, not the host. Generate / refresh with:
//   flutter test --update-goldens test/auris_golden_test.dart
import 'dart:io';

import 'package:auris/auris.dart';
import 'package:auris/auris_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// Load the bundled fonts so glyph geometry is deterministic across machines
// (without this, text renders as the Ahem fallback and the goldens would still
// be stable, but loading the real fonts keeps the goldens legible for review).
Future<void> _loadFonts() async {
  final Map<String, List<String>> families = <String, List<String>>{
    'packages/auris/ShareTechMono': <String>['fonts/ShareTechMono-Regular.ttf'],
    'packages/auris/Rajdhani': <String>[
      'fonts/Rajdhani-Medium.ttf',
      'fonts/Rajdhani-SemiBold.ttf',
      'fonts/Rajdhani-Bold.ttf',
    ],
    'packages/auris/ExoTwo': <String>['fonts/Exo2-Regular.ttf'],
  };
  for (final MapEntry<String, List<String>> e in families.entries) {
    final FontLoader loader = FontLoader(e.key);
    for (final String path in e.value) {
      final Uint8List bytes = File(path).readAsBytesSync();
      loader.addFont(Future<ByteData>.value(ByteData.view(bytes.buffer)));
    }
    await loader.load();
  }
}

// Pump [child] centered under the canonical dark theme on a fixed surface and
// assert it matches goldens/<name>.png.
Future<void> _expectGolden(
  WidgetTester tester, {
  required String name,
  required Size size,
  required Widget child,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await _loadFonts();

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AurisTheme.dark(),
      home: Builder(
        builder: (BuildContext context) {
          final AurisScheme scheme =
              Theme.of(context).extension<AurisScheme>()!;
          return Scaffold(
            backgroundColor: scheme.surfacePage,
            body: Center(
              child: RepaintBoundary(
                key: const ValueKey<String>('golden'),
                child: ColoredBox(
                  color: scheme.surfacePage,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: child,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
  // Settle entrance glow / animations to their resting frame.
  await tester.pump(const Duration(milliseconds: 400));

  await expectLater(
    find.byKey(const ValueKey<String>('golden')),
    matchesGoldenFile('goldens/$name.png'),
  );
}

void main() {
  testWidgets('AurisContainer', (WidgetTester tester) async {
    await _expectGolden(
      tester,
      name: 'auris_container',
      size: const Size(320, 240),
      child: const AurisContainer(
        width: 220,
        height: 140,
        padding: EdgeInsets.all(16),
        child: SizedBox.shrink(),
      ),
    );
  });

  testWidgets('AurisPanel', (WidgetTester tester) async {
    await _expectGolden(
      tester,
      name: 'auris_panel',
      size: const Size(420, 280),
      child: const SizedBox(
        width: 340,
        child: AurisPanel(
          title: 'REACTOR CORE',
          code: 'RC-09',
          accent: true,
          child: Column(
            children: <Widget>[
              AurisDataRow(label: 'CORE TEMP', value: '612 K'),
              AurisDataRow(label: 'FLUX', value: '8.4 TW'),
              AurisDataRow(label: 'OUTPUT', value: '99.2 %', highlight: true),
            ],
          ),
        ),
      ),
    );
  });

  testWidgets('AurisBadge', (WidgetTester tester) async {
    await _expectGolden(
      tester,
      name: 'auris_badge',
      size: const Size(360, 160),
      child: const Wrap(
        spacing: 8,
        runSpacing: 8,
        children: <Widget>[
          AurisBadge('ONLINE', variant: AurisBadgeVariant.success),
          AurisBadge('ARMED', variant: AurisBadgeVariant.gold),
          AurisBadge('SYNC', variant: AurisBadgeVariant.slate),
          AurisBadge('FAULT', variant: AurisBadgeVariant.danger),
        ],
      ),
    );
  });

  testWidgets('AurisSwitch', (WidgetTester tester) async {
    await _expectGolden(
      tester,
      name: 'auris_switch',
      size: const Size(420, 180),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AurisSwitch(
            value: true,
            onChanged: (_) {},
            label: 'SHIELDS',
            statusLabels: const ('OFF', 'ON'),
          ),
          const SizedBox(width: 24),
          AurisSwitch(value: false, onChanged: (_) {}, label: 'CLOAK'),
        ],
      ),
    );
  });

  testWidgets('AurisProgressBar', (WidgetTester tester) async {
    await _expectGolden(
      tester,
      name: 'auris_progress_bar',
      size: const Size(420, 140),
      child: const SizedBox(
        width: 360,
        child: AurisProgressBar(value: 0.6, label: 'POWER'),
      ),
    );
  });

  testWidgets('AurisSelect', (WidgetTester tester) async {
    await _expectGolden(
      tester,
      name: 'auris_select',
      size: const Size(360, 160),
      child: SizedBox(
        width: 280,
        child: AurisSelect<String>(
          value: 'NAV',
          onChanged: (_) {},
          options: const <AurisSelectOption<String>>[
            AurisSelectOption<String>(value: 'NAV', label: 'NAVIGATION'),
            AurisSelectOption<String>(value: 'WPN', label: 'WEAPONS'),
            AurisSelectOption<String>(value: 'COM', label: 'COMMS'),
          ],
        ),
      ),
    );
  });

  testWidgets('AurisRadio', (WidgetTester tester) async {
    await _expectGolden(
      tester,
      name: 'auris_radio',
      size: const Size(320, 140),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AurisRadio<int>(
            value: 0,
            groupValue: 0,
            onChanged: (_) {},
            label: 'AUTO',
          ),
          const SizedBox(width: 20),
          AurisRadio<int>(
            value: 1,
            groupValue: 0,
            onChanged: (_) {},
            label: 'MANUAL',
          ),
        ],
      ),
    );
  });

  testWidgets('AurisStatCard', (WidgetTester tester) async {
    await _expectGolden(
      tester,
      name: 'auris_stat_card',
      size: const Size(280, 200),
      child: const SizedBox(
        width: 220,
        child: AurisStatCard(
          label: 'THROUGHPUT',
          value: '94.2',
          unit: 'GB/s',
          delta: '+12.4%',
        ),
      ),
    );
  });

  testWidgets('AurisStepIndicator', (WidgetTester tester) async {
    await _expectGolden(
      tester,
      name: 'auris_step_indicator',
      size: const Size(360, 160),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AurisStepIndicator(step: 1, state: AurisStepState.complete, size: 56),
          SizedBox(width: 20),
          AurisStepIndicator(step: 2, state: AurisStepState.active, size: 56),
          SizedBox(width: 20),
          AurisStepIndicator(step: 3, state: AurisStepState.inactive, size: 56),
          SizedBox(width: 20),
          AurisStepIndicator(step: 4, state: AurisStepState.error, size: 56),
        ],
      ),
    );
  });
}
