import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_app/core/storage/local_preferences.dart';
import 'package:liquid_glass_app/core/theme/theme_controller.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('liquid_glass_prefs_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('defaults to system before load', () {
    final controller = ThemeController(
      preferences: LocalPreferences(seed: const {}),
    );
    expect(controller.mode, ThemeMode.system);
  });

  test('load applies persisted dark mode', () async {
    final file = File('${tempDir.path}/prefs.json');
    await file.writeAsString('{"${PreferenceKeys.themeMode}":"dark"}');
    final controller = ThemeController(
      preferences: LocalPreferences(file: file),
    );

    await controller.load();
    expect(controller.mode, ThemeMode.dark);
  });

  test('load falls back when stored value is corrupt', () async {
    final file = File('${tempDir.path}/prefs.json');
    await file.writeAsString('{"${PreferenceKeys.themeMode}":"banana"}');
    final controller = ThemeController(
      preferences: LocalPreferences(file: file),
    );

    await controller.load();
    expect(controller.mode, ThemeMode.system);
  });

  test('load falls back when file JSON is invalid', () async {
    final file = File('${tempDir.path}/prefs.json');
    await file.writeAsString('{not-json');
    final controller = ThemeController(
      preferences: LocalPreferences(file: file),
    );

    await controller.load();
    expect(controller.mode, ThemeMode.system);
  });

  test('setMode persists and notifies', () async {
    final file = File('${tempDir.path}/prefs.json');
    final controller = ThemeController(
      preferences: LocalPreferences(file: file),
    );
    var notified = 0;
    controller.addListener(() => notified++);

    await controller.setMode(ThemeMode.light);
    expect(controller.mode, ThemeMode.light);
    expect(notified, 1);
    expect(await file.readAsString(), contains('"light"'));

    await controller.setMode(ThemeMode.light);
    expect(notified, 1);

    final reloaded = ThemeController(
      preferences: LocalPreferences(file: file),
    );
    await reloaded.load();
    expect(reloaded.mode, ThemeMode.light);
  });
}
