import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/glass_tokens.dart';
import '../../../../core/utils/url_launcher.dart';
import '../../../../core/widgets/glass/glass_bento_card.dart';
import '../../../../core/widgets/glass/glass_tag_chip.dart';
import '../../../../data/models/github_stats.dart';

/// Reusable monthly commit activity breakdown matching
/// `dev.istuhin/components/stats/ContributionActivity.tsx`.
class ContributionActivityCard extends StatefulWidget {
  const ContributionActivityCard({
    super.key,
    required this.groups,
    required this.profileUrl,
  });

  final List<ContributionActivityGroup> groups;
  final String profileUrl;

  @override
  State<ContributionActivityCard> createState() =>
      _ContributionActivityCardState();
}

class _ContributionActivityCardState extends State<ContributionActivityCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final tokens = GlassTokens.of(context);
    final groups = widget.groups;
    if (groups.isEmpty) return const SizedBox.shrink();

    final visibleGroups = _expanded ? groups : groups.take(2).toList();
    var maxCommits = 1;
    for (final group in groups) {
      for (final repo in group.repositories) {
        if (repo.commits > maxCommits) maxCommits = repo.commits;
      }
    }

    return GlassBentoCard(
      padding: EdgeInsets.all(16 * tokens.scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contribution activity',
            style: TextStyle(
              color: tokens.activeIcon,
              fontSize: 14 * tokens.scale,
              fontWeight: FontWeight.w700,
              fontFamily: GlassTokens.fontMain,
              decoration: TextDecoration.none,
            ),
          ),
          SizedBox(height: 14 * tokens.scale),
          for (final group in visibleGroups) ...[
            Row(
              children: [
                Text(
                  group.label,
                  style: TextStyle(
                    color: tokens.inactiveIcon,
                    fontSize: 11 * tokens.scale,
                    fontWeight: FontWeight.w600,
                    fontFamily: GlassTokens.fontMain,
                    decoration: TextDecoration.none,
                  ),
                ),
                SizedBox(width: 8 * tokens.scale),
                Expanded(
                  child: Container(
                    height: 1,
                    color: tokens.fieldRim.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10 * tokens.scale),
            Container(
              padding: EdgeInsets.all(12 * tokens.scale),
              decoration: BoxDecoration(
                color: tokens.fieldFill,
                borderRadius: BorderRadius.circular(10 * tokens.scale),
                border: Border.all(color: tokens.fieldRim, width: 0.8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 18 * tokens.scale,
                        height: 18 * tokens.scale,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: tokens.neonAccent,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '↑',
                          style: TextStyle(
                            color: tokens.neonAccent,
                            fontSize: 10 * tokens.scale,
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                          ),
                        ),
                      ),
                      SizedBox(width: 8 * tokens.scale),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 11 * tokens.scale,
                              fontFamily: GlassTokens.fontMain,
                            ),
                            children: [
                              TextSpan(
                                text: 'Created ',
                                style: TextStyle(color: tokens.activeIcon),
                              ),
                              TextSpan(
                                text: '${group.totalCommits} ',
                                style: TextStyle(
                                  color: tokens.neonAccent,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextSpan(
                                text:
                                    '${group.totalCommits == 1 ? "commit" : "commits"} in ',
                                style: TextStyle(color: tokens.activeIcon),
                              ),
                              TextSpan(
                                text: '${group.repositories.length} ',
                                style: TextStyle(
                                  color: tokens.activeIcon,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextSpan(
                                text: group.repositories.length == 1
                                    ? 'repository'
                                    : 'repositories',
                                style: TextStyle(color: tokens.activeIcon),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10 * tokens.scale),
                  for (final repo in group.repositories) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 3 * tokens.scale,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () =>
                                    UrlLauncher.launch(context, repo.url),
                                child: Text(
                                  repo.nameWithOwner,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: tokens.activeIcon,
                                    fontSize: 11 * tokens.scale,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: GlassTokens.fontMain,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8 * tokens.scale),
                          Expanded(
                            flex: 2,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                2 * tokens.scale,
                              ),
                              child: LinearProgressIndicator(
                                value: (repo.commits /
                                        math.max(maxCommits, 1))
                                    .clamp(0.05, 1.0),
                                minHeight: 4 * tokens.scale,
                                backgroundColor:
                                    tokens.fieldRim.withValues(alpha: 0.3),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  tokens.neonAccent,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8 * tokens.scale),
                          Text(
                            '${repo.commits}',
                            style: TextStyle(
                              color: tokens.inactiveIcon,
                              fontSize: 10 * tokens.scale,
                              fontFamily: GlassTokens.fontMain,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 14 * tokens.scale),
          ],
          if (groups.length > 2) ...[
            Center(
              child: GlassTagChip(
                label: _expanded
                    ? 'Show less activity'
                    : 'Show more activity (${groups.length - 2})',
                accentColor: tokens.neonAccent,
                onTap: () => setState(() => _expanded = !_expanded),
              ),
            ),
          ] else ...[
            Center(
              child: GlassTagChip(
                label: 'Show more activity on GitHub',
                accentColor: tokens.neonAccent,
                onTap: () => UrlLauncher.launch(
                  context,
                  '${widget.profileUrl}?tab=overview',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

