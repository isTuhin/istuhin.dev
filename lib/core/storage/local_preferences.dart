import 'local_preferences_web.dart'
    if (dart.library.io) 'local_preferences_io.dart';

/// Keys for non-secret local preferences.
abstract final class PreferenceKeys {
  static const themeMode = 'theme_mode';
}

/// Hardened cross-platform string preferences (no native plugins, web-safe).
///
/// Features:
/// - Native (`dart.library.io`): Sandbox-safe atomic JSON file persistence for
///   iOS/macOS (`Library/Application Support`), Linux XDG, Windows APPDATA, and temp.
/// - Web (`Chrome` / browser): Safe in-memory session storage without touching
///   `dart:io` `Platform.environment` or `File`, preventing Web startup crashes.
/// - Payload size and key/value bounds validation.
class LocalPreferences {
  LocalPreferences({Object? file, Map<String, String>? seed})
      : _hasExplicitSeed = seed != null,
        _values = Map<String, String>.from(seed ?? const {}),
        _store = PlatformPreferenceStore(
          file: file,
          maxFileBytes: _maxFileBytes,
          maxEntries: _maxEntries,
          maxKeyLength: _maxKeyLength,
          maxValueLength: _maxValueLength,
        );

  static const int _maxFileBytes = 256 * 1024;
  static const int _maxEntries = 128;
  static const int _maxKeyLength = 128;
  static const int _maxValueLength = 64 * 1024;

  final bool _hasExplicitSeed;
  final Map<String, String> _values;
  final PlatformPreferenceStore _store;
  bool _loaded = false;

  /// Resolves a writable on-device file path on native platforms, or `null` on Web.
  static Object? defaultFile() => PlatformPreferenceStore.resolveDefaultFile();

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    _loaded = true;
    final loadedMap = await _store.load();
    if (loadedMap.isNotEmpty) {
      _values.addAll(loadedMap);
    } else if (_hasExplicitSeed) {
      // Preserve explicit seed map supplied in tests
    }
  }

  Future<String?> getString(String key) async {
    if (key.isEmpty || key.length > _maxKeyLength) return null;
    await _ensureLoaded();
    return _values[key];
  }

  Future<void> setString(String key, String value) async {
    if (key.isEmpty ||
        key.length > _maxKeyLength ||
        value.length > _maxValueLength) {
      return;
    }
    await _ensureLoaded();
    _values[key] = value;
    await _store.save(_values);
  }
}
