import 'dart:math' as math;

import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoIcons;
import 'package:material_ui/material_ui.dart';

import '../theme/glass_tokens.dart';

/// Reduce Motion glyph — overlapping dotted circle and solid circle
/// matching Apple's `circle.dotted.and.circle` icon.
class NavReduceMotionIcon extends StatelessWidget {
  const NavReduceMotionIcon({super.key, this.color, this.size});

  final Color? color;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final tokens = GlassTokens.of(context);
    final effectiveColor = color ?? tokens.inactiveIcon;
    final width = (size ?? 24) * tokens.scale;
    final height = (size ?? 18) * tokens.scale;

    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _ReduceMotionGlyphPainter(color: effectiveColor),
      ),
    );
  }
}

class _ReduceMotionGlyphPainter extends CustomPainter {
  const _ReduceMotionGlyphPainter({required this.color});

  final Color color;

  static const int _dotCount = 14;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = math.min(size.width * 0.29, size.height * 0.42);
    if (radius <= 0) return;

    final cy = size.height / 2;
    final leftCenter = Offset(size.width * 0.36, cy);
    final rightCenter = Offset(size.width * 0.64, cy);

    // 1. Left dotted circle
    final dotPaint = Paint()
      ..color = color.withValues(alpha: (color.a * 0.78).clamp(0.0, 1.0))
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final dotRadius = (radius * 0.13).clamp(0.7, 1.4);

    for (var i = 0; i < _dotCount; i++) {
      final angle = (i * 2 * math.pi) / _dotCount;
      final dx = leftCenter.dx + radius * math.cos(angle);
      final dy = leftCenter.dy + radius * math.sin(angle);
      canvas.drawCircle(Offset(dx, dy), dotRadius, dotPaint);
    }

