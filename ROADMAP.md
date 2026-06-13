# Auris — Roadmap

<!-- Sections in build-dependency order. Earlier sections validate -->
<!-- assumptions later sections depend on. Completed work leaves from -->
<!-- the head; new work enters at the tail. -->

## Walking skeleton — package, tokens, scheme, theme core, runnable example

The smallest end-to-end slice: a package that builds, resolves the design
scheme, applies it as a theme to a real Material screen, and runs. Validates
the whole spine (fonts → primitive tokens → resolved scheme → ThemeExtension →
theme → app) before breadth is added — the scheme/resolver seam is foundational
because both the theme layer and every custom widget read it.

### §road:package-scaffold

Create the package skeleton — `pubspec.yaml` (Flutter SDK only, no runtime
deps, bundled OFL fonts), the `lib/src/` directory layout, and the
`lib/auris.dart` / `lib/auris_widgets.dart` barrel exports. §spec:packaging,
§spec:overview

### §road:design-tokens

Implement `AurisTokens` in `lib/src/tokens.dart` — the primitive tier: all
color, typography, shape (bevel), glow, and motion values as `const`.
§spec:design-tokens. Depends on §road:package-scaffold.

### §road:scheme-resolver

Implement `AurisScheme` (a `ThemeExtension` of resolved semantic roles —
surfaces, text roles, primary ramp, borders, bevel scale, and depth-by-intent)
and its resolver taking brightness plus accent/bevel/glow overrides, with only
the dark branch populated, in `lib/src/scheme.dart`. §spec:scheme. Depends on
§road:design-tokens.

### §road:chamfer-clipper

Implement `ChamferClipper` in `lib/src/painters/chamfer_clipper.dart` — a
`CustomClipper<Path>` parameterized by corner cut that chamfers all four
corners at 45°. §spec:design-tokens. Depends on §road:design-tokens.

### §road:theme-core

Implement `AurisTheme.light()` in `lib/src/theme.dart` deriving `ColorScheme`
and the full `TextTheme` from the resolved `AurisScheme` and attaching that
scheme to the returned `ThemeData` as a `ThemeExtension`, with
`AurisTheme.dark()` throwing `UnimplementedError`. §spec:theme-layer,
§spec:scheme. Depends on §road:scheme-resolver.

### §road:example-skeleton

Create a minimal runnable `example/lib/main.dart` that applies
`AurisTheme.light()` and renders a screen with representative Material widgets
(text, button, card). §spec:showcase. Depends on §road:theme-core.

**Verify:** From `example/`, run `flutter run`. The app launches with a
near-black background and amber text; bundled display/body/mono fonts render;
a button and card show chamfered amber styling rather than default Material;
`Theme.of(context).extension<AurisScheme>()` resolves to the dark scheme.
`flutter analyze` reports zero warnings.

## Material re-skin — core controls

Re-skin the interactive controls an app uses most, and prove coverage in the
showcase.

### §road:button-themes

Implement the button component themes (Elevated, Outlined, Text, Filled, Icon,
FloatingActionButton, SegmentedButton) in `lib/src/theme/button_themes.dart`
and compose them into `AurisTheme.light()`. §spec:theme-layer. Depends on
§road:theme-core.

### §road:input-themes

Implement `InputDecorationTheme` and `DropdownMenuThemeData` in
`lib/src/theme/input_themes.dart`. §spec:theme-layer. Depends on
§road:theme-core.

### §road:selection-control-themes

Implement the Checkbox, Radio, Switch, Slider, and Chip themes in
`lib/src/theme/input_themes.dart`. §spec:theme-layer. Depends on
§road:theme-core.

### §road:core-controls-showcase

Add showcase sections for buttons, inputs, selection controls, and sliders to
`example/lib/main.dart`. §spec:showcase. Depends on §road:button-themes,
§road:input-themes, §road:selection-control-themes.

**Verify:** In the running example, scroll to the Buttons, Inputs, and
Selection sections. Every button variant (including disabled), text field
(normal and error), dropdown, checkbox, radio, switch, slider, and chip
renders fully themed — none falls back to default Material. Ripples are
replaced by amber hover/focus overlays.

## Material re-skin — surfaces, navigation & data

Re-skin the remaining component families: containers/overlays, navigation
chrome, and data/feedback widgets.

### §road:surface-overlay-themes

Implement the Card, Dialog, SnackBar, BottomSheet, Drawer, Tooltip, and
PopupMenu themes in `lib/src/theme/overlay_themes.dart`. §spec:theme-layer.
Depends on §road:theme-core.

### §road:navigation-themes

Implement the AppBar, NavigationBar, NavigationRail, and TabBar themes in
`lib/src/theme/navigation_themes.dart`. §spec:theme-layer. Depends on
§road:theme-core.

### §road:data-feedback-themes

