import 'package:liquid_glass_app/core/theme/theme_mode_preference.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('ThemeModePreference', () {
    test('encodes known modes', () {
      expect(ThemeModePreference.encode(ThemeMode.system), 'system');
      expect(ThemeModePreference.encode(ThemeMode.light), 'light');
      expect(ThemeModePreference.encode(ThemeMode.dark), 'dark');
    });

    test('decodes known modes', () {
      expect(ThemeModePreference.decode('system'), ThemeMode.system);
      expect(ThemeModePreference.decode('light'), ThemeMode.light);
      expect(ThemeModePreference.decode('dark'), ThemeMode.dark);
    });

    test('falls back to system for null or corrupt values', () {
      expect(ThemeModePreference.decode(null), ThemeMode.system);
      expect(ThemeModePreference.decode(''), ThemeMode.system);
      expect(ThemeModePreference.decode('nope'), ThemeMode.system);
      expect(ThemeModePreference.decode('DARK'), ThemeMode.system);
    });

    test('labels are stable', () {
      expect(ThemeModePreference.label(ThemeMode.system), 'System');
      expect(ThemeModePreference.label(ThemeMode.light), 'Light');
      expect(ThemeModePreference.label(ThemeMode.dark), 'Dark');
    });
  });
}
