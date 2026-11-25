import 'package:material_ui/material_ui.dart';

import '../../../core/utils/url_launcher.dart';
import '../../../core/widgets/glass/glass_kit.dart';
import '../../../data/models/github_stats.dart';
import 'stats/contribution_activity_card.dart';
import 'stats/contribution_calendar.dart';
import 'stats/contribution_day_cell.dart';
import 'stats/stat_card.dart';

export 'stats/contribution_activity_card.dart';
export 'stats/contribution_calendar.dart';
export 'stats/contribution_day_cell.dart';
export 'stats/contribution_legend.dart';
export 'stats/contribution_month_labels.dart';
export 'stats/stat_card.dart';

/// Live GitHub stats section matching `dev.istuhin/components/stats/LiveStats.tsx`:
/// - Composed from modular, reusable widgets under `lib/features/overview/widgets/stats/`:
///   - [GitHubStatCard] (`Public repos`, `Total stars`, `Total forks`, `Featured`)
///   - [ContributionCalendar] (`<N> contributions in the last year` + [ContributionMonthLabels]
///     + [ContributionDayCell] + [ContributionLegend])
///   - [ContributionActivityCard] (`Contribution activity` monthly breakdown)
///   - Language count chips (`HTML 1`, `C 1`)
///   - `Synced from github.com/<username> · <fetchedAt>` footer
class GitHubContributionCard extends StatelessWidget {
  const GitHubContributionCard({
    super.key,
    required this.stats,
    this.featuredCount,
  });

  final GitHubStats stats;
  final int? featuredCount;

  /// Exact heatmap cell colors from `dev.istuhin/app/globals.css` (`--contrib-0..4`).
  static Color heatmapCellColor(int intensity, bool isDark) =>
      ContributionDayCell.cellColor(intensity, isDark);

  List<List<ContributionDay>> get _resolvedWeeks {
    if (stats.contributionWeeks.isNotEmpty) {
      return stats.contributionWeeks;
    }
    return stats.heatmapWeeks
        .map(
          (w) => w
              .map((lvl) => ContributionDay(date: '', count: 0, level: lvl))
              .toList(),
        )
        .toList();
  }

  String _formatSyncedAt(String iso) {
    final parsed = DateTime.tryParse(iso)?.toLocal();
    if (parsed == null) return iso;
    final h12 = parsed.hour % 12 == 0 ? 12 : parsed.hour % 12;
    final ampm = parsed.hour >= 12 ? 'PM' : 'AM';
    final min = parsed.minute.toString().padLeft(2, '0');
    final sec = parsed.second.toString().padLeft(2, '0');
    return '${parsed.month}/${parsed.day}/${parsed.year}, $h12:$min:$sec $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final tokens = GlassTokens.of(context);
    final effectiveFeatured = featuredCount ?? stats.featuredCount;
    final weeks = _resolvedWeeks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. 4 Reusable Stat Cards (`StatCard.tsx`)
        GlassResponsiveGrid(
          compactColumns: 2,
          mediumColumns: 2,
          expandedColumns: 4,
          children: [
            GitHubStatCard(
              label: 'PUBLIC REPOS',
              value: '${stats.publicRepos}',
            ),
            GitHubStatCard(
              label: 'TOTAL STARS',
              value: '${stats.totalStars}',
            ),
            GitHubStatCard(
              label: 'TOTAL FORKS',
              value: '${stats.totalForks}',
            ),
            GitHubStatCard(
              label: 'FEATURED',
              value: '$effectiveFeatured',
              hint: 'Pinned or top starred',
            ),
          ],
        ),
        SizedBox(height: 14 * tokens.scale),
        // 2. Reusable 53-week Contribution Calendar (`ContributionCalendar.tsx`)
        ContributionCalendar(
          weeks: weeks,
          totalContributions: stats.annualContributions,
        ),
        // 3. Reusable Contribution Activity (`ContributionActivity.tsx`)
        if (stats.contributionActivity.isNotEmpty) ...[
          SizedBox(height: 14 * tokens.scale),
          ContributionActivityCard(
            groups: stats.contributionActivity,
            profileUrl: stats.profileUrl,
          ),
        ],
        // 4. Language count chips (`HTML 1`, `C 1`)
        if (stats.languages.isNotEmpty) ...[
          SizedBox(height: 14 * tokens.scale),
          Wrap(
            spacing: 8 * tokens.scale,
            runSpacing: 8 * tokens.scale,
            children: [
              for (final lang in stats.languages)
                GlassTagChip(
                  label: '${lang.name}  ${lang.count}',
                  isMonospace: true,
                ),
            ],
          ),
        ],
        // 5. Synced from github.com/<username> footer
        SizedBox(height: 12 * tokens.scale),
        Wrap(
          spacing: 6 * tokens.scale,
          runSpacing: 4 * tokens.scale,
          children: [
            Text(
              'Synced from',
              style: TextStyle(
                color: tokens.inactiveIcon,
                fontSize: 10.5 * tokens.scale,
                fontFamily: GlassTokens.fontMain,
                decoration: TextDecoration.none,
              ),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => UrlLauncher.launch(context, stats.profileUrl),
                child: Text(
                  'github.com/${stats.username}',
                  style: TextStyle(
                    color: tokens.neonAccent,
                    fontSize: 10.5 * tokens.scale,
                    fontWeight: FontWeight.w600,
                    fontFamily: GlassTokens.fontMain,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
            if (stats.fetchedAt.isNotEmpty)
              Text(
                '· ${_formatSyncedAt(stats.fetchedAt)}',
                style: TextStyle(
                  color: tokens.inactiveIcon,
                  fontSize: 10.5 * tokens.scale,
                  fontFamily: GlassTokens.fontMain,
                  decoration: TextDecoration.none,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
