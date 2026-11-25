import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:material_ui/material_ui.dart';

import '../../theme/glass_tokens.dart';
import '../../theme/liquid_glass_chrome.dart';
import '../nav_glyphs.dart';

/// Reusable iOS 26 Liquid Glass slider row with leading icon, label,
/// green active track, and optional discrete tick dots below the track.
///
/// Works both as a controlled widget (when [value] and [onChanged] are provided)
/// and as a self-contained interactive example when omitted.
class GlassSliderRow extends StatefulWidget {
  const GlassSliderRow({
    super.key,
    this.label = 'Example Slider',
    this.leading = const NavTextSizeIcon(),
    this.value,
    this.initialValue = 0.5,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions = 10,
    this.showTicks = true,
    this.showTopDivider = true,
    this.showBottomDivider = true,
    this.onChanged,
  });

  final String label;
  final Widget? leading;
  final double? value;
  final double initialValue;
  final double min;
  final double max;
  final int? divisions;
  final bool showTicks;
  final bool showTopDivider;
  final bool showBottomDivider;
  final ValueChanged<double>? onChanged;

  @override
  State<GlassSliderRow> createState() => _GlassSliderRowState();
}

class _GlassSliderRowState extends State<GlassSliderRow> {
  static const double _thumbRadius = 14.0;
  static const double _trackHeight = 6.0;

  late double _internalValue =
      widget.initialValue.clamp(widget.min, widget.max);

  double get _effectiveValue =>
      (widget.value ?? _internalValue).clamp(widget.min, widget.max);

  void _handleChanged(double next) {
    if (widget.value == null) {
      setState(() => _internalValue = next);
    }
    widget.onChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = GlassTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    final dividerColor = tokens.fieldRim.withValues(
      alpha: tokens.isDark ? 0.22 : 0.14,
    );
    final tickColor = tokens.inactiveIcon.withValues(
      alpha: tokens.isDark ? 0.38 : 0.30,
    );
    final inactiveTrackColor = tokens.isDark
        ? const Color(0x38FFFFFF)
        : const Color(0x1F000000);
    final divisions = widget.divisions;

    return Column(
      crossAxisAlignment: .stretch,
      children: [
        if (widget.showTopDivider)
          Divider(height: 1, thickness: 0.6, color: dividerColor),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10 * tokens.scale),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.leading != null) ...[
                widget.leading!,
                SizedBox(width: 12 * tokens.scale),
              ],
              Text(
                widget.label,
                style: textTheme.titleMedium?.copyWith(
                  color: tokens.activeIcon,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none,
                ),
              ),
              SizedBox(width: 16 * tokens.scale),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GlassSlider(
                      useOwnLayer: true,
                      quality: AppLiquidGlass.effectiveQuality,
                      label: widget.label,
                      value: _effectiveValue,
                      min: widget.min,
                      max: widget.max,
                      divisions: divisions,
                      trackHeight: _trackHeight,
                      thumbRadius: _thumbRadius,
                      activeColor: tokens.selectedIcon,
                      inactiveColor: inactiveTrackColor,
                      onChanged: _handleChanged,
                    ),
                    if (widget.showTicks && divisions != null && divisions > 0)
                      Transform.translate(
                        offset: const Offset(0, -8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: _thumbRadius,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List<Widget>.generate(
                              divisions + 1,
                              (_) => Container(
                                width: 3.5,
                                height: 3.5,
                                decoration: BoxDecoration(
                                  color: tickColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (widget.showBottomDivider)
          Divider(height: 1, thickness: 0.6, color: dividerColor),
      ],
    );
  }
}
