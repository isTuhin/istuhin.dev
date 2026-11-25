import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/glass_tokens.dart';
import '../../../../core/widgets/glass/glass_bento_card.dart';

/// Reusable metric card matching `dev.istuhin/components/stats/ui/StatCard.tsx`.
class GitHubStatCard extends StatelessWidget {
  const GitHubStatCard({
    super.key,
    required this.label,
    required this.value,
    this.hint,
  });

  final String label;
  final String value;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final tokens = GlassTokens.of(context);

    return GlassBentoCard(
      padding: EdgeInsets.symmetric(
        horizontal: 14 * tokens.scale,
        vertical: 12 * tokens.scale,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10 * tokens.scale,
              fontWeight: FontWeight.w600,
              fontFamily: GlassTokens.fontMain,
              letterSpacing: 1.2,
              color: tokens.inactiveIcon,
              decoration: TextDecoration.none,
            ),
          ),
          SizedBox(height: 6 * tokens.scale),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 22 * tokens.scale,
              fontWeight: FontWeight.w800,
              fontFamily: GlassTokens.fontMain,
              color: tokens.activeIcon,
              letterSpacing: -0.5,
              decoration: TextDecoration.none,
            ),
          ),
          if (hint != null && hint!.isNotEmpty) ...[
            SizedBox(height: 4 * tokens.scale),
            Text(
              hint!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.5 * tokens.scale,
                fontFamily: GlassTokens.fontMain,
                color: tokens.inactiveIcon,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

