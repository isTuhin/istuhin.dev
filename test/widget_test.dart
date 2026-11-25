import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoIcons;
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_app/app/app.dart';
import 'package:liquid_glass_app/core/storage/local_preferences.dart';
import 'package:liquid_glass_app/core/theme/theme_controller.dart';
import 'package:liquid_glass_app/core/widgets/appearance_mode_control.dart';
import 'package:liquid_glass_app/core/widgets/glass/liquid_glass_pill_button.dart';
import 'package:liquid_glass_app/core/widgets/glass/portfolio_app_bar.dart';
import 'package:liquid_glass_app/core/widgets/nav_glyphs.dart';
import 'package:liquid_glass_app/features/terminal_lab/widgets/interactive_zsh_terminal.dart';
import 'package:liquid_glass_app/shell/glass_bottom_nav.dart';
import 'package:material_ui/material_ui.dart';

ThemeController _testThemeController() {
  return ThemeController(
    preferences: LocalPreferences(seed: const {}),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'nav aligns Store right after Home, maps message button to redesigned Connect page with LiquidGlassPillButton, and morphs into search bar',
      (
    WidgetTester tester,
  ) async {
    final themeController = _testThemeController();
    await tester.pumpWidget(App(themeController: themeController));
    await tester.pumpAndSettle();

    final nav = find.byType(GlassBottomNav);
    expect(nav, findsOneWidget);
    expect(find.descendant(of: nav, matching: find.byType(Text)), findsNothing);

    final homeFinder = find.byIcon(CupertinoIcons.house_fill);
    final storeFinder = find.byType(NavStoreIcon).first;
    final connectFinder = find.byType(NavConnectIcon).first;
    final settingsFinder = find.byType(NavSettingsIcon).first;

    expect(homeFinder, findsOneWidget);
    expect(storeFinder, findsOneWidget);
    expect(connectFinder, findsOneWidget);
    expect(settingsFinder, findsOneWidget);
    expect(find.byIcon(CupertinoIcons.search), findsOneWidget);

    // Verify horizontal tab order: Home -> Store -> Connect -> Settings
    final homeX = tester.getCenter(homeFinder).dx;
    final storeX = tester.getCenter(storeFinder).dx;
    final connectX = tester.getCenter(connectFinder).dx;
    final settingsX = tester.getCenter(settingsFinder).dx;
    expect(homeX, lessThan(storeX));
    expect(storeX, lessThan(connectX));
    expect(connectX, lessThan(settingsX));

    expect(find.text('lovestack software developer'), findsOneWidget);

    // Switch to Store tab (aligned second, right after Home)
    await tester.tap(find.byType(NavStoreIcon).first);
    await tester.pumpAndSettle();
    expect(
      find.text('Open-source repositories and products from isTuhin.dev.'),
      findsOneWidget,
    );
    expect(find.text('No products listed yet.'), findsOneWidget);

    // Tap search orb from Store -> navigates to Home and focuses terminal for search
    await tester.tap(find.byIcon(CupertinoIcons.search));
    await tester.pumpAndSettle();
    expect(find.text('lovestack software developer'), findsOneWidget);
    final terminalField = find.descendant(
      of: find.byType(InteractiveZshTerminal),
      matching: find.byType(TextField),
    );
    expect(terminalField, findsOneWidget);
    expect(tester.widget<TextField>(terminalField).focusNode?.hasFocus, isTrue);

    // Run `search flutter` inside the terminal
    await tester.enterText(terminalField, 'search flutter');
    await tester.pump(const Duration(milliseconds: 50));
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpAndSettle();
    expect(find.textContaining('[skill] Flutter'), findsOneWidget);

    // Switch to Connect tab (third tab, message icon)
    await tester.tap(find.byType(NavConnectIcon).first);
    await tester.pumpAndSettle();
    expect(
      find.text('Send a message, or reach me on the channels below.'),
      findsOneWidget,
    );
    expect(find.byType(LiquidGlassPillButton), findsOneWidget);
    expect(find.text('Send message'), findsOneWidget);
    expect(find.text('DIRECT CONTACT'), findsOneWidget);
    expect(find.text('PROFESSIONAL NETWORKS'), findsOneWidget);

    // Switch to Settings tab
    await tester.tap(find.byType(NavSettingsIcon).first);
    await tester.pumpAndSettle();
    expect(find.byType(AppearanceModeControl), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.back), findsOneWidget);

    // Tap Back button on SettingsPage -> returns to previous tab (Connect)
    await tester.tap(find.byIcon(CupertinoIcons.back));
    await tester.pumpAndSettle();
    expect(
      find.text('Send a message, or reach me on the channels below.'),
      findsOneWidget,
    );

    // Switch back to Home tab
    await tester.tap(find.byIcon(CupertinoIcons.house));
    await tester.pumpAndSettle();
    expect(find.text('lovestack software developer'), findsOneWidget);
  });

  testWidgets(
      'mobile and tablet show floating bottom nav while desktop aligns nav inside PortfolioAppBar without bottom bar',
      (
    WidgetTester tester,
  ) async {
    final themeController = _testThemeController();

    Future<void> pumpAt(Size size, {required bool expectDesktopAppBarNav}) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(App(themeController: themeController));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(GlassBottomNav), findsOneWidget);

      final navWidget = tester.widget<GlassBottomNav>(find.byType(GlassBottomNav));
      expect(navWidget.inlineInAppBar, expectDesktopAppBarNav);
      if (expectDesktopAppBarNav) {
        expect(
          find.descendant(
            of: find.byType(PortfolioAppBar),
            matching: find.byType(GlassBottomNav),
          ),
          findsOneWidget,
        );
      }
    }

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpAt(const Size(320, 700), expectDesktopAppBarNav: false);
    await pumpAt(const Size(390, 844), expectDesktopAppBarNav: false);
    await pumpAt(const Size(768, 1024), expectDesktopAppBarNav: false);
    await pumpAt(const Size(1024, 1366), expectDesktopAppBarNav: true);
  });
}
