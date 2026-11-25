import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../theme/glass_tokens.dart';

/// Reusable responsive multi-column Bento grid that adapts column count across
/// compact phones, medium tablets/foldables, and expanded desktop displays
/// without duplicating `LayoutBuilder` + `Wrap` width math.
class GlassResponsiveGrid extends StatelessWidget {
  const GlassResponsiveGrid({
    super.key,
    required this.children,
    this.compactColumns = 1,
    this.mediumColumns = 2,
    this.expandedColumns = 2,
    this.wideExpandedColumns,
    this.wideBreakpoint = 920.0,
    this.spacing,
    this.runSpacing,
  })  : assert(compactColumns >= 1),
        assert(mediumColumns >= 1),
        assert(expandedColumns >= 1);

  final List<Widget> children;

  /// Column count when available width is `< 560pt`.
  final int compactColumns;

  /// Column count when available width is `560pt..759pt`.
  final int mediumColumns;

  /// Column count when available width is `>= 760pt`.
  final int expandedColumns;

  /// Optional column count when available width is `>= wideBreakpoint`.
  final int? wideExpandedColumns;

  /// Constraint width threshold for [wideExpandedColumns].
  final double wideBreakpoint;

  /// Horizontal gap between grid items (defaults to [GlassTokens.bentoGridSpacing]).
  final double? spacing;

  /// Vertical gap between grid rows (defaults to [spacing] or [GlassTokens.bentoGridSpacing]).
  final double? runSpacing;

  int _resolveColumnCount(double maxWidth, GlassTokens tokens) {
    if (wideExpandedColumns != null && maxWidth >= wideBreakpoint) {
      return wideExpandedColumns!;
    }
    if (maxWidth >= 720 || tokens.isExpanded) {
      return expandedColumns;
    }
    if (maxWidth >= 520 || tokens.isMedium) {
      return mediumColumns;
    }
    return compactColumns;
  }

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    final tokens = GlassTokens.of(context);
    final effectiveSpacing = spacing ?? tokens.bentoGridSpacing;
    final effectiveRunSpacing = runSpacing ?? effectiveSpacing;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : tokens.viewportWidth;
        final columns = math.max(
          1,
          math.min(
            children.length,
            _resolveColumnCount(availableWidth, tokens),
          ),
        );

        if (columns == 1) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) SizedBox(height: effectiveRunSpacing),
                children[i],
              ],
            ],
          );
        }

        final totalGap = effectiveSpacing * (columns - 1);
        final itemWidth =
            math.max(0.0, (availableWidth - totalGap) / columns);

        return Wrap(
          spacing: effectiveSpacing,
          runSpacing: effectiveRunSpacing,
          children: [
            for (final child in children)
              SizedBox(
                width: itemWidth,
                child: child,
              ),
          ],
        );
      },
    );
  }
}
