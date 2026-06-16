# Auris — Roadmap

<!-- Sections in build-dependency order. Earlier sections validate -->
<!-- assumptions later sections depend on. Completed work leaves from -->
<!-- the head; new work enters at the tail. -->

## Complete component-theme coverage

Close the gap between the theme layer's "no widget renders unstyled" promise and
the set of Material components it actually populates — measured by a census of
`ThemeData`'s component-theme slots rather than by the showcase
(§spec:theme-layer, §req:success-criteria #2). This is implementation work the
packaging sections below depend on, so it precedes them.

### §road:component-theme-census

Enumerate every `ThemeData` component-theme slot and record, in a checklist,
whether Auris populates it or deliberately excludes it with a reason. The
checklist is the completeness gate: a slot may be unset only with a recorded
rationale (legacy `ButtonTheme` / `ButtonBar`, glyph-only `actionIconTheme`, the
global `iconTheme` / `primaryTextTheme` / `primaryIconTheme` defaults).
§spec:theme-layer.

### §road:add-missing-component-themes

Populate the slots the census surfaces as missing, each derived from the resolved
`AurisScheme` (chamfer shape, glow-not-shadow, amber overlay, uppercase/monospace
type) exactly as the existing themes are — no raw literal, so accent / bevel /
glow overrides reach them (§spec:customization "Propagation invariant"). The set:
`DatePicker`, `TimePicker`, `Scrollbar`, `MaterialBanner`, `BottomAppBar`,
`BottomNavigationBar`, `Menu` / `MenuBar`, `NavigationDrawer`, `ToggleButtons`,
and text selection (cursor / handles / highlight). §spec:theme-layer,
§spec:customization. Depends on §road:component-theme-census.

### §road:showcase-missing-components

Add a showcase section rendering each newly themed component so the demo covers
the full set and a reviewer can confirm none falls back to default Material.
§spec:showcase. Depends on §road:add-missing-component-themes.

**Verify:** The census checklist marks every `ThemeData` component-theme slot
populated or excluded-with-reason, with nothing silently unaddressed. Flipping
the accent and glow re-skins each new component with no leftover default
(§spec:customization). The showcase renders date and time pickers, a scrollbar, a
material banner, a bottom app bar, bottom navigation, a menu bar / menu anchor, a
navigation drawer, and toggle buttons in the Auris aesthetic.

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

### §road:golden-tests

Add golden-image tests (`matchesGoldenFile`) under `test/goldens/` for the
geometry/glow-bearing custom widgets (`AurisContainer`, `AurisPanel`,
`AurisBadge`, `AurisSwitch`, `AurisProgressBar`, `AurisSelect`, `AurisRadio`,
`AurisStatCard`, `AurisStepIndicator`) so visual regressions fail CI.
§spec:showcase, §spec:custom-widgets. Depends on all implementation sections.

### §road:readme-and-gallery

Write `README.md` with an installation snippet, an `AurisTheme` usage example,
and a widget gallery (screenshot placeholder). §spec:packaging. Depends on
§road:analyze-clean-and-deps.

**Verify:** From a clean checkout, `flutter pub get` then `flutter run` the
example with no extra setup; fonts render. `flutter analyze` reports zero
warnings and `pubspec.yaml` lists no runtime dependencies beyond the Flutter
SDK. `flutter test` (including the golden-image tests) passes. The README usage
snippet matches the running example.
