import 'package:material_ui/material_ui.dart';

import '../../../core/utils/url_launcher.dart';
import '../../../core/widgets/glass/glass_kit.dart';
import '../../../data/models/skill_category.dart';
import '../../../data/repositories/portfolio_repository.dart';

/// Displays `isTuhin.dev`'s 4-tier engineering stack (*Languages & Mobile*,
/// *Frontend*, *Backend & Data*, *Tools & Automation*) in a clean 2x2 Bento grid.
class TechStackMatrix extends StatelessWidget {
  const TechStackMatrix({
    super.key,
    required this.repository,
    this.skills,
    this.onSkillTap,
  });

  final PortfolioRepository repository;
  final List<SkillItem>? skills;
  final ValueChanged<SkillItem>? onSkillTap;

  List<SkillItem> _skillsForDomain(SkillDomain domain) {
    final source = skills;
    if (source != null && source.isNotEmpty) {
      return source.where((s) => s.domain == domain).toList();
    }
    return repository.skillsByDomain(domain);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = GlassTokens.of(context);
    final textTheme = Theme.of(context).textTheme;

    return GlassResponsiveGrid(
      compactColumns: 1,
      mediumColumns: 2,
      expandedColumns: 2,
      children: [
        for (final domain in SkillDomain.values)
          GlassBentoCard(
            padding: EdgeInsets.all(16 * tokens.scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  domain.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    color: tokens.activeIcon,
                    fontWeight: FontWeight.w700,
                    fontFamily: GlassTokens.fontMain,
                  ),
                ),
                SizedBox(height: 12 * tokens.scale),
                Wrap(
                  spacing: 8 * tokens.scale,
                  runSpacing: 8 * tokens.scale,
                  children: [
                    for (final skill in _skillsForDomain(domain))
                      GlassTagChip(
                        label: skill.name,
                        isMonospace: true,
                        onTap: onSkillTap == null
                            ? null
                            : () => onSkillTap!(skill),
                      ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Verified credentials & Holopin developer badge board matching
/// `BadgesContainer.tsx` in `dev.istuhin/components/home/BadgesContainer.tsx`:
/// - Renders the live Holopin badge board (`https://holopin.me/istuhin`) inside
///   a rounded Liquid Glass container (`p-2 sm:p-6 md:p-8`)
/// - Instant offline / test fallback to the bundled `assets/images/holopin_board.png`
///   snapshot so the actual badge board always displays without text truncation.
class CertificationsGrid extends StatelessWidget {
  const CertificationsGrid({
    super.key,
    this.certificates = const [],
    this.holopinProfileUrl = 'https://holopin.io/@istuhin',
    this.holopinBoardUrl = 'https://holopin.me/istuhin',
  });

  final List<CertificateBadge> certificates;
  final String holopinProfileUrl;
  final String holopinBoardUrl;

  static const String fallbackAssetPath = 'assets/images/holopin_board.png';

  /// Aspect ratio of the `2428 × 764` Holopin board PNG (`~3.178`).
  static const double boardAspectRatio = 2428.0 / 764.0;

  @override
  Widget build(BuildContext context) {
    final tokens = GlassTokens.of(context);
    final innerPad = tokens.isExpanded
        ? 24.0 * tokens.scale
        : tokens.isMedium
            ? 16.0 * tokens.scale
            : 8.0 * tokens.scale;

    final fallbackBoard = Image.asset(
      fallbackAssetPath,
      fit: BoxFit.contain,
      semanticLabel: 'Developer badges and certifications',
    );

    return GlassBentoCard(
      padding: EdgeInsets.all(innerPad),
      semanticLabel: 'Developer badges and certifications',
      onTap: () => UrlLauncher.launch(context, holopinProfileUrl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1024),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12 * tokens.scale),
            child: AspectRatio(
              aspectRatio: boardAspectRatio,
              child: Image.network(
                holopinBoardUrl,
                fit: BoxFit.contain,
                semanticLabel: 'Developer badges and certifications',
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded || frame != null) {
                    return child;
                  }
                  return fallbackBoard;
                },
                errorBuilder: (context, error, stackTrace) {
                  return fallbackBoard;
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
