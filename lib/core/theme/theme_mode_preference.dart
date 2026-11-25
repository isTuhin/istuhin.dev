import 'package:material_ui/material_ui.dart';

/// Maps [ThemeMode] to/from allowlisted storage strings.
abstract final class ThemeModePreference {
  static const _system = 'system';
  static const _light = 'light';
  static const _dark = 'dark';

  static const defaultMode = ThemeMode.system;

  static String encode(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => _light,
      ThemeMode.dark => _dark,
      ThemeMode.system => _system,
    };
  }

  /// Unknown or null values fall back to [defaultMode].
  static ThemeMode decode(String? raw) {
    return switch (raw) {
      _light => ThemeMode.light,
      _dark => ThemeMode.dark,
      _system => ThemeMode.system,
      _ => defaultMode,
    };
  }

  static String label(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
      ThemeMode.system => 'System',
    };
  }
}
