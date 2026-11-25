import 'dart:math' as math;
import 'dart:ui' show PointerDeviceKind;

import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/glass_tokens.dart';
import '../../../../core/widgets/glass/glass_bento_card.dart';
import '../../../../data/models/github_stats.dart';
import 'contribution_day_cell.dart';
import 'contribution_legend.dart';
import 'contribution_month_labels.dart';

/// Pure responsive 53-week contribution calendar matching
/// `dev.istuhin/components/stats/ContributionCalendar.tsx` and
/// `computeContributionCellPx` in `dev.istuhin/lib/github/contributionCalendar.ts`.
class ContributionCalendar extends StatefulWidget {
  const ContributionCalendar({
    super.key,
    required this.weeks,
    required this.totalContributions,
  });

  final List<List<ContributionDay>> weeks;
  final int totalContributions;

  @override
  State<ContributionCalendar> createState() => _ContributionCalendarState();
}

class _ContributionCalendarState extends State<ContributionCalendar> {
  final ScrollController _scrollController = ScrollController();

  static const List<String> _weekdayLabels = <String>[
    '', 'Mon', '', 'Wed', '', 'Fri', '',
  ];

  @override
  void initState() {
    super.initState();
    _scrollToRecentWeeks();
  }

  @override
  void didUpdateWidget(covariant ContributionCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.weeks.length != widget.weeks.length) {
      _scrollToRecentWeeks();
    }
  }

  void _scrollToRecentWeeks() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final max = _scrollController.position.maxScrollExtent;
      if (max > 0) {
        _scrollController.jumpTo(max);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = GlassTokens.of(context);
    final weeks = widget.weeks;
    final totalContributions = widget.totalContributions;

    if (weeks.isEmpty) {
      return GlassBentoCard(
        padding: EdgeInsets.all(16 * tokens.scale),
        child: Text(
          'GitHub contribution calendar unavailable right now.',
          style: TextStyle(
            color: tokens.inactiveIcon,
            fontSize: 12 * tokens.scale,
            fontFamily: GlassTokens.fontMain,
          ),
        ),
      );
    }

    return GlassBentoCard(
      padding: EdgeInsets.all(16 * tokens.scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: TextStyle(
                fontSize: 13 * tokens.scale,
                fontFamily: GlassTokens.fontMain,
              ),
              children: [
                TextSpan(
                  text: '$totalContributions ',
                  style: TextStyle(
                    color: tokens.activeIcon,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: 'contributions in the last year',
                  style: TextStyle(color: tokens.inactiveIcon),
                ),
              ],
            ),
          ),
          SizedBox(height: 14 * tokens.scale),
          LayoutBuilder(
            builder: (context, constraints) {
              final weekCount = math.max(weeks.length, 1);
              final gapPx = 3.0 * tokens.scale;
              // 34px ensures 'Wed' in wide Michroma font never clips to 'We'
              final weekdayColPx = 34.0 * tokens.scale;
              final minCellPx = 10.0 * tokens.scale;

              // computeContributionCellPx from dev.istuhin/lib/github/contributionCalendar.ts
              final gaps = gapPx + (math.max(weekCount - 1, 0) * gapPx);
              final usable = constraints.maxWidth - weekdayColPx - gaps;
              final cellPx = math.max(
                minCellPx,
                usable > 0 ? (usable / weekCount).floorToDouble() : minCellPx,
              );

              return ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.trackpad,
                    PointerDeviceKind.stylus,
                  },
                ),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ContributionMonthLabels(
                        weeks: weeks,
                        cellPx: cellPx,
                        gapPx: gapPx,
                        weekdayColPx: weekdayColPx,
                      ),
                      SizedBox(height: 4 * tokens.scale),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: weekdayColPx,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (final dayLabel in _weekdayLabels)
                                  Container(
                                    height: cellPx,
                                    margin: EdgeInsets.only(bottom: gapPx),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      dayLabel,
                                      softWrap: false,
                                      overflow: TextOverflow.visible,
                                      style: TextStyle(
                                        color: tokens.inactiveIcon,
                                        fontSize: 9.0 * tokens.scale,
                                        fontFamily: GlassTokens.fontMain,
                                        height: 1.0,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(width: gapPx),
                          for (var wi = 0; wi < weeks.length; wi++)
                            Padding(
                              padding: EdgeInsets.only(
                                right: wi == weeks.length - 1 ? 0 : gapPx,
                              ),
                              child: Column(
                                children: [
                                  for (var di = 0; di < 7; di++)
                                    Padding(
                                      padding: EdgeInsets.only(bottom: gapPx),
                                      child: ContributionDayCell(
                                        day: di < weeks[wi].length
                                            ? weeks[wi][di]
                                            : null,
                                        cellPx: cellPx,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 10 * tokens.scale),
          const ContributionLegend(),
        ],
      ),
    );
  }
}

