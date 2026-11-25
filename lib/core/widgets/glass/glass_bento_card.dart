import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:material_ui/material_ui.dart';

import '../../theme/glass_tokens.dart';

/// Adaptive Liquid Glass Bento card container with `.shell-frame` animated
/// neon border (`2.2s ease-in-out` from `dev.istuhin/app/globals.css`),
/// hover/focus highlight, and accessible tap interaction.
///
/// The border animates smoothly on mount and on every hover, focus, or press
/// transition without running an unbounded infinite ticker that would block
/// `WidgetTester.pumpAndSettle()` in widget tests.
class GlassBentoCard extends StatefulWidget {
  const GlassBentoCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.accentColor,
    this.borderRadius,
    this.semanticLabel,
    this.animateBorder = true,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? accentColor;
  final double? borderRadius;
  final String? semanticLabel;
  final bool animateBorder;

  @override
  State<GlassBentoCard> createState() => _GlassBentoCardState();
}

class _GlassBentoCardState extends State<GlassBentoCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isFocused = false;
  bool _isPressed = false;
  late final AnimationController _borderController;
  late final Animation<double> _borderPulse;

  @override
  void initState() {
    super.initState();
    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _borderPulse = CurvedAnimation(
      parent: _borderController,
      curve: Curves.easeOutCubic,
    );
    if (widget.animateBorder) {
      _borderController.forward();
    } else {
      _borderController.value = 1.0;
    }
  }

  void _triggerBorderPulse() {
    if (!mounted ||
        !widget.animateBorder ||
        MediaQuery.disableAnimationsOf(context)) {
      return;
    }
    _borderController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _borderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = GlassTokens.of(context);
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final isInteractive = widget.onTap != null;
    final highlighted = _isHovered || _isFocused || _isPressed;
    final radius = widget.borderRadius ?? (18 * tokens.scale);

    final fill = tokens.isDark
        ? (highlighted ? const Color(0x1CFFFFFF) : const Color(0x10FFFFFF))
        : (highlighted ? const Color(0xE0FFFFFF) : const Color(0xC8FFFFFF));

    final baseAccent = widget.accentColor ?? tokens.neonAccent;

    return AnimatedBuilder(
      animation: _borderPulse,
      builder: (context, child) {
        final t = disableAnimations ? 1.0 : _borderPulse.value;
        // Pulses through a peak glow (`sin(t * pi)`) and settles at the resting
        // `.shell-frame` border intensity (or elevated intensity when hovered/focused).
        final pulseWave = (t < 1.0) ? (4.0 * t * (1.0 - t)) : 0.0;
        final restingAlpha = highlighted
            ? (tokens.isDark ? 0.72 : 0.60)
            : (tokens.isDark ? 0.26 : 0.24);
        final peakBoost = tokens.isDark ? 0.26 : 0.22;
        final rimAlpha =
            (restingAlpha + (peakBoost * pulseWave)).clamp(0.14, 0.90);
        final rimColor = baseAccent.withValues(alpha: rimAlpha);

        return AnimatedContainer(
          duration: disableAnimations
              ? Duration.zero
              : const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          padding: widget.padding ?? EdgeInsets.all(16 * tokens.scale),
          decoration: ShapeDecoration(
            color: fill,
            shape: LiquidRoundedSuperellipse(
              borderRadius: radius,
              side: BorderSide(
                color: rimColor,
                width: highlighted ? tokens.rimWidth * 1.35 : tokens.rimWidth,
              ),
            ),
          ),
          child: child,
        );
      },
      child: _buildInteractiveChild(isInteractive),
    );
  }

  Widget _buildInteractiveChild(bool isInteractive) {
    return MouseRegion(
      cursor: isInteractive ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) {
        setState(() => _isHovered = true);
        _triggerBorderPulse();
      },
      onExit: (_) => setState(() => _isHovered = false),
      child: !isInteractive
          ? widget.child
          : Semantics(
              button: true,
              label: widget.semanticLabel,
              child: FocusableActionDetector(
                mouseCursor: SystemMouseCursors.click,
                onShowFocusHighlight: (v) {
                  setState(() => _isFocused = v);
                  if (v) _triggerBorderPulse();
                },
                actions: <Type, Action<Intent>>{
                  ActivateIntent: CallbackAction<ActivateIntent>(
                    onInvoke: (_) {
                      _triggerBorderPulse();
                      widget.onTap?.call();
                      return null;
                    },
                  ),
                },
                child: GestureDetector(
                  onTap: () {
                    _triggerBorderPulse();
                    widget.onTap?.call();
                  },
                  onTapDown: (_) {
                    setState(() => _isPressed = true);
                    _triggerBorderPulse();
                  },
                  onTapUp: (_) => setState(() => _isPressed = false),
                  onTapCancel: () => setState(() => _isPressed = false),
                  behavior: HitTestBehavior.opaque,
                  child: widget.child,
                ),
              ),
            ),
    );
  }
}
