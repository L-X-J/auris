# Auris — Roadmap

<!-- Sections in build-dependency order. Earlier sections validate -->
<!-- assumptions later sections depend on. Completed work leaves from -->
<!-- the head; new work enters at the tail. -->

## Customization

Surface the resolver's override inputs publicly and prove they propagate, now
that the scheme seam already accepts them and all widgets read the scheme.

### §road:customization-api

Expose optional accent/bevel/glow override parameters on `AurisTheme.light()`
(defaults reproduce the canonical look) that pass through to the scheme resolver
in `lib/src/theme.dart`, and confirm every Material component theme and custom
widget honors them. §spec:customization.

### §road:customization-showcase

Add a showcase control demonstrating a non-default accent applied consistently
across themed Material widgets and Auris custom widgets in
`example/lib/main.dart`. §spec:customization, §spec:showcase. Depends on
§road:customization-api.

**Verify:** In the example, switch the demo to a non-default accent. Both
Material components and Auris custom widgets recolor consistently with no source
edits; bevel and glow overrides visibly change corner cut and glow strength.

## Accessibility & motion polish

Hold the cross-cutting quality bars — AA contrast, visible focus, reduced-motion
respect, and 60fps — across everything built so far.

### §road:contrast-and-focus

Tune any token used in a primary text/control role that fails WCAG AA, document
the dim tokens as decorative-only, and add a visible `gold` keyboard-focus
decoration to all interactive custom widgets. §spec:accessibility.

### §road:reduced-motion-and-perf

Make every animated widget honor `MediaQuery.disableAnimations` (render the end
state) and bound glow/segment/clip work to hold 60fps. §spec:motion-performance.

### §road:polish-showcase-verification

Add a reduced-motion and keyboard-navigation pass to the showcase so both
behaviors are demonstrable in `example/lib/main.dart`. §spec:showcase. Depends
on §road:contrast-and-focus, §road:reduced-motion-and-perf.

**Verify:** Enable the OS reduce-motion setting and reload the example —
animated widgets show their end state with no animation. Tab through the
showcase: a gold focus indicator is visible on every interactive element.
Primary text and controls meet AA contrast; scrolling stays smooth.

## Packaging & pub-readiness

Make Auris adoptable from a clean install and ready to publish.

### §road:font-fallback

Ensure text renders in a sensible fallback when a bundled font is missing, and
document any setup needed. §spec:packaging.

### §road:analyze-clean-and-deps

Ensure `flutter analyze` passes with zero warnings (including using
`Color.withValues` over the deprecated `withOpacity`) and confirm zero runtime
pub dependencies in `pubspec.yaml`. §spec:packaging. Depends on all
implementation sections.

### §road:readme-and-gallery

Write `README.md` with an installation snippet, an `AurisTheme` usage example,
and a widget gallery (screenshot placeholder). §spec:packaging. Depends on
§road:analyze-clean-and-deps.

**Verify:** From a clean checkout, `flutter pub get` then `flutter run` the
example with no extra setup; fonts render. `flutter analyze` reports zero
warnings and `pubspec.yaml` lists no runtime dependencies beyond the Flutter
SDK. The README usage snippet matches the running example.
