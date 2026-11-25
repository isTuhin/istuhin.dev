import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoIcons;
import 'package:material_ui/material_ui.dart';

import '../../theme/glass_tokens.dart';
import '../../theme/terminal_palette.dart';

/// Signature `isTuhin.dev` macOS window title bar with red/yellow/green traffic
/// lights, folder glyph, and `isTuhin.dev — ~ — -zsh` title.
/// Adapts seamlessly to both Dark and Light modes (`border-b border-white/10` / `border-border`).
class MacosWindowHeader extends StatelessWidget {
  const MacosWindowHeader({
    super.key,
    this.title = 'isTuhin.dev — ~ — -zsh',
    this.trailing,
    this.onClearTap,
  });

  final String title;
  final Widget? trailing;
  final VoidCallback? onClearTap;

  @override
  Widget build(BuildContext context) {
    final tokens = GlassTokens.of(context);
    final borderColor = tokens.isDark
        ? const Color(0x1AFFFFFF)
        : const Color(0x1F1C1917);
    final titleColor = tokens.inactiveIcon;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14 * tokens.scale,
        vertical: 10 * tokens.scale,
      ),
      decoration: BoxDecoration(
        color: const Color(0x00000000),
        border: Border(
          bottom: BorderSide(
            color: borderColor,
          ),
        ),
      ),
      child: Row(
        children: [
          // macOS traffic lights (`#ff5f56`, `#ffbd2e`, `#27c93f`)
          const _TrafficLightDot(color: TerminalPalette.trafficClose),
          SizedBox(width: 6 * tokens.scale),
          const _TrafficLightDot(color: TerminalPalette.trafficMinimize),
          SizedBox(width: 6 * tokens.scale),
          const _TrafficLightDot(color: TerminalPalette.trafficZoom),
          SizedBox(width: 10 * tokens.scale),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.folder_fill,
                  size: 12.5 * tokens.scale,
                  color: const Color(0xFF38BDF8),
                ),
                SizedBox(width: 6 * tokens.scale),
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 11 * tokens.scale,
                      fontWeight: FontWeight.w500,
                      fontFamily: GlassTokens.fontShell,
                      letterSpacing: 0.3,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null)
            trailing!
          else if (onClearTap != null)
            GestureDetector(
              onTap: onClearTap,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 6 * tokens.scale,
                  vertical: 2 * tokens.scale,
                ),
                child: Text(
                  'clear',
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 11 * tokens.scale,
                    fontFamily: GlassTokens.fontShell,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            )
          else
            SizedBox(width: 36 * tokens.scale),
        ],
      ),
    );
  }
}

class _TrafficLightDot extends StatelessWidget {
  const _TrafficLightDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final scale = GlassTokens.of(context).scale;
    return Container(
      width: 11 * scale,
      height: 11 * scale,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
