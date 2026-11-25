import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// Responsive device layout class.
enum GlassLayoutSize {
  /// Narrow & standard phones (< 600pt).
  compact,

  /// Large phones, foldables, small tablets (600–839pt).
  medium,

  /// Tablets & desktop windows (>= 840pt).
  expanded,
}

/// Chrome metrics + colors for glass surfaces across all device sizes.
///
/// Bottom bar glass comes from `liquid_glass_widgets`. This token set keeps
/// shared responsive dimensions and colors used by the shell, search bar, and pages.
final class GlassTokens {
  const GlassTokens._({
    required this.brightness,
    required this.layoutSize,
    required this.scale,
    required this.viewportWidth,
    required this.scaffoldBackground,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.idleIcon,
    required this.selectedIcon,
    required this.neonAccent,
    required this.brandLogoColor,
    required this.brandLogoGlowColor,
    required this.headerBackground,
    required this.headerBorder,
    required this.headerShadowColor,
    required this.selectionPill,
    required this.rimHighlight,
    required this.fieldFill,
    required this.fieldRim,
    required this.appBarHeight,
    required this.appBarButtonSize,
    required this.appBarIconSize,
    required this.appBarTitleSize,
    required this.portfolioMaxWidth,
    required this.portfolioBarHeight,
    required this.portfolioBarScrolledHeight,
    required this.portfolioHorizontalPadding,
    required this.brandLogoHeight,
    required this.brandLogoStrokeWidth,
    required this.capsuleHeight,
    required this.searchBarHeight,
    required this.searchDiameter,
    required this.iconSize,
    required this.capsuleSearchGap,
    required this.barSideInset,
    required this.barBottomInset,
    required this.maxBarWidth,
    required this.contentMaxWidth,
    required this.pageHorizontalPadding,
    required this.bentoGridSpacing,
    required this.rimWidth,
  });

  final Brightness brightness;
  final GlassLayoutSize layoutSize;
  final double scale;
  final double viewportWidth;

  /// Plain page fill under floating chrome.
  final Color scaffoldBackground;

  /// Strong content color (titles, field text).
  final Color activeIcon;

  /// Secondary text (subtitles, hints).
  final Color inactiveIcon;

  /// Idle tab glyph. Near-black in light, near-white in dark.
  final Color idleIcon;

  /// Selected tab glyph.
  final Color selectedIcon;

  /// Portfolio signature neon green (`#00FF99` in dark, `#047857` emerald in light).
  final Color neonAccent;

  /// Primary ink color for the `isTuhin` Moirai One vector brand logo (`#D1D5DB` dark, `#1F2328` light).
  final Color brandLogoColor;

  /// Ambient glow color behind the `isTuhin` Moirai One vector brand logo (`#00FF99` dark, `#059669` light).
  final Color brandLogoGlowColor;

  /// Translucent glass header background tint (`--header-bg` in `istuhin.dev`).
  final Color headerBackground;

  /// Hairline border for header (`--border` in `istuhin.dev`).
  final Color headerBorder;

  /// Subtle elevation shadow color when header is scrolled past threshold.
  final Color headerShadowColor;

  /// Soft stadium behind the active capsule tab (flat fill, not colorBurn).
  final Color selectionPill;

  /// Focused field rim.
  final Color rimHighlight;

  final Color fieldFill;
  final Color fieldRim;

  /// Compact top navigation bar height across device sizes.
  final double appBarHeight;

  /// Leading / trailing circular glass button diameter in the top app bar.
  final double appBarButtonSize;

  /// Leading / trailing icon size inside top app bar buttons.
  final double appBarIconSize;

  /// Inline navigation bar title font size (iOS 26 spec ~17pt).
  final double appBarTitleSize;

  /// Maximum width of the portfolio top AppBar container (`max-w-7xl` = 1280pt).
  final double portfolioMaxWidth;

  /// Unscrolled portfolio AppBar height (`h-14` / `sm:h-16` / `md:h-[4.5rem]`).
  final double portfolioBarHeight;

  /// Scrolled portfolio AppBar height (`h-14` / `sm:h-16`).
  final double portfolioBarScrolledHeight;

  /// Responsive horizontal padding inside the portfolio AppBar (`px-3` to `md:px-10`).
  final double portfolioHorizontalPadding;

  /// Responsive `isTuhin` Moirai One vector logo height across devices.
  final double brandLogoHeight;

  /// Outline stroke width in SVG coordinate units (`1.2` in dark, `1.35` in light).
  final double brandLogoStrokeWidth;

  final double capsuleHeight;
  final double searchBarHeight;
  final double searchDiameter;
  final double iconSize;
  final double capsuleSearchGap;

  /// Horizontal inset so the bar breathes on narrow phones.
  final double barSideInset;

  /// Gap above the home indicator / screen bottom.
  final double barBottomInset;

  /// Capsule + search group max width (screen-aware).
  final double maxBarWidth;

  /// Responsive max width for page content containers.
  final double contentMaxWidth;

  /// Responsive horizontal page gutter.
  final double pageHorizontalPadding;

  /// Standard gap between Bento cards across compact, medium, and expanded grids.
  final double bentoGridSpacing;

  final double rimWidth;

  /// Primary UI & monospace font family matching `dev.istuhin` (`--font-michroma`).
  static const String fontMain = 'Michroma';

  /// Narrow shell monospace font for terminal buffers (`SHELL_FONT` in `InteractiveTerminal.tsx`).
  static const String fontShell = 'monospace';

  /// Display brand font family (`--font-moirai`).
  static const String fontDisplay = 'MoiraiOne';

