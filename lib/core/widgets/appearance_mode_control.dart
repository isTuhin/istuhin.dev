import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/glass_tokens.dart';
import '../theme/liquid_glass_chrome.dart';
import '../theme/theme_mode_preference.dart';
import '../theme/theme_scope.dart';

/// iOS 26 Liquid Glass inline capsule System / Light / Dark preference control.
///
/// Uses [GlassTabBar.inline] with [MaskingQuality.high] (`JellyClipper`) so the
/// sliding glass lens dynamically reflects brand green ([GlassTokens.selectedIcon])
/// across text and icons as the indicator moves from one segment to another,
/// matching [GlassBottomNav].
class AppearanceModeControl extends StatelessWidget {
  const AppearanceModeControl({super.key});

  static const _modes = <ThemeMode>[
    ThemeMode.system,
    ThemeMode.light,
    ThemeMode.dark,
  ];

  @override
  Widget build(BuildContext context) {
    final controller = ThemeScope.of(context);
    final tokens = GlassTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    final selected = controller.mode;
    final selectedIndex = _modes.indexOf(selected).clamp(0, _modes.length - 1);
    final resolved = tokens.isDark ? 'Dark' : 'Light';
    final hint = selected == ThemeMode.system
        ? 'Following phone appearance · $resolved'
        : 'Forced $resolved';

    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Semantics(
          label: 'Appearance',
          child: GlassTabBar.inline(
            selectedIndex: selectedIndex,
            onTabSelected: (index) => controller.setMode(_modes[index]),
            barHeight: 46 * tokens.scale,
            barBorderRadius: GlassDefaults.capsuleRadius,
            indicatorBorderRadius: GlassDefaults.capsuleRadius,
            labelFontSize: 14 * tokens.scale,
            maskingQuality: MaskingQuality.high,
            quality: AppLiquidGlass.effectiveQuality,
            settings: tokens.isDark ? AppLiquidGlass.darkChrome : null,
            indicatorColor: tokens.selectionPill,
            indicatorSettings:
                AppLiquidGlass.indicatorSettings(isDark: tokens.isDark),
            selectedIconColor: tokens.selectedIcon,
            unselectedIconColor: tokens.idleIcon,
            selectedLabelColor: tokens.selectedIcon,
            unselectedLabelColor: tokens.idleIcon,
            selectedLabelStyle: TextStyle(
              color: tokens.selectedIcon,
              fontSize: 14 * tokens.scale,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.none,
            ),
            unselectedLabelStyle: TextStyle(
              color: tokens.idleIcon,
              fontSize: 14 * tokens.scale,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.none,
            ),
            tabs: [
              for (final mode in _modes)
                GlassTab(
                  label: ThemeModePreference.label(mode),
                  semanticLabel: ThemeModePreference.label(mode),
                ),
            ],
          ),
        ),
        SizedBox(height: 8 * tokens.scale),
        Text(
          hint,
          style: textTheme.bodySmall?.copyWith(color: tokens.inactiveIcon),
        ),
      ],
    );
  }
}
