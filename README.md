# Liquid Glass Flutter Starter Template

Production-ready Flutter starter template featuring Apple's iOS 26 **Liquid Glass** design system (`liquid_glass_widgets`). Clone this repository and start building any app without renaming boilerplate files.

## Prebuilt Features

- **Floating Bottom Chrome (`GlassBottomNav`):**
  - Default mode: `[ Home | Profile ]  ( 🔍 )`
  - Search mode: Morphs at the bottom directly on top of the keyboard into `[ 🔍 Search your library...  🎤 ]  ( ✕ )`
- **iOS 26 Collapsible Large Titles (`GlassLargeTitle` + `GlassAppBar`):** Smooth scroll collapse and `GlassScrollEdgeEffect` soft edge fade.
- **Persistent Theme Mode (`System` / `Light` / `Dark`):** Interactive `GlassSegmentedControl` backed by atomic, sandbox-safe JSON storage (`LocalPreferences`).
- **All-Device Responsive Tokens (`GlassTokens`):** Automatic breakpoints for compact phones (`< 600pt`), medium foldables/tablets (`600–839pt`), and expanded tablets/desktops (`≥ 840pt`).
- **One-Import Liquid Glass Kit (`glass_kit.dart`):** Re-exports all 50+ `liquid_glass_widgets` components plus `AppGlassOverlays` (`showSheet`, `showActionSheet`, `showDialog`, `showToast`).

## Run

```bash
flutter pub get
flutter run
```

Appearance settings live under **Profile → Settings**.

## Project Layout

```text
lib/
  main.dart
  app/app.dart                         # Root App widget & GlassPageTransitionsBuilder
  core/theme/
    glass_tokens.dart                  # Responsive GlassTokens & layout breakpoints
    liquid_glass_chrome.dart           # AppLiquidGlass light & dark recipes
    theme_controller.dart              # Persistent ThemeMode controller
    theme_mode_preference.dart
    theme_scope.dart
  core/storage/
    local_preferences.dart             # Sandbox-safe, atomic JSON preferences
  core/widgets/
    appearance_mode_control.dart       # GlassSegmentedControl theme switcher
    chrome_placeholder_page.dart       # Collapsible GlassLargeTitle page scaffold
    nav_glyphs.dart
    glass/
      glass_field.dart                 # GlassTextField wrapper
      glass_overlays.dart              # Sheet, ActionSheet, Dialog & Toast helpers
      glass_kit.dart                   # Single barrel export for the entire glass kit
  shell/
    app_shell.dart                     # GlassPage + GlassScrollEdgeEffect + IndexedStack
    glass_bottom_nav.dart              # Bottom tab capsule + keyboard-top search bar
  features/
    home/home_page.dart
    chats/chats_page.dart
    search/search_page.dart
    profile/profile_page.dart
    settings/settings_page.dart
```
