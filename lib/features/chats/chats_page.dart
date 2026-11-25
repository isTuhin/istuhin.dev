import 'package:material_ui/material_ui.dart';

import '../../core/utils/url_launcher.dart';
import '../../core/widgets/glass/glass_kit.dart';
import '../../data/repositories/portfolio_repository.dart';
import '../../data/services/github_stats_service.dart';
import '../../data/services/portfolio_controller.dart';
import 'widgets/connect_platform_icon.dart';

/// Dynamic Connect destination page (`Tab 3`) matching `dev.istuhin/app/connect/ConnectClient.tsx`,
/// `ContactForm.tsx`, `ContactSectionCard.tsx`, and `platformIcons.tsx`:
/// - Header: `Connect` + `Send a message, or reach me on the channels below.`
/// - Left / Top: `SEND A MESSAGE` `.shell-frame` container with labeled bordered inputs
///   (`Name`, `Email`, `Subject`, 4-row multi-line `Message` textarea) and a
///   [LiquidGlassPillButton] (`Send message`) wired to Supabase `public.submit_contact_message`.
/// - Right / Bottom: 4 compact `.shell-frame` channel sections (`Direct Contact`,
///   `Professional Networks`, `Development Platforms`, `Social & Support`) with
///   platform vector icons and signature accent colors.
class ConnectPage extends StatefulWidget {
  const ConnectPage({
    super.key,
    this.portfolioController,
    this.repository = const PortfolioRepository(),
  });

  final PortfolioController? portfolioController;
  final PortfolioRepository repository;

  @override
  State<ConnectPage> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isSubmitting = false;
  ContactSubmitStatus? _submitStatus;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleSendMessage(PortfolioConfig config) async {
    if (_isSubmitting) return;
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final subject = _subjectController.text.trim();
    final body = _messageController.text.trim();

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (name.isEmpty ||
        email.isEmpty ||
        !emailRegex.hasMatch(email) ||
        body.isEmpty) {
      setState(() => _submitStatus = ContactSubmitStatus.invalid);
      AppGlassOverlays.showToast(
        context,
        message: 'Check fields and try again.',
        type: GlassToastType.warning,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitStatus = null;
    });

    final controller = widget.portfolioController;
    final status = controller != null
        ? await controller.submitContactMessage(
            name: name,
            email: email,
            subject: subject,
            body: body,
          )
        : ContactSubmitStatus.sent;

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _submitStatus = status;
    });

    if (status == ContactSubmitStatus.sent) {
      _nameController.clear();
      _emailController.clear();
      _subjectController.clear();
      _messageController.clear();
      AppGlassOverlays.showToast(
        context,
        message: 'Message sent. Thanks!',
        type: GlassToastType.success,
      );
    } else if (status == ContactSubmitStatus.invalid) {
      AppGlassOverlays.showToast(
        context,
        message: 'Check fields and try again.',
        type: GlassToastType.warning,
      );
    } else {
      AppGlassOverlays.showToast(
        context,
        message: 'Server error. Try later.',
        type: GlassToastType.warning,
      );
    }
  }

  Widget _buildContent(BuildContext context, PortfolioConfig config) {
    final tokens = GlassTokens.of(context);
    final horizontalPad = tokens.pageHorizontalPadding;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final bottomPad = keyboardInset +
        (tokens.isExpanded ? 48 * tokens.scale : tokens.capsuleHeight + (56 * tokens.scale));
    final sections = config.connectSections;

    final formCard = GlassBentoCard(
      padding: EdgeInsets.all(20 * tokens.scale),
      accentColor: tokens.neonAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SEND A MESSAGE',
            style: TextStyle(
              color: tokens.activeIcon,
              fontSize: 13 * tokens.scale,
              fontWeight: FontWeight.w700,
              fontFamily: GlassTokens.fontMain,
              letterSpacing: 1.1,
              decoration: TextDecoration.none,
            ),
          ),
          SizedBox(height: 16 * tokens.scale),
          _ConnectLabeledInput(
            label: 'Name',
            controller: _nameController,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            maxLength: 120,
          ),
          SizedBox(height: 14 * tokens.scale),
          _ConnectLabeledInput(
            label: 'Email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            maxLength: 200,
          ),
          SizedBox(height: 14 * tokens.scale),
          _ConnectLabeledInput(
            label: 'Subject',
            controller: _subjectController,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            maxLength: 200,
          ),
          SizedBox(height: 14 * tokens.scale),
          _ConnectLabeledInput(
            label: 'Message',
            controller: _messageController,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            minLines: 4,
            maxLines: 6,
            maxLength: 5000,
          ),
          if (_submitStatus != null) ...[
            SizedBox(height: 12 * tokens.scale),
            Text(
              switch (_submitStatus!) {
                ContactSubmitStatus.sent => 'Message sent. Thanks!',
                ContactSubmitStatus.invalid => 'Check fields and try again.',
                ContactSubmitStatus.server => 'Server error. Try later.',
              },
              style: TextStyle(
                color: _submitStatus == ContactSubmitStatus.sent
                    ? tokens.neonAccent
                    : const Color(0xFFF87171),
                fontSize: 11.5 * tokens.scale,
                fontFamily: GlassTokens.fontMain,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
              ),
            ),
          ],
          SizedBox(height: 16 * tokens.scale),
          LiquidGlassPillButton(
            label: _isSubmitting ? 'Sending…' : 'Send message',
            isDisabled: _isSubmitting,
            onTap: () => _handleSendMessage(config),
          ),
        ],
      ),
    );

    final channelsColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < sections.length; i++) ...[
          if (i > 0) SizedBox(height: 14 * tokens.scale),
          _ContactSectionCard(section: sections[i]),
        ],
      ],
    );

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
                      'Connect',
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
                      'Send a message, or reach me on the channels below.',
                      style: TextStyle(
                        color: tokens.inactiveIcon,
                        fontSize: 12.5 * tokens.scale,
                        fontFamily: GlassTokens.fontMain,
                        height: 1.45,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    SizedBox(height: 24 * tokens.scale),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth >= 760) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: formCard),
                              SizedBox(width: 24 * tokens.scale),
                              Expanded(child: channelsColumn),
                            ],
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            formCard,
                            SizedBox(height: 18 * tokens.scale),
                            channelsColumn,
                          ],
                        );
                      },
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
      return _buildContent(context, PortfolioConfig.istuhinDev);
    }

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return _buildContent(context, controller.config);
      },
    );
  }
}

