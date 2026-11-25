import 'package:material_ui/material_ui.dart';

import '../../theme/glass_tokens.dart';

/// Centers and constrains page content to [GlassTokens.contentMaxWidth]
/// across compact phones, medium foldables/tablets, and expanded desktop screens.
class GlassResponsiveBody extends StatelessWidget {
  const GlassResponsiveBody({
    super.key,
    required this.child,
    this.alignment = Alignment.topCenter,
    this.maxWidth,
  });

  final Widget child;
  final AlignmentGeometry alignment;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final tokens = GlassTokens.of(context);

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? tokens.contentMaxWidth,
        ),
        child: child,
      ),
    );
  }
}
