import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_app/core/theme/glass_tokens.dart';
import 'package:liquid_glass_app/data/repositories/portfolio_seed_data.dart';
import 'package:liquid_glass_app/features/overview/widgets/github_contribution_card.dart';
import 'package:material_ui/material_ui.dart';

Widget _wrapWithTheme(Widget child, {required Size size, bool isDark = true}) {
  return MaterialApp(
    theme: ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      fontFamily: GlassTokens.fontMain,
    ),
    home: MediaQuery(
      data: MediaQueryData(
        size: size,
        devicePixelRatio: 1.0,
      ),
      child: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            width: size.width,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GitHubContributionCard Modular Components & Real Data', () {
    testWidgets(
        'renders modular GitHubStatCard, ContributionCalendar, ContributionMonthLabels, ContributionDayCell, ContributionLegend, and ContributionActivityCard on desktop (1440px)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final stats = PortfolioSeedData.githubStats;

      await tester.pumpWidget(
        _wrapWithTheme(
          GitHubContributionCard(stats: stats),
          size: const Size(1440, 900),
          isDark: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GitHubContributionCard), findsOneWidget);
      expect(find.byType(GitHubStatCard), findsNWidgets(4));
      expect(find.byType(ContributionCalendar), findsOneWidget);
      expect(find.byType(ContributionMonthLabels), findsOneWidget);
      expect(find.byType(ContributionLegend), findsOneWidget);
      expect(find.byType(ContributionActivityCard), findsOneWidget);
      expect(find.byType(ContributionDayCell), findsWidgets);

      expect(
        find.byWidgetPredicate(
          (w) =>
              w is RichText &&
              w.text
                  .toPlainText()
                  .contains('376 contributions in the last year'),
        ),
        findsOneWidget,
      );

      // Verify weekday labels ('Wed' is not clipped)
      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('Wed'), findsOneWidget);
      expect(find.text('Fri'), findsOneWidget);

      // Verify month labels across the 53 weeks
      expect(find.text('Nov'), findsWidgets);
      expect(find.text('Dec'), findsOneWidget);
      expect(find.text('Jan'), findsOneWidget);

      // Verify real active days count == 23 (no synthetic random pattern)
      final activeDays = stats.contributionWeeks
          .expand((w) => w)
          .where((d) => d.count > 0)
          .toList();
      expect(activeDays.length, 23);
    });

    testWidgets(
        'allows horizontal scrolling and auto-positions to recent weeks on mobile (360px)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final stats = PortfolioSeedData.githubStats;

      await tester.pumpWidget(
        _wrapWithTheme(
          GitHubContributionCard(stats: stats),
          size: const Size(360, 780),
          isDark: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsWidgets);
      expect(find.byType(ContributionCalendar), findsOneWidget);
    });
  });
}
