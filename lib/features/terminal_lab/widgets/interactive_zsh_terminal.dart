import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/glass/glass_kit.dart';
import '../terminal_controller.dart';

/// Soft zsh / Powerlevel10k-style prompt palette matching
/// `PROMPT_DARK` and `PROMPT_LIGHT` in `dev.istuhin/components/terminal/InteractiveTerminal.tsx`.
@immutable
final class _TerminalPromptPalette {
  const _TerminalPromptPalette({
    required this.bracket,
    required this.host,
    required this.git,
    required this.apple,
    required this.person,
    required this.chevron,
    required this.caret,
    required this.command,
    required this.outputText,
    required this.systemText,
    required this.placeholderText,
  });

  final Color bracket;
  final Color host;
  final Color git;
  final Color apple;
  final Color person;
  final Color chevron;
  final Color caret;
  final Color command;
  final Color outputText;
  final Color systemText;
  final Color placeholderText;

  static const dark = _TerminalPromptPalette(
    bracket: Color(0xFFE05238), // Vibrant red-orange rounded rail
    host: Color(0xFF9CA3AF), // Soft slate-gray host text (`isTuhin.dev`)
    git: Color(0xFF86EFAC), // Mint green Nerd-Font git branch glyph
    apple: Color(0xFF86EFAC), // Mint green Apple logo (``)
    person: Color(0xFF86EFAC), // Mint green user avatar glyph
    chevron: Color(0xFF00E5FF), // Electric cyan prompt chevron (`❯`)
    caret: Color(0xFFD1D5DB), // Solid block/caret color
    command: Color(0xFFD8DEE9),
    outputText: Color(0xFFD1D5DB),
    systemText: Color(0xB8D1D5DB),
    placeholderText: Color(0x789CA3AF),
  );

  static const light = _TerminalPromptPalette(
    bracket: Color(0xFFDC2626),
    host: Color(0xFF334155),
    git: Color(0xFF059669),
    apple: Color(0xFF059669),
    person: Color(0xFF059669),
    chevron: Color(0xFF0284C7),
    caret: Color(0xFF1C1917),
    command: Color(0xFF1C1917),
    outputText: Color(0xFF1C1917),
    systemText: Color(0xCC334155),
    placeholderText: Color(0x8878716C),
  );

  static _TerminalPromptPalette of(bool isDark) => isDark ? dark : light;
}

/// Single flame particle for VS Code Power Mode typing fire (`TypingFire.tsx`).
final class _FireParticle {
  _FireParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.maxLife,
    required this.size,
    required this.hue,
  });

  double x;
  double y;
  double vx;
  double vy;
  double life = 0;
  final double maxLife;
  final double size;
  final double hue;
}

/// Interactive macOS `-zsh` terminal widget matching `dev.istuhin/components/terminal/InteractiveTerminal.tsx`:
/// - Pulsing neon `.shell-frame` container (via [GlassBentoCard]) that works in both Dark and Light modes
/// - Exact **Apple logo (``) SVG**, **Git branch SVG**, **User avatar SVG**, and **rounded left bracket (`╭…╰`)**
/// - **VS Code Power Mode typing fire animation (`TypingFire.tsx`)** spawning glowing flame particles at the caret on every keystroke
/// - Tap anywhere in the terminal body to focus input + Up/Down arrow command history navigation
class InteractiveZshTerminal extends StatefulWidget {
  const InteractiveZshTerminal({
    super.key,
    required this.controller,
    this.maxOutputHeight = 250,
    this.showQuickCommandPills = false,
    this.windowTitle = 'isTuhin.dev — ~ — -zsh',
    this.promptLabel = 'isTuhin.dev',
  });

  final TerminalController controller;
  final double maxOutputHeight;
  final bool showQuickCommandPills;
  final String windowTitle;
  final String promptLabel;

  @override
  State<InteractiveZshTerminal> createState() => _InteractiveZshTerminalState();
}

