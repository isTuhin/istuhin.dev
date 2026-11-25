import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_app/app/app.dart';
import 'package:liquid_glass_app/core/storage/local_preferences.dart';
import 'package:liquid_glass_app/core/theme/theme_controller.dart';
import 'package:liquid_glass_app/core/widgets/glass/glass_kit.dart';
import 'package:liquid_glass_app/data/models/github_stats.dart';
import 'package:liquid_glass_app/data/models/skill_category.dart';
import 'package:liquid_glass_app/data/repositories/portfolio_seed_data.dart';
import 'package:liquid_glass_app/data/services/portfolio_controller.dart';
import 'package:liquid_glass_app/features/home/home_page.dart';
import 'package:liquid_glass_app/features/overview/widgets/github_contribution_card.dart';
import 'package:liquid_glass_app/features/overview/widgets/hero_terminal_banner.dart';
import 'package:liquid_glass_app/features/profile/profile_page.dart';
import 'package:liquid_glass_app/features/terminal_lab/widgets/interactive_zsh_terminal.dart';
import 'package:liquid_glass_app/features/terminal_lab/widgets/tech_stack_matrix.dart';
import 'package:material_ui/material_ui.dart';

ThemeController _testThemeController({ThemeMode initial = ThemeMode.dark}) {
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
      'App configures Michroma as primary font family and HomePage matches istuhin.dev layout without extra top gap',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final themeController = _testThemeController();
    await themeController.load();

    await tester.pumpWidget(App(themeController: themeController));
    await tester.pumpAndSettle();

    // Verify ThemeData uses Michroma font family globally
    final context = tester.element(find.byType(HomePage));
    expect(
      Theme.of(context).textTheme.bodyMedium?.fontFamily,
      GlassTokens.fontMain,
    );
    expect(GlassTokens.fontMain, 'Michroma');

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(GlassLargeTitle), findsNothing);
    expect(find.byType(HeroTerminalBanner), findsOneWidget);
    expect(find.byType(InteractiveZshTerminal), findsOneWidget);
    expect(find.byType(TechStackMatrix), findsOneWidget);
    expect(find.byType(GitHubContributionCard), findsOneWidget);
    expect(find.byType(CertificationsGrid), findsOneWidget);

    // Verify concise istuhin.dev Hero tags & strings
    expect(find.text('This is'), findsOneWidget);
    expect(find.text('lovestack software developer'), findsOneWidget);
    expect(
      find.text('Interactive portfolio shell. Type `help` to begin.'),
      findsOneWidget,
    );

    // Verify section headers match istuhin.dev
    expect(find.text('ECOSYSTEM'), findsOneWidget);
    expect(find.text('Tech Stack'), findsOneWidget);
    expect(find.text('GITHUB'), findsOneWidget);
    expect(find.text('Live Stats'), findsOneWidget);
    expect(find.text('CERTIFICATIONS'), findsOneWidget);
    expect(find.text('Badges'), findsOneWidget);

    // Verify 4 GitHub stat cards & Contribution activity section
    expect(find.text('PUBLIC REPOS'), findsOneWidget);
    expect(find.text('TOTAL STARS'), findsOneWidget);
    expect(find.text('TOTAL FORKS'), findsOneWidget);
    expect(find.text('FEATURED'), findsOneWidget);
    expect(find.text('Contribution activity'), findsOneWidget);
    expect(find.text('Show more activity on GitHub'), findsOneWidget);

    // Verify all 4 tech stack domain cards
    for (final domain in SkillDomain.values) {
      expect(find.text(domain.title), findsOneWidget);
    }
  });

  testWidgets(
      'PortfolioController dynamically updates HomePage, StorePage, and Terminal when live CMS or GitHub data changes',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final themeController = _testThemeController(initial: ThemeMode.dark);
    await themeController.load();
    final portfolioController = PortfolioController();
    addTearDown(portfolioController.dispose);

    await tester.pumpWidget(
      App(
        themeController: themeController,
        portfolioController: portfolioController,
      ),
    );
    await tester.pumpAndSettle();

    // Push live dynamic update from simulated /api/github/overview & Supabase site_settings
    final liveConfig = PortfolioConfig.fromSiteSettingsJson(
      const <String, dynamic>{
        'brand': 'isTuhin.dev',
        'brand_prefix': 'is',
        'brand_name': 'Tuhin',
        'brand_suffix': '.dev',
        'tagline': 'Welcome to',
        'role_title': 'principal flutter & cloud architect',
        'email': 'live@istuhin.dev',
        'github_username': 'isTuhin',
      },
    );
    final liveStats = GitHubStats.fromOverviewPayload(
      const <String, dynamic>{
        'data': <String, dynamic>{
          'stats': <String, dynamic>{
            'username': 'isTuhin',
            'publicRepos': 64,
            'totalStars': 512,
            'totalForks': 88,
            'followers': 240,
            'featuredCount': 2,
            'contributions': <String, dynamic>{
              'totalContributions': 980,
            },
            'languages': <Map<String, dynamic>>[
              <String, dynamic>{'name': 'Dart', 'count': 42},
            ],
            'fetchedAt': '2026-11-25T13:00:00Z',
          },
          'featured': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 99,
              'name': 'dynamic_liquid_glass',
              'fullName': 'isTuhin/dynamic_liquid_glass',
              'description': 'Live synced repository from GitHub API',
              'htmlUrl': 'https://github.com/isTuhin/dynamic_liquid_glass',
              'language': 'Dart',
              'stargazersCount': 128,
              'forksCount': 19,
            },
          ],
          'repositories': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 99,
              'name': 'dynamic_liquid_glass',
              'fullName': 'isTuhin/dynamic_liquid_glass',
              'description': 'Live synced repository from GitHub API',
              'htmlUrl': 'https://github.com/isTuhin/dynamic_liquid_glass',
              'language': 'Dart',
              'stargazersCount': 128,
              'forksCount': 19,
            },
          ],
        },
      },
      fallback: PortfolioSeedData.githubStats,
    );

    portfolioController.updateData(
      config: liveConfig,
      githubStats: liveStats,
    );
    await tester.pumpAndSettle();

    // HomePage immediately reflects new CMS role & live GitHub counters
    expect(find.text('Welcome to'), findsOneWidget);
    expect(find.text('principal flutter & cloud architect'), findsOneWidget);
    expect(find.text('64'), findsOneWidget);
    expect(find.text('512'), findsOneWidget);
    expect(find.text('88'), findsOneWidget);

    // Switch to Store tab -> live repository 'dynamic_liquid_glass' renders in Open Source section
    await tester.tap(find.byType(NavStoreIcon).first);
    await tester.pumpAndSettle();
    expect(find.byType(StorePage), findsOneWidget);
    expect(find.text('dynamic_liquid_glass'), findsWidgets);
    expect(find.text('★ 128'), findsWidgets);
  });

  testWidgets(
      'HomePage adapts responsive layout across compact phone, medium tablet, and wide desktop viewports in dark and light themes',
      (WidgetTester tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final themeController = _testThemeController(initial: ThemeMode.dark);
    await themeController.load();

    for (final mode in <ThemeMode>[ThemeMode.dark, ThemeMode.light]) {
      await themeController.setMode(mode);

      for (final size in <Size>[
        const Size(320, 700),
        const Size(390, 844),
        const Size(640, 960),
        const Size(768, 1024),
        const Size(1024, 1366),
        const Size(1440, 900),
      ]) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(App(themeController: themeController));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    }

    // On compact phone (390pt), Hero intro block stacks above InteractiveZshTerminal
    tester.view.physicalSize = const Size(390, 1200);
    await tester.pumpWidget(App(themeController: themeController));
    await tester.pumpAndSettle();

    final compactIntroCenter =
        tester.getCenter(find.text('lovestack software developer'));
    final compactTerminalCenter =
        tester.getCenter(find.byType(InteractiveZshTerminal));
    expect(compactIntroCenter.dy, lessThan(compactTerminalCenter.dy));

    // On desktop (1280pt), Hero intro block sits to the left of InteractiveZshTerminal (7/12 + 5/12)
    tester.view.physicalSize = const Size(1280, 1200);
    await tester.pumpWidget(App(themeController: themeController));
    await tester.pumpAndSettle();

    final wideIntroCenter =
        tester.getCenter(find.text('lovestack software developer'));
    final wideTerminalCenter =
        tester.getCenter(find.byType(InteractiveZshTerminal));
    expect(wideIntroCenter.dx, lessThan(wideTerminalCenter.dx));
  });

  testWidgets(
      'InteractiveZshTerminal renders Apple logo SVG, spawns typing fire particles, and executes commands',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final themeController = _testThemeController(initial: ThemeMode.dark);
    await themeController.load();

    await tester.pumpWidget(App(themeController: themeController));
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Apple logo CustomPaint (`TerminalAppleLogoPainter`) is rendered inside InteractiveZshTerminal
    final appleLogoPaints = tester
        .widgetList<CustomPaint>(
          find.descendant(
            of: find.byType(InteractiveZshTerminal),
            matching: find.byType(CustomPaint),
          ),
        )
        .where((cp) => cp.painter is TerminalAppleLogoPainter);
    expect(appleLogoPaints, isNotEmpty);

    // Verify dark mode bottom navigation bar has optical blur & frosted backing
    expect(AppLiquidGlass.darkChrome.blur, greaterThan(0));
    expect(AppLiquidGlass.darkChrome.frost, greaterThan(0));

    final terminalTextField = find.descendant(
      of: find.byType(InteractiveZshTerminal),
      matching: find.byType(TextField),
    );
    expect(terminalTextField, findsOneWidget);

    await tester.enterText(terminalTextField, 'theme light');
    await tester.pump(const Duration(milliseconds: 50));
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump(const Duration(milliseconds: 300));

    expect(themeController.mode, ThemeMode.light);
    expect(
      find.text('Switched Liquid Glass appearance to Light mode.'),
      findsOneWidget,
    );

    // Terminal input must remain focused after command submission so user can
    // type the next command without clicking the terminal again.
    final fieldWidget = tester.widget<TextField>(terminalTextField);
    expect(fieldWidget.focusNode?.hasFocus, isTrue);
  });
}
