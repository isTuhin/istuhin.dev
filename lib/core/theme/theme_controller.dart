import 'package:material_ui/material_ui.dart';

import '../storage/local_preferences.dart';
import 'theme_mode_preference.dart';

/// Holds and persists the user's [ThemeMode] preference.
class ThemeController extends ChangeNotifier {
  ThemeController({LocalPreferences? preferences})
      : _preferences = preferences ?? LocalPreferences();

  final LocalPreferences _preferences;

  ThemeMode _mode = ThemeModePreference.defaultMode;

  ThemeMode get mode => _mode;

  Future<void> load() async {
    final raw = await _preferences.getString(PreferenceKeys.themeMode);
    final next = ThemeModePreference.decode(raw);
    if (next == _mode) return;
    _mode = next;
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
    await _preferences.setString(
      PreferenceKeys.themeMode,
      ThemeModePreference.encode(mode),
    );
  }
}
