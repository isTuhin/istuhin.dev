import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// Vector platform icons matching `dev.istuhin/components/connect/platformIcons.tsx`
/// (`Portfolio`, `LinkedIn`, `GitHub`, `GitLab`, `CodePen`, `Dev.to`, `WhatsApp`,
/// `Business`, `iCloud`, `ProtonMail`, `Twitter`, `Instagram`, `Facebook`, `Buy Me A Coffee`).
class ConnectPlatformIcon extends StatelessWidget {
  const ConnectPlatformIcon({
    super.key,
    required this.platform,
    required this.color,
    this.size = 17.0,
  });

  final String platform;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _ConnectPlatformIconPainter(
          platform: platform,
          color: color,
        ),
      ),
    );
  }
}

class _ConnectPlatformIconPainter extends CustomPainter {
  const _ConnectPlatformIconPainter({
    required this.platform,
    required this.color,
  });

  final String platform;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final dim = math.min(size.width, size.height);
    if (dim <= 0) return;
    final u = dim / 24.0;

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.85 * u
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    switch (platform) {
      case 'Portfolio':
        // Globe icon (circle + equator + meridians)
        final c = Offset(12 * u, 12 * u);
        canvas.drawCircle(c, 9.5 * u, stroke);
        canvas.drawLine(Offset(2.5 * u, 12 * u), Offset(21.5 * u, 12 * u), stroke);
        canvas.drawOval(
          Rect.fromCenter(center: c, width: 8.2 * u, height: 19 * u),
          stroke,
        );

      case 'Business':
        // Gmail / Business M envelope
        final rrect = RRect.fromRectAndRadius(
          Rect.fromLTRB(2.2 * u, 5.0 * u, 21.8 * u, 19.0 * u),
          Radius.circular(2.2 * u),
        );
        canvas.drawRRect(rrect, stroke);
        final mPath = Path()
          ..moveTo(2.8 * u, 6.2 * u)
          ..lineTo(12.0 * u, 13.2 * u)
          ..lineTo(21.2 * u, 6.2 * u);
        canvas.drawPath(mPath, stroke);

      case 'iCloud':
        // Cloud silhouette
        final cloud = Path()
          ..moveTo(6.4 * u, 17.5 * u)
          ..lineTo(17.8 * u, 17.5 * u)
          ..arcToPoint(
            Offset(17.8 * u, 9.8 * u),
            radius: Radius.circular(3.85 * u),
            clockwise: false,
          )
          ..arcToPoint(
            Offset(8.8 * u, 8.2 * u),
            radius: Radius.circular(4.8 * u),
            clockwise: false,
          )
          ..arcToPoint(
            Offset(6.4 * u, 17.5 * u),
            radius: Radius.circular(4.65 * u),
            clockwise: false,
          )
          ..close();
        canvas.drawPath(cloud, stroke);

      case 'ProtonMail':
        // Shield/lock envelope
        final shield = RRect.fromRectAndRadius(
          Rect.fromLTRB(3.5 * u, 4.5 * u, 20.5 * u, 19.5 * u),
          Radius.circular(4.0 * u),
        );
        canvas.drawRRect(shield, stroke);
        final flap = Path()
          ..moveTo(4.2 * u, 8.0 * u)
          ..lineTo(12.0 * u, 13.4 * u)
          ..lineTo(19.8 * u, 8.0 * u);
        canvas.drawPath(flap, stroke);

      case 'WhatsApp':
        // Speech bubble + phone curve
        final bubble = Path()
          ..addArc(
            Rect.fromCircle(center: Offset(12.2 * u, 11.8 * u), radius: 8.8 * u),
            0.75 * math.pi,
            1.88 * math.pi,
          )
          ..lineTo(3.4 * u, 20.6 * u)
          ..close();
        canvas.drawPath(bubble, stroke);
        final handset = Path()
          ..moveTo(9.2 * u, 8.8 * u)
          ..quadraticBezierTo(8.8 * u, 12.6 * u, 15.0 * u, 14.8 * u);
        canvas.drawPath(
          handset,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.1 * u
            ..strokeCap = StrokeCap.round,
        );

      case 'LinkedIn':
        // 'in' glyph
        canvas.drawCircle(Offset(5.2 * u, 5.4 * u), 1.45 * u, fill);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTRB(3.9 * u, 9.2 * u, 6.5 * u, 19.6 * u),
            Radius.circular(0.8 * u),
          ),
          fill,
        );
        final nPath = Path()
          ..moveTo(10.5 * u, 19.4 * u)
          ..lineTo(10.5 * u, 9.6 * u)
          ..moveTo(10.5 * u, 12.4 * u)
          ..quadraticBezierTo(10.8 * u, 9.4 * u, 14.8 * u, 9.4 * u)
          ..quadraticBezierTo(18.8 * u, 9.4 * u, 18.8 * u, 13.4 * u)
          ..lineTo(18.8 * u, 19.4 * u);
        canvas.drawPath(
          nPath,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.35 * u
            ..strokeCap = StrokeCap.round,
        );

      case 'GitHub':
        // Octocat silhouette circle + ears + base
        final head = Path()
          ..moveTo(7.5 * u, 18.8 * u)
          ..quadraticBezierTo(3.5 * u, 16.5 * u, 3.8 * u, 11.4 * u)
          ..quadraticBezierTo(4.0 * u, 8.2 * u, 6.0 * u, 6.8 * u)
          ..lineTo(5.6 * u, 3.8 * u)
          ..lineTo(8.8 * u, 5.2 * u)
          ..quadraticBezierTo(12.0 * u, 4.4 * u, 15.2 * u, 5.2 * u)
          ..lineTo(18.4 * u, 3.8 * u)
          ..lineTo(18.0 * u, 6.8 * u)
          ..quadraticBezierTo(20.0 * u, 8.2 * u, 20.2 * u, 11.4 * u)
          ..quadraticBezierTo(20.5 * u, 16.5 * u, 16.5 * u, 18.8 * u);
        canvas.drawPath(head, stroke);
        canvas.drawLine(Offset(9.5 * u, 18.8 * u), Offset(9.5 * u, 21.2 * u), stroke);
        canvas.drawLine(Offset(14.5 * u, 18.8 * u), Offset(14.5 * u, 21.2 * u), stroke);

      case 'GitLab':
        // Tanuki geometric fox polygon
        final fox = Path()
          ..moveTo(12.0 * u, 20.6 * u)
          ..lineTo(2.4 * u, 13.4 * u)
          ..lineTo(5.4 * u, 3.8 * u)
          ..lineTo(8.4 * u, 10.6 * u)
          ..lineTo(15.6 * u, 10.6 * u)
          ..lineTo(18.6 * u, 3.8 * u)
          ..lineTo(21.6 * u, 13.4 * u)
          ..close();
        canvas.drawPath(fox, stroke);

      case 'CodePen':
        // 3D Isometric wireframe cube
        final cube = Path()
          ..moveTo(12.0 * u, 2.5 * u)
          ..lineTo(21.5 * u, 8.2 * u)
          ..lineTo(21.5 * u, 15.8 * u)
          ..lineTo(12.0 * u, 21.5 * u)
          ..lineTo(2.5 * u, 15.8 * u)
          ..lineTo(2.5 * u, 8.2 * u)
          ..close()
          ..moveTo(2.5 * u, 8.2 * u)
          ..lineTo(12.0 * u, 13.8 * u)
          ..lineTo(21.5 * u, 8.2 * u)
          ..moveTo(2.5 * u, 15.8 * u)
          ..lineTo(12.0 * u, 10.2 * u)
          ..lineTo(21.5 * u, 15.8 * u)
          ..moveTo(12.0 * u, 2.5 * u)
          ..lineTo(12.0 * u, 10.2 * u)
          ..moveTo(12.0 * u, 13.8 * u)
          ..lineTo(12.0 * u, 21.5 * u);
        canvas.drawPath(cube, stroke);

      case 'Dev.to':
        // Rounded badge with DEV brackets
        final badge = RRect.fromRectAndRadius(
          Rect.fromLTRB(2.0 * u, 4.5 * u, 22.0 * u, 19.5 * u),
          Radius.circular(3.0 * u),
        );
        canvas.drawRRect(badge, stroke);
        final dPath = Path()
          ..moveTo(6.2 * u, 8.8 * u)
          ..lineTo(6.2 * u, 15.2 * u)
          ..quadraticBezierTo(10.0 * u, 15.2 * u, 10.0 * u, 12.0 * u)
          ..quadraticBezierTo(10.0 * u, 8.8 * u, 6.2 * u, 8.8 * u)
          ..moveTo(12.5 * u, 8.8 * u)
          ..lineTo(12.5 * u, 15.2 * u)
          ..moveTo(12.5 * u, 8.8 * u)
          ..lineTo(15.2 * u, 8.8 * u)
          ..moveTo(12.5 * u, 12.0 * u)
          ..lineTo(14.8 * u, 12.0 * u)
          ..moveTo(12.5 * u, 15.2 * u)
          ..lineTo(15.2 * u, 15.2 * u)
          ..moveTo(16.8 * u, 8.8 * u)
          ..lineTo(18.2 * u, 15.2 * u)
          ..lineTo(19.6 * u, 8.8 * u);
        canvas.drawPath(
          dPath,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.55 * u
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );

      case 'Twitter':
        // X monogram
        final xPath = Path()
          ..moveTo(4.0 * u, 3.8 * u)
          ..lineTo(19.6 * u, 20.2 * u)
          ..moveTo(19.8 * u, 3.8 * u)
          ..lineTo(4.2 * u, 20.2 * u);
        canvas.drawPath(
          xPath,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.15 * u
            ..strokeCap = StrokeCap.round,
        );

      case 'Instagram':
        // Camera squircle + lens + flash dot
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTRB(3.0 * u, 3.0 * u, 21.0 * u, 21.0 * u),
            Radius.circular(5.2 * u),
          ),
          stroke,
        );
        canvas.drawCircle(Offset(12.0 * u, 12.0 * u), 4.2 * u, stroke);
        canvas.drawCircle(Offset(17.2 * u, 6.8 * u), 1.15 * u, fill);

      case 'Facebook':
        // Circle + 'f'
        canvas.drawCircle(Offset(12.0 * u, 12.0 * u), 9.6 * u, stroke);
        final fPath = Path()
          ..moveTo(13.2 * u, 21.2 * u)
          ..lineTo(13.2 * u, 10.2 * u)
          ..quadraticBezierTo(13.2 * u, 7.6 * u, 15.8 * u, 7.6 * u)
          ..moveTo(9.8 * u, 13.0 * u)
          ..lineTo(15.4 * u, 13.0 * u);
        canvas.drawPath(
          fPath,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0 * u
            ..strokeCap = StrokeCap.round,
        );

      case 'Buy Me A Coffee':
        // Coffee cup + handle + steam
        final cup = Path()
          ..moveTo(5.2 * u, 8.8 * u)
          ..lineTo(16.8 * u, 8.8 * u)
          ..lineTo(15.6 * u, 18.2 * u)
          ..quadraticBezierTo(15.3 * u, 20.2 * u, 13.2 * u, 20.2 * u)
          ..lineTo(8.8 * u, 20.2 * u)
          ..quadraticBezierTo(6.7 * u, 20.2 * u, 6.4 * u, 18.2 * u)
          ..close();
        canvas.drawPath(cup, stroke);
        final handle = Path()
          ..moveTo(16.6 * u, 10.2 * u)
          ..arcToPoint(
            Offset(16.1 * u, 15.8 * u),
            radius: Radius.circular(2.8 * u),
            clockwise: true,
          );
        canvas.drawPath(handle, stroke);
        canvas.drawLine(Offset(8.8 * u, 4.2 * u), Offset(8.8 * u, 6.4 * u), stroke);
        canvas.drawLine(Offset(13.2 * u, 4.2 * u), Offset(13.2 * u, 6.4 * u), stroke);

      default:
        // Link chain icon
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTRB(3.5 * u, 8.5 * u, 13.5 * u, 15.5 * u),
            Radius.circular(3.5 * u),
          ),
          stroke,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTRB(10.5 * u, 8.5 * u, 20.5 * u, 15.5 * u),
            Radius.circular(3.5 * u),
          ),
          stroke,
        );
    }
  }

  @override
  bool shouldRepaint(covariant _ConnectPlatformIconPainter oldDelegate) {
    return oldDelegate.platform != platform || oldDelegate.color != color;
  }
}
