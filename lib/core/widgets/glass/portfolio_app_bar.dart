import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:material_ui/material_ui.dart';

import '../../config/portfolio_config.dart';
import '../../theme/glass_tokens.dart';
import '../../theme/liquid_glass_chrome.dart';
import 'portfolio_brand_logo.dart';

/// Scroll offset threshold (in logical pixels) at which [PortfolioAppBar]
/// transitions into its compact `.header-scrolled` state (`window.scrollY > 20`).
const double kPortfolioAppBarScrollThreshold = 20.0;

/// Primary Liquid Glass portfolio header featuring the responsive `isTuhin`
/// Moirai One vector brand mark on the left and, on desktop viewports, the
/// aligned navigation bar controls on the right.
class PortfolioAppBar extends StatefulWidget {
  const PortfolioAppBar({
    super.key,
    this.config = PortfolioConfig.istuhinDev,
    this.isScrolled = false,
    this.onBrandTap,
    this.trailingNav,
  });

  final PortfolioConfig config;
  final bool isScrolled;
  final VoidCallback? onBrandTap;
  final Widget? trailingNav;

  @override
  State<PortfolioAppBar> createState() => _PortfolioAppBarState();
}

class _PortfolioAppBarState extends State<PortfolioAppBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _opacityAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _opacityAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutCubic,
      ),
    );
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  void _handleBrandTap() {
    widget.onBrandTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = GlassTokens.of(context);
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final targetHeight = widget.isScrolled
        ? tokens.portfolioBarScrolledHeight
        : tokens.portfolioBarHeight;

    final Widget bar = Semantics(
      container: true,
      header: true,
      label: 'Primary navigation',
      child: AdaptiveLiquidGlassLayer(
        quality: AppLiquidGlass.effectiveQuality,
        settings: tokens.isDark ? AppLiquidGlass.darkChrome : null,
        child: AnimatedContainer(
          duration: disableAnimations
              ? Duration.zero
              : const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: tokens.headerBackground,
            border: Border(
              bottom: BorderSide(
                color: tokens.headerBorder,
                width: tokens.rimWidth,
              ),
            ),
            boxShadow: widget.isScrolled
                ? <BoxShadow>[
                    BoxShadow(
                      color: tokens.headerShadowColor,
                      blurRadius: tokens.isDark ? 8.0 : 6.0,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : const <BoxShadow>[],
          ),
          child: SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: 1.0,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: tokens.portfolioMaxWidth,
                ),
                child: AnimatedContainer(
                  duration: disableAnimations
                      ? Duration.zero
                      : const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  height: targetHeight,
                  padding: EdgeInsets.symmetric(
                    horizontal: tokens.portfolioHorizontalPadding,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PortfolioBrandLogo(
                        label: widget.config.brandLogoLabel,
                        onTap: _handleBrandTap,
                      ),
                      if (widget.trailingNav != null)
                        Flexible(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: widget.trailingNav!,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (disableAnimations) {
      return bar;
    }

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: bar,
      ),
    );
  }
}