    // 2. Right solid-stroke circle
    final circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = (radius * 0.24).clamp(1.3, 2.0)
      ..isAntiAlias = true;
    canvas.drawCircle(rightCenter, radius, circlePaint);
  }

  @override
  bool shouldRepaint(covariant _ReduceMotionGlyphPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

/// Typographic `AA` icon (small `A` + large `A`) matching the iOS Text Size glyph.
class NavTextSizeIcon extends StatelessWidget {
  const NavTextSizeIcon({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tokens = GlassTokens.of(context);
    final effectiveColor = color ?? tokens.inactiveIcon;

    return Semantics(
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            'A',
            style: TextStyle(
              color: effectiveColor,
              fontSize: 13 * tokens.scale,
              fontWeight: FontWeight.w500,
              height: 1.0,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(width: 1.5),
          Text(
            'A',
            style: TextStyle(
              color: effectiveColor,
              fontSize: 18 * tokens.scale,
              fontWeight: FontWeight.w500,
              height: 1.0,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}

/// Store glyph — Custom vector storefront with trapezoidal awning roof,
/// 4 scalloped awning loops, lower-left U-shaped shop window, and lower-right
/// vertical door post matching the reference storefront icon.
class NavStoreIcon extends StatelessWidget {
  const NavStoreIcon({
    super.key,
    this.filled = false,
    this.color,
    this.size,
  });

  final bool filled;
  final Color? color;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final effectiveSize = (size ?? iconTheme.size ?? 24) * 1.08;
    final effectiveColor =
        color ?? iconTheme.color ?? Theme.of(context).colorScheme.onSurface;

    return SizedBox.square(
      dimension: effectiveSize,
      child: CustomPaint(
        painter: _StorefrontAwningPainter(
          color: effectiveColor,
          filled: filled,
        ),
      ),
    );
  }
}

class _StorefrontAwningPainter extends CustomPainter {
  const _StorefrontAwningPainter({
    required this.color,
    required this.filled,
  });

  final Color color;
  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    final dim = math.min(size.width, size.height);
    if (dim <= 0) return;

    final u = dim / 24.0;
    final strokeW = 1.85 * u;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    // 1. Trapezoidal awning roof (top y=3.6, bottom y=9.4)
    final roofPath = Path()
      ..moveTo(5.6 * u, 3.6 * u)
      ..lineTo(18.4 * u, 3.6 * u)
      ..quadraticBezierTo(19.3 * u, 3.6 * u, 19.6 * u, 4.5 * u)
      ..lineTo(20.8 * u, 9.2 * u)
      ..lineTo(3.2 * u, 9.2 * u)
      ..lineTo(4.4 * u, 4.5 * u)
      ..quadraticBezierTo(4.7 * u, 3.6 * u, 5.6 * u, 3.6 * u)
      ..close();

    if (filled) {
      final fillPaint = Paint()
        ..color = color.withValues(alpha: 0.22)
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;
      canvas.drawPath(roofPath, fillPaint);
    }
    canvas.drawPath(roofPath, strokePaint);

    // 2. 4 scalloped semicircular awning loops under the roof bar (x: 3.2 -> 20.8)
    const scallopCount = 4;
    final startX = 3.2 * u;
    final endX = 20.8 * u;
    final scallopW = (endX - startX) / scallopCount;
    final scallopTopY = 9.2 * u;
    final scallopDepth = 2.45 * u;

    final scallopPath = Path()..moveTo(startX, scallopTopY);
    for (var i = 0; i < scallopCount; i++) {
      final x0 = startX + (i * scallopW);
      final xMid = x0 + (scallopW / 2);
      final x1 = x0 + scallopW;
      scallopPath.cubicTo(
        x0,
        scallopTopY + scallopDepth,
        x1,
        scallopTopY + scallopDepth,
        x1,
        scallopTopY,
      );
      if (i < scallopCount - 1) {
        scallopPath.moveTo(x1, scallopTopY);
      }
      // Subtle fill inside scallops when active
      if (filled) {
        final scFill = Path()
          ..moveTo(x0, scallopTopY)
          ..quadraticBezierTo(
            xMid,
            scallopTopY + scallopDepth,
            x1,
            scallopTopY,
          )
          ..close();
        canvas.drawPath(
          scFill,
          Paint()
            ..color = color.withValues(alpha: 0.18)
            ..style = PaintingStyle.fill,
        );
      }
    }
    canvas.drawPath(scallopPath, strokePaint);

    // 3. Lower-left U-shaped storefront window/counter frame
    final uLeft = 4.4 * u;
    final uRight = 15.0 * u;
    final uTop = 14.2 * u;
    final uBottom = 20.2 * u;
    final cornerR = 1.6 * u;

    final windowPath = Path()
      ..moveTo(uLeft, uTop)
      ..lineTo(uLeft, uBottom - cornerR)
      ..quadraticBezierTo(uLeft, uBottom, uLeft + cornerR, uBottom)
      ..lineTo(uRight - cornerR, uBottom)
      ..quadraticBezierTo(uRight, uBottom, uRight, uBottom - cornerR)
      ..lineTo(uRight, uTop);
    canvas.drawPath(windowPath, strokePaint);

    // 4. Lower-right vertical door post
    final postX = 19.2 * u;
    canvas.drawLine(
      Offset(postX, uTop),
      Offset(postX, uBottom),
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _StorefrontAwningPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.filled != filled;
  }
}

/// Connect / Message glyph — Cupertino double speech bubble (outline / fill).
class NavConnectIcon extends StatelessWidget {
  const NavConnectIcon({super.key, this.filled = false});

  final bool filled;

  @override
  Widget build(BuildContext context) {
    final base = IconTheme.of(context).size ?? 24;
    return Icon(
      filled
          ? CupertinoIcons.chat_bubble_2_fill
          : CupertinoIcons.chat_bubble_2,
      size: base * 1.28,
    );
  }
}

/// Legacy alias for [NavConnectIcon].
typedef NavChatsIcon = NavConnectIcon;

/// Legacy alias for [NavStoreIcon].
typedef NavProfileIcon = NavStoreIcon;

/// Settings glyph — iOS / WhatsApp Business 3-spoke toothed gear.
class NavSettingsIcon extends StatelessWidget {
  const NavSettingsIcon({
    super.key,
    this.filled = false,
    this.color,
    this.size,
  });

  final bool filled;
  final Color? color;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final effectiveSize = (size ?? iconTheme.size ?? 24) * 1.08;
    final effectiveColor =
        color ?? iconTheme.color ?? Theme.of(context).colorScheme.onSurface;

    return SizedBox.square(
      dimension: effectiveSize,
      child: CustomPaint(
        painter: _IosThreeSpokeGearPainter(
          color: effectiveColor,
          filled: filled,
        ),
      ),
    );
  }
}

class _IosThreeSpokeGearPainter extends CustomPainter {
  const _IosThreeSpokeGearPainter({
    required this.color,
    required this.filled,
  });

  final Color color;
  final bool filled;

  static const int _toothCount = 18;
  static const List<double> _spokeAngles = <double>[
    0.0, // 3 o'clock
    2 * math.pi / 3, // 7 o'clock (120°)
    4 * math.pi / 3, // 11 o'clock (240°)
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final dim = math.min(size.width, size.height);
    if (dim <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final unit = dim / 24.0;

    final rTip = 10.6 * unit;
    final rOuterRing = 8.45 * unit;
    final ringStroke = 1.65 * unit;

    final rHub = 2.05 * unit;
    final hubStroke = 1.65 * unit;
    final spokeStroke = 1.65 * unit;

    // 1. Outer 18 gear teeth
    final toothPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.55 * unit
      ..strokeCap = StrokeCap.round;

    final toothStartR = rOuterRing - (0.2 * unit);
    for (var i = 0; i < _toothCount; i++) {
      final angle = (i * 2 * math.pi) / _toothCount;
      final cosA = math.cos(angle);
      final sinA = math.sin(angle);
      final p1 = Offset(
        center.dx + toothStartR * cosA,
        center.dy + toothStartR * sinA,
      );
      final p2 = Offset(
        center.dx + rTip * cosA,
        center.dy + rTip * sinA,
      );
      canvas.drawLine(p1, p2, toothPaint);
    }

    // 2. Outer gear ring
    final ringPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringStroke;
    canvas.drawCircle(center, rOuterRing, ringPaint);

    // 3. 3 radial spokes connecting center hub ring to outer ring
    final spokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = spokeStroke
      ..strokeCap = StrokeCap.butt;

    for (final angle in _spokeAngles) {
      final cosA = math.cos(angle);
      final sinA = math.sin(angle);
      final start = Offset(
        center.dx + rHub * cosA,
        center.dy + rHub * sinA,
      );
      final end = Offset(
        center.dx + rOuterRing * cosA,
        center.dy + rOuterRing * sinA,
      );
      canvas.drawLine(start, end, spokePaint);
    }

    // 4. Center hub ring
    final hubPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = hubStroke;
    canvas.drawCircle(center, rHub, hubPaint);

    // 5. Selected state: fill the 3 inner sector windows with uniform margin
    if (filled) {
      final gap = 1.05 * unit;
      final rSectorOuter = rOuterRing - (ringStroke / 2) - gap;
      final rSectorInner = rHub + (hubStroke / 2) + gap;

      if (rSectorOuter > rSectorInner) {
        final outerDisk = Path()
          ..addOval(Rect.fromCircle(center: center, radius: rSectorOuter));
        final innerDisk = Path()
          ..addOval(Rect.fromCircle(center: center, radius: rSectorInner));
        var sectorsPath = Path.combine(
          PathOperation.difference,
          outerDisk,
          innerDisk,
        );

        final corridorHalfWidth = (spokeStroke / 2) + gap;
        final corridorLength = rSectorOuter + (2 * unit);

        for (final angle in _spokeAngles) {
          final cosA = math.cos(angle);
          final sinA = math.sin(angle);
          final px = -sinA * corridorHalfWidth;
          final py = cosA * corridorHalfWidth;
          final fx = cosA * corridorLength;
          final fy = sinA * corridorLength;

          final corridor = Path()
            ..moveTo(center.dx + px, center.dy + py)
            ..lineTo(center.dx + fx + px, center.dy + fy + py)
            ..lineTo(center.dx + fx - px, center.dy + fy - py)
            ..lineTo(center.dx - px, center.dy - py)
            ..close();

          sectorsPath = Path.combine(
            PathOperation.difference,
            sectorsPath,
            corridor,
          );
        }

        final fillPaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill
          ..isAntiAlias = true;
        canvas.drawPath(sectorsPath, fillPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _IosThreeSpokeGearPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.filled != filled;
  }
}
