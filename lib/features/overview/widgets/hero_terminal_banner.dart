import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/glass/glass_kit.dart';
import '../../terminal_lab/terminal_controller.dart';
import '../../terminal_lab/widgets/interactive_zsh_terminal.dart';

/// Concise `istuhin.dev` Hero section matching `dev.istuhin/components/home/HeroSectionContainer.tsx`:
/// - Left column (7/12 on desktop, stacked on mobile/tablet):
///   - `<p> This is </p>`
///   - `<h1> isTuhin.dev ▊ </h1>` with character-by-character typewriter animation,
///     breathing `.dev` suffix pulse, and blinking neon-green cursor block
///   - `<p> lovestack software developer </p>`
/// - Right column (5/12 on desktop, stacked on mobile/tablet):
///   - Interactive macOS `-zsh` terminal (`isTuhin.dev — ~ — -zsh`) when [PortfolioConfig.terminalEnabled] is true.
class HeroTerminalBanner extends StatelessWidget {
  const HeroTerminalBanner({
    super.key,
    required this.terminalController,
    this.config = PortfolioConfig.istuhinDev,
  });

  final TerminalController terminalController;
  final PortfolioConfig config;

  @override
  Widget build(BuildContext context) {
    final tokens = GlassTokens.of(context);
    final introBlock = _HeroCodeIdentityBlock(config: config);
    final terminalBlock = config.terminalEnabled
        ? InteractiveZshTerminal(
            controller: terminalController,
            windowTitle: '${config.brand} — ~ — -zsh',
            promptLabel: config.brand,
            showQuickCommandPills: false,
            maxOutputHeight: 240,
          )
        : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSideBySide =
            constraints.maxWidth >= 760 && terminalBlock != null;
        if (!isSideBySide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              introBlock,
              if (terminalBlock != null) ...[
                SizedBox(height: 18 * tokens.scale),
                terminalBlock,
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 7,
              child: introBlock,
            ),
            SizedBox(width: 28 * tokens.scale),
            Expanded(
              flex: 5,
              child: terminalBlock,
            ),
          ],
        );
      },
    );
  }
}

class _HeroCodeIdentityBlock extends StatefulWidget {
  const _HeroCodeIdentityBlock({required this.config});

  final PortfolioConfig config;

  @override
  State<_HeroCodeIdentityBlock> createState() => _HeroCodeIdentityBlockState();
}

class _HeroCodeIdentityBlockState extends State<_HeroCodeIdentityBlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool get _isTestEnvironment =>
      WidgetsBinding.instance.runtimeType.toString().contains('Test');

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed &&
          mounted &&
          !_isTestEnvironment) {
        // Loop the post-typing phase (0.50 -> 1.00) so `.dev` breathes and
        // the neon cursor blinks continuously in production runtime.
        _controller.repeat(
          min: 0.50,
          max: 1.0,
          period: const Duration(milliseconds: 2000),
        );
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _sliceTyped(String full, double t, double start, double end) {
    if (full.isEmpty || t >= end) return full;
    if (t <= start) return '';
    final progress = ((t - start) / (end - start)).clamp(0.0, 1.0);
    final count = (progress * full.length).ceil().clamp(0, full.length);
    return full.substring(0, count);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = GlassTokens.of(context);
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final neon = tokens.neonAccent;
    final fg = tokens.activeIcon;
    final tagStyle = TextStyle(
      color: neon.withValues(alpha: 0.9),
      fontSize: 12.5 * tokens.scale,
      fontWeight: FontWeight.w500,
      fontFamily: GlassTokens.fontMain,
      decoration: TextDecoration.none,
    );
    final headlineFontSize = tokens.isExpanded
        ? 44 * tokens.scale
        : tokens.isMedium
            ? 36 * tokens.scale
            : 28 * tokens.scale;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = disableAnimations ? 1.0 : _controller.value;

        // Staggered typewriter progression matching HeroSectionContainer.tsx:
        // 1. brandPrefix ("is")  : 0.06 -> 0.18
        // 2. brandName ("Tuhin") : 0.18 -> 0.36
        // 3. brandSuffix (".dev"): 0.36 -> 0.50
        final prefixText =
            _sliceTyped(widget.config.brandPrefix, t, 0.06, 0.18);
        final nameText = _sliceTyped(widget.config.brandName, t, 0.18, 0.36);
        final suffixText =
            _sliceTyped(widget.config.brandSuffix, t, 0.36, 0.50);

        // Once typing completes (t >= 0.50), `.dev` gently pulses its opacity
        // (1 -> 0.15 -> 1) and the cursor block blinks at 2x frequency.
        final postTypingPhase =
            t > 0.50 ? ((t - 0.50) / 0.50).clamp(0.0, 1.0) : 0.0;
        final suffixOpacity = (t <= 0.50 || t >= 0.99 || disableAnimations)
            ? 1.0
            : (0.55 + 0.45 * math.cos(postTypingPhase * 2 * math.pi))
                .clamp(0.15, 1.0);
        final cursorOpacity = (t >= 0.99 || disableAnimations)
            ? 1.0
            : (0.5 + 0.5 * math.sin(t * 6 * math.pi)).clamp(0.1, 1.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // <p> This is </p>
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6 * tokens.scale,
              children: [
                Text('<p>', style: tagStyle),
                Text(
                  widget.config.tagline,
                  style: TextStyle(
                    color: fg,
                    fontSize: 15 * tokens.scale,
                    fontWeight: FontWeight.w500,
                    fontFamily: GlassTokens.fontMain,
                    decoration: TextDecoration.none,
                  ),
                ),
                Text('</p>', style: tagStyle),
              ],
            ),
            SizedBox(height: 10 * tokens.scale),
            // <h1> isTuhin.dev ▊ </h1>
            Text('<h1>', style: tagStyle),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 10 * tokens.scale,
                vertical: 4 * tokens.scale,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: headlineFontSize,
                            fontWeight: FontWeight.w800,
                            fontFamily: GlassTokens.fontMain,
                            height: 1.15,
                            letterSpacing: -0.8,
                          ),
                          children: [
                            TextSpan(
                              text: prefixText,
                              style: TextStyle(color: neon),
                            ),
                            TextSpan(
                              text: nameText,
                              style: TextStyle(color: fg),
                            ),
                            TextSpan(
                              text: suffixText,
                              style: TextStyle(
                                color: neon.withValues(alpha: suffixOpacity),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8 * tokens.scale),
                  Opacity(
                    opacity: cursorOpacity,
                    child: Container(
                      width: 10 * tokens.scale,
                      height: headlineFontSize * 0.78,
                      decoration: BoxDecoration(
                        color: neon,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text('</h1>', style: tagStyle),
            SizedBox(height: 10 * tokens.scale),
            // <p> lovestack software developer </p>
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6 * tokens.scale,
              runSpacing: 4 * tokens.scale,
              children: [
                Text('<p>', style: tagStyle),
                Text(
                  widget.config.role,
                  style: TextStyle(
                    color: fg,
                    fontSize: (tokens.isExpanded ? 17.5 : 14.5) * tokens.scale,
                    fontWeight: FontWeight.w700,
                    fontFamily: GlassTokens.fontMain,
                    letterSpacing: 0.2,
                    decoration: TextDecoration.none,
                  ),
                ),
                Text('</p>', style: tagStyle),
              ],
            ),
          ],
        );
      },
    );
  }
}
