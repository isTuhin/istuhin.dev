import 'package:material_ui/material_ui.dart';

import '../../core/utils/url_launcher.dart';
import '../../core/widgets/glass/glass_kit.dart';
import '../../data/models/github_stats.dart';
import '../../data/models/project_item.dart';
import '../../data/repositories/portfolio_repository.dart';
import '../../data/services/portfolio_controller.dart';

/// Dynamic Store page (`Tab 2`) matching `dev.istuhin/app/store/page.tsx`,
/// `ProductsSection.tsx`, `ProductCard.tsx`, `OpenSourceSection.tsx`, and `RepoCard.tsx`:
/// - Header: `Store` + `Open-source repositories and products from isTuhin.dev.`
/// - Section 1 (`FOR SALE / Products`): Driven dynamically by Supabase `public.projects`.
///   When empty, renders the dashed card `"No products listed yet."`. When admin adds
///   products in Supabase, renders `FEATURED` and `ALL PRODUCTS` [StoreProductCard] grids.
/// - Section 2 (`FREE / Open source`): Live featured & recent public [GitHubRepo] cards
///   with `Updated DD Mon YYYY` metadata and a [LiquidGlassPillButton] `"Show more"` toggle.
class StorePage extends StatefulWidget {
  const StorePage({
    super.key,
    this.portfolioController,
    this.repository = const PortfolioRepository(),
  });

  final PortfolioController? portfolioController;
  final PortfolioRepository repository;

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  bool _showAllRepos = false;

