import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:material_ui/material_ui.dart';

import '../../theme/glass_tokens.dart';
import '../../theme/liquid_glass_chrome.dart';
import '../nav_glyphs.dart';

/// Reusable iOS 26 Liquid Glass toggle switch row with leading icon, label,
/// and brand green active state.
///
/// Works both as a controlled widget (when [value] and [onChanged] are provided)
/// and as a self-contained interactive example when omitted.
class GlassSwitchRow extends StatefulWidget {
  const GlassSwitchRow({
    super.key,
    this.label = 'Example Button',
    this.leading = const NavReduceMotionIcon(),
    this.value,
    this.initialValue = false,
    this.showTopDivider = false,
    this.showBottomDivider = true,
    this.onChanged,
  });

  final String label;
  final Widget? leading;
  final bool? value;
  final bool initialValue;
  final bool showTopDivider;
  final bool showBottomDivider;
  final ValueChanged<bool>? onChanged;

  @override
  State<GlassSwitchRow> createState() => _GlassSwitchRowState();
}

class _GlassSwitchRowState extends State<GlassSwitchRow> {
  late bool _internalValue = widget.initialValue;

  bool get _effectiveValue => widget.value ?? _internalValue;

  void _handleChanged(bool next) {
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
    final inactiveTrackColor = tokens.isDark
        ? const Color(0x38FFFFFF)
        : const Color(0x1F000000);

    return Column(
      crossAxisAlignment: .stretch,
      children: [
        if (widget.showTopDivider)
          Divider(height: 1, thickness: 0.6, color: dividerColor),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12 * tokens.scale),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.leading != null) ...[
                widget.leading!,
                SizedBox(width: 12 * tokens.scale),
              ],
              Expanded(
                child: Text(
                  widget.label,
                  style: textTheme.titleMedium?.copyWith(
                    color: tokens.activeIcon,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              SizedBox(width: 16 * tokens.scale),
              GlassSwitch(
                useOwnLayer: true,
                quality: AppLiquidGlass.effectiveQuality,
                semanticLabel: widget.label,
                value: _effectiveValue,
                activeColor: tokens.selectedIcon,
                inactiveColor: inactiveTrackColor,
                onChanged: _handleChanged,
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
