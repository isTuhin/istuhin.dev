import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/glass_tokens.dart';
import 'glass/glass_responsive_body.dart';

/// Shared iOS 26 Liquid Glass tab layout with collapsible [GlassLargeTitle]
/// and responsive width constraints across phones, tablets, and desktops.
class ChromePlaceholderPage extends StatefulWidget {
  const ChromePlaceholderPage({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.headerTrailing,
    this.searchBar,
  });

  final String title;
  final String subtitle;

  /// Optional content rendered below [subtitle] in the page body.
  final Widget? trailing;

  /// Optional action widget placed at the trailing edge of the large title row.
  final Widget? headerTrailing;

  /// Optional [GlassSearchBar] attached to [GlassLargeTitle] for two-phase collapse.
  final Widget? searchBar;

  @override
  State<ChromePlaceholderPage> createState() => _ChromePlaceholderPageState();
}

class _ChromePlaceholderPageState extends State<ChromePlaceholderPage> {
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
        keyboardInset + tokens.capsuleHeight + (64 * tokens.scale);

    return SafeArea(
      top: false,
      bottom: false,
      child: GlassResponsiveBody(
        child: CustomScrollView(
          controller: _titleController.scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(height: 12 * tokens.scale),
            ),
            GlassLargeTitle(
              text: widget.title,
              controller: _titleController,
              color: tokens.activeIcon,
              trailing: widget.headerTrailing,
              searchBar: widget.searchBar,
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
                  crossAxisAlignment: .stretch,
                  children: [
                    Text(
                      widget.subtitle,
                      style: textTheme.bodyLarge?.copyWith(
                        color: tokens.inactiveIcon,
                        height: 1.35,
                      ),
                    ),
                    if (widget.trailing != null) ...[
                      SizedBox(height: 20 * tokens.scale),
                      widget.trailing!,
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