  bool get isDark => brightness == Brightness.dark;
  bool get isCompact => layoutSize == GlassLayoutSize.compact;
  bool get isMedium => layoutSize == GlassLayoutSize.medium;
  bool get isExpanded => layoutSize == GlassLayoutSize.expanded;

  /// Build from [Theme] + [MediaQuery] so chrome stays responsive on all devices.
  factory GlassTokens.of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1);

    final layoutSize = size.width >= 840
        ? GlassLayoutSize.expanded
        : size.width >= 600
            ? GlassLayoutSize.medium
            : GlassLayoutSize.compact;

    final widthScale = (size.shortestSide / 390).clamp(0.82, 1.18);
    final scale = (widthScale * (0.92 + (textScale * 0.08))).clamp(0.82, 1.22);

    final isDark = brightness == Brightness.dark;
    // Compact top navigation bar metrics
    final appBarHeight = (44 * scale).clamp(40.0, 50.0);
    final appBarButtonSize = (36 * scale).clamp(32.0, 40.0);
    final appBarIconSize = (18 * scale).clamp(16.0, 21.0);
    final appBarTitleSize = (17 * scale).clamp(15.5, 19.5);

    // ~49–56pt bottom bar; expanded search bar sits at ~50–54pt right above keyboard.
    final capsuleHeight = 54 * scale;
    final searchBarHeight = 50 * scale;
    final sideInset = (16 * scale).clamp(12.0, 28.0);
    final bottomInset = math.max(6.0 * scale, padding.bottom > 0 ? 2.0 : 8.0);

    final maxBarCap = switch (layoutSize) {
      GlassLayoutSize.compact => 520 * scale,
      GlassLayoutSize.medium => 580 * scale,
      GlassLayoutSize.expanded => 640 * scale,
    };
    final maxBarWidth =
        math.max(220.0, math.min(maxBarCap, size.width - sideInset * 2) - 4);

    final contentMaxWidth = switch (layoutSize) {
      GlassLayoutSize.compact => 540.0,
      GlassLayoutSize.medium => 780.0,
      GlassLayoutSize.expanded => 1120.0,
    };

    final pageHorizontalPadding = switch (layoutSize) {
      GlassLayoutSize.compact => 20 * scale,
      GlassLayoutSize.medium => 28 * scale,
      GlassLayoutSize.expanded => 36 * scale,
    };

    final bentoGridSpacing = switch (layoutSize) {
      GlassLayoutSize.compact => 12 * scale,
      GlassLayoutSize.medium => 14 * scale,
      GlassLayoutSize.expanded => 16 * scale,
    };

    final w = size.width;
    final portfolioBarHeight = w >= 768
        ? 72.0
        : w >= 640
            ? 64.0
            : 56.0;
    final portfolioBarScrolledHeight = w >= 640 ? 64.0 : 56.0;
    final portfolioHorizontalPadding = w >= 768
        ? 40.0
        : w >= 640
            ? 24.0
            : w >= 400
                ? 16.0
                : 12.0;

    final brandLogoHeight = (w >= 768
            ? 34.0
            : w >= 640
                ? 29.0
                : w >= 380
                    ? 25.0
                    : 22.0) *
        (0.92 + (scale * 0.08));

    return GlassTokens._(
      brightness: brightness,
      layoutSize: layoutSize,
      scale: scale,
      viewportWidth: w,
      scaffoldBackground:
          isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
      activeIcon: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF1C1917),
      inactiveIcon: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF78716C),
      idleIcon: isDark ? const Color(0xF0FFFFFF) : const Color(0xFF1C1917),
      selectedIcon: isDark ? const Color(0xFF69D17A) : const Color(0xFF4CAF50),
      neonAccent: isDark ? const Color(0xFF00FF99) : const Color(0xFF047857),
      brandLogoColor:
          isDark ? const Color(0xFFD1D5DB) : const Color(0xFF1F2328),
      brandLogoGlowColor:
          isDark ? const Color(0xFF00FF99) : const Color(0xFF059669),
      headerBackground:
          isDark ? const Color(0xD90A0A0C) : const Color(0xEBF7F6F3),
      headerBorder:
          isDark ? const Color(0x1AFFFFFF) : const Color(0x2E0F172A),
      headerShadowColor:
          isDark ? const Color(0x2E000000) : const Color(0x141C1917),
      selectionPill:
          isDark ? const Color(0x26FFFFFF) : const Color(0x14000000),
      rimHighlight: isDark ? const Color(0x66FFFFFF) : const Color(0xE6FFFFFF),
      fieldFill: isDark ? const Color(0x66000000) : const Color(0x99FFFFFF),
      fieldRim: isDark ? const Color(0x40FFFFFF) : const Color(0x2E000000),
      appBarHeight: appBarHeight,
      appBarButtonSize: appBarButtonSize,
      appBarIconSize: appBarIconSize,
      appBarTitleSize: appBarTitleSize,
      portfolioMaxWidth: 1280.0,
      portfolioBarHeight: portfolioBarHeight,
      portfolioBarScrolledHeight: portfolioBarScrolledHeight,
      portfolioHorizontalPadding: portfolioHorizontalPadding,
      brandLogoHeight: brandLogoHeight,
      brandLogoStrokeWidth: isDark ? 1.2 : 1.35,
      capsuleHeight: capsuleHeight,
      searchBarHeight: searchBarHeight,
      searchDiameter: capsuleHeight,
      iconSize: 25 * scale,
      capsuleSearchGap: 10 * scale,
      barSideInset: sideInset,
      barBottomInset: bottomInset,
      maxBarWidth: maxBarWidth,
      contentMaxWidth: contentMaxWidth,
      pageHorizontalPadding: pageHorizontalPadding,
      bentoGridSpacing: bentoGridSpacing,
      rimWidth: 1,
    );
  }
}
