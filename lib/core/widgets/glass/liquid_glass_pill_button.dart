import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:material_ui/material_ui.dart';

import '../../theme/glass_tokens.dart';
import '../../theme/liquid_glass_chrome.dart';

/// Reusable Liquid Glass stadium pill button matching `.liquid-glass` in
/// `dev.istuhin/app/globals.css` & `ContactForm.tsx` / `OpenSourceSection.tsx`:
/// - Uses [AdaptiveLiquidGlassLayer] + [LiquidRoundedSuperellipse] for genuine
///   Liquid Glass refraction and specular rim
/// - Smooth hover & press neon-green border and text transition
/// - Supports disabled / pending states (`"Sending…"`).
class LiquidGlassPillButton extends StatefulWidget {
  const LiquidGlassPillButton({
    super.key,
    required this.label,
    this.onTap,
    this.isActive = false,
    this.isDisabled = false,
    this.leading,
    this.padding,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isActive;
  final bool isDisabled;
  final Widget? leading;
  final EdgeInsetsGeometry? padding;

  @override
  State<LiquidGlassPillButton> createState() => _LiquidGlassPillButtonState();
}

class _LiquidGlassPillButtonState extends State<LiquidGlassPillButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final tokens = GlassTokens.of(context);
    final highlighted = !widget.isDisabled && (widget.isActive || _isHovered);
    final textColor = highlighted ? tokens.neonAccent : tokens.activeIcon;

    return Semantics(
      button: true,
      enabled: !widget.isDisabled,
      label: widget.label,
      child: MouseRegion(
        cursor: widget.isDisabled
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedOpacity(
          opacity: widget.isDisabled ? 0.5 : 1.0,
          duration: const Duration(milliseconds: 180),
          child: GlassButton.custom(
            useOwnLayer: true,
            quality: AppLiquidGlass.effectiveQuality,
            settings: tokens.isDark ? AppLiquidGlass.darkChrome : null,
            shape: const LiquidRoundedSuperellipse(borderRadius: 999),
            enabled: !widget.isDisabled,
            label: widget.label,
            glowColor: highlighted
                ? tokens.neonAccent.withValues(alpha: 0.24)
                : null,
            onTap: widget.onTap ?? () {},
            child: Padding(
              padding: widget.padding ??
                  EdgeInsets.symmetric(
                    horizontal: 22 * tokens.scale,
                    vertical: 12 * tokens.scale,
                  ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.leading != null) ...[
                    widget.leading!,
                    SizedBox(width: 8 * tokens.scale),
                  ],
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12 * tokens.scale,
                      fontWeight: FontWeight.w600,
                      fontFamily: GlassTokens.fontMain,
                      height: 1.1,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
