import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoIcons;
import 'package:material_ui/material_ui.dart';

import '../../../core/utils/url_launcher.dart';
import '../../../core/widgets/glass/glass_kit.dart';
import '../../../data/models/project_item.dart';

/// Liquid Glass card for a digital product (*Connectis*, *HackiisLab*, *Niihut*)
/// or open-source repository.
class ProjectGlassCard extends StatelessWidget {
  const ProjectGlassCard({
    super.key,
    required this.project,
    this.onTap,
  });

  final ProjectItem project;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = GlassTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    final accent = Color(project.accentHex);

    return GlassBentoCard(
      accentColor: accent,
      onTap: onTap ?? () => ProjectDetailSheet.show(context, project),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10 * tokens.scale,
                height: 10 * tokens.scale,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8 * tokens.scale),
              Expanded(
                child: Text(
                  project.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    color: tokens.activeIcon,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(width: 8 * tokens.scale),
              Flexible(
                child: GlassTagChip(
                  label: project.statusLabel,
                  accentColor: accent,
                  isMonospace: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * tokens.scale),
          Text(
            project.tagline,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(
              color: tokens.inactiveIcon,
              height: 1.35,
            ),
          ),
          SizedBox(height: 12 * tokens.scale),
          Wrap(
            spacing: 6 * tokens.scale,
            runSpacing: 6 * tokens.scale,
            children: [
              for (final tech in project.techStack.take(4))
                GlassTagChip(
                  label: tech,
                  isMonospace: true,
                ),
              if (project.techStack.length > 4)
                GlassTagChip(
                  label: '+${project.techStack.length - 4}',
                  isMonospace: true,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Interactive iOS 26 Liquid Glass modal sheet presenting full architecture
/// highlights, stack tags, and links for a selected [ProjectItem].
class ProjectDetailSheet extends StatelessWidget {
  const ProjectDetailSheet({
    super.key,
    required this.project,
  });

  final ProjectItem project;

  static Future<void> show(BuildContext context, ProjectItem project) {
    return AppGlassOverlays.showSheet<void>(
      context: context,
      builder: (_) => ProjectDetailSheet(project: project),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = GlassTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    final accent = Color(project.accentHex);

    return Material(
      type: MaterialType.transparency,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          22 * tokens.scale,
          16 * tokens.scale,
          22 * tokens.scale,
          36 * tokens.scale,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GlassTagChip(
                  label: '${project.category.label} · ${project.year}',
                  accentColor: accent,
                  isMonospace: true,
                ),
                GlassTagChip(
                  label: project.statusLabel,
                  leadingDotColor: accent,
                ),
              ],
            ),
            SizedBox(height: 14 * tokens.scale),
            Text(
              project.title,
              style: textTheme.headlineSmall?.copyWith(
                color: tokens.activeIcon,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 4 * tokens.scale),
            Text(
              project.role,
              style: textTheme.bodyMedium?.copyWith(
                color: accent,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12 * tokens.scale),
            Text(
              project.description,
              style: textTheme.bodyLarge?.copyWith(
                color: tokens.inactiveIcon,
                height: 1.45,
              ),
            ),
            if (project.highlights.isNotEmpty) ...[
              SizedBox(height: 18 * tokens.scale),
              Text(
                'Architecture & Key Highlights',
                style: textTheme.titleSmall?.copyWith(
                  color: tokens.activeIcon,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8 * tokens.scale),
              for (final highlight in project.highlights)
                Padding(
                  padding: EdgeInsets.only(bottom: 8 * tokens.scale),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        CupertinoIcons.checkmark_circle_fill,
                        size: 16 * tokens.scale,
                        color: accent,
                      ),
                      SizedBox(width: 8 * tokens.scale),
                      Expanded(
                        child: Text(
                          highlight,
                          style: textTheme.bodyMedium?.copyWith(
                            color: tokens.activeIcon,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            SizedBox(height: 16 * tokens.scale),
            Text(
              'Tech Stack',
              style: textTheme.titleSmall?.copyWith(
                color: tokens.activeIcon,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8 * tokens.scale),
            Wrap(
              spacing: 8 * tokens.scale,
              runSpacing: 8 * tokens.scale,
              children: [
                for (final tech in project.techStack)
                  GlassTagChip(
                    label: tech,
                    accentColor: accent,
                    isMonospace: true,
                  ),
              ],
            ),
            if (PortfolioNavResolver.isSafeHref(project.liveUrl) ||
                PortfolioNavResolver.isSafeHref(project.repoUrl)) ...[
              SizedBox(height: 20 * tokens.scale),
              Wrap(
                spacing: 10 * tokens.scale,
                runSpacing: 10 * tokens.scale,
                children: [
                  if (PortfolioNavResolver.isSafeHref(project.liveUrl))
                    GlassTagChip(
                      label: '↗ ${project.liveUrl}',
                      accentColor: accent,
                      isMonospace: true,
                      onTap: () =>
                          UrlLauncher.launch(context, project.liveUrl!),
                    ),
                  if (PortfolioNavResolver.isSafeHref(project.repoUrl))
                    GlassTagChip(
                      label: 'GitHub Repository',
                      isMonospace: true,
                      onTap: () =>
                          UrlLauncher.launch(context, project.repoUrl!),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
