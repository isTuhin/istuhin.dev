import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:material_ui/material_ui.dart';

import 'app/app.dart';
import 'core/storage/local_preferences.dart';
import 'core/theme/liquid_glass_chrome.dart';
import 'core/theme/theme_controller.dart';
import 'data/services/github_stats_service.dart';
import 'data/services/portfolio_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await LiquidGlassWidgets.initialize();
  } catch (_) {
    // Allow app to continue mounting if shader warm-up is unsupported on host.
  }

  final preferences = LocalPreferences(file: LocalPreferences.defaultFile());
  final themeController = ThemeController(preferences: preferences);
  try {
    await themeController.load();
  } catch (_) {
    // Fallback to default ThemeMode.system on restricted storage environments.
  }

  final portfolioController = PortfolioController(
    githubService: GitHubStatsService(
      preferences: preferences,
      enableNetwork: true,
    ),
  )..start();

  runApp(
    LiquidGlassWidgets.wrap(
      brightnessResolver: Theme.maybeBrightnessOf,
      theme: AppLiquidGlass.themeData,
      child: App(
        themeController: themeController,
        portfolioController: portfolioController,
      ),
    ),
  );
}
