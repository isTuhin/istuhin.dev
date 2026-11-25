import 'dart:convert';
import 'dart:io';

/// Native (`dart:io`) file-backed persistence engine for [LocalPreferences].
class PlatformPreferenceStore {
  PlatformPreferenceStore({
    Object? file,
    required this.maxFileBytes,
    required this.maxEntries,
    required this.maxKeyLength,
    required this.maxValueLength,
  }) : _file = file is File ? file : null;

  final File? _file;
  final int maxFileBytes;
  final int maxEntries;
  final int maxKeyLength;
  final int maxValueLength;

  /// Resolves a writable on-device file path inside the app sandbox.
  static Object? resolveDefaultFile() {
    try {
      final env = Platform.environment;

      // 1. iOS / macOS app sandbox: $HOME/Library/Application Support
      final home = env['HOME'];
      if (home != null && home.isNotEmpty) {
        final appleSupport = Directory('$home/Library/Application Support');
        if (appleSupport.existsSync()) {
          return File('${appleSupport.path}/app_preferences.json');
        }
      }

      // 2. Linux XDG_DATA_HOME or Windows APPDATA
      final xdg = env['XDG_DATA_HOME'];
      if (xdg != null && xdg.isNotEmpty) {
        return File('$xdg/app_preferences.json');
      }
      final appData = env['APPDATA'];
      if (appData != null && appData.isNotEmpty) {
        return File('$appData/app_preferences.json');
      }

      // 3. Desktop $HOME/.config fallback
      if (home != null && home.isNotEmpty) {
        return File('$home/.config/app_preferences.json');
      }

      // 4. System temp directory fallback
      return File('${Directory.systemTemp.path}/app_preferences.json');
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, String>> load() async {
    final result = <String, String>{};
    final file = _file;
    if (file == null || !await file.exists()) return result;
    try {
      final stat = await file.stat();
      if (stat.size > maxFileBytes) return result;

      final raw = await file.readAsString();
      if (raw.trim().isEmpty) return result;
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return result;

      var count = 0;
      for (final entry in decoded.entries) {
        if (count >= maxEntries) break;
        final key = entry.key;
        final value = entry.value;
        if (key is String &&
            value is String &&
            key.isNotEmpty &&
            key.length <= maxKeyLength &&
            value.length <= maxValueLength) {
          result[key] = value;
          count++;
        }
      }
    } on FormatException {
      // Corrupt file — keep empty map; next write replaces it atomically.
    } on FileSystemException {
      // Unreadable — treat as empty.
    }
    return result;
  }

  Future<void> save(Map<String, String> values) async {
    final file = _file;
    if (file == null) return;
    try {
      await file.parent.create(recursive: true);
      final tmpFile = File('${file.path}.tmp');
      await tmpFile.writeAsString(jsonEncode(values), flush: true);
      await tmpFile.rename(file.path);
    } on FileSystemException {
      // Best-effort persistence; in-memory values still apply this session.
    }
  }
}