Implement the DataTable, ListTile, ExpansionTile, ProgressIndicator, Divider,
Badge, Stepper, and SearchBar/SearchView themes in
`lib/src/theme/data_themes.dart`. §spec:theme-layer. Depends on
§road:theme-core.

### §road:surfaces-nav-data-showcase

Add showcase sections for surfaces/overlays, navigation, and data/feedback
components to `example/lib/main.dart`. §spec:showcase. Depends on
§road:surface-overlay-themes, §road:navigation-themes, §road:data-feedback-themes.

**Verify:** In the running example, exercise the Cards/Dialogs/Sheets,
Navigation (TabBar, NavigationBar), and Data (DataTable, ListTile, Stepper,
ProgressIndicator) sections; trigger a dialog and a snackbar. All surfaces use
chamfered borders and amber glow instead of Material elevation shadows; no
component renders default-styled.

## Custom HUD widgets — containers, panels & display

Deliver the static HUD components that `ThemeData` cannot express, built on the
chamfer primitive.

### §road:auris-container

Implement `AurisContainer` in `lib/src/widgets/auris_container.dart` — the
chamfered border + fill + depth-by-intent primitive that clips its child via
`ChamferClipper` and reads colors/bevel/depth from the resolved `AurisScheme`.
§spec:custom-widgets, §spec:scheme. Depends on §road:chamfer-clipper,
§road:scheme-resolver.

### §road:display-widgets

Implement `AurisBadge`, `AurisPanel`, `AurisNotification`, `AurisDataRow`, and
`AurisStatCard` in `lib/src/widgets/`. §spec:custom-widgets. Depends on
§road:auris-container.

### §road:ornament-widgets

Implement `AurisHexOrnament` and `AurisScanBracket`, with
`lib/src/painters/hex_painter.dart`, in `lib/src/widgets/`, reading colors from
the resolved `AurisScheme`. §spec:custom-widgets, §spec:scheme. Depends on
§road:scheme-resolver.

### §road:display-widgets-showcase

Export the display and ornament widgets from `lib/auris_widgets.dart` and add
their showcase sections to `example/lib/main.dart`. §spec:custom-widgets,
§spec:showcase. Depends on §road:display-widgets, §road:ornament-widgets.

**Verify:** In the example, the Badges, Panels, Notifications, Data Rows, Stat
Cards, and Ornaments sections render. Panels show header brackets and status
codes; stat cards show a glowing value and signed delta; hex ornaments and scan
brackets paint correctly behind and around content.

## Custom HUD widgets — interactive & dynamic

Deliver the stateful/animated HUD widgets and the custom replacements for the
Material widgets Flutter cannot fully theme.

### §road:auris-switch

Implement `AurisSwitch` (true chamfered animated track and thumb, optional
label and status labels) in `lib/src/widgets/auris_switch.dart`.
§spec:custom-widgets. Depends on §road:auris-container.

### §road:auris-progress-bar

Implement `AurisProgressBar` (segmented, with an `.animated` constructor)
reading variant colors and depth from the resolved `AurisScheme` in
`lib/src/widgets/auris_progress_bar.dart`. §spec:custom-widgets, §spec:scheme.
Depends on §road:chamfer-clipper, §road:scheme-resolver.

### §road:terminal-and-stepper

Implement `AurisTerminal` (auto-scrolling monospace log with blinking cursor)
and `AurisStepIndicator` in `lib/src/widgets/`. §spec:custom-widgets. Depends
on §road:auris-container.

### §road:interactive-widgets-showcase

Export the interactive widgets and add their showcase sections — including a
live-appending terminal — to `example/lib/main.dart`. §spec:custom-widgets,
§spec:showcase. Depends on §road:auris-switch, §road:auris-progress-bar,
§road:terminal-and-stepper.

**Verify:** In the example, toggle `AurisSwitch` and watch the thumb animate
across a chamfered track; watch `AurisProgressBar` segments fill with the
leading segment glowing; observe the terminal auto-scroll as lines append and
the cursor blink; the stepper shows active/complete/error states.

## Customization

Surface the resolver's override inputs publicly and prove they propagate, now
that the scheme seam already accepts them and all widgets read the scheme.

### §road:customization-api

Expose optional accent/bevel/glow override parameters on `AurisTheme.light()`
(defaults reproduce the canonical look) that pass through to the scheme resolver
in `lib/src/theme.dart`, and confirm every Material component theme and custom
widget honors them. §spec:customization. Depends on §road:theme-core,
§road:display-widgets, §road:interactive-widgets-showcase.

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
decoration to all interactive custom widgets. §spec:accessibility. Depends on
§road:interactive-widgets-showcase.

### §road:reduced-motion-and-perf

Make every animated widget honor `MediaQuery.disableAnimations` (render the end
state) and bound glow/segment/clip work to hold 60fps. §spec:motion-performance.
Depends on §road:interactive-widgets-showcase.

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
document any setup needed. §spec:packaging. Depends on §road:package-scaffold.

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
