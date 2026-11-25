import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_app/app/app.dart';
import 'package:liquid_glass_app/core/storage/local_preferences.dart';
import 'package:liquid_glass_app/core/theme/glass_tokens.dart';
import 'package:liquid_glass_app/core/theme/theme_controller.dart';
import 'package:liquid_glass_app/core/widgets/glass/portfolio_app_bar.dart';
import 'package:liquid_glass_app/core/widgets/glass/portfolio_brand_logo.dart';
import 'package:liquid_glass_app/core/widgets/nav_glyphs.dart';
import 'package:liquid_glass_app/shell/glass_bottom_nav.dart';
import 'package:material_ui/material_ui.dart';

ThemeController _testController({ThemeMode initial = ThemeMode.dark}) {
  return ThemeController(
    preferences: LocalPreferences(
      seed: <String, String>{
        PreferenceKeys.themeMode: initial.name,
      },
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'PortfolioAppBar aligns navigation buttons inside top AppBar on desktop and hides bottom appbar',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = _testController();
    await controller.load();

    await tester.pumpWidget(App(themeController: controller));
    await tester.pumpAndSettle();

    final appBar = find.byType(PortfolioAppBar);
    expect(appBar, findsOneWidget);
    expect(find.byType(PortfolioBrandLogo), findsOneWidget);

    // On desktop (1280px), GlassBottomNav is aligned inside PortfolioAppBar
    expect(
      find.descendant(of: appBar, matching: find.byType(GlassBottomNav)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: appBar, matching: find.byType(NavStoreIcon)),
      findsWidgets,
    );

    // Verify CustomPaint uses IsTuhinMoiraiLogoPainter
    final logoCustomPaint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(PortfolioBrandLogo),
        matching: find.byType(CustomPaint),
      ),
    );
    expect(logoCustomPaint.painter, isA<IsTuhinMoiraiLogoPainter>());
  });

  testWidgets(
      'PortfolioBrandLogo adapts colors and glow between dark and light modes and scales across all device widths',
      (WidgetTester tester) async {
    final controller = _testController(initial: ThemeMode.dark);
    await controller.load();

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final heightsByWidth = <double, double>{};
    for (final width in <double>[320, 390, 640, 768, 1280]) {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(App(themeController: controller));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final logoSize = tester.getSize(find.byType(PortfolioBrandLogo));
      heightsByWidth[width] = logoSize.height;
    }

    // Logo scales up from compact phones to desktop screens
    expect(heightsByWidth[320]!, lessThan(heightsByWidth[640]!));
    expect(heightsByWidth[640]!, lessThan(heightsByWidth[1280]!));

    // Verify Dark mode painter colors
    var paintWidget = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(PortfolioBrandLogo),
        matching: find.byType(CustomPaint),
      ),
    );
    final darkPainter = paintWidget.painter! as IsTuhinMoiraiLogoPainter;
    final darkTokens =
        GlassTokens.of(tester.element(find.byType(PortfolioAppBar)));
    expect(darkPainter.isDark, isTrue);
    expect(darkPainter.color, darkTokens.brandLogoColor);
    expect(darkPainter.glowColor, darkTokens.brandLogoGlowColor);

    // Switch to Light mode -> verify Light mode painter colors
    await controller.setMode(ThemeMode.light);
    await tester.pumpAndSettle();

    paintWidget = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(PortfolioBrandLogo),
        matching: find.byType(CustomPaint),
      ),
    );
    final lightPainter = paintWidget.painter! as IsTuhinMoiraiLogoPainter;
    final lightTokens =
        GlassTokens.of(tester.element(find.byType(PortfolioAppBar)));
    expect(lightPainter.isDark, isFalse);
    expect(lightPainter.color, lightTokens.brandLogoColor);
    expect(lightPainter.glowColor, lightTokens.brandLogoGlowColor);
    expect(lightPainter.color, isNot(equals(darkPainter.color)));
  });

  testWidgets(
      'tapping PortfolioBrandLogo navigates back to Home from Store or Connect pages',
      (WidgetTester tester) async {
    final controller = _testController();
    await controller.load();

    await tester.pumpWidget(App(themeController: controller));
    await tester.pumpAndSettle();

    // Navigate to Store tab
    await tester.tap(find.byType(NavStoreIcon).first);
    await tester.pumpAndSettle();
    expect(
      find.text('Open-source repositories and products from isTuhin.dev.'),
      findsOneWidget,
    );

    // Tap isTuhin vector brand logo in AppBar -> returns to Home
    await tester.tap(find.byType(PortfolioBrandLogo));
    await tester.pumpAndSettle();
    expect(find.text('lovestack software developer'), findsOneWidget);
  });

  testWidgets(
      'scrolling page content past 20pt transitions PortfolioAppBar into scrolled state',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = _testController();
    await controller.load();

    await tester.pumpWidget(App(themeController: controller));
    await tester.pumpAndSettle();

    expect(
      tester.widget<PortfolioAppBar>(find.byType(PortfolioAppBar)).isScrolled,
      isFalse,
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(CustomScrollView).first),
    );
    await gesture.moveBy(const Offset(0, -80));
    await tester.pump();

    expect(
      tester.widget<PortfolioAppBar>(find.byType(PortfolioAppBar)).isScrolled,
      isTrue,
    );

    await gesture.up();
    await tester.pumpAndSettle();
  });
}
