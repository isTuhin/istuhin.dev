import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoIcons;
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:material_ui/material_ui.dart';

import '../../theme/glass_tokens.dart';
import 'glass_responsive_body.dart';

/// Compact, responsive iOS 26 top navigation bar aligned with
/// [GlassResponsiveBody] across phones, foldables, tablets, and desktops.
class GlassPageAppBar extends StatelessWidget {
  const GlassPageAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.showBackButton = true,
    this.actions,
  });

  final String title;
  final VoidCallback? onBack;
  final bool showBackButton;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final tokens = GlassTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    final horizontalPad = tokens.pageHorizontalPadding;

    return GlassResponsiveBody(
      child: GlassAppBar(
        backgroundColor: const Color(0x00000000),
        toolbarHeight: tokens.appBarHeight,
        padding: EdgeInsets.symmetric(horizontal: horizontalPad),
        leading: showBackButton
            ? GlassIconButton(
                useOwnLayer: true,
                size: tokens.appBarButtonSize,
                semanticLabel: 'Back',
                icon: Icon(
                  CupertinoIcons.back,
                  color: tokens.activeIcon,
                  size: tokens.appBarIconSize,
                ),
                onPressed: () {
                  if (onBack != null) {
                    onBack!();
                  } else {
                    Navigator.of(context).maybePop();
                  }
                },
              )
            : null,
        title: Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            color: tokens.activeIcon,
            fontSize: tokens.appBarTitleSize,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            decoration: TextDecoration.none,
          ),
        ),
        actions: actions,
      ),
    );
  }
}