  Widget _buildContent(
    BuildContext context, {
    required PortfolioConfig config,
    required GitHubStats stats,
    required List<ProjectItem> products,
  }) {
    final tokens = GlassTokens.of(context);
    final horizontalPad = tokens.pageHorizontalPadding;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final bottomPad = keyboardInset +
        (tokens.isExpanded ? 48 * tokens.scale : tokens.capsuleHeight + (56 * tokens.scale));

    final featuredProducts =
        products.where((p) => p.isFeaturedProduct).toList();
    final restProducts = products.where((p) => !p.isFeaturedProduct).toList();
    final featuredRepos = stats.featuredRepos;
    final recentRepos = stats.recentRepos;
    final visibleRepos =
        _showAllRepos ? recentRepos : recentRepos.take(6).toList();

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
                18 * tokens.scale,
                horizontalPad,
                bottomPad,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Store',
                      style: TextStyle(
                        color: tokens.activeIcon,
                        fontSize: (tokens.isExpanded ? 36 : 26) * tokens.scale,
                        fontWeight: FontWeight.w800,
                        fontFamily: GlassTokens.fontMain,
                        letterSpacing: -0.8,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    SizedBox(height: 6 * tokens.scale),
                    Text(
                      'Open-source repositories and products from ${config.brand}.',
                      style: TextStyle(
                        color: tokens.inactiveIcon,
                        fontSize: 12.5 * tokens.scale,
                        fontFamily: GlassTokens.fontMain,
                        height: 1.45,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    SizedBox(height: 28 * tokens.scale),
                    // Section 1: FOR SALE / Products (ProductsSection.tsx)
                    const GlassSectionHeader(
                      eyebrow: 'FOR SALE',
                      label: 'Products',
                      showAccentRule: true,
                    ),
                    SizedBox(height: 14 * tokens.scale),
                    if (products.isEmpty)
                      const _DashedEmptyProductsCard()
                    else ...[
                      if (featuredProducts.isNotEmpty) ...[
                        Text(
                          'FEATURED',
                          style: TextStyle(
                            color: tokens.inactiveIcon,
                            fontSize: 11 * tokens.scale,
                            fontWeight: FontWeight.w600,
                            fontFamily: GlassTokens.fontMain,
                            letterSpacing: 1.4,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        SizedBox(height: 10 * tokens.scale),
                        GlassResponsiveGrid(
                          compactColumns: 1,
                          mediumColumns: 2,
                          expandedColumns: 2,
                          wideExpandedColumns: 3,
                          wideBreakpoint: 960.0,
                          children: [
                            for (final product in featuredProducts)
                              StoreProductCard(product: product),
                          ],
                        ),
                        SizedBox(height: 20 * tokens.scale),
                      ],
                      if (restProducts.isNotEmpty) ...[
                        Text(
                          'ALL PRODUCTS',
                          style: TextStyle(
                            color: tokens.inactiveIcon,
                            fontSize: 11 * tokens.scale,
                            fontWeight: FontWeight.w600,
                            fontFamily: GlassTokens.fontMain,
                            letterSpacing: 1.4,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        SizedBox(height: 10 * tokens.scale),
                        GlassResponsiveGrid(
                          compactColumns: 1,
                          mediumColumns: 2,
                          expandedColumns: 2,
                          wideExpandedColumns: 3,
                          wideBreakpoint: 960.0,
                          children: [
                            for (final product in restProducts)
                              StoreProductCard(product: product),
                          ],
                        ),
                      ],
                    ],
                    SizedBox(height: 36 * tokens.scale),
                    // Section 2: FREE / Open source (OpenSourceSection.tsx)
                    const GlassSectionHeader(
                      eyebrow: 'FREE',
                      label: 'Open source',
                      showAccentRule: true,
                    ),
                    SizedBox(height: 14 * tokens.scale),
                    if (featuredRepos.isNotEmpty) ...[
                      GlassResponsiveGrid(
                        compactColumns: 1,
                        mediumColumns: 2,
                        expandedColumns: 2,
                        wideExpandedColumns: 3,
                        wideBreakpoint: 960.0,
                        children: [
                          for (final repo in featuredRepos)
                            GitHubRepoGlassCard(
                              repo: repo,
                              isFeatured: true,
                            ),
                        ],
                      ),
                      SizedBox(height: 22 * tokens.scale),
                    ],
                    Text(
                      'RECENT PUBLIC REPOSITORIES',
                      style: TextStyle(
                        color: tokens.inactiveIcon,
                        fontSize: 11 * tokens.scale,
                        fontWeight: FontWeight.w600,
                        fontFamily: GlassTokens.fontMain,
                        letterSpacing: 1.4,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    SizedBox(height: 12 * tokens.scale),
                    GlassResponsiveGrid(
                      compactColumns: 1,
                      mediumColumns: 2,
                      expandedColumns: 2,
                      wideExpandedColumns: 3,
                      wideBreakpoint: 960.0,
                      children: [
                        for (final repo in visibleRepos)
                          GitHubRepoGlassCard(repo: repo),
                      ],
                    ),
                    if (recentRepos.length > 6) ...[
                      SizedBox(height: 20 * tokens.scale),
                      Center(
                        child: LiquidGlassPillButton(
                          label: _showAllRepos
                              ? 'Show less'
                              : 'Show more (${recentRepos.length - 6})',
                          onTap: () =>
                              setState(() => _showAllRepos = !_showAllRepos),
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

  @override
  Widget build(BuildContext context) {
    final controller = widget.portfolioController;
    if (controller == null) {
      return _buildContent(
        context,
        config: PortfolioConfig.istuhinDev,
        stats: widget.repository.seedGitHubStats,
        products: widget.repository.projects,
      );
    }

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return _buildContent(
          context,
          config: controller.config,
          stats: controller.githubStats,
          products: controller.projects,
        );
      },
    );
  }
}

/// Dashed empty state container matching `ProductsSection.tsx`
/// (`rounded-2xl border border-dashed border-border bg-transparent px-4 py-5 font-mono text-sm text-muted`).
class _DashedEmptyProductsCard extends StatelessWidget {
  const _DashedEmptyProductsCard();

  @override
  Widget build(BuildContext context) {
    final tokens = GlassTokens.of(context);
    final borderColor = tokens.isDark
        ? Colors.white.withValues(alpha: 0.14)
        : const Color(0xFF1C1917).withValues(alpha: 0.18);

    return CustomPaint(
      painter: _DashedRRectPainter(
        color: borderColor,
        radius: 16 * tokens.scale,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 18 * tokens.scale,
          vertical: 18 * tokens.scale,
        ),
        child: Text(
          'No products listed yet.',
          style: TextStyle(
            color: tokens.inactiveIcon,
            fontSize: 12.5 * tokens.scale,
            fontFamily: GlassTokens.fontMain,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  const _DashedRRectPainter({
    required this.color,
    required this.radius,
  });

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..isAntiAlias = true;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);

    const dashWidth = 6.0;
    const dashSpace = 4.5;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}

/// Reusable product card matching `dev.istuhin/components/store/ProductCard.tsx`.
class StoreProductCard extends StatefulWidget {
  const StoreProductCard({
    super.key,
    required this.product,
  });

  final ProjectItem product;

  @override
  State<StoreProductCard> createState() => _StoreProductCardState();
}

class _StoreProductCardState extends State<StoreProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final tokens = GlassTokens.of(context);
    final p = widget.product;
    final href = p.primaryHref;
    final borderColor = _isHovered
        ? tokens.neonAccent.withValues(alpha: 0.55)
        : (tokens.isDark
            ? Colors.white.withValues(alpha: 0.10)
            : const Color(0xFF1C1917).withValues(alpha: 0.12));

    return MouseRegion(
      cursor: href != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: href == null ? null : () => UrlLauncher.launch(context, href),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.all(18 * tokens.scale),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16 * tokens.scale),
            border: Border.all(color: borderColor, width: 1.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      p.title,
                      style: TextStyle(
                        color: _isHovered ? tokens.neonAccent : tokens.activeIcon,
                        fontSize: 13.5 * tokens.scale,
                        fontWeight: FontWeight.w700,
                        fontFamily: GlassTokens.fontMain,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  SizedBox(width: 8 * tokens.scale),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8 * tokens.scale,
                      vertical: 3 * tokens.scale,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6 * tokens.scale),
                      border: Border.all(color: borderColor),
                    ),
                    child: Text(
                      p.categoryBadge.toUpperCase(),
                      style: TextStyle(
                        color: tokens.inactiveIcon,
                        fontSize: 9.5 * tokens.scale,
                        fontFamily: GlassTokens.fontMain,
                        letterSpacing: 0.8,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
              if (p.isFeaturedProduct) ...[
                SizedBox(height: 6 * tokens.scale),
                Text(
                  'FEATURED',
                  style: TextStyle(
                    color: tokens.neonAccent,
                    fontSize: 9.5 * tokens.scale,
                    fontFamily: GlassTokens.fontMain,
                    letterSpacing: 1.0,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
              if (p.description.isNotEmpty) ...[
                SizedBox(height: 8 * tokens.scale),
                Text(
                  p.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: tokens.inactiveIcon,
                    fontSize: 11.5 * tokens.scale,
                    fontFamily: GlassTokens.fontMain,
                    height: 1.4,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
              if (p.techStack.isNotEmpty) ...[
                SizedBox(height: 12 * tokens.scale),
                Wrap(
                  spacing: 6 * tokens.scale,
                  runSpacing: 6 * tokens.scale,
                  children: [
                    for (final tech in p.techStack.take(6))
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 7 * tokens.scale,
                          vertical: 2.5 * tokens.scale,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6 * tokens.scale),
                          border: Border.all(color: borderColor),
                        ),
                        child: Text(
                          tech,
                          style: TextStyle(
                            color: tokens.inactiveIcon,
                            fontSize: 9.5 * tokens.scale,
                            fontFamily: GlassTokens.fontMain,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
              SizedBox(height: 14 * tokens.scale),
              Text(
                p.liveUrl != null
                    ? 'View product'
                    : p.repoUrl != null
                        ? 'View source'
                        : 'Details coming soon',
                style: TextStyle(
                  color: href != null ? tokens.neonAccent : tokens.inactiveIcon,
                  fontSize: 11 * tokens.scale,
                  fontWeight: FontWeight.w600,
                  fontFamily: GlassTokens.fontMain,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reusable outlined repository card matching `RepoCard.tsx`
/// in `dev.istuhin/components/github/RepoCard.tsx`.
class GitHubRepoGlassCard extends StatefulWidget {
  const GitHubRepoGlassCard({
    super.key,
    required this.repo,
    this.isFeatured = false,
  });

  final GitHubRepo repo;
  final bool isFeatured;

  @override
  State<GitHubRepoGlassCard> createState() => _GitHubRepoGlassCardState();
}

class _GitHubRepoGlassCardState extends State<GitHubRepoGlassCard> {
  bool _isHovered = false;

  static const List<String> _months = <String>[
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _formatDate(String iso) {
    if (iso.isEmpty) return '';
    final parsed = DateTime.tryParse(iso)?.toLocal();
    if (parsed == null) return '';
    final m = _months[(parsed.month - 1).clamp(0, 11)];
    return '${parsed.day} $m ${parsed.year}';
  }

  @override
  Widget build(BuildContext context) {
    final tokens = GlassTokens.of(context);
    final repo = widget.repo;
    final updatedIso = (repo.pushedAt != null && repo.pushedAt!.isNotEmpty)
        ? repo.pushedAt!
        : repo.updatedAt;
    final formattedDate = _formatDate(updatedIso);

    final borderColor = _isHovered
        ? tokens.neonAccent.withValues(alpha: 0.55)
        : (tokens.isDark
            ? Colors.white.withValues(alpha: 0.10)
            : const Color(0xFF1C1917).withValues(alpha: 0.12));

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => UrlLauncher.launch(context, repo.htmlUrl),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.all(18 * tokens.scale),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16 * tokens.scale),
            border: Border.all(color: borderColor, width: 1.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      repo.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _isHovered
                            ? tokens.neonAccent
                            : tokens.activeIcon,
                        fontSize: 13.5 * tokens.scale,
                        fontWeight: FontWeight.w700,
                        fontFamily: GlassTokens.fontMain,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  if (widget.isFeatured) ...[
                    SizedBox(width: 8 * tokens.scale),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8 * tokens.scale,
                        vertical: 3 * tokens.scale,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6 * tokens.scale),
                        border: Border.all(
                          color: tokens.neonAccent.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Text(
                        'FEATURED',
                        style: TextStyle(
                          color: tokens.neonAccent,
                          fontSize: 9.5 * tokens.scale,
                          fontFamily: GlassTokens.fontMain,
                          letterSpacing: 0.8,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (repo.description != null && repo.description!.isNotEmpty) ...[
                SizedBox(height: 8 * tokens.scale),
                Text(
                  repo.description!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: tokens.inactiveIcon,
                    fontSize: 11.5 * tokens.scale,
                    fontFamily: GlassTokens.fontMain,
                    height: 1.4,
                    decoration: TextDecoration.none,
                  ),
                ),
              ] else
                SizedBox(height: 16 * tokens.scale),
              SizedBox(height: 14 * tokens.scale),
              Wrap(
                spacing: 12 * tokens.scale,
                runSpacing: 6 * tokens.scale,
                children: [
                  if (repo.language != null && repo.language!.isNotEmpty)
                    Text(
                      repo.language!,
                      style: TextStyle(
                        color: tokens.activeIcon.withValues(alpha: 0.85),
                        fontSize: 11 * tokens.scale,
                        fontWeight: FontWeight.w600,
                        fontFamily: GlassTokens.fontMain,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  Text(
                    '★ ${repo.stargazersCount}',
                    style: TextStyle(
                      color: tokens.inactiveIcon,
                      fontSize: 11 * tokens.scale,
                      fontFamily: GlassTokens.fontMain,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  Text(
                    '⑂ ${repo.forksCount}',
                    style: TextStyle(
                      color: tokens.inactiveIcon,
                      fontSize: 11 * tokens.scale,
                      fontFamily: GlassTokens.fontMain,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  if (formattedDate.isNotEmpty)
                    Text(
                      'Updated $formattedDate',
                      style: TextStyle(
                        color: tokens.inactiveIcon,
                        fontSize: 11 * tokens.scale,
                        fontFamily: GlassTokens.fontMain,
                        decoration: TextDecoration.none,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Legacy alias for [StorePage].
typedef ProfilePage = StorePage;
