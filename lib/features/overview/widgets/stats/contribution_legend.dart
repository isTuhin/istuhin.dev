import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/glass_tokens.dart';
import '../../../../core/utils/url_launcher.dart';
import 'contribution_day_cell.dart';

const String kContributionDocsUrl =
    'https://docs.github.com/en/account-and-profile/setting-up-and-managing-your-github-profile/managing-contribution-settings-on-your-profile/why-are-my-contributions-not-showing-up-on-my-profile';

/// Bottom legend bar matching `dev.istuhin/components/stats/ContributionLegend.tsx`.
class ContributionLegend extends StatelessWidget {
  const ContributionLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = GlassTokens.of(context);

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12 * tokens.scale,
      runSpacing: 6 * tokens.scale,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => UrlLauncher.launch(context, kContributionDocsUrl),
            child: Text(
              'Learn how we count contributions',
              style: TextStyle(
                color: tokens.inactiveIcon,
                fontSize: 10.5 * tokens.scale,
                fontFamily: GlassTokens.fontMain,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Less',
              style: TextStyle(
                color: tokens.inactiveIcon,
                fontSize: 10.5 * tokens.scale,
                fontFamily: GlassTokens.fontMain,
                decoration: TextDecoration.none,
              ),
            ),
            SizedBox(width: 6 * tokens.scale),
            for (var level = 0; level <= 4; level++)
              Padding(
                padding: EdgeInsets.only(right: 4 * tokens.scale),
                child: Container(
                  width: 10 * tokens.scale,
                  height: 10 * tokens.scale,
                  decoration: BoxDecoration(
                    color: ContributionDayCell.cellColor(level, tokens.isDark),
                    borderRadius: BorderRadius.circular(2 * tokens.scale),
                  ),
                ),
              ),
            SizedBox(width: 2 * tokens.scale),
            Text(
              'More',
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

