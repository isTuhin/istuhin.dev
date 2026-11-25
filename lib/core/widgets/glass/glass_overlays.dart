import 'dart:async';

import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoIcons;
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:material_ui/material_ui.dart';

import '../../theme/glass_tokens.dart';
import '../../theme/liquid_glass_chrome.dart';

/// Unified convenience helpers for Apple iOS 26 Liquid Glass overlays:
/// sheets (with optional trigger morphing), action sheets, dialogs, and toasts.
abstract final class AppGlassOverlays {
  static OverlayEntry? _activeToastEntry;
  static Timer? _activeToastTimer;

  /// Presents a multi-detent [GlassModalSheet].
  ///
  /// Pass [morphFrom] (from a [GlassMorphTrigger]) to morph the sheet fluidly
  /// out of the originating button.
  static Future<T?> showSheet<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    GlassMorphAnchor? morphFrom,
    Set<GlassSheetDetent> detents = const {
      GlassSheetDetent.medium,
      GlassSheetDetent.large,
    },
    GlassSheetState initialState = GlassSheetState.half,
    bool dismissible = true,
  }) {
    return GlassModalSheet.show<T>(
      context: context,
      builder: builder,
      morphFrom: morphFrom,
      detents: detents,
      initialState: initialState,
      dismissible: dismissible,
    );
  }

  /// Presents an iOS 26 Liquid Glass action sheet platter.
  static Future<T?> showActionSheet<T>({
    required BuildContext context,
    required List<GlassActionSheetAction> actions,
    String? title,
    String? message,
    String cancelLabel = 'Cancel',
    bool showCancelButton = true,
  }) {
    return showGlassActionSheet<T>(
      context: context,
      title: title,
      message: message,
      actions: actions,
      cancelLabel: cancelLabel,
      showCancelButton: showCancelButton,
    );
  }

  /// Presents an iOS 26 Liquid Glass alert dialog (`1..3` actions).
  static Future<T?> showDialog<T>({
    required BuildContext context,
    required String title,
    required List<GlassDialogAction> actions,
    String? message,
    Widget? content,
  }) {
    return GlassDialog.show<T>(
      context: context,
      title: title,
      message: message,
      content: content,
      actions: actions,
    );
  }

  /// Dismisses any currently visible toast overlay.
  static void dismissToast() {
    _activeToastTimer?.cancel();
    _activeToastTimer = null;
    _activeToastEntry?.remove();
    _activeToastEntry = null;
  }

  /// Shows a non-blocking, responsive pill-shaped Liquid Glass toast notification.
  ///
  /// Uses a [Material] ancestor (preventing yellow underline artifacts) and
  /// adaptive [GlassTokens.activeIcon] text color (black on white/light glass,
  /// white on dark glass).
  static void showToast(
    BuildContext context, {
    required String message,
    GlassToastType type = GlassToastType.info,
    GlassToastPosition position = GlassToastPosition.top,
    Duration duration = const Duration(seconds: 3),
    Widget? icon,
    GlassToastAction? action,
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    final tokens = GlassTokens.of(context);
    dismissToast();

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _GlassAlertToastOverlay(
        tokens: tokens,
        message: message,
        type: type,
        position: position,
        icon: icon,
        action: action,
        onDismiss: () {
          if (_activeToastEntry == entry) {
            dismissToast();
          }
        },
      ),
    );

    _activeToastEntry = entry;
    overlay.insert(entry);
    _activeToastTimer = Timer(duration, () {
      if (_activeToastEntry == entry) {
        dismissToast();
      }
    });
  }
}

class _GlassAlertToastOverlay extends StatefulWidget {
  const _GlassAlertToastOverlay({
    required this.tokens,
    required this.message,
    required this.type,
    required this.position,
    required this.onDismiss,
    this.icon,
    this.action,
  });

  final GlassTokens tokens;
  final String message;
  final GlassToastType type;
  final GlassToastPosition position;
  final VoidCallback onDismiss;
  final Widget? icon;
  final GlassToastAction? action;

  @override
  State<_GlassAlertToastOverlay> createState() =>
      _GlassAlertToastOverlayState();
}

class _GlassAlertToastOverlayState extends State<_GlassAlertToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: Offset(
        0,
        widget.position == GlassToastPosition.top ? -0.25 : 0.25,
      ),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _typeColor(GlassTokens tokens) {
    return switch (widget.type) {
      GlassToastType.success => tokens.neonAccent,
      GlassToastType.warning =>
        tokens.isDark ? const Color(0xFFF59E0B) : const Color(0xFFD97706),
      GlassToastType.error =>
        tokens.isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
      GlassToastType.info =>
        tokens.isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
      GlassToastType.neutral => tokens.activeIcon,
    };
  }

  IconData _typeIcon() {
    return switch (widget.type) {
      GlassToastType.success => CupertinoIcons.checkmark_circle_fill,
      GlassToastType.warning => CupertinoIcons.exclamationmark_triangle_fill,
      GlassToastType.error => CupertinoIcons.xmark_circle_fill,
      GlassToastType.info => CupertinoIcons.info_circle_fill,
      GlassToastType.neutral => CupertinoIcons.bell_fill,
    };
  }

  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;
    final isTop = widget.position == GlassToastPosition.top;
    final accent = _typeColor(tokens);

    return Positioned(
      top: isTop ? 0 : null,
      bottom: isTop ? null : 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.pageHorizontalPadding,
            vertical: 12 * tokens.scale,
          ),
          child: Align(
            alignment: isTop ? Alignment.topCenter : Alignment.bottomCenter,
            child: SlideTransition(
              position: _slide,
              child: FadeTransition(
                opacity: _opacity,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: tokens.isExpanded ? 520.0 : 460.0,
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    child: GestureDetector(
                      onTap: widget.onDismiss,
                      child: AdaptiveGlass(
                        useOwnLayer: true,
                        quality: AppLiquidGlass.effectiveQuality,
                        settings: tokens.isDark
                            ? AppLiquidGlass.darkChrome
                            : LiquidGlassSettings.ios27Light,
                        shape: const LiquidRoundedSuperellipse(
                          borderRadius: 999,
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16 * tokens.scale,
                            vertical: 12 * tokens.scale,
                          ),
                          decoration: ShapeDecoration(
                            color: tokens.isDark
                                ? const Color(0xB812141A)
                                : const Color(0xE6FFFFFF),
                            shape: LiquidRoundedSuperellipse(
                              borderRadius: 999,
                              side: BorderSide(
                                color: tokens.isDark
                                    ? Colors.white.withValues(alpha: 0.14)
                                    : const Color(0xFF0F172A)
                                        .withValues(alpha: 0.10),
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              widget.icon ??
                                  Icon(
                                    _typeIcon(),
                                    size: 18 * tokens.scale,
                                    color: accent,
                                  ),
                              SizedBox(width: 10 * tokens.scale),
                              Flexible(
                                child: Text(
                                  widget.message,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: tokens.activeIcon,
                                    fontSize: 12.5 * tokens.scale,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: GlassTokens.fontMain,
                                    height: 1.35,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                              if (widget.action != null) ...[
                                SizedBox(width: 12 * tokens.scale),
                                GestureDetector(
                                  onTap: () {
                                    widget.action!.onPressed();
                                    widget.onDismiss();
                                  },
                                  child: Text(
                                    widget.action!.label,
                                    style: TextStyle(
                                      color: accent,
                                      fontSize: 12 * tokens.scale,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: GlassTokens.fontMain,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
