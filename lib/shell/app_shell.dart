import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:material_ui/material_ui.dart';

import '../core/config/portfolio_config.dart';
import '../core/theme/glass_tokens.dart';
import '../core/theme/theme_scope.dart';
import '../core/widgets/glass/portfolio_app_bar.dart';
import '../data/repositories/portfolio_repository.dart';
import '../data/services/portfolio_controller.dart';
import '../features/chats/chats_page.dart';
import '../features/ecosystem/widgets/project_glass_card.dart';
import '../features/home/home_page.dart';
import '../features/profile/profile_page.dart';
import '../features/search/search_page.dart';
import '../features/settings/settings_page.dart';
import '../features/terminal_lab/terminal_controller.dart';
import 'glass_bottom_nav.dart';

/// App chrome: glass page scope + Liquid Glass [PortfolioAppBar] + scroll-edge effect
/// + responsive navigation:
/// - On Desktop (`tokens.isExpanded`, width >= 840px): no bottom navigation bar is
///   shown; navigation buttons align directly on the right side of [PortfolioAppBar].
/// - On Mobile / Tablet (`!tokens.isExpanded`): floating [GlassBottomNav] at bottom.
///
/// Page index matches [GlassBottomNav]:
/// 0 Home, 1 Search, 2 Store (aligned right after Home), 3 Connect (message button), 4 Settings.
class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    this.portfolioConfig = PortfolioConfig.istuhinDev,
    this.repository = const PortfolioRepository(),
    this.portfolioController,
  });

  final PortfolioConfig portfolioConfig;
  final PortfolioRepository repository;
  final PortfolioController? portfolioController;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = GlassBottomNav.homePageIndex;
  int _previousNonSettingsIndex = GlassBottomNav.homePageIndex;
  bool _isScrolled = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late PortfolioController _portfolioController;
  bool _ownsPortfolioController = false;
  late final TerminalController _terminalController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initPortfolioController();
    _terminalController = TerminalController(
      repository: widget.repository,
      portfolioController: _portfolioController,
      onNavigateTab: _handleDestinationSelected,
      onSetThemeMode: (mode) {
        if (!mounted) return;
        ThemeScope.of(context).setMode(mode);
      },
      onInspectProject: (project) {
        if (!mounted) return;
        ProjectDetailSheet.show(context, project);
      },
    );
  }

  void _initPortfolioController() {
    if (widget.portfolioController != null) {
      _portfolioController = widget.portfolioController!;
      _ownsPortfolioController = false;
    } else {
      _portfolioController = PortfolioController(
        repository: widget.repository,
        initialConfig: widget.portfolioConfig,
      );
      _ownsPortfolioController = true;
    }
  }

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.portfolioController != widget.portfolioController) {
      if (_ownsPortfolioController) {
        _portfolioController.dispose();
      }
      _initPortfolioController();
    }
  }

  @override
  void dispose() {
    _terminalController.dispose();
    if (_ownsPortfolioController) {
      _portfolioController.dispose();
    }
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _handleDestinationSelected(int index) {
    final isSearchAction = index == GlassBottomNav.searchPageIndex;
    final targetIndex = isSearchAction ? GlassBottomNav.homePageIndex : index;
    setState(() {
      if (_index != GlassBottomNav.settingsPageIndex &&
          targetIndex == GlassBottomNav.settingsPageIndex) {
        _previousNonSettingsIndex = _index;
      }
      _index = targetIndex;
      _isScrolled = false;
      _searchQuery = '';
    });
    if (isSearchAction) {
      _terminalController.requestFocus();
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth == 0 &&
        notification.metrics.axis == Axis.vertical) {
      final scrolled =
          notification.metrics.pixels > kPortfolioAppBarScrollThreshold;
      if (scrolled != _isScrolled) {
        setState(() => _isScrolled = scrolled);
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = GlassTokens.of(context);
    final isDesktop = tokens.isExpanded;
    final background = tokens.scaffoldBackground;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final bottomFadeHeight = isDesktop
        ? 0.0
        : (tokens.capsuleHeight + tokens.barBottomInset * 2 + bottomPadding);
    final showTopPortfolioBar =
        isDesktop || _index != GlassBottomNav.settingsPageIndex;

    final navBar = GlassBottomNav(
      currentIndex: _index,
      searchController: _searchController,
      searchFocusNode: _searchFocusNode,
      onDestinationSelected: _handleDestinationSelected,
      onSearchChanged: (value) => setState(() => _searchQuery = value),
      inlineInAppBar: isDesktop,
    );

    final pages = <Widget>[
      HomePage(
        portfolioConfig: widget.portfolioConfig,
        repository: widget.repository,
        portfolioController: _portfolioController,
        terminalController: _terminalController,
        onNavigateTab: _handleDestinationSelected,
      ),
      SearchPage(
        query: _searchQuery,
        onRequestFocus: _searchFocusNode.requestFocus,
        portfolioController: _portfolioController,
        repository: widget.repository,
      ),
      StorePage(
        portfolioController: _portfolioController,
        repository: widget.repository,
      ),
      ConnectPage(
        portfolioController: _portfolioController,
        repository: widget.repository,
      ),
      SettingsPage(
        onBack: () => _handleDestinationSelected(_previousNonSettingsIndex),
      ),
    ];

    return ListenableBuilder(
      listenable: _portfolioController,
      builder: (context, _) {
        return GlassPage(
          statusBarStyle: GlassStatusBarStyle.auto,
          child: Scaffold(
            backgroundColor: background,
            extendBody: !isDesktop,
            resizeToAvoidBottomInset: false,
            body: ColoredBox(
              color: background,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showTopPortfolioBar)
                    PortfolioAppBar(
                      config: _portfolioController.config,
                      isScrolled: _isScrolled,
                      onBrandTap: () => _handleDestinationSelected(
                        GlassBottomNav.homePageIndex,
                      ),
                      trailingNav: isDesktop ? navBar : null,
                    ),
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: _handleScrollNotification,
                      child: GlassScrollEdgeEffect(
                        fadeColor: background,
                        topFadeHeight: 0,
                        bottomFadeHeight: bottomFadeHeight,
                        style: GlassScrollEdgeStyle.soft,
                        child: IndexedStack(index: _index, children: pages),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: isDesktop ? null : navBar,
          ),
        );
      },
    );
  }
}
