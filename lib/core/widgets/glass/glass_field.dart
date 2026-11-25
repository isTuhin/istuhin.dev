import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:material_ui/material_ui.dart';

import '../../theme/glass_tokens.dart';
import 'glass_keyboard_search_bar.dart';

/// Liquid-glass text field chrome backed by [GlassTextField].
class GlassField extends StatelessWidget {
  const GlassField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.keyboardType,
    this.obscureText = false,
    this.maxLength = kMaxSearchQueryLength,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    final tokens = GlassTokens.of(context);

    return GlassTextField(
      useOwnLayer: true,
      controller: controller,
      focusNode: focusNode,
      placeholder: hintText,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLength: maxLength,
      inputFormatters: [kControlCharFilter],
      textInputAction: textInputAction ?? TextInputAction.search,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      shape: LiquidRoundedSuperellipse(borderRadius: 18 * tokens.scale),
      padding: EdgeInsets.symmetric(
        horizontal: 16 * tokens.scale,
        vertical: 14 * tokens.scale,
      ),
      prefixIcon: prefixIcon == null
          ? null
          : Icon(
              prefixIcon,
              color: tokens.inactiveIcon,
              size: 20 * tokens.scale,
            ),
      suffixIcon: suffixIcon == null
          ? null
          : Icon(
              suffixIcon,
              color: tokens.inactiveIcon,
              size: 20 * tokens.scale,
            ),
      onSuffixTap: onSuffixTap,
    );
  }
}
