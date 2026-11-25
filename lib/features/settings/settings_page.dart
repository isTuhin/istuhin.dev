import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/glass_tokens.dart';
import '../../core/widgets/appearance_mode_control.dart';
import '../../core/widgets/glass/glass_page_app_bar.dart';
import '../../core/widgets/glass/glass_responsive_body.dart';
import '../../core/widgets/glass/glass_section_header.dart';
import '../../core/widgets/glass/glass_slider_row.dart';
import '../../core/widgets/glass/glass_switch_row.dart';

/// Matches [pubspec.yaml] version — update when releasing.
const _appVersion = '1.0.0';

/// App settings — Appearance is interactive; reusable example controls included.
class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    this.onBack,
  });

  /// Called when the leading back button is pressed inside a tab shell.
  /// Falls back to [Navigator.maybePop] when null.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final tokens = GlassTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    final horizontalPad = tokens.pageHorizontalPadding;

    return ColoredBox(
      color: tokens.scaffoldBackground,
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            GlassPageAppBar(
              title: 'Settings',
              onBack: onBack,
            ),
            Expanded(
              child: GlassResponsiveBody(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPad,
                    12 * tokens.scale,
                    horizontalPad,
                    120 * tokens.scale,
                  ),
                  children: [
                    const GlassSectionHeader(label: 'Appearance'),
                    SizedBox(height: 10 * tokens.scale),
                    Text(
                      'Theme',
                      style: textTheme.bodyMedium?.copyWith(
                        color: tokens.inactiveIcon,
                      ),
                    ),
                    SizedBox(height: 8 * tokens.scale),
                    const AppearanceModeControl(),
                    SizedBox(height: 18 * tokens.scale),
                    const GlassSliderRow(label: 'Example Slider'),
                    const GlassSwitchRow(label: 'Example Button'),
                    SizedBox(height: 28 * tokens.scale),
                    const GlassSectionHeader(label: 'About'),
                    SizedBox(height: 10 * tokens.scale),
                    GlassGroupedSection(
                      margin: EdgeInsets.zero,
                      surfaceStyle: GlassSurfaceStyle.solid,
                      children: [
                        GlassListTile(
                          title: Text(
                            'App version',
                            style: textTheme.bodyLarge?.copyWith(
                              color: tokens.activeIcon,
                            ),
                          ),
                          trailing: Text(
                            _appVersion,
                            style: textTheme.bodyLarge?.copyWith(
                              color: tokens.inactiveIcon,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
