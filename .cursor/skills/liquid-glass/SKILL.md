---
name: liquid-glass
description: >-
  Liquid glass Flutter starter — glass shell, GlassTheme tokens,
  ThemeController (System/Light/Dark), nav glyphs, and feature layout. Use when
  editing the Flutter app, bottom nav, glass chrome, theme/appearance, or
  screens under features/.
---

# Liquid glass starter

Small starter. Follow existing patterns. Do not invent parallel theme or nav systems.

## Layout

```text
lib/
  app/           # LiquidGlassApp + ThemeScope
  core/          # theme, storage, glass widgets, glyphs
  shell/         # AppShell + GlassTabBar bottom nav
  features/      # home, search, profile
```

- Capsule: Home · Profile. Search = trailing circle (not in capsule). Settings stays under Profile.
- Page index: 0 Home, 1 Search, 2 Profile.

## Theme (required)

- User mode: System / Light / Dark via `ThemeController` + `ThemeScope`
- Persist with `LocalPreferences` (JSON file). Corrupt values → System
- `MaterialApp.themeMode` bound to controller; load prefs in `main` before `runApp`
- Keep `LiquidGlassWidgets.wrap(brightnessResolver: Theme.maybeBrightnessOf, theme: AppLiquidGlass.themeData)`
- Colors/metrics: `GlassTheme.of(context)` in `core/theme/glass_tokens.dart` — no hardcoded shell hex
- Dark chrome: transparent fill + thin rim only (`AppLiquidGlass.darkChrome`). Light: milky iOS 27 glass. Do not re-add smoke/matte fill in dark
- Bar metrics from `GlassTheme` (`barSideInset`, `maxBarWidth`, scale) — keep responsive; do not hardcode widths

**Mac Dark Mode ≠ iOS Simulator appearance.** System theme follows the **phone**, not the Mac Control Center. Toggle Simulator: Features → Toggle Appearance. Appearance (System/Light/Dark) lives under **Profile → Settings** — not bottom nav. Forced Dark/Light ignores Simulator Appearance until user picks System again (prefs: `~/.liquid_glass/preferences.json` key `theme_mode`).

## Bottom nav

- `GlassBottomNav`: `GlassTabBar.bottom` + `GlassTabBarExtraButton` (`liquid_glass_widgets`)
- Icons only; Semantics labels. Hide package `GlassTheme` when importing — use app `GlassTheme`
- Glyphs: Cupertino house / search; `NavProfileIcon` in `nav_glyphs.dart`
- Tint via `IconTheme` / token colors (`idleIcon`, `selectedIcon`)

## New UI

1. Put screens under `features/<name>/`
2. Reuse `ChromePlaceholderPage`, `GlassField`, `AppearanceModeControl` when they fit
3. Read tokens from `GlassTheme.of(context)` (scale, scaffoldBackground, icons, field chrome)
4. After changes: `flutter analyze lib test` and `flutter test` from the repo root

## Do not

- Hardcode `ThemeMode.system` only — keep user preference
- Put Search inside the main capsule
- Add `shared_preferences` / `path_provider` without checking native-hook + test impact on this machine
- Dump Flutter SDK docs into the app or this skill
