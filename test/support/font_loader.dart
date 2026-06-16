// Shared test helper: load the bundled Auris fonts into the test font
// collection so glyphs render as real type instead of Ahem blocks. Used by the
// golden tests, the render harness, and the README gallery renderer so the font
// list lives in ONE place and cannot drift from `pubspec.yaml` across them.
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Load every bundled Auris font family (all weights) for the current test.
///
/// Multiple files per family so Flutter can pick the right weight (matching the
/// `pubspec.yaml` declaration). Rajdhani ships Medium / SemiBold / Bold; loading
/// only one made every weight render the same, hiding weight changes.
Future<void> loadAurisFonts() async {
  const Map<String, List<String>> families = <String, List<String>>{
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
