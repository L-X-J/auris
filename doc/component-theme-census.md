# Component-theme census

The completeness gate for the theme layer (§spec:theme-layer, §road:component-theme-census).

This checklist enumerates **every** component-theme slot on Flutter's `ThemeData`
and records, for each, whether Auris populates it or deliberately leaves it at the
Material default. A slot may be unset **only** with a recorded rationale — that is
how a gap hides: a widget a real app reaches for renders as default Material even
though the demo never shows it (§spec:theme-layer "Verification path").

The slot list is taken verbatim from the `ThemeData` constructor parameters in the
pinned Flutter SDK (3.44). When the SDK adds a slot, add a row here and either
populate it or record why not.

Status key: **✓ populated** — Auris sets it, derived from the resolved
`AurisScheme`. **— excluded** — deliberately left at the Material default, with the
reason in the Notes column.

## Styling component themes

These slots style a standard, visible Material widget. Every one is populated and
derived from the resolved `AurisScheme` (§spec:scheme), so accent / bevel / glow
overrides propagate to all of them (§spec:customization "Propagation invariant").

| Slot | Status | Builder | Notes |
| --- | --- | --- | --- |
| `colorScheme` | ✓ populated | `AurisTheme._colorSchemeFrom` | Drives every role-derived Material default, including `Stepper` (no slot of its own). |
| `textTheme` | ✓ populated | `AurisTheme._textThemeFrom` | Full display→label scale. |
| `elevatedButtonTheme` | ✓ populated | `AurisButtonThemes.elevated` | |
| `filledButtonTheme` | ✓ populated | `AurisButtonThemes.filled` | |
| `outlinedButtonTheme` | ✓ populated | `AurisButtonThemes.outlined` | |
| `textButtonTheme` | ✓ populated | `AurisButtonThemes.text` | |
| `iconButtonTheme` | ✓ populated | `AurisButtonThemes.icon` | |
| `floatingActionButtonTheme` | ✓ populated | `AurisButtonThemes.fab` | |
| `segmentedButtonTheme` | ✓ populated | `AurisButtonThemes.segmented` | |
| `toggleButtonsTheme` | ✓ populated | `AurisButtonThemes.toggleButtons` | Chamfered group, gold-filled selected button, amber overlay. |
| `inputDecorationTheme` | ✓ populated | `AurisInputThemes.inputDecoration` | Chamfered `InputBorder`. |
| `textSelectionTheme` | ✓ populated | `AurisInputThemes.textSelection` | Gold cursor / handles, amber selection highlight. |
| `dropdownMenuTheme` | ✓ populated | `AurisInputThemes.dropdownMenu` | |
| `menuButtonTheme` | ✓ populated | `AurisInputThemes.menuButton` | Shared by `DropdownMenu` rows and `MenuBar` / `MenuAnchor` items. |
| `menuTheme` | ✓ populated | `AurisInputThemes.menu` | `MenuAnchor` popup surface — chamfered panel, flat. |
| `menuBarTheme` | ✓ populated | `AurisInputThemes.menuBar` | Top-level `MenuBar` strip — panel surface, flat. |
| `checkboxTheme` | ✓ populated | `AurisInputThemes.checkbox` | |
| `radioTheme` | ✓ populated | `AurisInputThemes.radio` | |
| `switchTheme` | ✓ populated | `AurisInputThemes.switchTheme` | |
| `sliderTheme` | ✓ populated | `AurisInputThemes.slider` | |
| `chipTheme` | ✓ populated | `AurisInputThemes.chip` | |
| `cardTheme` | ✓ populated | `AurisOverlayThemes.card` | |
| `dialogTheme` | ✓ populated | `AurisOverlayThemes.dialog` | |
| `snackBarTheme` | ✓ populated | `AurisOverlayThemes.snackBar` | |
| `bannerTheme` | ✓ populated | `AurisOverlayThemes.banner` | `MaterialBanner` — inset surface, chamfered, gold action, left accent. |
| `bottomSheetTheme` | ✓ populated | `AurisOverlayThemes.bottomSheet` | |
| `tooltipTheme` | ✓ populated | `AurisOverlayThemes.tooltip` | |
| `popupMenuTheme` | ✓ populated | `AurisOverlayThemes.popupMenu` | |
| `datePickerTheme` | ✓ populated | `AurisOverlayThemes.datePicker` | Chamfered dialog, gold selected day, mono labels. |
| `timePickerTheme` | ✓ populated | `AurisOverlayThemes.timePicker` | Chamfered dialog, gold selected dial / field. |
| `scrollbarTheme` | ✓ populated | `AurisDataThemes.scrollbar` | Gold thumb, inset track, square (slim) geometry. |
| `appBarTheme` | ✓ populated | `AurisNavigationThemes.appBar` | |
| `bottomAppBarTheme` | ✓ populated | `AurisNavigationThemes.bottomAppBar` | Panel surface, flat, no notch shadow. |
| `navigationBarTheme` | ✓ populated | `AurisNavigationThemes.navigationBar` | |
| `bottomNavigationBarTheme` | ✓ populated | `AurisNavigationThemes.bottomNavigationBar` | Legacy bottom nav — panel surface, gold selected, mono labels. |
| `navigationRailTheme` | ✓ populated | `AurisNavigationThemes.navigationRail` | |
| `drawerTheme` | ✓ populated | `AurisOverlayThemes.drawer` | |
| `navigationDrawerTheme` | ✓ populated | `AurisNavigationThemes.navigationDrawer` | Chamfered gold selection indicator, mono labels. |
| `tabBarTheme` | ✓ populated | `AurisNavigationThemes.tabBar` | |
| `dataTableTheme` | ✓ populated | `AurisDataThemes.dataTable` | |
| `listTileTheme` | ✓ populated | `AurisDataThemes.listTile` | |
| `expansionTileTheme` | ✓ populated | `AurisDataThemes.expansionTile` | |
| `progressIndicatorTheme` | ✓ populated | `AurisDataThemes.progressIndicator` | |
| `dividerTheme` | ✓ populated | `AurisDataThemes.divider` | |
| `badgeTheme` | ✓ populated | `AurisDataThemes.badge` | |
| `searchBarTheme` | ✓ populated | `AurisDataThemes.searchBar` | |
| `searchViewTheme` | ✓ populated | `AurisDataThemes.searchView` | |
| `carouselViewTheme` | ✓ populated | `AurisDataThemes.carouselView` | `CarouselView` — chamfered items on the inset surface, flat. |

