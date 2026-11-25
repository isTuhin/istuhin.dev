import 'package:material_ui/material_ui.dart';

import '../../theme/glass_tokens.dart';

/// Pill-shaped Liquid Glass badge for tech stack tags, CLI commands, and status indicators.
class GlassTagChip extends StatefulWidget {
  const GlassTagChip({
    super.key,
    required this.label,
    this.accentColor,
    this.leadingDotColor,
    this.isMonospace = false,
    this.onTap,
    this.semanticLabel,
  });

  final String label;
  final Color? accentColor;
  final Color? leadingDotColor;
  final bool isMonospace;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  State<GlassTagChip> createState() => _GlassTagChipState();
}

class _GlassTagChipState extends State<GlassTagChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final tokens = GlassTokens.of(context);
    final isInteractive = widget.onTap != null;
    final highlighted = isInteractive && _isHovered;
    final effectiveAccent = widget.accentColor ?? tokens.selectedIcon;

    final bgColor = widget.accentColor != null
        ? effectiveAccent.withValues(
            alpha: highlighted
                ? (tokens.isDark ? 0.26 : 0.20)
                : (tokens.isDark ? 0.16 : 0.12),
          )
        : (tokens.isDark
            ? (highlighted
                ? const Color(0x30FFFFFF)
                : const Color(0x1FFFFFFF))
            : (highlighted
                ? const Color(0x1F000000)
                : const Color(0x12000000)));
    final borderColor = widget.accentColor != null
        ? effectiveAccent.withValues(
            alpha: highlighted
                ? (tokens.isDark ? 0.70 : 0.50)
                : (tokens.isDark ? 0.45 : 0.32),
          )
        : (tokens.isDark
            ? const Color(0x2EFFFFFF)
            : const Color(0x1F000000));
    final textColor = widget.accentColor != null
        ? (tokens.isDark ? effectiveAccent : tokens.activeIcon)
        : tokens.activeIcon;

    final pill = Container(
      padding: EdgeInsets.symmetric(
        horizontal: 11 * tokens.scale,
        vertical: 6 * tokens.scale,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.leadingDotColor != null) ...[
            Container(
              width: 7 * tokens.scale,
              height: 7 * tokens.scale,
              decoration: BoxDecoration(
                color: widget.leadingDotColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 6 * tokens.scale),
          ],
          Flexible(
            child: Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontSize: 12 * tokens.scale,
                fontWeight: FontWeight.w600,
                fontFamily: GlassTokens.fontMain,
                height: 1.15,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );

    if (!isInteractive) return pill;

    return Semantics(
      button: true,
      label: widget.semanticLabel ?? widget.label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: pill,
        ),
      ),
    );
  }
}