class _InteractiveZshTerminalState extends State<InteractiveZshTerminal>
    with SingleTickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final FocusNode _inputFocusNode;
  final GlobalKey _terminalBoxKey = GlobalKey();
  final GlobalKey _inputFieldKey = GlobalKey();

  late final AnimationController _fireTicker;
  final List<_FireParticle> _particles = <_FireParticle>[];
  final math.Random _rng = math.Random();
  String _lastInputText = '';
  int _historyIndex = -1;
  int _lastFocusRequestId = 0;

  @override
  void initState() {
    super.initState();
    _inputFocusNode = FocusNode(onKeyEvent: _handleKeyEvent);
    _lastFocusRequestId = widget.controller.focusRequestId;
    _fireTicker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_tickParticles);
    _inputController.addListener(_handleInputChanged);
    widget.controller.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant InteractiveZshTerminal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleControllerChanged);
      _lastFocusRequestId = widget.controller.focusRequestId;
      widget.controller.addListener(_handleControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    _inputController.removeListener(_handleInputChanged);
    _fireTicker.dispose();
    _inputFocusNode.dispose();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final history = widget.controller.history;
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (history.isEmpty) return KeyEventResult.handled;
      final next = math.min(_historyIndex + 1, history.length - 1);
      _historyIndex = next;
      final text = history[next];
      _lastInputText = text;
      _inputController.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      final next = _historyIndex - 1;
      if (next < 0) {
        _historyIndex = -1;
        _lastInputText = '';
        _inputController.clear();
        return KeyEventResult.handled;
      }
      _historyIndex = next;
      final text = history[next];
      _lastInputText = text;
      _inputController.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _handleInputChanged() {
    final current = _inputController.text;
    if (current != _lastInputText) {
      _lastInputText = current;
      _spawnTypingFireAtCaret(current);
    }
  }

  /// Spawns 10 VS Code Power Mode flame particles at the current caret position
  /// matching `TypingFire.tsx` in `dev.istuhin/components/terminal/TypingFire.tsx`.
  void _spawnTypingFireAtCaret(String text) {
    if (!mounted || MediaQuery.disableAnimationsOf(context)) return;

    final boxContext = _terminalBoxKey.currentContext;
    final inputContext = _inputFieldKey.currentContext;
    if (boxContext == null || inputContext == null) return;

    final terminalBox = boxContext.findRenderObject() as RenderBox?;
    final inputBox = inputContext.findRenderObject() as RenderBox?;
    if (terminalBox == null ||
        inputBox == null ||
        !terminalBox.hasSize ||
        !inputBox.hasSize) {
      return;
    }

    final tokens = GlassTokens.of(context);
    final inputOrigin =
        inputBox.localToGlobal(Offset.zero, ancestor: terminalBox);

    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 13.5 * tokens.scale,
          fontFamily: GlassTokens.fontShell,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    final caretX = inputOrigin.dx +
        math.min(painter.width + 4.0, math.max(0.0, inputBox.size.width - 8.0));
    final caretY = inputOrigin.dy + (inputBox.size.height * 0.55);

    for (var i = 0; i < 10; i++) {
      _particles.add(
        _FireParticle(
          x: caretX + (_rng.nextDouble() - 0.5) * 6.0,
          y: caretY + (_rng.nextDouble() - 0.5) * 4.0,
          vx: (_rng.nextDouble() - 0.5) * 2.4,
          vy: -(_rng.nextDouble() * 2.6 + 1.1),
          maxLife: 24 + _rng.nextDouble() * 18,
          size: (1.8 + _rng.nextDouble() * 2.4) * tokens.scale,
          hue: 14 + _rng.nextDouble() * 42, // Orange-red to golden flame hue
        ),
      );
    }

    if (_particles.length > 120) {
      _particles.removeRange(0, _particles.length - 120);
    }

    if (!_fireTicker.isAnimating) {
      _fireTicker.forward(from: 0.0);
    }
  }

  void _tickParticles() {
    if (_particles.isEmpty) {
      _fireTicker.stop();
      return;
    }
    for (var i = _particles.length - 1; i >= 0; i--) {
      final p = _particles[i];
      p.life += 1.0;
      if (p.life >= p.maxLife) {
        _particles.removeAt(i);
        continue;
      }
      p.x += p.vx;
      p.y += p.vy;
      p.vy -= 0.05;
      p.vx *= 0.98;
    }
    if (_particles.isEmpty) {
      _fireTicker.stop();
    } else if (_fireTicker.status == AnimationStatus.completed) {
      _fireTicker.forward(from: 0.0);
    }
  }

  void _handleControllerChanged() {
    if (widget.controller.focusRequestId != _lastFocusRequestId) {
      _lastFocusRequestId = widget.controller.focusRequestId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _inputFocusNode.requestFocus();
        }
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _focusTerminalInput() {
    _inputFocusNode.requestFocus();
  }

  void _submitCommand(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _inputFocusNode.requestFocus();
      });
      return;
    }
    _spawnTypingFireAtCaret(trimmed);
    _historyIndex = -1;
    _lastInputText = '';
    _inputController.clear();
    widget.controller.execute(trimmed);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _inputFocusNode.requestFocus();
    });
  }

  Color _colorForTone(TerminalLineTone tone, _TerminalPromptPalette palette) {
    return switch (tone) {
      TerminalLineTone.prompt => palette.apple,
      TerminalLineTone.normal => palette.outputText,
      TerminalLineTone.success => palette.apple,
      TerminalLineTone.highlight => palette.chevron,
      TerminalLineTone.warning => TerminalPalette.commandAmber,
      TerminalLineTone.error => TerminalPalette.errorCoral,
    };
  }

  @override
  Widget build(BuildContext context) {
    final tokens = GlassTokens.of(context);
    final palette = _TerminalPromptPalette.of(tokens.isDark);
    final bodyHeight = (tokens.isExpanded
            ? 240.0
            : tokens.isMedium
                ? 220.0
                : 196.0) *
        tokens.scale;

    return GlassBentoCard(
      key: _terminalBoxKey,
      padding: EdgeInsets.zero,
      accentColor: tokens.neonAccent,
      borderRadius: 16 * tokens.scale,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _focusTerminalInput,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                MacosWindowHeader(
                  title: widget.windowTitle,
                ),
                ListenableBuilder(
                  listenable: widget.controller,
                  builder: (context, _) {
                    final entries = widget.controller.entries;
                    return SizedBox(
                      height: math.min(
                        bodyHeight,
                        widget.maxOutputHeight * tokens.scale,
                      ),
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(
                          horizontal: 14 * tokens.scale,
                          vertical: 12 * tokens.scale,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final entry in entries) ...[
                              if (entry.command.isNotEmpty) ...[
                                _ShellPromptRow(
                                  promptLabel: widget.promptLabel,
                                  palette: palette,
                                  scale: tokens.scale,
                                  child: Text(
                                    entry.command,
                                    style: TextStyle(
                                      color: palette.command,
                                      fontSize: 13.5 * tokens.scale,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: GlassTokens.fontShell,
                                      height: 1.3,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 6 * tokens.scale),
                              ],
                              for (final line in entry.lines)
                                Padding(
                                  padding: EdgeInsets.only(
                                    bottom: 4 * tokens.scale,
                                  ),
                                  child: Text(
                                    line,
                                    style: TextStyle(
                                      color: entry.command.isEmpty
                                          ? palette.systemText
                                          : _colorForTone(entry.tone, palette),
                                      fontSize: 13 * tokens.scale,
                                      height: 1.38,
                                      fontFamily: GlassTokens.fontShell,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                              SizedBox(height: 10 * tokens.scale),
                            ],
                            // Active zsh / Powerlevel10k prompt with Apple logo (``)
                            _ShellPromptRow(
                              promptLabel: widget.promptLabel,
                              palette: palette,
                              scale: tokens.scale,
                              child: Material(
                                key: _inputFieldKey,
                                type: MaterialType.transparency,
                                child: TextField(
                                  controller: _inputController,
                                  focusNode: _inputFocusNode,
                                  onEditingComplete: () {},
                                  onSubmitted: _submitCommand,
                                  textInputAction: TextInputAction.send,
                                  autocorrect: false,
                                  enableSuggestions: false,
                                  style: TextStyle(
                                    color: palette.command,
                                    fontSize: 13.5 * tokens.scale,
                                    fontFamily: GlassTokens.fontShell,
                                    height: 1.3,
                                  ),
                                  cursorColor: palette.caret,
                                  cursorWidth: 7.5 * tokens.scale,
                                  cursorRadius: const Radius.circular(1),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    border: InputBorder.none,
                                    hintText: 'type a command…',
                                    hintStyle: TextStyle(
                                      color: palette.placeholderText,
                                      fontSize: 13.5 * tokens.scale,
                                      fontFamily: GlassTokens.fontShell,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                if (widget.showQuickCommandPills)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12 * tokens.scale,
                      vertical: 8 * tokens.scale,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: tokens.headerBorder),
                      ),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final cmd in TerminalController.quickCommands)
                            Padding(
                              padding: EdgeInsets.only(right: 6 * tokens.scale),
                              child: GlassTagChip(
                                label: '› $cmd',
                                isMonospace: true,
                                accentColor: tokens.neonAccent,
                                onTap: () {
                                  widget.controller.execute(cmd);
                                  _focusTerminalInput();
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            // VS Code Power Mode typing fire particle overlay
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _fireTicker,
                  builder: (context, _) {
                    if (_particles.isEmpty) return const SizedBox.shrink();
                    return CustomPaint(
                      painter: _TypingFirePainter(
                        particles: _particles,
                        repaintTick: _fireTicker.value,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Renders the two-line `ShellPrompt` from `InteractiveTerminal.tsx` (Screenshot 2):
/// - Left continuous rounded red-orange bracket (`╭…╰`) connecting the two rows
/// - Top row: `[UserIcon]  isTuhin.dev  [GitBranchIcon]`
/// - Bottom row: `[AppleLogo ]  ❯  <input or command>`
class _ShellPromptRow extends StatelessWidget {
  const _ShellPromptRow({
    required this.promptLabel,
    required this.palette,
    required this.scale,
    required this.child,
  });

  final String promptLabel;
  final _TerminalPromptPalette palette;
  final double scale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Continuous rounded bracket `╭…╰`
          SizedBox(
            width: 11 * scale,
            child: CustomPaint(
              painter: _RoundedBracketPainter(
                color: palette.bracket,
                strokeWidth: 1.8 * scale,
              ),
            ),
          ),
          SizedBox(width: 7 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top row: User Avatar SVG + `isTuhin.dev` + Nerd-Font Git Branch SVG
                Row(
                  children: [
                    SizedBox(
                      width: 15 * scale,
                      height: 15 * scale,
                      child: CustomPaint(
                        painter: _UserAvatarIconPainter(color: palette.person),
                      ),
                    ),
                    SizedBox(width: 6 * scale),
                    Flexible(
                      child: Text(
                        promptLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.host,
                          fontSize: 13.5 * scale,
                          fontWeight: FontWeight.w600,
                          fontFamily: GlassTokens.fontShell,
                          letterSpacing: -0.2,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    SizedBox(width: 7 * scale),
                    SizedBox(
                      width: 13.5 * scale,
                      height: 13.5 * scale,
                      child: CustomPaint(
                        painter: _GitBranchIconPainter(color: palette.git),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6 * scale),
                // Bottom row: Exact Apple Logo (``) SVG + Bold Cyan Chevron (`❯`) + Input
                Row(
                  children: [
                    SizedBox(
                      width: 15.5 * scale,
                      height: 15.5 * scale,
                      child: CustomPaint(
                        painter: TerminalAppleLogoPainter(color: palette.apple),
                      ),
                    ),
                    SizedBox(width: 6 * scale),
                    Text(
                      '❯',
                      style: TextStyle(
                        color: palette.chevron,
                        fontSize: 13 * scale,
                        fontWeight: FontWeight.w800,
                        fontFamily: GlassTokens.fontShell,
                        height: 1.1,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    SizedBox(width: 7 * scale),
                    Expanded(child: child),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints the continuous rounded left bracket (`╭…╰`) landing on the top and
/// bottom icon midlines (matching Screenshot 2).
class _RoundedBracketPainter extends CustomPainter {
  const _RoundedBracketPainter({
    required this.color,
    required this.strokeWidth,
  });

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final topY = 7.5;
    final bottomY = math.max(topY + 8.0, size.height - 8.5);
    final rightX = size.width - 1.0;
    final leftX = strokeWidth * 0.6;
    final r = math.min(4.5, (bottomY - topY) * 0.35);

    final path = Path()
      ..moveTo(rightX, topY)
      ..lineTo(leftX + r, topY)
      ..quadraticBezierTo(leftX, topY, leftX, topY + r)
      ..lineTo(leftX, bottomY - r)
      ..quadraticBezierTo(leftX, bottomY, leftX + r, bottomY)
      ..lineTo(rightX, bottomY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _RoundedBracketPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Exact User Avatar SVG from `InteractiveTerminal.tsx`:
/// `M12 12c2.7 0 4.8-2.1 4.8-4.8S14.7 2.4 12 2.4 7.2 4.5 7.2 7.2 9.3 12 12 12zm0 2.4c-3.2 0-9.6 1.6-9.6 4.8v1.2h19.2v-1.2c0-3.2-6.4-4.8-9.6-4.8z`
class _UserAvatarIconPainter extends CustomPainter {
  const _UserAvatarIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 24.0;
    final sy = size.height / 24.0;
    canvas.save();
    canvas.scale(sx, sy);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Head circle
    canvas.drawCircle(const Offset(12.0, 7.2), 4.6, paint);

    // Shoulders dome
    final body = Path()
      ..moveTo(2.4, 20.4)
      ..lineTo(2.4, 19.0)
      ..cubicTo(2.4, 15.8, 8.8, 14.4, 12.0, 14.4)
      ..cubicTo(15.2, 14.4, 21.6, 15.8, 21.6, 19.0)
      ..lineTo(21.6, 20.4)
      ..close();
    canvas.drawPath(body, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _UserAvatarIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Exact Nerd-Font Git Branch SVG (`GitBranchIcon`) from `InteractiveTerminal.tsx`:
/// circles at `(6,6)`, `(6,18)`, `(18,9)` + stem `(6, 8.25 -> 15.75)` + curve `(6,12 -> 12,12 -> 16,8)`.
class _GitBranchIconPainter extends CustomPainter {
  const _GitBranchIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 24.0;
    final sy = size.height / 24.0;
    canvas.save();
    canvas.scale(sx, sy);

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    canvas.drawCircle(const Offset(6, 6), 2.4, fillPaint);
    canvas.drawCircle(const Offset(6, 18), 2.4, fillPaint);
    canvas.drawCircle(const Offset(18, 9), 2.4, fillPaint);

    final path = Path()
      ..moveTo(6, 8.25)
      ..lineTo(6, 15.75)
      ..moveTo(6, 12)
      ..lineTo(13, 12)
      ..quadraticBezierTo(18, 12, 18, 9);

    canvas.drawPath(path, strokePaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GitBranchIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Exact Apple Logo (``) vector SVG path from `InteractiveTerminal.tsx`:
/// `M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z`
class TerminalAppleLogoPainter extends CustomPainter {
  const TerminalAppleLogoPainter({required this.color});

  final Color color;

  static Path? _cachedApplePath;

  static Path _buildApplePath() {
    final cached = _cachedApplePath;
    if (cached != null) return cached;

    final path = Path()
      // Apple body
      ..moveTo(18.71, 19.5)
      ..cubicTo(17.88, 20.74, 17.0, 21.95, 15.66, 21.97)
      ..cubicTo(14.32, 22.0, 13.89, 21.18, 12.37, 21.18)
      ..cubicTo(10.84, 21.18, 10.37, 21.95, 9.10, 22.0)
      ..cubicTo(7.79, 22.05, 6.80, 20.68, 5.96, 19.47)
      ..cubicTo(4.25, 17.0, 2.94, 12.45, 4.70, 9.39)
      ..cubicTo(5.57, 7.87, 7.13, 6.91, 8.82, 6.88)
      ..cubicTo(10.10, 6.86, 11.32, 7.75, 12.11, 7.75)
      ..cubicTo(12.89, 7.75, 14.37, 6.68, 15.92, 6.84)
      ..cubicTo(16.57, 6.87, 18.39, 7.10, 19.56, 8.82)
      ..cubicTo(19.47, 8.88, 17.39, 10.10, 17.41, 12.63)
      ..cubicTo(17.44, 15.65, 20.06, 16.66, 20.09, 16.67)
      ..cubicTo(20.06, 16.74, 19.67, 18.11, 18.71, 19.5)
      ..close()
      // Apple leaf
      ..moveTo(13.0, 3.5)
      ..cubicTo(13.73, 2.67, 14.94, 2.04, 15.94, 2.0)
      ..cubicTo(16.07, 3.17, 15.60, 4.35, 14.90, 5.19)
      ..cubicTo(14.21, 6.04, 13.07, 6.70, 11.95, 6.61)
      ..cubicTo(11.80, 5.46, 12.36, 4.26, 13.0, 3.5)
      ..close();

    _cachedApplePath = path;
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 24.0;
    final sy = size.height / 24.0;
    canvas.save();
    canvas.scale(sx, sy);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawPath(_buildApplePath(), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant TerminalAppleLogoPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Paints the VS Code Power Mode flame particles (`TypingFire.tsx`).
class _TypingFirePainter extends CustomPainter {
  const _TypingFirePainter({
    required this.particles,
    required this.repaintTick,
  });

  final List<_FireParticle> particles;
  final double repaintTick;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = (1.0 - (p.life / p.maxLife)).clamp(0.0, 1.0);
      if (t <= 0) continue;
      final alpha = (t * 0.95).clamp(0.0, 1.0);
      final lightness = (0.55 + (t * 0.25)).clamp(0.0, 1.0);
      final flameColor =
          HSLColor.fromAHSL(alpha, p.hue, 1.0, lightness).toColor();
      final glowColor =
          HSLColor.fromAHSL(alpha * 0.75, p.hue, 1.0, 0.55).toColor();
      final radius = math.max(0.6, p.size * t);

      final glowPaint = Paint()
        ..color = glowColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0)
        ..isAntiAlias = true;
      canvas.drawCircle(Offset(p.x, p.y), radius * 1.6, glowPaint);

      final corePaint = Paint()
        ..color = flameColor
        ..isAntiAlias = true;
      canvas.drawCircle(Offset(p.x, p.y), radius, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TypingFirePainter oldDelegate) => true;
}
