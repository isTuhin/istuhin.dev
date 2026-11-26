import 'package:material_ui/material_ui.dart';

import '../../core/widgets/glass/glass_kit.dart';
import '../../data/models/github_stats.dart';
import '../../data/models/skill_category.dart';
import '../../data/repositories/portfolio_repository.dart';
import '../../data/services/github_stats_service.dart';
import '../../data/services/portfolio_controller.dart';
import '../overview/widgets/github_contribution_card.dart';
import '../overview/widgets/hero_terminal_banner.dart';
import '../terminal_lab/terminal_controller.dart';
import '../terminal_lab/widgets/tech_stack_matrix.dart';

/// Production Home Page (`Tab 0`) matching `istuhin.dev` (`dev.istuhin/app/page.tsx`):
/// - Global `Michroma` font family + `Moirai One` brand header
/// - Dynamically reacts to [PortfolioController] (live Supabase `site_settings` + `/api/github/overview`)
/// - Section 1: [HeroTerminalBanner] (`<p>This is</p> <h1>isTuhin.dev</h1> <p>lovestack software developer</p>` + `-zsh` Terminal)
/// - Section 2: `ECOSYSTEM / Tech Stack` ([TechStackMatrix] 2x2 Bento grid)
/// - Section 3: `GITHUB / Live Stats` ([GitHubContributionCard] 4 stat cards + contribution heatmap + activity + languages)
/// - Section 4: `CERTIFICATIONS / Badges` ([CertificationsGrid])
class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.portfolioConfig = PortfolioConfig.istuhinDev,
    this.repository = const PortfolioRepository(),
    this.portfolioController,
    this.terminalController,
    this.githubService,
    this.onNavigateTab,
  });

  final PortfolioConfig portfolioConfig;
  final PortfolioRepository repository;
  final PortfolioController? portfolioController;
  final TerminalController? terminalController;
  final GitHubStatsService? githubService;
  final ValueChanged<int>? onNavigateTab;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  late TerminalController _terminalController;
  bool _ownsTerminalController = false;
  late GitHubStats _fallbackStats;
  int _lastFocusRequestId = 0;

  @override
  void initState() {
    super.initState();
    _initTerminalController();
    _fallbackStats = widget.repository.seedGitHubStats;
    _refreshLegacyGitHubStats();
  }

  void _initTerminalController() {
    if (widget.terminalController != null) {
      _terminalController = widget.terminalController!;
      _ownsTerminalController = false;
    } else {
      _terminalController = TerminalController(
        repository: widget.repository,
        portfolioController: widget.portfolioController,
        onNavigateTab: widget.onNavigateTab,
      );
      _ownsTerminalController = true;
    }
    _lastFocusRequestId = _terminalController.focusRequestId;
    _terminalController.addListener(_handleTerminalChanged);
  }

  void _handleTerminalChanged() {
    if (_terminalController.focusRequestId == _lastFocusRequestId) return;
    _lastFocusRequestId = _terminalController.focusRequestId;
    if (_scrollController.hasClients && _scrollController.offset > 0) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.terminalController != widget.terminalController) {
      _terminalController.removeListener(_handleTerminalChanged);
      if (_ownsTerminalController) {
        _terminalController.dispose();
      }
      _initTerminalController();
    }
    if (oldWidget.githubService != widget.githubService) {
      _refreshLegacyGitHubStats();
    }
  }

  Future<void> _refreshLegacyGitHubStats() async {
    final service = widget.githubService;
    if (service == null || widget.portfolioController != null) return;
    final updated = await service.loadStats();
    if (mounted) {
      setState(() => _fallbackStats = updated);
    }
  }

  void _handleSkillTap(SkillItem skill) {
    _terminalController.execute('skills ${skill.domain.cliFlag}');
    AppGlassOverlays.showToast(
      context,
      message: '${skill.name} · ${skill.levelLabel}',
    );
  }

  @override
  void dispose() {
    _terminalController.removeListener(_handleTerminalChanged);
    if (_ownsTerminalController) {
      _terminalController.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildBody(
    BuildContext context, {
    required PortfolioConfig config,
    required GitHubStats stats,
  }) {
    final tokens = GlassTokens.of(context);
    final horizontalPad = tokens.pageHorizontalPadding;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final bottomPad = keyboardInset > 0
        ? keyboardInset + (24 * tokens.scale)
        : tokens.capsuleHeight + (56 * tokens.scale);

    return SafeArea(
      top: false,
      bottom: false,
      child: GlassResponsiveBody(
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                horizontalPad,
                16 * tokens.scale,
                horizontalPad,
                bottomPad,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    HeroTerminalBanner(
                      config: config,
                      terminalController: _terminalController,
                    ),
                    SizedBox(height: 36 * tokens.scale),
                    const GlassSectionHeader(
                      eyebrow: 'ECOSYSTEM',
                      label: 'Tech Stack',
                      showAccentRule: true,
                    ),
                    SizedBox(height: 16 * tokens.scale),
                    TechStackMatrix(
                      repository: widget.repository,
                      skills: widget.portfolioController?.skills,
                      onSkillTap: _handleSkillTap,
                    ),
                    SizedBox(height: 36 * tokens.scale),
                    const GlassSectionHeader(
                      eyebrow: 'GITHUB',
                      label: 'Live Stats',
                      showAccentRule: true,
                    ),
                    SizedBox(height: 16 * tokens.scale),
                    GitHubContributionCard(
                      stats: stats,
                      featuredCount: stats.featuredCount,
                    ),
                    SizedBox(height: 36 * tokens.scale),
                    const GlassSectionHeader(
                      eyebrow: 'CERTIFICATIONS',
                      label: 'Badges',
                      showAccentRule: true,
                    ),
                    SizedBox(height: 16 * tokens.scale),
                    CertificationsGrid(
                      certificates: widget.repository.certificates,
                      holopinProfileUrl: config.holopinProfileUrl,
                      holopinBoardUrl: config.holopinBoardUrl,
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

  @override
  Widget build(BuildContext context) {
    final controller = widget.portfolioController;
    if (controller == null) {
      return _buildBody(
        context,
        config: widget.portfolioConfig,
        stats: _fallbackStats,
      );
    }

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return _buildBody(
          context,
          config: controller.config,
          stats: controller.githubStats,
        );
      },
    );
  }
}
