import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_app/app/app.dart';
import 'package:liquid_glass_app/core/storage/local_preferences.dart';
import 'package:liquid_glass_app/core/theme/glass_tokens.dart';
import 'package:liquid_glass_app/core/theme/theme_controller.dart';
import 'package:liquid_glass_app/core/theme/theme_scope.dart';
import 'package:liquid_glass_app/core/widgets/appearance_mode_control.dart';
import 'package:liquid_glass_app/core/widgets/glass/glass_page_app_bar.dart';
import 'package:liquid_glass_app/core/widgets/glass/glass_slider_row.dart';
import 'package:liquid_glass_app/core/widgets/glass/glass_switch_row.dart';
import 'package:liquid_glass_app/features/settings/settings_page.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:material_ui/material_ui.dart';

ThemeController _controller({Map<String, String>? seed}) {
  return ThemeController(
    preferences: LocalPreferences(seed: seed ?? const {}),
  );
}

Future<void> _pumpApp(
  WidgetTester tester,
  ThemeController controller, {
  Brightness platformBrightness = Brightness.light,
}) async {
  tester.platformDispatcher.platformBrightnessTestValue = platformBrightness;
  addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

  await tester.pumpWidget(App(themeController: controller));
  await tester.pumpAndSettle();
}

Widget _scopedApp({
  required ThemeController controller,
  required Widget home,
}) {
  return ThemeScope(
    controller: controller,
    child: ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return MaterialApp(
          themeMode: controller.mode,
          theme: ThemeData(
            colorScheme: .fromSeed(
              seedColor: const Color(0xFF2F6FED),
              brightness: .light,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: .fromSeed(
              seedColor: const Color(0xFF2F6FED),
              brightness: .dark,
            ),
            useMaterial3: true,
          ),
          home: home,
        );
      },
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('forced dark sets Material and GlassTokens brightness', (
    WidgetTester tester,
  ) async {
    final controller = _controller();
    await controller.setMode(ThemeMode.dark);
    await _pumpApp(tester, controller, platformBrightness: Brightness.light);

    final BuildContext shellContext =
        tester.element(find.byType(Scaffold).first);
    expect(Theme.of(shellContext).brightness, Brightness.dark);
    expect(GlassTokens.of(shellContext).isDark, isTrue);
    expect(
      GlassTokens.of(shellContext).scaffoldBackground,
      const Color(0xFF000000),
    );
  });

  testWidgets('forced light ignores platform dark',
      (WidgetTester tester) async {
    final controller = _controller();
    await controller.setMode(ThemeMode.light);
    await _pumpApp(tester, controller, platformBrightness: Brightness.dark);

    final BuildContext shellContext =
        tester.element(find.byType(Scaffold).first);
    expect(Theme.of(shellContext).brightness, Brightness.light);
    expect(GlassTokens.of(shellContext).isDark, isFalse);
  });

  testWidgets('system mode follows platform brightness', (
    WidgetTester tester,
  ) async {
    final controller = _controller();
    await controller.setMode(ThemeMode.system);
    await _pumpApp(tester, controller, platformBrightness: Brightness.dark);

    final BuildContext shellContext =
        tester.element(find.byType(Scaffold).first);
    expect(Theme.of(shellContext).brightness, Brightness.dark);
  });

  testWidgets('appearance control updates theme mode', (
    WidgetTester tester,
  ) async {
    final controller = _controller();
    await tester.pumpWidget(
      _scopedApp(controller: controller, home: const SettingsPage()),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppearanceModeControl), findsOneWidget);
    final inlineBar = tester.widget<GlassTabBar>(
      find.descendant(
        of: find.byType(AppearanceModeControl),
        matching: find.byType(GlassTabBar),
      ),
    );
    expect(inlineBar.barBorderRadius, GlassDefaults.capsuleRadius);
    expect(inlineBar.maskingQuality, MaskingQuality.high);
    final tokens = GlassTokens.of(tester.element(find.byType(SettingsPage)));
    expect(inlineBar.selectedLabelColor, tokens.selectedIcon);
    expect(inlineBar.selectedIconColor, tokens.selectedIcon);

    await tester.tap(find.text('Dark').first);
    await tester.pumpAndSettle();
    expect(controller.mode, ThemeMode.dark);
    expect(
      Theme.of(tester.element(find.byType(SettingsPage))).brightness,
      Brightness.dark,
    );

    await tester.tap(find.text('Light').first);
    await tester.pumpAndSettle();
    expect(controller.mode, ThemeMode.light);
    expect(
      Theme.of(tester.element(find.byType(SettingsPage))).brightness,
      Brightness.light,
    );
  });

  testWidgets('settings page shows back button and invokes onBack', (
    WidgetTester tester,
  ) async {
    final controller = _controller();
    var backPressed = false;
    await tester.pumpWidget(
      _scopedApp(
        controller: controller,
        home: SettingsPage(onBack: () => backPressed = true),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SettingsPage), findsOneWidget);
    expect(find.byType(GlassPageAppBar), findsOneWidget);
    expect(find.byType(AppearanceModeControl), findsOneWidget);
    expect(find.byType(GlassSliderRow), findsOneWidget);
    expect(find.byType(GlassSlider), findsOneWidget);
    expect(find.text('Example Slider'), findsOneWidget);
    expect(find.byType(GlassSwitchRow), findsOneWidget);
    expect(find.byType(GlassSwitch), findsOneWidget);
    expect(find.text('Example Button'), findsOneWidget);

    final glassSwitch = tester.widget<GlassSwitch>(find.byType(GlassSwitch));
    final tokens = GlassTokens.of(tester.element(find.byType(SettingsPage)));
    expect(glassSwitch.activeColor, tokens.selectedIcon);
    expect(glassSwitch.value, isFalse);

    await tester.tap(find.byType(GlassSwitch));
    await tester.pumpAndSettle();
    expect(
      tester.widget<GlassSwitch>(find.byType(GlassSwitch)).value,
      isTrue,
    );

    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    expect(backPressed, isTrue);
  });
}
