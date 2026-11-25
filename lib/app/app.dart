import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:material_ui/material_ui.dart';

import '../core/config/portfolio_config.dart';
import '../core/theme/glass_tokens.dart';
import '../core/theme/theme_controller.dart';
import '../core/theme/theme_scope.dart';
import '../data/services/portfolio_controller.dart';
import '../shell/app_shell.dart';

class App extends StatelessWidget {
  const App({
    super.key,
    required this.themeController,
    this.portfolioConfig = PortfolioConfig.istuhinDev,
    this.portfolioController,
  });

  final ThemeController themeController;
  final PortfolioConfig portfolioConfig;
  final PortfolioController? portfolioController;

  static const _seed = Color(0xFF00FF99);

  static const _pageTransitions = PageTransitionsTheme(
    builders: {
      TargetPlatform.iOS: GlassPageTransitionsBuilder(),
      TargetPlatform.macOS: GlassPageTransitionsBuilder(),
      TargetPlatform.android: GlassPageTransitionsBuilder(),
      TargetPlatform.linux: GlassPageTransitionsBuilder(),
      TargetPlatform.windows: GlassPageTransitionsBuilder(),
      TargetPlatform.fuchsia: GlassPageTransitionsBuilder(),
    },
  );

  @override
  Widget build(BuildContext context) {
    return ThemeScope(
      controller: themeController,
      child: ListenableBuilder(
        listenable: themeController,
        builder: (context, _) {
          return MaterialApp(
            title: portfolioConfig.brand,
            debugShowCheckedModeBanner: false,
            themeMode: themeController.mode,
            theme: ThemeData(
              fontFamily: GlassTokens.fontMain,
              colorScheme: .fromSeed(
                seedColor: _seed,
                brightness: .light,
              ),
              scaffoldBackgroundColor: const Color(0x00000000),
              pageTransitionsTheme: _pageTransitions,
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              fontFamily: GlassTokens.fontMain,
              colorScheme: .fromSeed(
                seedColor: _seed,
                brightness: .dark,
              ),
              scaffoldBackgroundColor: const Color(0x00000000),
              pageTransitionsTheme: _pageTransitions,
              useMaterial3: true,
            ),
            home: AppShell(
              portfolioConfig: portfolioConfig,
              portfolioController: portfolioController,
            ),
          );
        },
      ),
    );
  }
}
