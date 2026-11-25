import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/glass_tokens.dart';
import '../../../../data/models/github_stats.dart';

/// Month header row matching `dev.istuhin/components/stats/ContributionMonthLabels.tsx`
/// and `buildMonthLabels` in `dev.istuhin/lib/github/contributionCalendar.ts`.
class ContributionMonthLabels extends StatelessWidget {
  const ContributionMonthLabels({
    super.key,
    required this.weeks,
    required this.cellPx,
    required this.gapPx,
    required this.weekdayColPx,
  });

  final List<List<ContributionDay>> weeks;
  final double cellPx;
  final double gapPx;
  final double weekdayColPx;

  static const List<String> _monthNames = <String>[
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static List<String> buildMonthLabels(List<List<ContributionDay>> weeks) {
    final labels = <String>[];
    var lastMonth = -1;
    for (final week in weeks) {
      if (week.isEmpty || week.first.date.isEmpty) {
        labels.add('');
        continue;
      }
      final parsed = DateTime.tryParse('${week.first.date}T00:00:00Z');
      if (parsed == null) {
        labels.add('');
        continue;
      }
      final month = parsed.month - 1;
      if (month != lastMonth && month >= 0 && month < _monthNames.length) {
        labels.add(_monthNames[month]);
        lastMonth = month;
      } else {
        labels.add('');
      }
    }
    return labels;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = GlassTokens.of(context);
    final labels = buildMonthLabels(weeks);
    final weekCount = weeks.length;
    final totalWidth = (weekCount * cellPx) + ((weekCount - 1) * gapPx);

    return Row(
      children: [
        SizedBox(width: weekdayColPx + gapPx),
        SizedBox(
          width: totalWidth,
          height: 15 * tokens.scale,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (var i = 0; i < labels.length; i++)
                if (labels[i].isNotEmpty)
                  Positioned(
                    left: i * (cellPx + gapPx),
                    top: 0,
                    child: Text(
                      labels[i],
                      style: TextStyle(
                        color: tokens.inactiveIcon,
                        fontSize: 10 * tokens.scale,
                        fontFamily: GlassTokens.fontMain,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}