## Deliberately excluded slots

These slots are left at the Material default by design. "Unset" here never means
"overlooked" — each carries the reason it is not populated.

| Slot | Status | Reason |
| --- | --- | --- |
| `buttonTheme` | — excluded | Legacy pre-Material-3 `ButtonTheme` (styles the removed `MaterialButton` / `RaisedButton` / `FlatButton`). Auris does not support those widgets; the M3 button themes above cover the supported buttons. |
| `actionIconTheme` | — excluded | Selects *which glyph* a back / close / drawer / end-drawer button shows, not how it is styled. Auris keeps Material's default glyphs; the icon styling comes from the populated `iconButtonTheme` / `iconTheme`. |
| `iconTheme` | — excluded | The global default `IconThemeData` derives from the already-populated `ColorScheme`; per-surface icon colors are set on each component theme (app bar, nav, list tile, etc.) where they matter. |
| `primaryTextTheme` | — excluded | The text theme drawn on top of `ColorScheme.primary` surfaces; derives from the populated `textTheme` / `ColorScheme`. No Auris surface uses a primary-colored chrome that needs an independent scale. |
| `primaryIconTheme` | — excluded | The icon theme for primary-colored chrome; same rationale as `primaryTextTheme` — derived from the populated `ColorScheme`. |
| `cupertinoOverrideTheme` | — excluded | Themes Cupertino (iOS-style) widgets, not Material. Auris is a Material 3 kit and ships no Cupertino widgets. |
| `pageTransitionsTheme` | — excluded | Configures route *transition animations*, not the appearance of any widget. Out of scope for a presentational re-skin; Auris leaves the platform default. |

## Result

49 styling slots populated, all derived from the resolved `AurisScheme`;
7 slots deliberately excluded with a recorded reason. No `ThemeData`
component-theme slot is silently unaddressed.
