import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoIcons;
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/glass_tokens.dart';
import '../../core/theme/terminal_palette.dart';
import '../../core/utils/url_launcher.dart';
import '../../core/widgets/appearance_mode_control.dart';
import '../../core/widgets/glass/glass_bento_card.dart';
import '../../core/widgets/glass/glass_field.dart';
import '../../core/widgets/glass/glass_overlays.dart';
import '../../core/widgets/glass/glass_page_app_bar.dart';
import '../../core/widgets/glass/glass_responsive_body.dart';
import '../../core/widgets/glass/glass_section_header.dart';
import '../../core/widgets/glass/glass_tag_chip.dart';
import '../../data/repositories/portfolio_repository.dart';

const _appVersion = '2.0.0 (isTuhin.dev Liquid Glass)';

/// Tab 4 (`Connect & Settings`): Direct Liquid Glass message form,
/// professional & social networks (GitHub, LinkedIn, GitLab, Dev.to, X),
/// and `AppearanceModeControl` (`System / Light / Dark`).
class ConnectPage extends StatefulWidget {
  const ConnectPage({
    super.key,
    this.onBack,
    this.repository = const PortfolioRepository(),
  });

  final VoidCallback? onBack;
  final PortfolioRepository repository;

  @override
  State<ConnectPage> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _handleSendMessage() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();

    if (name.isEmpty || email.isEmpty || message.isEmpty) {
      AppGlassOverlays.showToast(
        context,
        message: 'Please fill in Name, Email, and Message.',
        type: GlassToastType.warning,
      );
      return;
    }

    _nameController.clear();
    _emailController.clear();
    _subjectController.clear();
    _messageController.clear();

    AppGlassOverlays.showToast(
      context,
      message:
          'Message queued for ${widget.repository.profile.email} (${subject.isEmpty ? "General Inquiry" : subject})',
      type: GlassToastType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = GlassTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    final horizontalPad = tokens.pageHorizontalPadding;
    final profile = widget.repository.profile;
    final socials = widget.repository.socials;

    return ColoredBox(
      color: tokens.scaffoldBackground,
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassPageAppBar(
              title: 'Connect & Settings',
              onBack: widget.onBack,
            ),
            Expanded(
              child: GlassResponsiveBody(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPad,
                    12 * tokens.scale,
                    horizontalPad,
                    120 * tokens.scale,
                  ),
                  children: [
                    const GlassSectionHeader(label: 'Appearance'),
                    SizedBox(height: 10 * tokens.scale),
                    Text(
                      'Theme',
                      style: textTheme.bodyMedium?.copyWith(
                        color: tokens.inactiveIcon,
                      ),
                    ),
                    SizedBox(height: 8 * tokens.scale),
                    const AppearanceModeControl(),
                    SizedBox(height: 24 * tokens.scale),
                    const GlassSectionHeader(label: 'Direct Message'),
                    SizedBox(height: 10 * tokens.scale),
                    GlassBentoCard(
                      accentColor: TerminalPalette.promptArrow,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Send a message to ${profile.email}',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: tokens.activeIcon,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const GlassTagChip(
                                label: '● Online',
                                isMonospace: true,
                                accentColor: TerminalPalette.promptArrow,
                              ),
                            ],
                          ),
                          SizedBox(height: 12 * tokens.scale),
                          GlassField(
                            controller: _nameController,
                            hintText: 'Your Name',
                            prefixIcon: CupertinoIcons.person,
                            textInputAction: TextInputAction.next,
                          ),
                          SizedBox(height: 10 * tokens.scale),
                          GlassField(
                            controller: _emailController,
                            hintText: 'Your Email (e.g. you@domain.com)',
                            prefixIcon: CupertinoIcons.mail,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                          ),
                          SizedBox(height: 10 * tokens.scale),
                          GlassField(
                            controller: _subjectController,
                            hintText: 'Subject (Product / Collaboration / Hire)',
                            prefixIcon: CupertinoIcons.tag,
                            textInputAction: TextInputAction.next,
                          ),
                          SizedBox(height: 10 * tokens.scale),
                          GlassField(
                            controller: _messageController,
                            hintText: 'Tell me about your project or idea...',
                            prefixIcon: CupertinoIcons.chat_bubble_text,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _handleSendMessage(),
                          ),
                          SizedBox(height: 14 * tokens.scale),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GlassTagChip(
                              label: 'Send Message ↗',
                              accentColor: TerminalPalette.promptArrow,
                              onTap: _handleSendMessage,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24 * tokens.scale),
                    const GlassSectionHeader(
                      label: 'Social & Developer Networks',
                    ),
                    SizedBox(height: 10 * tokens.scale),
                    for (final social in socials)
                      Padding(
                        padding: EdgeInsets.only(bottom: 10 * tokens.scale),
                        child: GlassBentoCard(
                          padding: EdgeInsets.all(14 * tokens.scale),
                          onTap: () => UrlLauncher.launch(context, social.url),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      social.platform,
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
                              SizedBox(width: 8 * tokens.scale),
                              GlassTagChip(
                                label: social.handle,
                                isMonospace: true,
                                accentColor: TerminalPalette.directoryCyan,
                              ),
                            ],
                          ),
                        ),
                      ),
                    SizedBox(height: 24 * tokens.scale),
                    const GlassSectionHeader(label: 'About Portfolio'),
                    SizedBox(height: 10 * tokens.scale),
                    GlassGroupedSection(
                      margin: EdgeInsets.zero,
                      surfaceStyle: GlassSurfaceStyle.solid,
                      children: [
                        GlassListTile(
                          title: Text(
                            'Domain',
                            style: textTheme.bodyLarge?.copyWith(
                              color: tokens.activeIcon,
                            ),
                          ),
                          trailing: Text(
                            profile.domain,
                            style: textTheme.bodyLarge?.copyWith(
                              color: tokens.selectedIcon,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        GlassListTile(
                          title: Text(
                            'App version',
                            style: textTheme.bodyLarge?.copyWith(
                              color: tokens.activeIcon,
                            ),
                          ),
                          trailing: Text(
                            _appVersion,
                            style: textTheme.bodyLarge?.copyWith(
                              color: tokens.inactiveIcon,
                            ),
                          ),
                        ),
                      ],
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