/// Clean developer form field matching `dev.istuhin/components/contact/ContactForm.tsx`
/// (`label` above + `rounded-xl border border-border/70 bg-transparent px-3 py-2.5 focus:border-neon-green/60`).
class _ConnectLabeledInput extends StatefulWidget {
  const _ConnectLabeledInput({
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.minLines = 1,
    this.maxLines = 1,
    this.maxLength,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final int minLines;
  final int maxLines;
  final int? maxLength;

  @override
  State<_ConnectLabeledInput> createState() => _ConnectLabeledInputState();
}

class _ConnectLabeledInputState extends State<_ConnectLabeledInput> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() => _isFocused = _focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = GlassTokens.of(context);
    final borderColor = _isFocused
        ? tokens.neonAccent.withValues(alpha: 0.72)
        : _isHovered
            ? tokens.neonAccent.withValues(alpha: 0.38)
            : (tokens.isDark
                ? Colors.white.withValues(alpha: 0.14)
                : const Color(0xFF1C1917).withValues(alpha: 0.16));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: _isFocused ? tokens.neonAccent : tokens.inactiveIcon,
            fontSize: 11.5 * tokens.scale,
            fontFamily: GlassTokens.fontMain,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
          ),
        ),
        SizedBox(height: 6 * tokens.scale),
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: 13 * tokens.scale,
              vertical: (widget.maxLines > 1 ? 10 : 8) * tokens.scale,
            ),
            decoration: BoxDecoration(
              color: _isFocused
                  ? tokens.neonAccent.withValues(
                      alpha: tokens.isDark ? 0.04 : 0.03,
                    )
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12 * tokens.scale),
              border: Border.all(
                color: borderColor,
                width: _isFocused ? 1.25 : 1.0,
              ),
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              minLines: widget.minLines,
              maxLines: widget.maxLines,
              maxLength: widget.maxLength,
              cursorColor: tokens.neonAccent,
              style: TextStyle(
                color: tokens.activeIcon,
                fontSize: 13 * tokens.scale,
                fontFamily: GlassTokens.fontMain,
                height: 1.4,
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                counterText: '',
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Compact Connect section card matching `dev.istuhin/components/connect/ContactSectionCard.tsx`.
class _ContactSectionCard extends StatelessWidget {
  const _ContactSectionCard({required this.section});

  final ConnectSectionGroup section;

  @override
  Widget build(BuildContext context) {
    final tokens = GlassTokens.of(context);

    return GlassBentoCard(
      padding: EdgeInsets.all(14 * tokens.scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4 * tokens.scale),
            child: Text(
              section.title.toUpperCase(),
              style: TextStyle(
                color: tokens.inactiveIcon,
                fontSize: 11 * tokens.scale,
                fontWeight: FontWeight.w700,
                fontFamily: GlassTokens.fontMain,
                letterSpacing: 1.1,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          SizedBox(height: 10 * tokens.scale),
          LayoutBuilder(
            builder: (context, constraints) {
              final twoCols = constraints.maxWidth >= 280;
              final gap = 8.0 * tokens.scale;
              if (!twoCols) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < section.items.length; i++) ...[
                      if (i > 0) SizedBox(height: gap),
                      _ConnectChannelTile(item: section.items[i]),
                    ],
                  ],
                );
              }

              final rows = <Widget>[];
              for (var i = 0; i < section.items.length; i += 2) {
                if (i > 0) rows.add(SizedBox(height: gap));
                final first = section.items[i];
                final second = (i + 1 < section.items.length)
                    ? section.items[i + 1]
                    : null;
                rows.add(
                  Row(
                    children: [
                      Expanded(child: _ConnectChannelTile(item: first)),
                      SizedBox(width: gap),
                      Expanded(
                        child: second != null
                            ? _ConnectChannelTile(item: second)
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: rows,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ConnectChannelTile extends StatefulWidget {
  const _ConnectChannelTile({required this.item});

  final ConnectLinkItem item;

  @override
  State<_ConnectChannelTile> createState() => _ConnectChannelTileState();
}

class _ConnectChannelTileState extends State<_ConnectChannelTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final tokens = GlassTokens.of(context);
    final accentColor = Color(widget.item.accentHex);
    final borderColor = _isHovered
        ? tokens.neonAccent.withValues(alpha: 0.55)
        : (tokens.isDark
            ? Colors.white.withValues(alpha: 0.08)
            : const Color(0xFF1C1917).withValues(alpha: 0.10));

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => UrlLauncher.launch(context, widget.item.href),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: 10 * tokens.scale,
            vertical: 9 * tokens.scale,
          ),
          decoration: BoxDecoration(
            color: _isHovered
                ? tokens.neonAccent.withValues(
                    alpha: tokens.isDark ? 0.05 : 0.04,
                  )
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12 * tokens.scale),
            border: Border.all(color: borderColor, width: 1.0),
          ),
          child: Row(
            children: [
              Container(
                width: 34 * tokens.scale,
                height: 34 * tokens.scale,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8 * tokens.scale),
                  border: Border.all(
                    color: tokens.isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : const Color(0xFF1C1917).withValues(alpha: 0.14),
                    width: 1.0,
                  ),
                ),
                child: ConnectPlatformIcon(
                  platform: widget.item.platform,
                  color: accentColor,
                  size: 16.5 * tokens.scale,
                ),
              ),
              SizedBox(width: 10 * tokens.scale),
              Expanded(
                child: Text(
                  widget.item.platform,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _isHovered ? tokens.neonAccent : tokens.activeIcon,
                    fontSize: 12 * tokens.scale,
                    fontWeight: FontWeight.w500,
                    fontFamily: GlassTokens.fontMain,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Legacy alias for [ConnectPage].
typedef ChatsPage = ConnectPage;
