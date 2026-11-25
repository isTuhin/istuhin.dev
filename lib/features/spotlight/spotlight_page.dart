import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/glass_tokens.dart';
import '../../core/theme/terminal_palette.dart';
import '../../core/widgets/glass/glass_bento_card.dart';
import '../../core/widgets/glass/glass_responsive_body.dart';
import '../../core/widgets/glass/glass_section_header.dart';
import '../../core/widgets/glass/glass_tag_chip.dart';
import '../../data/repositories/portfolio_repository.dart';
import '../ecosystem/widgets/project_glass_card.dart';
import '../terminal_lab/terminal_controller.dart';

/// Orb 1 (`Spotlight & CLI Search`): Coupled with the keyboard-top
/// `GlassKeyboardSearchBar` in `GlassBottomNav`. Searches across projects,
/// skills, and socials in real time and executes `-zsh` commands.
class SpotlightPage extends StatefulWidget {
  const SpotlightPage({
    super.key,
    this.query = '',
    this.onRequestFocus,
    required this.terminalController,
    this.repository = const PortfolioRepository(),
    this.onOpenTerminalTab,
  });

  final String query;
  final VoidCallback? onRequestFocus;
  final TerminalController terminalController;
  final PortfolioRepository repository;
  final VoidCallback? onOpenTerminalTab;

  @override
  State<SpotlightPage> createState() => _SpotlightPageState();
}

class _SpotlightPageState extends State<SpotlightPage> {
  late final GlassLargeTitleController _titleController =
      GlassLargeTitleController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = GlassTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final horizontalPad = tokens.pageHorizontalPadding;
    final bottomPad =
        keyboardInset + tokens.capsuleHeight + (68 * tokens.scale);

    final trimmed = widget.query.trim();
    final subtitle = trimmed.isEmpty
        ? 'Search projects, stack & socials or run a -zsh command'
        : 'Results for "$trimmed"';

    final matchingProjects = widget.repository.projects
        .where((p) => p.matchesQuery(trimmed))
        .toList();
    final matchingSkills = widget.repository.skills
        .where((s) => s.matchesQuery(trimmed))
        .toList();
    final matchingSocials = widget.repository.socials
        .where((s) => s.matchesQuery(trimmed))
        .toList();

    return SafeArea(
      bottom: false,
      child: GlassResponsiveBody(
        child: CustomScrollView(
          controller: _titleController.scrollController,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(height: 12 * tokens.scale),
            ),
            GlassLargeTitle(
              text: 'Spotlight & CLI',
              controller: _titleController,
              color: tokens.activeIcon,
              padding: EdgeInsetsDirectional.fromSTEB(
                horizontalPad,
                8 * tokens.scale,
                horizontalPad,
                8 * tokens.scale,
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                horizontalPad,
                4 * tokens.scale,
                horizontalPad,
                bottomPad,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      subtitle,
                      style: textTheme.bodyLarge?.copyWith(
                        color: tokens.inactiveIcon,
                        height: 1.35,
                      ),
                    ),
                    SizedBox(height: 14 * tokens.scale),
                    Wrap(
                      spacing: 8 * tokens.scale,
                      runSpacing: 8 * tokens.scale,
                      children: [
                        for (final cmd in TerminalController.quickCommands)
                          GlassTagChip(
                            label: '› $cmd',
                            isMonospace: true,
                            accentColor: TerminalPalette.promptArrow,
                            onTap: () {
                              widget.terminalController.execute(cmd);
                              widget.onOpenTerminalTab?.call();
                            },
                          ),
                      ],
                    ),
                    if (trimmed.isNotEmpty) ...[
                      SizedBox(height: 14 * tokens.scale),
                      GlassBentoCard(
                        padding: EdgeInsets.all(14 * tokens.scale),
                        accentColor: TerminalPalette.promptArrow,
                        onTap: () {
                          widget.terminalController.execute(trimmed);
                          widget.onOpenTerminalTab?.call();
                        },
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Run in -zsh terminal: › $trimmed',
                                style: TextStyle(
                                  color: TerminalPalette.promptArrow,
                                  fontSize: 13 * tokens.scale,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'monospace',
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                            const GlassTagChip(
                              label: 'Execute ↵',
                              isMonospace: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (matchingProjects.isNotEmpty) ...[
                      SizedBox(height: 22 * tokens.scale),
                      GlassSectionHeader(
                        label: 'Projects (${matchingProjects.length})',
                      ),
                      SizedBox(height: 10 * tokens.scale),
                      for (final project in matchingProjects)
                        Padding(
                          padding: EdgeInsets.only(bottom: 12 * tokens.scale),
                          child: ProjectGlassCard(project: project),
                        ),
                    ],
                    if (matchingSkills.isNotEmpty) ...[
                      SizedBox(height: 18 * tokens.scale),
                      GlassSectionHeader(
                        label: 'Tech Stack (${matchingSkills.length})',
                      ),
                      SizedBox(height: 10 * tokens.scale),
                      Wrap(
                        spacing: 8 * tokens.scale,
                        runSpacing: 8 * tokens.scale,
                        children: [
                          for (final skill in matchingSkills)
                            GlassTagChip(
                              label: '${skill.name} · ${skill.domain.title}',
                              accentColor: skill.isPrimary
                                  ? TerminalPalette.directoryCyan
                                  : null,
                            ),
                        ],
                      ),
                    ],
                    if (matchingSocials.isNotEmpty) ...[
                      SizedBox(height: 22 * tokens.scale),
                      GlassSectionHeader(
                        label: 'Channels (${matchingSocials.length})',
                      ),
                      SizedBox(height: 10 * tokens.scale),
                      for (final social in matchingSocials)
                        Padding(
                          padding: EdgeInsets.only(bottom: 10 * tokens.scale),
                          child: GlassBentoCard(
                            padding: EdgeInsets.all(14 * tokens.scale),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${social.platform} (${social.handle})',
                                        style: textTheme.bodyLarge?.copyWith(
                                          color: tokens.activeIcon,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(height: 2 * tokens.scale),
                                      Text(
                                        social.subtitle,
                                        style: textTheme.bodySmall?.copyWith(
                                          color: tokens.inactiveIcon,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GlassTagChip(
                                  label: social.url.replaceFirst('https://', ''),
                                  isMonospace: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
