import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/glass_tokens.dart';
import '../../core/widgets/glass/glass_responsive_body.dart';
import '../../core/widgets/glass/glass_tag_chip.dart';
import '../../data/models/project_item.dart';
import '../../data/repositories/portfolio_repository.dart';
import 'widgets/project_glass_card.dart';

/// Tab 2 (`Ecosystem / Store`): Filterable digital products (*Connectis*,
/// *HackiisLab*, *Niihut*), cross-platform Flutter apps, and open-source repositories.
class EcosystemPage extends StatefulWidget {
  const EcosystemPage({
    super.key,
    this.repository = const PortfolioRepository(),
  });

  final PortfolioRepository repository;

  @override
  State<EcosystemPage> createState() => _EcosystemPageState();
}

class _EcosystemPageState extends State<EcosystemPage> {
  late final GlassLargeTitleController _titleController =
      GlassLargeTitleController();
  ProjectCategory? _selectedCategory;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  List<ProjectItem> get _filteredProjects {
    final all = widget.repository.projects;
    if (_selectedCategory == null) return all;
    return all.where((p) => p.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = GlassTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    final horizontalPad = tokens.pageHorizontalPadding;
    final bottomPad = tokens.capsuleHeight + (72 * tokens.scale);
    final projects = _filteredProjects;

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
              text: 'Ecosystem & Store',
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
                      'Digital products, cross-platform applications, and open-source packages built by Touhidur Rahman.',
                      style: textTheme.bodyLarge?.copyWith(
                        color: tokens.inactiveIcon,
                        height: 1.35,
                      ),
                    ),
                    SizedBox(height: 16 * tokens.scale),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 8 * tokens.scale),
                            child: GlassTagChip(
                              label: 'All (${widget.repository.projects.length})',
                              accentColor: _selectedCategory == null
                                  ? tokens.selectedIcon
                                  : null,
                              onTap: () =>
                                  setState(() => _selectedCategory = null),
                            ),
                          ),
                          for (final category in ProjectCategory.values)
                            Padding(
                              padding: EdgeInsets.only(right: 8 * tokens.scale),
                              child: GlassTagChip(
                                label: category.shortLabel,
                                accentColor: _selectedCategory == category
                                    ? tokens.selectedIcon
                                    : null,
                                onTap: () => setState(
                                  () => _selectedCategory = category,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 18 * tokens.scale),
                    for (final project in projects)
                      Padding(
                        padding: EdgeInsets.only(bottom: 14 * tokens.scale),
                        child: ProjectGlassCard(project: project),
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
