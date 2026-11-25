import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/glass_tokens.dart';
import '../../../../core/widgets/glass/glass_overlays.dart';
import '../../../../data/models/github_stats.dart';

/// Single day cell inside the contribution calendar matching
/// `dev.istuhin/components/stats/ContributionDayCell.tsx`.
class ContributionDayCell extends StatelessWidget {
  const ContributionDayCell({
    super.key,
    required this.day,
    required this.cellPx,
    this.isEmptySlot = false,
  });

  final ContributionDay? day;
  final double cellPx;
  final bool isEmptySlot;

  static Color cellColor(int intensity, bool isDark) {
    if (isDark) {
      return switch (intensity) {
        0 => const Color(0xFF161B22),
        1 => const Color(0xFF0E4429),
        2 => const Color(0xFF006D32),
        3 => const Color(0xFF26A641),
        _ => const Color(0xFF39D353),
      };
    }
    return switch (intensity) {
      0 => const Color(0xFFE8E6E1),
      1 => const Color(0xFF9BE9A8),
      2 => const Color(0xFF40C463),
      3 => const Color(0xFF30A14E),
      _ => const Color(0xFF216E39),
    };
  }

  @override
  Widget build(BuildContext context) {
    final tokens = GlassTokens.of(context);
    final empty = isEmptySlot || day == null;
    final level = day?.level ?? 0;
    final baseColor = cellColor(level, tokens.isDark);

    final box = Container(
      width: cellPx,
      height: cellPx,
      decoration: BoxDecoration(
        color: empty ? baseColor.withValues(alpha: 0.35) : baseColor,
        borderRadius: BorderRadius.circular(2.0 * tokens.scale),
      ),
    );

    if (empty || (day?.date.isEmpty ?? true)) {
      return box;
    }

    final d = day!;
    final tooltip =
        '${d.date}: ${d.count} ${d.count == 1 ? "contribution" : "contributions"}';

    return Semantics(
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        preferBelow: false,
        verticalOffset: cellPx + 4,
        textStyle: TextStyle(
          color: tokens.isDark ? Colors.white : Colors.black,
          fontSize: 10 * tokens.scale,
          fontFamily: GlassTokens.fontMain,
        ),
        decoration: BoxDecoration(
          color: tokens.isDark
              ? const Color(0xFF1F242C)
              : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(4 * tokens.scale),
          border: Border.all(color: tokens.fieldRim, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () => AppGlassOverlays.showToast(context, message: tooltip),
          child: box,
        ),
      ),
    );
  }
}

