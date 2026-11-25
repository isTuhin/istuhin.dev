import 'package:material_ui/material_ui.dart';

import '../../core/widgets/glass/glass_kit.dart';
import '../../data/repositories/portfolio_repository.dart';
import '../../data/services/portfolio_controller.dart';
import '../ecosystem/widgets/project_glass_card.dart';
import '../profile/profile_page.dart';

/// Dynamic Search destination page (`Tab 1`) coupled with the keyboard-top
/// [GlassKeyboardSearchBar] in `GlassBottomNav`.
///
/// Filters live GitHub repositories, digital products, tech stack skills,
/// and social channels from [PortfolioController] in real time.
class SearchPage extends StatelessWidget {
  const SearchPage({
    super.key,
    this.query = '',
    this.onRequestFocus,
    this.portfolioController,
    this.repository = const PortfolioRepository(),
  });

  final String query;
  final VoidCallback? onRequestFocus;
  final PortfolioController? portfolioController;
  final PortfolioRepository repository;

  Widget _buildResults(BuildContext context) {
    final tokens = GlassTokens.of(context);
    final horizontalPad = tokens.pageHorizontalPadding;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final bottomPad =
        keyboardInset + tokens.capsuleHeight + (64 * tokens.scale);

    final trimmed = query.trim();
    final subtitle = trimmed.isEmpty
        ? 'Look through this app'
        : 'Results for "$trimmed"';

    final stats =
        portfolioController?.githubStats ?? repository.seedGitHubStats;
    final matchingRepos = stats.recentRepos
        .where((r) => r.matchesQuery(trimmed))
        .toList();
    final sourceProducts =
        portfolioController?.projects ?? repository.featuredProducts;
    final matchingProducts = sourceProducts
        .where((p) => p.matchesQuery(trimmed))
        .toList();
    final sourceSkills = portfolioController?.skills ?? repository.skills;
    final matchingSkills = sourceSkills
        .where((s) => s.matchesQuery(trimmed))
        .toList();

    return SafeArea(
      top: false,
      bottom: false,
      child: GlassResponsiveBody(
        child: CustomScrollView(
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
                    Text(
                      'Search',
                      style: TextStyle(
                        color: tokens.activeIcon,
                        fontSize: (tokens.isExpanded ? 32 : 24) * tokens.scale,
                        fontWeight: FontWeight.w800,
                        fontFamily: GlassTokens.fontMain,
                        letterSpacing: -0.6,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    SizedBox(height: 6 * tokens.scale),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: tokens.inactiveIcon,
                        fontSize: 12.5 * tokens.scale,
                        fontFamily: GlassTokens.fontMain,
                        height: 1.4,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    if (matchingProducts.isNotEmpty) ...[
                      SizedBox(height: 22 * tokens.scale),
                      GlassSectionHeader(
                        eyebrow: 'STORE',
                        label: 'Products (${matchingProducts.length})',
                        showAccentRule: true,
                      ),
                      SizedBox(height: 12 * tokens.scale),
                      GlassResponsiveGrid(
                        compactColumns: 1,
                        mediumColumns: 2,
                        expandedColumns: 2,
                        wideExpandedColumns: 3,
                        wideBreakpoint: 960.0,
                        children: [
                          for (final product in matchingProducts)
                            ProjectGlassCard(project: product),
                        ],
                      ),
                    ],
                    if (matchingRepos.isNotEmpty) ...[
                      SizedBox(height: 24 * tokens.scale),
                      GlassSectionHeader(
                        eyebrow: 'GITHUB',
                        label: 'Repositories (${matchingRepos.length})',
                        showAccentRule: true,
                      ),
                      SizedBox(height: 12 * tokens.scale),
                      GlassResponsiveGrid(
                        compactColumns: 1,
                        mediumColumns: 2,
                        expandedColumns: 2,
                        wideExpandedColumns: 3,
                        wideBreakpoint: 960.0,
                        children: [
                          for (final repo in matchingRepos.take(6))
                            GitHubRepoGlassCard(repo: repo),
                        ],
                      ),
                    ],
                    if (matchingSkills.isNotEmpty) ...[
                      SizedBox(height: 24 * tokens.scale),
                      GlassSectionHeader(
                        eyebrow: 'ECOSYSTEM',
                        label: 'Tech Stack (${matchingSkills.length})',
                        showAccentRule: true,
                      ),
                      SizedBox(height: 12 * tokens.scale),
                      Wrap(
                        spacing: 8 * tokens.scale,
                        runSpacing: 8 * tokens.scale,
                        children: [
                          for (final skill in matchingSkills)
                            GlassTagChip(
                              label: skill.name,
                              isMonospace: true,
                            ),
                        ],
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

  @override
  Widget build(BuildContext context) {
    final controller = portfolioController;
    if (controller == null) {
      return _buildResults(context);
    }

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => _buildResults(context),
    );
  }
}
