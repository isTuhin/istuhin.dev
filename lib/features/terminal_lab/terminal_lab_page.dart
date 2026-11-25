import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/glass_tokens.dart';
import '../../core/widgets/glass/glass_overlays.dart';
import '../../core/widgets/glass/glass_responsive_body.dart';
import '../../core/widgets/glass/glass_section_header.dart';
import '../../data/repositories/portfolio_repository.dart';
import 'terminal_controller.dart';
import 'widgets/interactive_zsh_terminal.dart';
import 'widgets/tech_stack_matrix.dart';

/// Tab 3 (`Profile / Lab`): Interactive macOS `-zsh` terminal shell,
/// 4-tier Tech Stack Matrix, and Verified Certifications & Holopin Badges.
class TerminalLabPage extends StatefulWidget {
  const TerminalLabPage({
    super.key,
    required this.terminalController,
    this.repository = const PortfolioRepository(),
  });

  final TerminalController terminalController;
  final PortfolioRepository repository;

  @override
  State<TerminalLabPage> createState() => _TerminalLabPageState();
}

class _TerminalLabPageState extends State<TerminalLabPage> {
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
    final horizontalPad = tokens.pageHorizontalPadding;
    final bottomPad = tokens.capsuleHeight + (72 * tokens.scale);

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
              text: 'Stack & -zsh Lab',
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
                      'Interactive macOS terminal shell & full-stack engineering matrix for isTuhin.dev.',
                      style: textTheme.bodyLarge?.copyWith(
                        color: tokens.inactiveIcon,
                        height: 1.35,
                      ),
                    ),
                    SizedBox(height: 18 * tokens.scale),
                    InteractiveZshTerminal(
                      controller: widget.terminalController,
                      maxOutputHeight: 280,
                    ),
                    SizedBox(height: 28 * tokens.scale),
                    const GlassSectionHeader(
                      label: 'Ecosystem & Tech Stack',
                    ),
                    SizedBox(height: 12 * tokens.scale),
                    TechStackMatrix(
                      repository: widget.repository,
                      onSkillTap: (skill) {
                        widget.terminalController
                            .execute('stack ${skill.domain.cliFlag}');
                        AppGlassOverlays.showToast(
                          context,
                          message: '${skill.name} · ${skill.levelLabel}',
                        );
                      },
                    ),
                    SizedBox(height: 18 * tokens.scale),
                    const GlassSectionHeader(
                      label: 'Certifications & Verified Badges',
                    ),
                    SizedBox(height: 12 * tokens.scale),
                    CertificationsGrid(
                      certificates: widget.repository.certificates,
                    ),
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
