import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoIcons;
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:material_ui/material_ui.dart';

import '../../theme/glass_tokens.dart';
import '../../theme/liquid_glass_chrome.dart';

/// Maximum characters allowed in search and single-line inputs for safety.
const int kMaxSearchQueryLength = 120;

/// Strips non-printable control characters from user input.
final TextInputFormatter kControlCharFilter = FilteringTextInputFormatter.deny(
  RegExp(r'[\x00-\x1F\x7F]'),
);

/// Reusable iOS 26 pill search bar + circular `( ✕ )` dismiss button
/// designed to float directly above the keyboard or at the bottom of a view.
class GlassKeyboardSearchBar extends StatelessWidget {
  const GlassKeyboardSearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onClearText,
    required this.onCloseSearch,
    this.hintText = 'Search your library...',
    this.onChanged,
    this.onSubmitted,
    this.onMicTap,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback onClearText;
  final VoidCallback? onMicTap;
  final VoidCallback onCloseSearch;

  @override
  Widget build(BuildContext context) {
    final tokens = GlassTokens.of(context);
    final barHeight = tokens.searchBarHeight;
    final pillRadius = barHeight / 2;
    final hasText = controller.text.isNotEmpty;
    final glassSettings = tokens.isDark ? AppLiquidGlass.darkChrome : null;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 14 * tokens.scale,
        vertical: 5 * tokens.scale,
      ),
      child: SizedBox(
        height: barHeight,
        child: AdaptiveLiquidGlassLayer(
          quality: AppLiquidGlass.effectiveQuality,
          settings: glassSettings,
          child: Row(
            children: [
              Expanded(
                child: GlassTextField(
                  controller: controller,
                  focusNode: focusNode,
                  height: barHeight,
                  maxLength: kMaxSearchQueryLength,
                  inputFormatters: [kControlCharFilter],
                  placeholder: hintText,
                  textInputAction: TextInputAction.search,
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                  shape: LiquidRoundedSuperellipse(borderRadius: pillRadius),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16 * tokens.scale,
                  ),
                  textStyle: TextStyle(
                    color: tokens.activeIcon,
                    fontSize: 17 * tokens.scale,
                    fontWeight: FontWeight.w400,
                  ),
                  placeholderStyle: TextStyle(
                    color: tokens.inactiveIcon,
                    fontSize: 17 * tokens.scale,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Icon(
                    CupertinoIcons.search,
                    color: tokens.activeIcon,
                    size: 20 * tokens.scale,
                  ),
                  suffixIcon: Icon(
                    hasText
                        ? CupertinoIcons.clear_circled_solid
                        : CupertinoIcons.mic,
                    color: hasText ? tokens.inactiveIcon : tokens.activeIcon,
                    size: 20 * tokens.scale,
                  ),
                  suffixSemanticLabel:
                      hasText ? 'Clear search' : 'Voice search',
                  onSuffixTap: hasText ? onClearText : onMicTap,
                ),
              ),
              SizedBox(width: tokens.capsuleSearchGap),
              GlassIconButton(
                size: barHeight,
                iconSize: 22 * tokens.scale,
                shape: GlassIconButtonShape.circle,
                semanticLabel: 'Close search',
                icon: Icon(
                  CupertinoIcons.xmark,
                  color: tokens.activeIcon,
                  size: 22 * tokens.scale,
                ),
                onPressed: onCloseSearch,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
