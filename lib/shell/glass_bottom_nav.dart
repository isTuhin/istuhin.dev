import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoIcons;
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:material_ui/material_ui.dart';

import '../core/theme/glass_tokens.dart';
import '../core/theme/liquid_glass_chrome.dart';
import '../core/widgets/glass/glass_keyboard_search_bar.dart';
import '../core/widgets/nav_glyphs.dart';

/// Liquid-glass navigation chrome:
/// - Default mode: `[ Home | Store | Connect | Settings ]  ( 🔍 )`
/// - Search mode:  `[ 🔍 Search...   🎤 ]  ( ✕ )`
/// - When [inlineInAppBar] is `true` (Desktop viewports), aligns directly inside
///   the top `PortfolioAppBar` so desktop has no bottom navigation bar.
///
/// Shell page indexes:
/// - `0`: Home
/// - `1`: Search (detached search orb)
/// - `2`: Store (aligned immediately after Home, using custom storefront icon)
/// - `3`: Connect (message button)
/// - `4`: Settings
class GlassBottomNav extends StatefulWidget {
  const GlassBottomNav({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    this.searchController,
    this.searchFocusNode,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onMicTap,
    this.searchHintText = 'Search your library...',
    this.inlineInAppBar = false,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final TextEditingController? searchController;
  final FocusNode? searchFocusNode;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;
  final VoidCallback? onMicTap;
  final String searchHintText;
  final bool inlineInAppBar;

  static const int homePageIndex = 0;
  static const int searchPageIndex = 1;
  static const int storePageIndex = 2;
  static const int connectPageIndex = 3;
  static const int settingsPageIndex = 4;

  static const List<int> mainPageIndexes = [
    homePageIndex,
    storePageIndex,
    connectPageIndex,
    settingsPageIndex,
  ];

  @override
  State<GlassBottomNav> createState() => _GlassBottomNavState();
}

class _GlassBottomNavState extends State<GlassBottomNav> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _ownsController = false;
  bool _ownsFocusNode = false;
  int _lastNonSearchIndex = 0;

  bool get _isSearchActive =>
      widget.currentIndex == GlassBottomNav.searchPageIndex;

  int get _capsuleSelectedIndex {
    final activePage =
        _isSearchActive ? _lastNonSearchIndex : widget.currentIndex;
    final i = GlassBottomNav.mainPageIndexes.indexOf(activePage);
    return i < 0 ? 0 : i;
  }

  @override
  void initState() {
    super.initState();
    _initController();
    _initFocusNode();
    if (!_isSearchActive) {
      _lastNonSearchIndex = widget.currentIndex;
    }
  }

  void _initController() {
    if (widget.searchController != null) {
      _controller = widget.searchController!;
      _ownsController = false;
    } else {
      _controller = TextEditingController();
      _ownsController = true;
    }
    _controller.addListener(_onTextChanged);
  }

  void _initFocusNode() {
    if (widget.searchFocusNode != null) {
      _focusNode = widget.searchFocusNode!;
      _ownsFocusNode = false;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }
  }

  @override
  void didUpdateWidget(covariant GlassBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchController != widget.searchController) {
      _controller.removeListener(_onTextChanged);
      if (_ownsController) _controller.dispose();
      _initController();
    }
    if (oldWidget.searchFocusNode != widget.searchFocusNode) {
      if (_ownsFocusNode) _focusNode.dispose();
      _initFocusNode();
    }

    if (widget.currentIndex != GlassBottomNav.searchPageIndex) {
      _lastNonSearchIndex = widget.currentIndex;
    }

    final wasSearch = oldWidget.currentIndex == GlassBottomNav.searchPageIndex;
    if (!wasSearch && _isSearchActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _isSearchActive) {
          _focusNode.requestFocus();
        }
      });
    } else if (wasSearch && !_isSearchActive) {
      _focusNode.unfocus();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (_ownsController) _controller.dispose();
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  void _handleClearText() {
    _controller.clear();
    widget.onSearchChanged?.call('');
    _focusNode.requestFocus();
  }

  void _handleCloseSearch() {
    _focusNode.unfocus();
    _controller.clear();
    widget.onSearchChanged?.call('');
    widget.onDestinationSelected(_lastNonSearchIndex);
  }

  Widget _buildNavSwitcher(BuildContext context, GlassTokens tokens) {
    final barHeight = widget.inlineInAppBar
        ? (44.0 * tokens.scale).clamp(40.0, 48.0)
        : tokens.capsuleHeight;
    final searchOrbSize = widget.inlineInAppBar
        ? (44.0 * tokens.scale).clamp(40.0, 48.0)
        : tokens.searchDiameter;
    final iconSz = widget.inlineInAppBar
        ? (20.0 * tokens.scale).clamp(18.0, 22.0)
        : tokens.iconSize;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
      child: _isSearchActive
          ? GlassKeyboardSearchBar(
              key: const ValueKey('keyboard-top-search-bar'),
              controller: _controller,
              focusNode: _focusNode,
              hintText: widget.searchHintText,
              onChanged: widget.onSearchChanged,
              onSubmitted: widget.onSearchSubmitted,
              onClearText: _handleClearText,
              onMicTap: widget.onMicTap,
              onCloseSearch: _handleCloseSearch,
            )
          : GlassTabBar.bottom(
              key: const ValueKey('bottom-tab-bar'),
              selectedIndex: _capsuleSelectedIndex,
              showIndicator: true,
              onTabSelected: (index) {
                widget.onDestinationSelected(
                  GlassBottomNav.mainPageIndexes[index],
                );
              },
              selectedIconColor: tokens.selectedIcon,
              unselectedIconColor: tokens.idleIcon,
              indicatorColor: tokens.selectionPill,
              indicatorSettings:
                  AppLiquidGlass.indicatorSettings(isDark: tokens.isDark),
              iconSize: iconSz,
              barHeight: barHeight,
              spacing: tokens.capsuleSearchGap,
              horizontalPadding: 14 * tokens.scale,
              verticalPadding: 4 * tokens.scale,
              quality: AppLiquidGlass.effectiveQuality,
              settings: tokens.isDark ? AppLiquidGlass.darkChrome : null,
              tabs: const [
                GlassTab(
                  icon: Icon(CupertinoIcons.house),
                  activeIcon: Icon(CupertinoIcons.house_fill),
                  semanticLabel: 'Home',
                ),
                GlassTab(
                  icon: NavStoreIcon(),
                  activeIcon: NavStoreIcon(filled: true),
                  semanticLabel: 'Store',
                ),
                GlassTab(
                  icon: NavConnectIcon(),
                  activeIcon: NavConnectIcon(filled: true),
                  semanticLabel: 'Connect',
                ),
                GlassTab(
                  icon: NavSettingsIcon(),
                  activeIcon: NavSettingsIcon(filled: true),
                  semanticLabel: 'Settings',
                ),
              ],
              extraButton: GlassTabBarExtraButton(
                icon: Icon(
                  CupertinoIcons.search,
                  size: iconSz + 2,
                ),
                label: 'Search',
                size: searchOrbSize,
                iconColor: tokens.idleIcon,
                onTap: () => widget.onDestinationSelected(
                  GlassBottomNav.searchPageIndex,
                ),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = GlassTokens.of(context);

    if (widget.inlineInAppBar) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: _isSearchActive ? 420.0 : 340.0,
        ),
        child: _buildNavSwitcher(context, tokens),
      );
    }

    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final isKeyboardVisible = keyboardInset > 0;
    final bottomGap = isKeyboardVisible
        ? keyboardInset + (8 * tokens.scale)
        : tokens.barBottomInset;

    return SafeArea(
      top: false,
      bottom: !isKeyboardVisible,
      minimum: EdgeInsets.only(
        bottom: isKeyboardVisible ? 0 : tokens.barBottomInset,
      ),
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.fromLTRB(
          tokens.barSideInset,
          0,
          tokens.barSideInset,
          bottomGap,
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: 1.0,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: tokens.maxBarWidth),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: _buildNavSwitcher(context, tokens),
            ),
          ),
        ),
      ),
    );
  }
}
