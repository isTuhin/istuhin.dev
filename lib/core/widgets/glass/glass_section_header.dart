import 'package:material_ui/material_ui.dart';

import '../../theme/glass_tokens.dart';

/// Reusable section title header for grouped settings and feature screens.
/// Supports optional monospace [eyebrow] label and neon horizontal rule matching `istuhin.dev`.
class GlassSectionHeader extends StatelessWidget {
  const GlassSectionHeader({
    super.key,
    required this.label,
    this.eyebrow,
    this.showAccentRule = false,
    this.trailing,
  });

  final String label;
  final String? eyebrow;
  final bool showAccentRule;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final tokens = GlassTokens.of(context);
    final textTheme = Theme.of(context).textTheme;

    final titleText = Text(
      label,
      style: (eyebrow != null ? textTheme.headlineSmall : textTheme.titleMedium)
          ?.copyWith(
        color: tokens.activeIcon,
        fontWeight: eyebrow != null ? FontWeight.w800 : FontWeight.w600,
        fontFamily: GlassTokens.fontMain,
        letterSpacing: eyebrow != null ? -0.4 : null,
      ),
    );

    final Widget titleRow = Row(
      children: [
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                (eyebrow != null ? textTheme.headlineSmall : textTheme.titleMedium)
                    ?.copyWith(
              color: tokens.activeIcon,
              fontWeight: eyebrow != null ? FontWeight.w800 : FontWeight.w600,
              fontFamily: GlassTokens.fontMain,
              letterSpacing: eyebrow != null ? -0.4 : null,
            ),
          ),
        ),
        if (showAccentRule) ...[
          SizedBox(width: 12 * tokens.scale),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 220 * tokens.scale),
                child: Container(
                  height: 1,
                  color: tokens.neonAccent.withValues(alpha: 0.32),
                ),
              ),
            ),
          ),
        ] else if (trailing != null)
          const Spacer(),
        if (trailing != null) ...[
          SizedBox(width: 8 * tokens.scale),
          Flexible(child: trailing!),
        ],
      ],
    );

    if (eyebrow == null && !showAccentRule && trailing == null) {
      return titleText;
    }

    if (eyebrow == null) {
      return titleRow;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow!.toUpperCase(),
          style: TextStyle(
            color: tokens.neonAccent.withValues(alpha: 0.9),
            fontSize: 11 * tokens.scale,
            fontWeight: FontWeight.w600,
            fontFamily: GlassTokens.fontMain,
            letterSpacing: 1.6,
            decoration: TextDecoration.none,
          ),
        ),
        SizedBox(height: 4 * tokens.scale),
        titleRow,
      ],
    );
  }
}
