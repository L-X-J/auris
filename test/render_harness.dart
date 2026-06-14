// Render harness (NOT a normal test): pumps the geometry/glow-bearing widgets
// at chosen accent + glow settings and writes PNGs to /tmp/auris_renders so the
// rendered appearance can be inspected directly. Run explicitly:
//   flutter test test/render_harness.dart
// Each variant is its own test so the per-test binding is fresh (multiple
// toImage calls in one test deadlock).
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:auris/auris.dart';
import 'package:auris/auris_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

class _Variant {
  const _Variant(this.name, {this.accent, this.glowScale = 1.0});
  final String name;
  final Color? accent;
  final double glowScale;
}

void main() {
  const Color teal = Color(0xFF35E0C0);
  const List<_Variant> variants = <_Variant>[
    _Variant('amber_glow1'),
    _Variant('teal_glow1', accent: teal),
    _Variant('teal_glow0', accent: teal, glowScale: 0.0),
    _Variant('teal_glow3', accent: teal, glowScale: 3.0),
  ];

  for (final _Variant v in variants) {
    testWidgets('render ${v.name}', (WidgetTester tester) async {
      final Directory outDir = Directory('/tmp/auris_renders')
        ..createSync(recursive: true);
      tester.view.physicalSize = const Size(1100, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AurisTheme.light(accent: v.accent, glowScale: v.glowScale),
          home: Builder(
            builder: (BuildContext context) {
              final AurisScheme scheme =
                  Theme.of(context).extension<AurisScheme>()!;
              return Scaffold(
                backgroundColor: scheme.surfacePage,
                body: Center(
                  child: RepaintBoundary(
                    key: const ValueKey<String>('shot'),
                    child: ColoredBox(
                      color: scheme.surfacePage,
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                const AurisStepIndicator(step: 1, state: AurisStepState.complete),
                                const SizedBox(width: 16),
                                const AurisStepIndicator(step: 2, state: AurisStepState.active),
                                const SizedBox(width: 16),
                                const AurisStepIndicator(step: 3, state: AurisStepState.inactive),
                                const SizedBox(width: 16),
                                AurisRadio<int>(
                                  value: 0,
                                  groupValue: 0,
                                  onChanged: (_) {},
                                  label: 'SEL',
                                ),
                                const SizedBox(width: 16),
                                AurisRadio<int>(
                                  value: 1,
                                  groupValue: 0,
                                  onChanged: (_) {},
                                  label: 'OFF',
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const SizedBox(
                              width: 420,
                              child: AurisProgressBar(value: 0.5),
                            ),
                            const SizedBox(height: 24),
                            const SizedBox(
                              width: 420,
                              child: AurisNotification(
                                variant: AurisNotificationVariant.info,
                                title: 'UPLINK',
                                message: 'Telemetry nominal',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));

      final RenderRepaintBoundary boundary = tester.renderObject(
        find.byKey(const ValueKey<String>('shot')),
      );
      final Uint8List? png = await tester.runAsync(() async {
        final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
        final ByteData? bytes =
            await image.toByteData(format: ui.ImageByteFormat.png);
        return bytes!.buffer.asUint8List();
      });
      File('${outDir.path}/${v.name}.png').writeAsBytesSync(png!);
    });
  }
}
