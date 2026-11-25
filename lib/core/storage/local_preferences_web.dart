/// Web-safe preference store stub (`dart.library.js_interop`) that avoids
/// importing `dart:io` in Chrome / browser builds.
class PlatformPreferenceStore {
  PlatformPreferenceStore({
    Object? file,
    required int maxFileBytes,
    required int maxEntries,
    required int maxKeyLength,
    required int maxValueLength,
  });

  /// Returns `null` on Web because local filesystem paths (`dart:io` `File`)
  /// do not exist in browser sandboxes.
  static Object? resolveDefaultFile() => null;

  static final Map<String, String> _webSessionStore = <String, String>{};

  Future<Map<String, String>> load() async {
    return Map<String, String>.from(_webSessionStore);
  }

  Future<void> save(Map<String, String> values) async {
    _webSessionStore
      ..clear()
      ..addAll(values);
  }
}
